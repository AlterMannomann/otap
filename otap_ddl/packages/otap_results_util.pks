-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides utility functions and procedures for table OTAP_RESULTS.
CREATE OR REPLACE PACKAGE otap_results_util
AS
  /**
  * Provides internal functions and procedures for OTAP_RESULTS.
  *
  * Package is not fail safe. Exceptions are raised after trying to log them.
  */

  /** PROCEDURE otap_results_util.write_test_result
  * Just persist the given values. Minimal handling of input. Invalid TO_DELETE
  * and TEST_PASSED will be set to the default. NULL values neither checked nor allowed
  * for parameters without default. May throw exceptions.
  *
  * @param p_to_delete A valid to delete value, either 0 or 1.
  * @param p_test_passed A valid test passed, either 0, -1 or 1.
  * @param p_test_session_id A valid current test session id.
  * @param p_test_executor A valid executor / session user name.
  * @param p_test_set The test set defined for the current test.
  * @param p_db_user The database user for this test.
  * @param p_db_schema The schema used for this test.
  * @param p_test_group The test group defined for the current test.
  * @param p_test_start The start of the test.
  * @param p_test_end The end of the test.
  * @param p_test_name The test name defined for the current test.
  * @param p_test_desc The test description of the current test.
  * @param p_test_errors Any errors during test execution, if any.
  */
  PROCEDURE write_test_result( p_to_delete         IN NUMBER
                             , p_test_passed       IN NUMBER
                             , p_test_session_id   IN NUMBER
                             , p_test_executor     IN VARCHAR2
                             , p_test_set          IN VARCHAR2
                             , p_db_user           IN VARCHAR2
                             , p_db_schema         IN VARCHAR2
                             , p_test_group        IN VARCHAR2
                             , p_test_start        IN TIMESTAMP
                             , p_test_end          IN TIMESTAMP
                             , p_test_name         IN VARCHAR2
                             , p_test_desc         IN VARCHAR2
                             , p_test_errors       IN VARCHAR2 DEFAULT NULL
                             )
  ;

  /** PROCEDURE otap_results_util.result_cleanup
  * Used for cleanup of the test results. Will run under scheduler job OTAP_MAINTENANCE every
  * day. Will use the current otap configuration in OTAP_CONFIG, where PRESERVE_DAYS defines
  * the days to keep test results, the DELETE_BATCH_SIZE defines the amount of rows to delete
  * before committing them and DELETE_DELAY the seconds to wait after a commit before deleting
  * more rows. Records must be marked for deletion. Provides debug logging if debug mode is
  * activated in OTAP_CONFIG.
  */
  PROCEDURE result_cleanup;

  /** FUNCTION otap_results_util.max_text_size
  * Determines the maximum size for a session id the text label test_set, test_group, test_name and test_description.
  * Used for report formatting. Error text is not considered as this might get huge.
  *
  * @param p_session_id A valid session id to get the maximum text size for.
  *
  * @return The maximum text size for the given session id or otap_constants.OTAP_NUM_MIN_FILL_LENGTH on errors.
  */
  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  ;

END;
/