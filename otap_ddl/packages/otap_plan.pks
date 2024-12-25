-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- provides the pgTap plan and finish functionality to otap_test.
CREATE OR REPLACE PACKAGE otap_plan
AS

  /**
  * This package provides the functions used by the wrapper package otap_test for test
  * setup, name definitions and test maintenance.
  *
  * It is intended for package otap_test or packages which have an OTAP_SESSION object
  * from otap_test. Otherwise won't work as expected. Exceptions are raised, if not handled.
  *
  * -20099 Internal error, OTAP_SESSION object not valid. Details see specific error message.
  */

  /** PROCEDURE otap_plan.write_test_result
  * Writes the result of a test to OTAP_RESULTS. If OTAP_SESSION persist_test is set to FALSE
  * the TO_DELETE flag is set on insert. Will retrieve most of the details from the current
  * session_record given by OTAP_TEST package or the test function using this procedure.
  * Will fail the test, if p_test_passed is not valid.
  *
  * @param p_test_description The test description for a specific test. If missing, will generate Unspecified test x where x is a SCN number.
  * @param p_otap_session A valid OTAP_SESSION object to be used for the insert with details on the test category and scope.
  * @param p_test_passed A valid test passed ID, allowed values are otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED and otap_constants.OTAP_NUM_TEST_UNDEFINED.
  * @param p_test_errors Test error information limited to 4000 chars.
  */
  PROCEDURE write_test_result( p_test_description IN VARCHAR2
                             , p_otap_session     IN OTAP_SESSION
                             , p_test_passed      IN NUMBER
                             , p_test_errors      IN VARCHAR2     DEFAULT NULL
                             )
  ;

  /** PROCEDURE otap_plan.write_count_result
  * Checks if intended_count is set and writes a final test record about expected and executed tests.
  * Does nothing if OTAP_SESSION intended_count less or equal to 0.
  *
  * @param p_otap_session A valid OTAP_SESSION object to be used for test result insert.
  */
  PROCEDURE write_count_result(p_otap_session IN OTAP_SESSION);

  /** PROCEDURE otap_plan.verify_otap_session
  * Verifies the OTAP_SESSION object and checks for NULL or 0 string length, no NULL values allowed.
  * Recommended to be called before and after usage or manipulation of the object.
  *
  * @param p_otap_session The OTAP_SESSION object to verify.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  PROCEDURE verify_otap_session(p_otap_session IN OTAP_SESSION);

  /** FUNCTION otap_plan.current_test_set
  * Return the current package variables of otap_test as LF delimited text.
  *
  * @param p_otap_session The otap_session object from package OTAP_TEST.
  *
  * @return A text message, LF delimited, listing current settings of OTAP_SESSION object.
  */
  FUNCTION current_test_setting(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_plan.init_test
  * Provides the init_test functionality needed by otap_test and setting the package session variables.
  * Errors will get logged.
  *
  * @param p_test_count The amount of tests expected to be executed when called.
  * @param p_test_set The name of the test set applied if the name of the executed test procedure or function does not provide a test set name or name precendence is disabled.
  * @param p_test_group The name of the test group applied if the name of the executed test procedure or function does not provide a test group name or name precendence is disabled.
  * @param p_prefix The prefix to use for identifying test functions and procedures. Limited to 4 chars. Test functions and procedures must have a trailing delimiter _ after the prefix to be identified.
  * @param p_name_precedence Can disable the naming conventions for otap. If set to otap_constants.OTAP_NUM_FALSE, all tests will run under the defined test set and group, set by init_test.
  * @param p_include_pkg Can enable to search also packages and package procedures and functions that fit the naming convention with the given prefix, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_persist Can enable to persist the test results longer than the current default of PRESERVE_DAYS in OTAP_CONFIG, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_schema The current schema from caller environment as reported from otap_test.
  * @param p_user The current user from caller environment as reported from otap_test.
  * @param p_executor The session user from caller environment as reported from otap_test.
  * @param o_fallback_test_set The otap_test package variable session_fallback_test_set.
  * @param o_fallback_test_group The otap_test package variable session_fallback_test_group.
  * @param o_default_prefix The otap_test package variable session_default_prefix.
  * @param o_executor The otap_test package variable session_executor.
  * @param o_db_user The otap_test package variable session_db_user.
  * @param o_db_schema The otap_test package variable session_db_schema.
  * @param o_intended_test_count The otap_test package variable session_intended_test_count.
  * @param o_testname_precedence The otap_test package variable session_testname_precedence.
  * @param o_include_packages The otap_test package variable session_include_packages.
  * @param o_persist_tests The otap_test package variable session_persist_tests.
  *
  * @return The current test session settings as text LF delimited.
  */
  FUNCTION init_test( p_test_count          IN            NUMBER
                    , p_test_set            IN            VARCHAR2
                    , p_test_group          IN            VARCHAR2
                    , p_prefix              IN            VARCHAR2
                    , p_name_precedence     IN            NUMBER
                    , p_include_pkg         IN            NUMBER
                    , p_persist             IN            NUMBER
                    , p_schema              IN            VARCHAR2
                    , p_user                IN            VARCHAR2
                    , p_executor            IN            VARCHAR2
                    , o_otap_session        IN OUT NOCOPY OTAP_SESSION
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_plan.set_test_name
  * Handles and sets the current active test name. If test name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_NAME
  * is used.
  *
  * @param p_test_name The test name to use for the next test.
  * @param o_otap_session The current session_record from otap_test package.
  *
  * @return The test name currently active as text message.
  */
  FUNCTION set_test_name( p_test_name     IN            VARCHAR2
                        , o_otap_session  IN OUT NOCOPY OTAP_SESSION
                        )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_plan.set_test_group
  * Handles and sets the current active test group. If test group name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_GROUP
  * is used.
  *
  * @param p_test_group The test group name to use for the next tests.
  * @param o_otap_session The current session_record from otap_test package.
  *
  * @return The test group currently active as text message.
  */
  FUNCTION set_test_group( p_test_group    IN            VARCHAR2
                         , o_otap_session  IN OUT NOCOPY OTAP_SESSION
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_plan.set_test_set
  * Handles and sets the current active test set. If test set name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_SET
  * is used.
  *
  * @param p_test_set The test set name to use for the next tests.
  * @param o_otap_session The current session_record from otap_test package.
  *
  * @return The test set currently active as text message.
  */
  FUNCTION set_test_set( p_test_set     IN            VARCHAR2
                       , o_otap_session IN OUT NOCOPY OTAP_SESSION
                       )
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_plan.add_test
  * Add a test to current test count value in OTAP_SESSION object. Used by
  * otap test functions after executing a test.
  *
  * @param o_otap_session The otap_session object from package OTAP_TEST to modify.
  */
  PROCEDURE add_test(o_otap_session IN OUT NOCOPY OTAP_SESSION);

  FUNCTION format_test_result( p_test_passed IN INTEGER
                             , p_description IN VARCHAR2
                             )
    RETURN VARCHAR2
  ;
END;
/