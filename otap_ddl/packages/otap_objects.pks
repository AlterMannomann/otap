-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides management functions and procedures for otap object types.
CREATE OR REPLACE PACKAGE otap_objects
AS
  /**
  * This package provides utility functions and procedures to handle OTAP_SESSION object.
  * Member functions do not work as expected and are far too limited.
  * This is no standalone package, it requires to be called by OTAP_TEST and other packages
  * which have a session_record from OTAP_TEST available.
  *
  * All procedures and functions verify the OTAP_SESSION object. No NULL allowed for any field.
  * They will throw the exception "-20099 Invalid OTAP_SESSION object" if the object is not valid.
  */

  /** PROCEDURE otap_objects.otap_session_verify
  * Verifies the OTAP_SESSION object and checks for NULL or 0 string length, no NULL values allowed.
  *
  * @param p_otap_session The OTAP_SESSION object to verify.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  PROCEDURE otap_session_verify(p_otap_session IN OTAP_SESSION);

  /** FUNCTION otap_objects.otap_session_show
  * Return the current package variables of OTAP_TEST as LF delimited text.
  *
  * @param p_otap_session The otap_session object from package OTAP_TEST.
  *
  * @return A text message, LF delimited, listing current settings of OTAP_SESSION object.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_show(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_objects.otap_session_set
  * Sets the package session variables of a valid OTAP_SESSION object. Errors will get logged.
  *
  * @param p_test_count The amount of tests expected to be executed when called.
  * @param p_test_set The name of the test set applied if the name of the executed test procedure or function does not provide a test set name or name precendence is disabled.
  * @param p_test_group The name of the test group applied if the name of the executed test procedure or function does not provide a test group name or name precendence is disabled.
  * @param p_test_name The name of the test name applied if the name of the executed test procedure or function does not provide a test name or name precendence is disabled.
  * @param p_prefix The prefix to use for identifying test functions and procedures. Limited to 4 chars. Test functions and procedures must have a trailing delimiter _ after the prefix to be identified.
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
  *
  * @exception -20099 ERROR otap_objects.otap_session_set. Invalid OTAP_SESSION initialization.
  */
  FUNCTION otap_session_set( p_test_count          IN            NUMBER
                           , p_test_set            IN            VARCHAR2
                           , p_test_group          IN            VARCHAR2
                           , p_test_name           IN            VARCHAR2
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

  /** FUNCTION otap_objects.otap_session_copy
  * Create a copy of the OTAP_SESSION object.
  *
  * @param p_otap_session The otap_session object from package OTAP_TEST.
  *
  * @return A copy of the OTAP_SESSION object.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_copy(p_otap_session IN OTAP_SESSION)
    RETURN OTAP_SESSION
  ;

  /** FUNCTION otap_objects.otap_session_set_test_set
  * Sets the current active test set. If test set name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_SET
  * is used.
  *
  * @param p_test_set The test set name to use for the next tests.
  * @param o_otap_session The current session_record from otap_test package.
  *
  * @return The test set currently active as text message.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_set_test_set( p_test_set     IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_objects.otap_session_set_test_group
  * Sets the current active test group. If test group name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_GROUP
  * is used.
  *
  * @param p_test_group The test group name to use for the next tests.
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @return The test group currently active as text message.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_set_test_group( p_test_group   IN            VARCHAR2
                                      , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_objects.otap_session_set_test_name
  * Sets the current active test. If test name is longer than 256 chars
  * it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_DEFAULT_TEST_NAME
  * is used.
  *
  * @param p_test_name The test name to use for the next tests.
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @return The test name currently active as text message.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_set_test_name( p_test_name    IN            VARCHAR2
                                     , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_objects.otap_session_get_test_id
  * Gets the current active test session id from OTAP_SESSION object.
  *
  * @param p_otap_session The current session_record from OTAP_TEST package.
  *
  * @return The current active test session id.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_get_test_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** FUNCTION otap_objects.otap_session_get_report_id
  * Gets the last view id if available or the current active test session id
  * from OTAP_SESSION object.
  *
  * @param p_otap_session The current session_record from OTAP_TEST package.
  *
  * @return The last view id if available or the current active test session id.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_get_report_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** PROCEDURE otap_objects.otap_session_add_test
  * Adds a test run to the OTAP_SESSION object. If the test is not passed, raises
  * the error count for this test session.
  *
  * @param p_test_passed The test state as defined in otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED and otap_constants.OTAP_NUM_TEST_UNDEFINED.
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  PROCEDURE otap_session_add_test( p_test_passed  IN            NUMBER
                                 , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                 )
  ;

  /** FUNCTION otap_objects.otap_session_summary
  * Gets a current summary from OTAP_SESSION object. Lists session id, session start, test runs and errors.
  *
  * @param p_otap_session The current session_record from OTAP_TEST package.
  *
  * @return The current test session summary as text.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_summary(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_objects.otap_session_finish
  * Resets the OTAP_SESSION object. Will set a new session id, reset the counters and the names
  * for test set, group and name. When a test session is finished, the test session view will not
  * longer show the tests from the old session.
  *
  * @param o_otap_session The current session_record from OTAP_TEST package.
  *
  * @return A summary of the old session and details of the new session as text message LF delimited.
  *
  * @exception -20099 Internal error, invalid OTAP_SESSION object.
  */
  FUNCTION otap_session_finish(o_otap_session IN OUT NOCOPY OTAP_SESSION)
    RETURN VARCHAR2
  ;

END;
/

