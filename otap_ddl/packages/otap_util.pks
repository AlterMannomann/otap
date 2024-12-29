-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides utility functions and procedures for otap.
CREATE OR REPLACE PACKAGE otap_util
AS
  /**
  * Provides internal functions and procedures for otap like logging, interface to OTAP_CONFIG and
  * others without a clear category. You need the schema owner to use this functions.
  */

  /** FUNCTION otap_util.debug_active
  * Returns the debug state, defined in OTAP_CONFIG. Can't log errors as log depends on
  * this function.
  *
  * @return TRUE if DEBUG_MODE is set to 1 in OTAP_CONFIG, otherwise or on errors FALSE.
  */
  FUNCTION debug_active
    RETURN BOOLEAN
  ;

  /** PROCEDURE otap_util.log
  * Writes a log message to SPERRORLOG which should be already available by setup. If the identifier
  * is not OTAP_ERROR the log output will only be stored, if OTAP_CONFIG DEBUG_MODE is set to 1.
  * User and timestamp are set by the procedure. Runs as autonomous transaction. If SPERRORLOG does
  * not exist, will do nothing. Do nothing on exceptions, just consume them.
  *
  * @param p_log_message The message to log in SPERRORLOG.
  * @param p_script The script, package or function that caused the message.
  * @param p_statement The statement that caused the message.
  * @param p_identifier The identifier in SPERRORLOG. If not OTAP_ERROR, message is logged only if debug mode is set.
  */
  PROCEDURE log( p_log_message  IN VARCHAR2
               , p_script       IN VARCHAR2 DEFAULT 'N/A'
               , p_statement    IN VARCHAR2 DEFAULT 'N/A'
               , p_identifier   IN VARCHAR2 DEFAULT 'OTAP_ERROR'
               )
  ;

  /** PROCEDURE otap_util.set_debug
  * Sets the debug state in OTAP_CONFIG. On errors debug state will be deactivated or
  * left unchanged.
  *
  * @param p_active The active (TRUE) or inactive debug state.
  */
  PROCEDURE set_debug(p_active IN BOOLEAN DEFAULT FALSE);

  /** FUNCTION otap_util.preserve_days
  * Returns the setting for PRESERVE_DAYS, defined in OTAP_CONFIG.
  *
  * @return The setting of PRESERVE_DAYS in OTAP_CONFIG or default 1 on errors.
  */
  FUNCTION preserve_days
    RETURN NUMBER
  ;

  /** PROCEDURE otap_util.set_preserve_days
  * Sets preserve days in OTAP_CONFIG. On errors preserve days will be set to default or
  * left unchanged. Allowed are values between 1 and 7 days.
  *
  * @param p_preserve_days The amount of days to preserve test results.
  */
  PROCEDURE set_preserve_days(p_preserve_days IN NUMBER DEFAULT 1);

  /** FUNCTION otap_util.delete_delay
  * Returns the setting for DELETE_DELAY, defined in OTAP_CONFIG.
  *
  * @return The setting of DELETE_DELAY in OTAP_CONFIG or default 10 on errors.
  */
  FUNCTION delete_delay
    RETURN NUMBER
  ;

  /** PROCEDURE otap_util.set_delete_delay
  * Sets delete delay seconds in OTAP_CONFIG. On errors delete delay will be set to default or
  * left unchanged. Allowed are values between 1 and 600 seconds.
  *
  * @param p_delete_delay The amount of seconds to wait between batch size deletes.
  */
  PROCEDURE set_delete_delay(p_delete_delay IN NUMBER DEFAULT 10);

  /** FUNCTION otap_util.delete_batch_size
  * Returns the setting for DELETE_BATCH_SIZE, defined in OTAP_CONFIG.
  *
  * @return The setting of DELETE_BATCH_SIZE in OTAP_CONFIG or default 1000 on errors.
  */
  FUNCTION delete_batch_size
    RETURN NUMBER
  ;

  /** PROCEDURE otap_util.set_delete_batch_size
  * Sets delete batch size in OTAP_CONFIG. On errors delete batch size will be set to default or
  * left unchanged. Allowed are values between 100 and 10000 rows to delete before commit.
  *
  * @param p_delete_batch_size The amount of rows to delete as batch before commit.
  */
  PROCEDURE set_delete_batch_size(p_delete_batch_size IN NUMBER DEFAULT 1000);

  /** PROCEDURE otap_util.result_cleanup
  * Used for cleanup of the test results. Will run under scheduler job OTAP_MAINTENANCE every
  * day. Will use the current otap configuration in OTAP_CONFIG, where PRESERVE_DAYS defines
  * the days to keep test results, the DELETE_BATCH_SIZE defines the amount of rows to delete
  * before committing them and DELETE_DELAY the seconds to wait after a commit before deleting
  * more rows. Records must be marked for deletion. Provides debug logging if debug mode is
  * activated in OTAP_CONFIG.
  */
  PROCEDURE result_cleanup;

  /** FUNCTION otap_util.format_test_result
  * Get a standard formatted string for test result and description.
  *
  * @param p_test_passed A valid test state identifier, as defined in otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED and otap_constants.OTAP_NUM_TEST_UNDEFINED.
  *
  * @return A formatted text string with text representation of test state and test description.
  */
  FUNCTION format_test_result( p_test_passed IN INTEGER
                             , p_description IN VARCHAR2
                             )
    RETURN VARCHAR2
  ;

END;
/