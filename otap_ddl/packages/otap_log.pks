-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides utility functions and procedures for table OTAP_CONFIG.
CREATE OR REPLACE PACKAGE otap_log
AS
  /**
  * Provides logging functionality. Dependency on OTAP_CONFIG table for DEBUG_MODE. Other
  * functionality of OTAP_CONFIG table is provided in otap_config_util. Provided as internal
  * function not exposed to package header. Fail save implementation. Will do nothing apart
  * from DBMS_OUTPUT on exceptions and errors. Logging is not critical for otap.
  *
  * It is a simple and very reduced log using SPERRORLOG which should have been created by setup.
  */

  /** PROCEDURE otap_util.log
  * Writes a log message to SPERRORLOG which should be already available by setup. If the identifier
  * is not otap_constants.OTAP_ERROR_IDENTIFIER the log output will only be stored, if OTAP_CONFIG
  * DEBUG_MODE is set to 1. User and timestamp are set by the procedure. Runs as autonomous transaction.
  * If SPERRORLOG does not exist, will do nothing apart from DBMS_OUTPUT the exception.
  *
  * @param p_log_message The message to log in SPERRORLOG.
  * @param p_script The script, package or function that caused the message.
  * @param p_statement The statement that caused the message.
  * @param p_identifier The identifier in SPERRORLOG. If not otap_constants.OTAP_ERROR_IDENTIFIER, message is logged only if debug mode is set.
  */
  PROCEDURE log( p_log_message  IN VARCHAR2
               , p_script       IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
               , p_statement    IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
               , p_identifier   IN VARCHAR2 DEFAULT otap_constants.OTAP_ERROR_IDENTIFIER
               )
  ;

END;
/