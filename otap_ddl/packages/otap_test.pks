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
  * @param p_language_id The session language id to use for test reports and results. Limited to 3 chars. If language has no translation, default is used.
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
                    , p_test_set        IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                    , p_test_group      IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                    , p_test_name       IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                    , p_prefix          IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                    , p_language_id     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
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
  * @param p_write_count_rec The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE. Setting has no effect if intented count is not set or 0.
  *
  * @return A summary of the old session and details of the new session as text message LF delimited.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION finish_test(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.finish_test_with_exit_code
  * This function is for automation purposes. It translates and returns an exit code that can be uses in CMD and shell scripts
  * to handle reactions based on the output of a test session, e.g. if test is passed you don't need probably the test report. Or you want
  * your build to fail, if test is not passed.
  *
  * Equal to finish_test apart from the return value check and translation. Undefined overrules failed. If undefined is returned, also
  * failed tests may be contained in the current test report. If you finish a test session without any test run, the result is UNDEFINED.
  *
  * @param p_write_count_rec The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE.
  *
  * @return A positive integer as result. 0 = success, all tests passed. 1 = at least one test failed. 2 = at least one test undefined.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION finish_test_with_exit_code(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN NUMBER
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
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
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
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
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
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
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

  /** FUNCTION otap_test.set_language
  * Sets the current session language, limited to 3 chars, always converted to upper case.
  * Longer values are cutted to 3 chars. If NULL is given than, otap_constants.OTAP_INTERNAL_NA
  * is used. If the language does not exist in OTAP_TRANSLATE it is ignored and defaults are used.
  *
  * @param p_language_id The 3 char language id to use. No effect if OTAP_TRANSLATE is empty.
  *
  * @return The session language id currently active.
  */
  FUNCTION set_language(p_language_id IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.get_language
  * Retrieves the current active session language id, limited to 3 chars.
  * Wrapper for otap_api.otap_session_get_language.
  *
  * @return The session language id currently active.
  */
  FUNCTION get_language
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

  /** FUNCTION otap_test.set_active_report_id
  * Temporarily sets the active report id. Will be overwritten if tests are running afterwards.
  * Used to access specific older or persisted test reports with OTAP_LATEST_TEST_RESULTS_V.
  * Checks if the session id exists. If it does not exist, the report is is not changed.
  * Wrapper for otap_api.set_active_report_id.
  *
  * @return An success or error message.
  */
  FUNCTION set_active_report_id(p_report_id IN NUMBER)
    RETURN VARCHAR2
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
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).
  *
  * @return The test result as text.
  */
  FUNCTION has_table( p_table_name      IN VARCHAR2
                    , p_schema          IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
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
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and column must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_data_type Optional check the datatype of the column. Ignored if NULL. NOT case sensitive.
  * @param p_data_length Optional check the data length of the column. Ignored if NULL.
  * @param p_data_precision Optional check the data precision of the column. Ignored if NULL. Results in test error if datatype is not NUMBER.
  * @param p_data_scale Optional check the data scale of the column. Ignored if NULL. Results in test error if datatype is not NUMBER or TIMESTAMP.
  * @param p_nullable Optional check if the column is nullable. Ignored if NULL. NOT case sensitive.
  * @param p_data_default Optional check the default for the column. Ignored if NULL. Must match all chars, including ' and ". Limited to defaults shorter than 4000 chars.
  * @param p_expected_result The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).
  *
  * @return The test result as text.
  */
  FUNCTION has_column( p_table_name      IN VARCHAR2
                     , p_column_name     IN VARCHAR2
                     , p_schema          IN VARCHAR2 DEFAULT NULL
                     , p_description     IN VARCHAR2 DEFAULT NULL
                     , p_data_type       IN VARCHAR2 DEFAULT NULL
                     , p_data_length     IN NUMBER   DEFAULT NULL
                     , p_data_precision  IN NUMBER   DEFAULT NULL
                     , p_data_scale      IN NUMBER   DEFAULT NULL
                     , p_nullable        IN VARCHAR2 DEFAULT NULL
                     , p_data_default    IN VARCHAR2 DEFAULT NULL
                     , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_package
  * Checks if a given package exists. Check if header and body, if available, are valid by default.
  *
  * @param p_package_name The name of the package, take as is. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the package must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_package_type The object type of the package. PACKAGE or PACKAGE BODY. Not case sensitive. Invalid values cause test result undefined.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_package( p_package_name    IN     VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT NULL
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_package_type    IN     VARCHAR2 DEFAULT 'PACKAGE'
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_schema.has_procedure
  * Checks if a given procedure or function exists. If package is given, the package procedure or function
  * is checked.
  *
  * @param p_procedure_name The name of the procedure or function, take as is. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_procedure_type Procedure type, mandatory. Either FUNCTION (default) or PROCEDURE. Not case sensitive. Invalid values cause test result undefined.
  * @param p_package_name Either NULL (normal functions and procedures) or a package name for package functions and procedures. Case sensitive.
  * @param p_return_type Either NULL (procedures) or the return data type of a function. Not case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_procedure( p_procedure_name  IN     VARCHAR2
                        , p_schema          IN     VARCHAR2 DEFAULT NULL
                        , p_description     IN     VARCHAR2 DEFAULT NULL
                        , p_procedure_type  IN     VARCHAR2 DEFAULT 'FUNCTION'
                        , p_package_name    IN     VARCHAR2 DEFAULT NULL
                        , p_return_type     IN     VARCHAR2 DEFAULT NULL
                        , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_trigger
  * Checks if a given trigger exists.
  *
  * @param p_trigger_name The name of the trigger, take as is. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_trigger_type The trigger type as in USER_TRIGGERS. Optional. Not case sensitive. Invalid values cause test failed.
  * @param p_trigger_event The triggering event as in USER_TRIGGERS. Optional. Not case sensitive.
  * @param p_table_owner The table owner as in USER_TRIGGERS. Optional. Case sensitive.
  * @param p_table_name The table name as in USER_TRIGGERS. Optional. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_trigger( p_trigger_name    IN     VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT NULL
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_type    IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_event   IN     VARCHAR2 DEFAULT NULL
                      , p_table_owner     IN     VARCHAR2 DEFAULT NULL
                      , p_table_name      IN     VARCHAR2 DEFAULT NULL
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_schema.has_object
  * Checks if a given database object exists.
  *
  * @param p_object_name The name of the object, take as is. Case sensitive.
  * @param p_object_type The object type of the given object. Mandatory. Object must be unique identifiable, otherwise test will result in undefined. Not case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_object( p_object_name     IN     VARCHAR2
                     , p_object_type     IN     VARCHAR2
                     , p_schema          IN     VARCHAR2 DEFAULT NULL
                     , p_description     IN     VARCHAR2 DEFAULT NULL
                     , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_constraint
  * Checks if a given table has a constraint of the given type. Optional you can specify column and constraint name.
  *
  * Supported constraint types:
  * C - Check constraint on a table
  * P - Primary key
  * U - Unique key
  * R - Referential integrity - use has_ref_constraint for more options
  * V - With check option, on a view
  * O - With read only, on a view
  * H - Hash expression
  * F - Constraint that involves a REF column - use has_ref_constraint for more options
  * S is not supported, could not find or create an example to examine. SUPPLEMENTAL LOG clause only reflects in CDEF$ and CCOL$.
  *
  * @param p_table_name Mandatory. The table to be checked for constraint, take as is. Case sensitive. Missing value will cause test to fail.
  * @param p_constraint_type Mandatory. A valid constraint type. Not case sensitive. Wrong values will cause the test to fail.
  * @param p_column_name Optional. The column that is part of the constraint. Case sensitive.
  * @param p_constraint Optional. The name of the constraint. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_constraint( p_table_name      IN VARCHAR2
                         , p_constraint_type IN VARCHAR2 DEFAULT 'C'
                         , p_column_name     IN VARCHAR2 DEFAULT NULL
                         , p_constraint      IN VARCHAR2 DEFAULT NULL
                         , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_description     IN VARCHAR2 DEFAULT NULL
                         , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_ref_constraint
  * Checks if a given table has a reference constraint. You may also use has_constraint. But if you want to check the
  * referenced owner, constraint, column and table, you have to use this function.
  *
  * @param p_table_name Mandatory. The table to be checked for the reference constraint, take as is. Case sensitive.
  * @param p_constraint_type Mandatory. A valid ref constraint type. Not case sensitive. Only 'R' and 'F' allowed, 'R' on invalid or empty values.
  * @param p_column_name Optional. The column that is part of the reference constraint. Case sensitive.
  * @param p_constraint Optional. The name of the reference constraint. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_r_table_name Optional. The referenced table of the reference constraint, take as is. Case sensitive.
  * @param p_r_column_name Optional. The referenced column that is part of the reference constraint. Case sensitive.
  * @param p_r_constraint Optional. The name of the referenced constraint by the reference constraint. Case sensitive.
  * @param p_r_schema Optional. The reference schema of the constraint. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_ref_constraint( p_table_name      IN VARCHAR2
                             , p_constraint_type IN VARCHAR2 DEFAULT 'R'
                             , p_column_name     IN VARCHAR2 DEFAULT NULL
                             , p_constraint      IN VARCHAR2 DEFAULT NULL
                             , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                             , p_r_table_name    IN VARCHAR2 DEFAULT NULL
                             , p_r_column_name   IN VARCHAR2 DEFAULT NULL
                             , p_r_constraint    IN VARCHAR2 DEFAULT NULL
                             , p_r_schema        IN VARCHAR2 DEFAULT NULL
                             , p_description     IN VARCHAR2 DEFAULT NULL
                             , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_not_null_constraint
  * Checks if a given table column has a not null check constraint. Optional you can specify the constraint name. NOT NULL constraint is
  * somewhat special as it is recommended for inline creation, which generates system constraint names. You are also free to create it
  * outbound. Therefore in most cases the constraint name is not defined or may change on recreation. Also NULLABLE may not reflect an
  * existing outbound NOT NULL constraint. This function checks also the definition, which has the generated format: "COLUMN_NAME" IS NOT NULL.
  * Any outbund declaration will probably look different. Therefore the term "IS NOT NULL" and the column name is searched after UPPER conversion
  * of SEARCH_CONDITION_VC. Will not work for search conditions > 4000 char.
  *
  * @param p_table_name Mandatory. The table to be checked for NOT NULL constraint, take as is. Case sensitive. Missing value will cause test to fail.
  * @param p_column_name Mandator. The column that is checked for the NOT NULL constraint. Case sensitive.
  * @param p_constraint Optional. The name of the constraint. Case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_not_null_constraint( p_table_name      IN VARCHAR2
                                  , p_column_name     IN VARCHAR2
                                  , p_constraint      IN VARCHAR2 DEFAULT NULL
                                  , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_description     IN VARCHAR2 DEFAULT NULL
                                  , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_index
  * Checks if a given index exists. You may specify table name or index name. Both values NULL will lead to test failed.
  *
  * @param p_table_name Mandatory if index name is NULL. The table name of the table that owns the index.
  * @param p_column_name Optional. The column name used in the index. Case sensitive.
  * @param p_index_name Mandatory if table name is NULL. The index name to check. Case sensitive.
  * @param p_index_type Optional. The index type of the index to check. Not case sensitive.
  * @param p_table_type Optional. The table type of the index to check. Not case sensitive.
  * @param p_uniqueness Optional. The uniqueness of the index to check. Not case sensitive.
  * @param p_tablespace_name Optional. The tablespace name used by the index to check. Case sensitive.
  * @param p_partitioned Optional. The partitioned state of the index to check. Not case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_index( p_table_name      IN VARCHAR2
                    , p_column_name     IN VARCHAR2 DEFAULT NULL
                    , p_index_name      IN VARCHAR2 DEFAULT NULL
                    , p_index_type      IN VARCHAR2 DEFAULT NULL
                    , p_table_type      IN VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN VARCHAR2 DEFAULT NULL
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_type
  * Checks if a given type exists. The type code (e.g. OBJECT, COLLECTION) is shown as sub object in the exist message.
  *
  * @param p_type_name Mandatory. The name of the type to check. Case sensitive.
  * @param p_typecode Optional. The typecode like OBJECT of the type to check. Not case sensitive.
  * @param p_attributes Optional. The number of type attributes to check.
  * @param p_methods Optional. The number of type methods to check.
  * @param p_predefined Optional. The predefined state of the type to check. Not case sensitive.
  * @param p_incomplete Optional. The incomplete state of the type to check. Not case sensitive.
  * @param p_final Optional. The final state of the type to check. Not case sensitive.
  * @param p_persistable Optional. The persistable state of the type to check. Not case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_type( p_type_name       IN VARCHAR2
                   , p_typecode        IN VARCHAR2 DEFAULT NULL
                   , p_attributes      IN NUMBER   DEFAULT NULL
                   , p_methods         IN NUMBER   DEFAULT NULL
                   , p_predefined      IN VARCHAR2 DEFAULT NULL
                   , p_incomplete      IN VARCHAR2 DEFAULT NULL
                   , p_final           IN VARCHAR2 DEFAULT NULL
                   , p_persistable     IN VARCHAR2 DEFAULT NULL
                   , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                   , p_description     IN VARCHAR2 DEFAULT NULL
                   , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_sequence
  * Checks if a given sequence exists. It can be identified either by the sequence name or the table and column name.
  * If sequence name is NULL, table AND column name must be given to identify the sequence. In case the table owner
  * differs from the sequence owner, the table owner can be specified. If not specified, the normal schema logic takes
  * place.
  *
  * @param p_sequence_name Mandatory if not table and column name are given. The name of the sequence to check. Case sensitive.
  * @param p_table_name Mandatory if sequence name is not given. The table name with the identity column that uses the sequence to check. Case sensitive.
  * @param p_column_name Mandatory if sequence name is not given. The identity column name that uses the sequence to check. Case sensitive.
  * @param p_min_value Optional. The minimum value attribute of the sequence to check.
  * @param p_max_value Optional. The maximum value attribute of the sequence to check.
  * @param p_increment_by Optional. The increment of the sequence to check.
  * @param p_cycle_flag Optional. The cycle flag of the sequence to check. Not case sensitive.
  * @param p_order_flag Optional. The order flag of the sequence to check. Not case sensitive.
  * @param p_cache_size Optional. The cache size of the sequence to check.
  * @param p_scale_flag Optional. The scale flag of the sequence to check. Not case sensitive.
  * @param p_extend_flag Optional. The extend flag of the sequence to check. Not case sensitive.
  * @param p_sharded_flag Optional. The sharded flag of the sequence to check. Not case sensitive.
  * @param p_session_flag Optional. The session flag of the sequence to check. Not case sensitive.
  * @param p_keep_value Optional. The keep value flag of the sequence to check. Not case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_sequence( p_sequence_name   IN VARCHAR2
                       , p_table_name      IN VARCHAR2 DEFAULT NULL
                       , p_column_name     IN VARCHAR2 DEFAULT NULL
                       , p_min_value       IN NUMBER   DEFAULT NULL
                       , p_max_value       IN NUMBER   DEFAULT NULL
                       , p_increment_by    IN NUMBER   DEFAULT NULL
                       , p_cycle_flag      IN VARCHAR2 DEFAULT NULL
                       , p_order_flag      IN VARCHAR2 DEFAULT NULL
                       , p_cache_size      IN NUMBER   DEFAULT NULL
                       , p_scale_flag      IN VARCHAR2 DEFAULT NULL
                       , p_extend_flag     IN VARCHAR2 DEFAULT NULL
                       , p_sharded_flag    IN VARCHAR2 DEFAULT NULL
                       , p_session_flag    IN VARCHAR2 DEFAULT NULL
                       , p_keep_value      IN VARCHAR2 DEFAULT NULL
                       , p_table_owner     IN VARCHAR2 DEFAULT NULL
                       , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_description     IN VARCHAR2 DEFAULT NULL
                       , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                       )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_scheduler_job
  * Checks basically if a given scheduler job exists.
  *
  * @param p_job_name Mandatory. The name of the scheduler job to check. Case sensitive.
  * @param p_job_style Optional. The job style of the scheduler job to check. Not case sensitive.
  * @param p_job_type Optional. The job type of the scheduler job to check. Not case sensitive.
  * @param p_job_action Optional. The job action of the scheduler job to check. Compares code with UPPER and flatten. Not case sensitive.
  * @param p_schedule_type Optional. The schedule type of the scheduler job to check. Not case sensitive.
  * @param p_repeat_interval Optional. The repeat interval of the scheduler job to check. Not case sensitive.
  * @param p_job_class Optional. The job class of the scheduler job to check. Not case sensitive.
  * @param p_logging_level Optional. The logging level indicator of the scheduler job to check. Not case sensitive.
  * @param p_store_output Optional. The store output indicator of the scheduler job to check. Not case sensitive.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_scheduler_job( p_job_name        IN VARCHAR2
                            , p_job_style       IN VARCHAR2 DEFAULT NULL
                            , p_job_type        IN VARCHAR2 DEFAULT NULL
                            , p_job_action      IN VARCHAR2 DEFAULT NULL
                            , p_schedule_type   IN VARCHAR2 DEFAULT NULL
                            , p_repeat_interval IN VARCHAR2 DEFAULT NULL
                            , p_job_class       IN VARCHAR2 DEFAULT NULL
                            , p_logging_level   IN VARCHAR2 DEFAULT NULL
                            , p_store_output    IN VARCHAR2 DEFAULT NULL
                            , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                            , p_description     IN VARCHAR2 DEFAULT NULL
                            , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.has_user
  * Checks basically if a given user exists.
  *
  * @param p_username Mandatory. The name of the database user to check. Case sensitive.
  * @param p_account_status Optional. The account status of the database user to check. Not case sensitive.
  * @param p_default_tablespace Optional. The default tablespace of the database user to check. Case sensitive.
  * @param p_temporary_tablespace Optional. The temporary tablespace of the database user to check. Case sensitive.
  * @param p_local_temp_tablespace Optional. The local temporary tablespace of the database user to check. Case sensitive.
  * @param p_profile Optional. The profile setting of the database user to check. Not case sensitive.
  * @param p_password_versions Optional. The password versions if any defined of the database user to check. Case sensitive.
  * @param p_authentication_type Optional. The authentication type of the database user to check. Not case sensitive.
  * @param p_proxy_only_connect Optional. The proxy only connect indicator of the database user to check. Not case sensitive.
  * @param p_protected Optional. The protected state indicator of the database user to check. Not case sensitive.
  * @param p_read_only Optional. The read only state indicator of the database user to check. Not case sensitive.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as text.
  */
  FUNCTION has_user( p_username              IN VARCHAR2
                   , p_account_status        IN VARCHAR2 DEFAULT NULL
                   , p_default_tablespace    IN VARCHAR2 DEFAULT NULL
                   , p_temporary_tablespace  IN VARCHAR2 DEFAULT NULL
                   , p_local_temp_tablespace IN VARCHAR2 DEFAULT NULL
                   , p_profile               IN VARCHAR2 DEFAULT NULL
                   , p_password_versions     IN VARCHAR2 DEFAULT NULL
                   , p_authentication_type   IN VARCHAR2 DEFAULT NULL
                   , p_proxy_only_connect    IN VARCHAR2 DEFAULT NULL
                   , p_protected             IN VARCHAR2 DEFAULT NULL
                   , p_read_only             IN VARCHAR2 DEFAULT NULL
                   , p_description           IN VARCHAR2 DEFAULT NULL
                   , p_expected_result       IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.ok
  * Checks if a boolean expression result is TRUE. To test for FALSE just set expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  * It is recommended to use a description as generated text does not contain details on the the test condition.
  *
  * @param p_boolean The result of a boolean expression to check.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  */
  FUNCTION ok( p_boolean         IN BOOLEAN
             , p_description     IN VARCHAR2 DEFAULT NULL
             , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.is_eq
  * Checks given data of type VARCHAR2, NUMBER and DATE against a given value. As "IS" is a reserved word in Oracle
  * this is the equivalent of is and isnt. isnt is achieved by setting expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  *
  * Other types are more or less problematic, e.g. you can't declare in Oracle a function with date and timestamp parameter. If providing
  * TIMESTAMP Oracle gets confused which function to use. Try to convert or cast the types to the base types. CAST will probably not
  * preserve all information. TO_CHAR is almost always an option.
  *
  * Passing simply NULL, NULL without that datatypes are defined by columns, the function will fail with ORA-06553: Too much declarations
  * of is_eq. To do a NULL test, use, according to p_have datatype, TO_CHAR(NULL), TO_NUMBER(NULL) or TO_DATE(NULL) so correct function
  * signature is identified and function does not fail.
  *
  * @param p_have The data to check.
  * @param p_want The expected data. Must have the same datatype as p_have.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  */
  FUNCTION is_eq( p_have            IN VARCHAR2
                , p_want            IN VARCHAR2
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                )
    RETURN VARCHAR2
  ;
  FUNCTION is_eq( p_have            IN NUMBER
                , p_want            IN NUMBER
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                )
    RETURN VARCHAR2
  ;
  FUNCTION is_eq( p_have            IN DATE
                , p_want            IN DATE
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.match_regex
  * Checks given data of type VARCHAR2 against an Oracle REGEX expression. Uses REGEXP_LIKE.
  * ATTENTION Oracle REGEX implementation is not standard. Unix regex which work like charm take hours to implement in
  * Oracle REGEX to work as desired. Test your expression well with Oracle before using it.
  *
  * Easiest way to check is SELECT COUNT(*) FROM dual WHERE regexp_like('your string', 'your regex', 'regex param');
  * Should result in 1 if successful checked. You may want to prepare a with block with different string to pass them
  * through the regular expression.
  *
  * @param p_have The data to check.
  * @param p_regex A valid Oracle regular expression that p_have must match.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_param Parameter for REGEXP_LIKE. 'i' is case insensitive. See Oracle documentation for details, https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Pattern-matching-Conditions.html#GUID-D2124F3A-C6E4-4CCA-A40E-2FFCABFD8E19.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  */
  FUNCTION match_regex( p_have            IN VARCHAR2
                      , p_regex           IN VARCHAR2
                      , p_description     IN VARCHAR2 DEFAULT NULL
                      , p_param           IN VARCHAR2 DEFAULT NULL
                      , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.alike
  * Checks given data of type VARCHAR2 against an Oracle LIKE expression. LIKE is currently more reliable and easier
  * to use than Oracle REGEX implementation. But also much more limited.
  *
  * @param p_have The data to check.
  * @param p_like A valid Oracle like expression that p_have must match.
  * @param p_case_sensitive Optional defines that the compared result is handled as case sensitive, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  */
  FUNCTION alike( p_have            IN VARCHAR2
                , p_like            IN VARCHAR2
                , p_case_sensitive  IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.throws_ok
  * Checks if a given statement or code block throws the expected error message. The expected error message must match
  * the SQLERRM returned from exception thrown. Use throws_match or throws_like if only parts of the error message must
  * match. If the statement starts with SELECT it is executed as is, without caring for returned columns or rows and ignoring
  * any given header definition. The header definition is a code block for the declare section defining variables that may be
  * needed by called functions or procedures. It is only used if the statement does not start with SELECT and if the declaration
  * block can be executed with a NULL procedure without throwing exceptions.
  *
  * Function comes in two flavors, comparing SQLERRM as VARCHAR2 or the error code SQLCODE as number. It can also be used to check
  * if a statement does not cause any exception by switching the expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  *
  * SQL statements (SELECT, UPDATE, DELETE) MUST NOT have a trailing semicolon. otap will try to detect and remove it, but may fail.
  * Semicolon in dynamically executed SQL statements will cause an unexpected exception.
  *
  * Functions and procedures MUST have a trailing semicolon, especially if more than one command is executed in the block.
  *
  * Syntax errors will most likely cause a different exception as the expected one and fail the test. This is especially important if
  * you switch the expected test result. otap expects in this case, that the statement could be executed without any exception.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_sqlerrm Mandatory. The exact case sensitive expected error message as returned by SQLERRM after a provoked exception.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  *
  * Examples (english messages)
  * SELECT otap_test.throws_ok('SELECT 1/0 FROM dual', 'ORA-01476: divisor is equal to zero') AS test_result FROM dual;
  * SELECT otap_test.throws_ok('l_return := 1/0;', 'ORA-01476: divisor is equal to zero', 'l_return NUMBER;') AS test_result FROM dual;
  */
  FUNCTION throws_ok( p_statement       IN VARCHAR2
                    , p_sqlerrm         IN VARCHAR2
                    , p_header_def      IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.throws_ok
  * Flavor error code SQLCODE as number. Same behavior as flavor error message. Be aware that some Oracle error codes are group error codes where
  * the error message differs depending on the exact error cause.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_sqlcode Mandatory. The exact expected error code as returned by SQLCODE after a provoked exception.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  *
  * Example
  * SELECT otap_test.throws_ok('SELECT 1/0 FROM dual', -1476) AS test_result FROM dual;
  */
  FUNCTION throws_ok( p_statement       IN VARCHAR2
                    , p_sqlcode         IN NUMBER
                    , p_header_def      IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.throws_matches
  * Same as otap_test.throws_ok apart from using Oracle REGEXP to identify the error message.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_regex_sqlerrm Mandatory. The regular expression to match the expected error message as returned by SQLERRM after a provoked exception.
  * @param p_param Optional valid parameter for REGEXP_LIKE. 'i' means case insensitive. Parameters are case sensitive. See Oracle documentation for details, https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Pattern-matching-Conditions.html#GUID-D2124F3A-C6E4-4CCA-A40E-2FFCABFD8E19.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  *
  * Example (english message)
  * SELECT otap_test.throws_matches('SELECT 1/0 FROM dual', '.*-01476: divisor is equal to zero.*') FROM dual;
  */
  FUNCTION throws_matches( p_statement       IN VARCHAR2
                         , p_regex_sqlerrm   IN VARCHAR2
                         , p_param           IN VARCHAR2 DEFAULT NULL
                         , p_header_def      IN VARCHAR2 DEFAULT NULL
                         , p_description     IN VARCHAR2 DEFAULT NULL
                         , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.throws_like
  * Same as otap_test.throws_ok apart from using Oracle LIKE to identify the error message.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_like_sqlerrm Mandatory. The LIKE expression to match the expected error message as returned by SQLERRM after a provoked exception.
  * @param p_case_sensitive Optional defines that the compared result is handled as case sensitive, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_description The test description if any. If not given, a description is generated, see template.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  * @param p_schema A schema override of the current test session if needed, taken as is. Compares are not clearly associated to a schema. Case sensitive.
  *
  * @return The test result as text.
  *
  * Example (english message)
  * SELECT otap_test.throws_like('SELECT 1/0 FROM dual', '%-01476: divisor is equal to zero%') FROM dual;
  */
  FUNCTION throws_like( p_statement       IN VARCHAR2
                      , p_like_sqlerrm    IN VARCHAR2
                      , p_case_sensitive  IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                      , p_header_def      IN VARCHAR2 DEFAULT NULL
                      , p_description     IN VARCHAR2 DEFAULT NULL
                      , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.test_error
  * Provides a possibility to report script errors to test sessions, that are not discovered by tests itself.
  * Usually using SPERRORLOG and an error identifier during script runs or in exception blocks. Test errors
  * are always considered as UNDEFINED as tests have not been executed as intended. Does not execute any test
  * only writes an test error record.
  *
  * @param p_description Mandatory. The description of the identified error.
  * @param p_errors Mandatory. The identified error messages like SQLERRM or MESSAGE column of SPERRORLOG.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. Case sensitive.
  *
  * @return Always an otap_constants.OTAP_NUM_TEST_UNDEFINED result message using the description given.
  */
  FUNCTION test_error( p_description     IN            VARCHAR2
                     , p_errors          IN            VARCHAR2
                     , p_schema          IN            VARCHAR2     DEFAULT NULL
                     )
    RETURN VARCHAR2
  ;

  -- generate functionality, all generate functions only require the otap user role as they operate on meta data

  /** PROCEDURE otap_test.generate_set_type
  * Sets the generation type. Default is script (S). Options are procedure (P) or function (F).
  * Fallback on errors is script. This setting is only valid within the current session.
  *
  * @param p_gen_type A valid generation type. See otap_constants.OTAP_GEN_TYPE_ variables.
  */
  PROCEDURE generate_set_type(p_gen_type IN VARCHAR2);

  /** FUNCTION otap_test.generate_type
  * @return The current active generation type for the current session.
  */
  FUNCTION generate_type
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_test.generate_schema_tests
  * Generates the test scripts for the current available otap schema functions using by default the current
  * schema. Test set gets defined as schema, group represents the object types, like tables, triggers and so on.
  * No translation provided. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you
  * spool the content to files.
  *
  * Including system generated objects is a good idea if your system is stable and you want to ensure that no one
  * changed the current state. With CI/CD or during development, when objects get recreated, it is a really bad idea.
  * Excluded by default are objects beginning with SYS_ for system generated object or containing $ or # chars, which
  * may occur anywhere in the name of system objects.
  *
  * There is no best option, some constraints like NOT NULL must be defined inline to count a column as NOT NULL.
  * With an additional added constraint, the column will be still marked as NULLABLE. Identity columns are another
  * issue, as you cannot define a name for the generated sequence. Make extra tests limited on the system generated
  * objects you rely on (like NOT NULL and identity).
  *
  * @param p_like_schema The LIKE expression for schema names. Default is current schema. % will generate for all schemas in the database, be careful. Underlying objects are not limited. Case sensitive.
  * @param p_required_user An optional comma separated list of users required to be checked by the schema test. Will not include the selected schemas. Useful for specific schemas and integration tests.
  * @param p_title_prefix An optional title prefix for set, group and test names. Limited to 10 chars. Will be added without delimiter to the processed schema.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_schema_tests( p_like_schema   IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_required_user IN VARCHAR2 DEFAULT NULL
                                , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_table_tests
  * Generates the test scripts for the tables of the given schema with the current available
  * otap schema functions. Provides set (schema), group (tables) and name (table name) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_table The LIKE expression for tables names for the given schema. Default is %, all tables. Underlying objects like columns are not limited. Case sensitive.
  * @param p_schema Mandatory. The schema to generate the table tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars. Will be added without delimiter to the test set created.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_table_tests( p_like_table    IN VARCHAR2 DEFAULT '%'
                               , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                               , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                               , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_column_tests
  * Generates the test scripts for the columns of a given table and schema with the current available
  * otap schema functions. Provides set (schema), group (tables) and name (table name) management. Limited
  * to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get column tests for. Case sensitive.
  * @param p_like_column The LIKE expression for column names for the given schema and table. Can also be a specific column name. Default is %, all columns. Underlying objects are not limited. Case sensitive.
  * @param p_schema Mandatory. The schema to generate the column tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_column_tests( p_table         IN VARCHAR2
                                , p_like_column   IN VARCHAR2 DEFAULT '%'
                                , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_trigger_tests
  * Generates the test scripts for the trigger of the given schema with the current available otap schema functions.
  * Provides set (schema), group (triggers) and name (table trigger, non table trigger) management. Limited to line
  * size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_trigger The like expression for the trigger to generate tests for the given schema. Can also be a specific trigger name. Default is %, all trigger. Underlying objects are not limited. Case sensitive.
  * @param p_schema The schema to generate the trigger tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_trigger_tests( p_like_trigger  IN VARCHAR2 DEFAULT '%'
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_package_tests
  * Generates the test scripts for the packages of the given schema with the current available
  * otap schema functions. Provides set (schema), group (package) and name (package function and procedures) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_package The like expression for the package to generate tests for the given schema. Can also be a specific package name. Default is %, all packages. Underlying objects are not limited. Case sensitive.
  * @param p_schema The schema to generate the package tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_package_tests( p_like_package  IN VARCHAR2 DEFAULT '%'
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_procedure_tests
  * Generates the test scripts for the procedures and functions, including packages. with the current available
  * otap schema functions. Provides set (schema), group (procedures) and names (function, procedure, package type) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_procedure The like expression for the procedure (function, procedure, package type) to generate tests for the given schema. Can also be a specific procedure name. Default is %, all procedures. Underlying objects are not limited. Case sensitive.
  * @param p_package_name Optional. Package name for the functions and procedures. Case sensitive.
  * @param p_schema The schema to generate the package tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_procedure_tests( p_like_procedure IN VARCHAR2 DEFAULT '%'
                                   , p_package_name   IN VARCHAR  DEFAULT NULL
                                   , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                   , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                                   , p_show_header    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                   , p_excl_sysgen    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                   )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_view_tests
  * Generates the test scripts for the views of the given schema with the current available otap schema functions.
  * Provides set (schema), group (views) and name (view name) management. Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_view The like expression for the views to generate tests for the given schema. Can also be a specific view name. Default is %, all views. Underlying objects are not limited. Case sensitive.
  * @param p_schema The schema to generate the view tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_view_tests( p_like_view     IN VARCHAR2 DEFAULT '%'
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_schema_user_test
  * Generates the test script for the schema user processed.
  * Provides group (users) and name (simple user checks) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_schema The schema to generate the user test for.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_schema_user_test( p_schema        IN VARCHAR2 DEFAULT NULL
                                    , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                    , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_scheduler_job_tests
  * Generates the test scripts for the scheduler jobs of the given schema with the current available
  * otap schema functions. Provides name (scheduler jobs) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_job The like expression for the scheduler jobs to generate tests for. Can also be a specific scheduler job name. Case sensitive.
  * @param p_schema The schema to generate the scheduler job tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_scheduler_job_tests( p_like_job      IN VARCHAR2 DEFAULT '%'
                                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                       )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_related_user_tests
  * Generates the simple test scripts for a user list to be processed. User names will only be checked for user name and open account status.
  * Provides group (schema user) and name (schema user check) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_user_list The comma separated user list to generate the simple user tests for.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_related_user_tests( p_user_list     IN VARCHAR2 DEFAULT NULL
                                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                      , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                      )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_constraint_tests
  * Generates the test scripts for the constraints of a given table. Even if system objects are excluded, the generator will create
  * tests for system generated NOT NULL constraints, using all parameters apart the constraint name. Provides
  * group (constraints) and name (constraint type) management. Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get constraint tests for. Case sensitive.
  * @param p_like_constraints The like expression for the constraints to generate tests for. Can also be a specific constraint name. Case sensitive.
  * @param p_schema The schema to generate the constraint tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_constraint_tests( p_table            IN VARCHAR2
                                    , p_like_constraints IN VARCHAR2 DEFAULT '%'
                                    , p_schema           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                    , p_title_prefix     IN VARCHAR2 DEFAULT NULL
                                    , p_show_header      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    , p_excl_sysgen      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_index_tests
  * Generates the test scripts for the indexes of a given table. Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get index tests for. Case sensitive.
  * @param p_like_index The like expression for the indexes to generate tests for. Can also be a specific index name. Case sensitive.
  * @param p_schema The schema to generate the index tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_index_tests( p_table         IN VARCHAR2
                               , p_like_index    IN VARCHAR2 DEFAULT '%'
                               , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                               , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                               , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_type_tests
  * Generates the test scripts for the types of the given schema with the current available
  * otap schema functions. Provides name (types) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_type The like expression for the types to generate tests for. Can also be a specific type name. Case sensitive.
  * @param p_schema The schema to generate the type tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_type_tests( p_like_type     IN VARCHAR2 DEFAULT '%'
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_test.generate_sequence_tests
  * Generates the test scripts for the sequences of the given schema with the current available
  * otap schema functions. Provides name (sequences) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_sequence The like expression for the sequences to generate tests for. Can also be a specific sequence name. Case sensitive.
  * @param p_schema The schema to generate the sequence tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION generate_sequence_tests( p_like_sequence IN VARCHAR2 DEFAULT '%'
                                  , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                  , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                  , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                  )
    RETURN otap_view_result_tbl PIPELINED
  ;

END;
/
GRANT EXECUTE ON otap_test TO &OTAP_ROLE;