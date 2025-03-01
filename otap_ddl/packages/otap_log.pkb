-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_log
AS

  /** internal FUNCTION otap_log.debug_active
  * Returns the debug state, defined in OTAP_CONFIG. Can't log errors as log depends on
  * this function. Fail save.
  *
  * @return TRUE if DEBUG_MODE is set to 1 in OTAP_CONFIG, otherwise or on errors FALSE.
  */
  FUNCTION debug_active
    RETURN BOOLEAN
  IS
    l_debug_mode  VARCHAR2(1 CHAR);
    l_return      BOOLEAN;
  BEGIN
    l_return := FALSE;
    SELECT config_value INTO l_debug_mode FROM otap_config WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE;
    IF l_debug_mode = '1'
    THEN
      l_return := TRUE;
    END IF;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END debug_active;

  -- for description see header file
  PROCEDURE log( p_log_message  IN VARCHAR2
               , p_script       IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
               , p_statement    IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
               , p_identifier   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_ERROR
               )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_has_sperrorlog  NUMBER;
  BEGIN
    -- check which type of log
    IF    p_identifier IN (otap_constants.OTAP_INTERNAL_ERROR, otap_constants.OTAP_INTERNAL_WARNING)
       OR otap_log.debug_active
    THEN
      -- check if table exists
      SELECT COUNT(*) INTO l_has_sperrorlog FROM user_tables WHERE table_name = 'SPERRORLOG';
      IF l_has_sperrorlog = 1
      THEN
        INSERT INTO sperrorlog
          ( username
          , timestamp
          , script
          , identifier
          , message
          , statement
          )
          VALUES ( otap_constants.OTAP_INTERNAL_SCHEMA
                 , SYSTIMESTAMP
                 , p_script
                 , TRIM(SUBSTR(TRIM(p_identifier), 1, 256))
                 , p_log_message
                 , p_statement
                 )
        ;
        COMMIT;
      ELSE
        -- give some output even if no one will notice it
        DBMS_OUTPUT.PUT_LINE('No logging possible, SPERRORLOG table does not exist');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- explicitly do not care about log exceptions, application should fail otherwise
      -- logging is not critical for otap, only an option, usually not recommended to do
      -- it this way, give some output even if no one will notice it
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END log;

END;
/