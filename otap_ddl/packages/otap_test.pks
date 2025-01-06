-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Main package that provides the testing functions and procedures.

-- read setup configuration as written by DBA setup, path relative to setup caller
@@../setup/otap_setup_def.sql
CREATE OR REPLACE PACKAGE otap_test
AS
  /**
  * Provides the test run interface to users with otap user role. Allows definition of
  * test scope, name and test handling. This package may seem huge in terms of functions
  * contained. But every function is only a wrapper for the internal package. To get the
  * code executed refer to the called package functions.
  *
  * Every functionality is available as function, so it can be used in SQL statements as
  * well as in packages, procedures and functions. Parameters are kept SQL compatible.
  *
  * The package keeps private package variables in the body which are valid through the
  * session, but not longer. Any values set and used by this package are only valid for the
  * current session. EXCEPTIONS, if not handled, ARE RAISED. Every function may raise -20099
  * Internal error, if the session variable is in an incorrect state. Functions called can
  * rely on the session variable that all fields are set.
  *
  * Names of test functions and procedures follow this rules:
  *  3 delimiter: prefix, test set, test group, test name
  *               <test prefix><delimiter><test set name><delimiter><test group name><delimiter><test name>
  *               e.g. TEST_MYTESTSET_MYGROUP_MYTEST0001
  *  2 delimiter: prefix, test group, test name
  *               <test prefix><delimiter><test group name><delimiter><test name>
  *               e.g. TEST_MYGROUP_MYTEST0002
  *  1 delimiter: prefix, test name
  *               <test prefix><delimiter><test name>
  *               e.g. TEST_MYTEST0004
  * >3 delimiter: prefix, test set, test group, rest is testname
  *               <test prefix><delimiter><test set name><delimiter><test group name>(n <delimiter><test name> occurances)
  *               TEST_MYTESTSET_MYGROUP_MYTEST_WITH_A_VERY_LONG_NAME_0001
  *
  * Delimiter is limited to underscore _. Oracle strongly discourages from using $ or #. Test functions or procedures
  * must contain a delimiter after the prefix. Otherwise they are ignored, e.g. testMyFunction is NOT a valid name
  * considered by otap. otap ignores case sensitive names. It handles names as not case sensitive.
  *
  * Name components not given are replaced by the fall_back session variables. They can be set before the test.
  * Otherwise they use the defaults. Default is that names define the test set, test group and name. This can
  * also be overwritten before the test. In this case test set and test group are retrieved by the session variables
  * and test name equals the whole name without the prefix.
  * Defaults for prefix and delimiter are defined in OTAP_CONSTANTS.
  */

  /** FUNCTION otap_test.init_test
  * This function is at some points equal to pgTap plan. As plan is a reserved name in Oracle, even calling
  * a package function plan lead to errors. The name init would have been sufficient, but to avoid naming conflicts
  * pgTap plan equivalent in otap is init_test.
  *
  * This function is optional. If you do not execute this, the default settings will be used. Ensure proper naming of
  * your test functions and preocedures to make it work as desired without initialization.
  *
  * Function will set internal package variables for the duration of the session. If you open a different session, make
  * sure that you run init_test before, if needed.
  *
  * Main functionality is setting the amount of tests to expect. If greater than 0 this will include a test report section
  * containing differences in tests expected and tests executed.
  *
  * Wrapper for otap_api.init_test.
  *
  * @param p_test_count The amount of tests expected to be executed when called.
  * @param p_test_set The name of the test set applied if the name of the executed test procedure or function does not provide a test set name or name precendence is disabled.
  * @param p_test_group The name of the test group applied if the name of the executed test procedure or function does not provide a test group name or name precendence is disabled.
  * @param p_test_name The name of the test name applied if the name of the executed test procedure or function does not provide a test name or name precendence is disabled.
  * @param p_prefix The prefix to use for identifying test functions and procedures. Limited to 4 chars. Test functions and procedures must have a trailing delimiter _ after the prefix to be identified.
  * @param p_name_precedence Can disable the naming conventions for otap. If set to otap_constants.OTAP_NUM_FALSE, all tests will run under the defined test set and group, set by init_test.
  * @param p_include_pkg Can enable to search also packages and package procedures and functions that fit the naming convention with the given prefix, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_persist Can enable to persist the test results longer than the current default of PRESERVE_DAYS in OTAP_CONFIG, if set to otap_constants.OTAP_NUM_TRUE.
  *
  * The following parameters are needed by otap, but should never be overwritten.
  * It is the only way otap can find out correctly under which schema and user it is running.
  * @param p_schema Reads current schema from caller environment, DO NOT SET, let the defaults provide the value.
  * @param p_user Reads current user from caller environment, DO NOT SET, let the defaults provide the value.
  * @param p_executor Reads session user from caller environment, DO NOT SET, let the defaults provide the value.
  */
  FUNCTION init_test( p_test_count      IN NUMBER   DEFAULT 0
                    , p_test_set        IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_SET
                    , p_test_group      IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_GROUP
                    , p_test_name       IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_NAME
                    , p_prefix          IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_PREFIX
                    , p_name_precedence IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                    , p_include_pkg     IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    , p_persist         IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    -- internal variables from caller environment DO NOT SET them explicitely
                    -- you may want to set p_schema, which is the default schema used for object searches
                    -- but schema test functions provide a schema override, so in general there is no need
                    -- for overwritting this value
                    -- currently no save way exists to get the correct values from inside a procedure of function
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_user            IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER')
                    , p_executor        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER')
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.finish_test
  * Resets the OTAP_SESSION object. Will set a new session id, reset the counters and the names
  * for test set, group and name. When a test session is finished, the test session view will not
  * longer show the tests from the old session. If intended count is set, a test record about
  * executed and expected tests is written. Wrapper for otap_api.finish_test.
  *
  * @param p_write_count_rec The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE.
  *
  * @return A summary of the old session and details of the new session as text message LF delimited.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION finish_test(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.current_settings
  * Returns a LF terminated string about the current package session state.
  * Wrapper for otap_api.otap_session_show.
  *
  * @return An info message about the current package session variables.
  */
  FUNCTION current_settings
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.current_summary
  * Returns a string with a current summary of the test session. Session id, run time, tests executed
  * and test in error. Wrapper for otap_api.otap_session_summary.
  *
  * @return An info message about the current package session variables.
  */
  FUNCTION current_summary
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.set_test_name
  * Handles and sets the current active test name. If test name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_NAME
  * is used. Only valid within one session, if session ends, test name is reset.
  * Wrapper for otap_api.otap_session_set_test_name.
  *
  * Test names are usually retrieved from the executed test function or procedure. Can
  * be used to overwrite the group within a test function or procedure.
  *
  * @param p_test_name The test name to use for the next test.
  *
  * @return The test name currently active as text message.
  */
  FUNCTION set_test_name(p_test_name IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.set_test_group
  * Handles and sets the current active test group. If test group name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_GROUP
  * is used. Only valid within one session, if session ends, test name is reset.
  * Wrapper for otap_api.otap_session_set_test_group.
  *
  * Test group names are usually retrieved from the executed test function or procedure. Can
  * be used to overwrite the group within a test function or procedure.
  *
  * @param p_test_group The test group name to use for the next tests.
  *
  * @return The test group currently active as text message.
  */
  FUNCTION set_test_group(p_test_group IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.set_test_set
  * Handles and sets the current active test set. If test set name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_SET
  * is used. Wrapper for otap_api.otap_session_set_test_set.
  *
  * Test set names are usually retrieved from the executed test function or procedure. Can
  * be used to overwrite the set within a test function or procedure.
  *
  * @param p_test_set The test set name to use for the next tests.
  *
  * @return The test set currently active as text message.
  */
  FUNCTION set_test_set(p_test_set IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.get_session_id
  * Retrieves the current active test session id.
  * Wrapper for otap_api.otap_session_get_test_id.
  *
  * @return The current active test session id.
  */
  FUNCTION get_session_id
    RETURN NUMBER
  ;

  /** FUNCTION otap_test.get_report_id
  * Retrieves the last view id from finsih or the current active test session id. Usually used in views.
  * Wrapper for otap_api.otap_session_get_report_id.
  *
  * @return The last view id or the current active test session id.
  */
  FUNCTION get_report_id
    RETURN NUMBER
  ;

  /** FUNCTION otap_test.result_view
  * Returns the results and provides hierarchical master detail test results.
  * To be called with SELECT * FROM TABLE(otap_test.result_view(otap_test.get_session_id));
  * The only function which is no wrapper due to limitation with piped rows.
  *
  * @param p_session_id The test session id for filtering the results.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION result_view(p_session_id IN NUMBER)
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.has_table
  * Tests if a table exists or not and outputs the test result. Wrapper for otap_api.has_table.
  * Writes and adds the test result for the current active test session.
  *
  * @param p_table_name The table name of the table, taken as is. If not case sensitive you must provide the table name in UPPERCASE.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. If not case sensitive you must provide the schema name in UPPERCASE.
  * @param p_description The test description if any. If not given, a description is generated, see FN template.
  *
  * @return The test result as text.
  */
  FUNCTION has_table( p_table_name   IN VARCHAR2
                    , p_schema       IN VARCHAR2 DEFAULT NULL
                    , p_description  IN VARCHAR2 DEFAULT NULL
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_column
  * Tests if a table column exists. Additional tests on the column can be added by using the additional
  * parameters with default NULL. The expected values have to match the content of DBA_TAB_COLUMNS for the given table,
  * column and schema.
  *
  * If checking defaults, it is limited to defaults not longer than 4000 char, using the DATA_DEFAULT_VC column. Expressions
  * must match all chars in the default, like quotation. Use q-syntax where possible to define correct strings, e.g.
  * SELECT q'[SYS_CONTEXT('USERENV', 'OS_USER')]' FROM dual;
  *
  * @param p_table_name The name of the table, taken as is. Case sensitive.
  * @param p_column_name The column name of the table, taken as is. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and column must exist in this schema. If not case sensitive you must provide the schema name in UPPERCASE.
  * @param p_description The test description if any. If not given, a description is generated, see FN template.
  * @param p_data_type Optional check the datatype of the column. Ignored if NULL. NOT case sensitive.
  * @param p_data_length Optional check the data length of the column. Ignored if NULL.
  * @param p_data_precision Optional check the data precision of the column. Ignored if NULL. Results in test error if datatype is not NUMBER.
  * @param p_data_scale Optional check the data scale of the column. Ignored if NULL. Results in test error if datatype is not NUMBER or TIMESTAMP.
  * @param p_nullable Optional check if the column is nullable. Ignored if NULL. NOT case sensitive.
  * @param p_data_default Optional check the default for the column. Ignored if NULL. Must match all chars, including ' and ". Limited to defaults shorter than 4000 chars.
  *
  * @return The test result as text.
  */
  FUNCTION has_column( p_table_name     IN  VARCHAR2
                     , p_column_name    IN  VARCHAR2
                     , p_schema         IN  VARCHAR2 DEFAULT NULL
                     , p_description    IN  VARCHAR2 DEFAULT NULL
                     , p_data_type      IN  VARCHAR2 DEFAULT NULL
                     , p_data_length    IN  NUMBER   DEFAULT NULL
                     , p_data_precision IN  NUMBER   DEFAULT NULL
                     , p_data_scale     IN  NUMBER   DEFAULT NULL
                     , p_nullable       IN  VARCHAR2 DEFAULT NULL
                     , p_data_default   IN  VARCHAR2 DEFAULT NULL -- maps to DATA_DEFAULT_VC limited to 4000, LONG is a pain in the ass
                     )
    RETURN VARCHAR2
  ;

  -- debug function
  FUNCTION get_session_var
    RETURN OTAP_SESSION
  ;

END;
/
GRANT EXECUTE ON otap_test TO &OTAP_ROLE;