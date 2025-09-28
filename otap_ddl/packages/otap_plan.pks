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
  * It is a main for package otap_test or packages which have an OTAP_SESSION object
  * from otap_test. Otherwise won't work as expected. Exceptions are raised, if not handled.
  *
  * -20099 Internal error, OTAP_SESSION object not valid. Details see specific error message.
  */

  /** FUNCTION otap_plan.write_test_result
  * Writes the result of a test to OTAP_RESULTS. If OTAP_SESSION persist_test is set to FALSE
  * the TO_DELETE flag is set on insert. Will retrieve most of the details from the current
  * session_record given by OTAP_TEST package or the test function using this procedure.
  * Will fail the test, if p_test_passed is not valid. Adds a new test to the session variable
  * and returns the result as VARCHAR2 message. Defines the test end by being called.
  *
  * @param p_test_description The test description for a specific test. If missing, will generate Unspecified test x where x is a SCN number.
  * @param o_otap_session A valid OTAP_SESSION object to be used for update and the insert with details on the test category and scope.
  * @param p_used_schema The schema used for the test. May differ from session object.
  * @param p_test_passed A valid test passed ID, allowed values are otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED and otap_constants.OTAP_NUM_TEST_UNDEFINED.
  * @param p_test_start The timestamp of the test start, must be provided by test functions.
  * @param p_test_errors Test error information limited to 4000 chars.
  *
  * @return The result as message to display, limited to 4000 char.
  */
  FUNCTION write_test_result( p_test_description IN            VARCHAR2
                            , o_otap_session     IN OUT NOCOPY OTAP_SESSION
                            , p_schema_used      IN            VARCHAR2
                            , p_test_passed      IN            NUMBER
                            , p_test_start       IN            TIMESTAMP
                            , p_test_errors      IN            VARCHAR2
                            )
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_plan.write_count_result
  * Checks if intended_count is set and writes a final test record about expected and executed tests.
  * Does nothing if OTAP_SESSION intended_count less or equal to 0. This test is not counted within
  * the test count.
  *
  * @param o_otap_session A valid OTAP_SESSION object to be used for test result insert.
  */
  PROCEDURE write_count_result(o_otap_session IN OUT NOCOPY OTAP_SESSION);

  /** FUNCTION otap_plan.init_test
  * Provides the init_test functionality needed by otap_test and setting the package session variables.
  * Errors will get logged.
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
  * The following parameters are expected from OTAP_TEST package. Caller should not set this variables.
  * @param p_schema The current schema from caller environment as reported from otap_test.
  * @param p_user The current user from caller environment as reported from otap_test.
  * @param p_executor The session user from caller environment as reported from otap_test.
  * @param o_otap_session The OTAP_SESSION object to set.
  *
  * @return The current test session settings as text LF delimited.
  */
  FUNCTION init_test( p_test_count          IN            NUMBER
                    , p_test_set            IN            VARCHAR2
                    , p_test_group          IN            VARCHAR2
                    , p_test_name           IN            VARCHAR2
                    , p_prefix              IN            VARCHAR2
                    , p_language_id         IN            VARCHAR2
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

  /** FUNCTION otap_plan.finish_test
  * Resets the OTAP_SESSION object. Will set a new session id, reset the counters and the names
  * for test set, group and name. When a test session is finished, the test session view will not
  * longer show the tests from the old session. If intended count is set, a test record about
  * executed and expected tests is written.
  *
  * @param p_write_count_rec The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE.
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @return A summary of the old session and details of the new session as text message LF delimited.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION finish_test( p_write_count_rec IN            NUMBER
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.finish_test_with_exit_code
  * This function is for automation purposes. It translates and returns an exit code that can be uses in CMD and shell scripts
  * to handle reactions based on the output of a test session, e.g. if test is passed you don't need probably the test report. Or you want
  * your build to fail, if test is not passed.
  *
  * Equal to finish_test apart from the return value check and translation. Undefined overrules failed. If undefined is returned, also
  * failed tests may be contained in the current test report. If you finish a test session without any test run, the result is UNDEFINED.
  *
  * @param p_write_count_rec The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE.
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @return A positive integer as result. 0 = success, all tests passed. 1 = at least one test failed. 2 = at least one test undefined.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION finish_test_with_exit_code( p_write_count_rec IN            NUMBER
                                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN NUMBER
  ;

END;
/