-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_util
AS
  -- for description see header file
  FUNCTION debug_active
    RETURN BOOLEAN
  IS
    l_debug_mode  VARCHAR2(1);
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

  PROCEDURE log( p_log_message  IN VARCHAR2
               , p_script       IN VARCHAR2 DEFAULT 'N/A'
               , p_statement    IN VARCHAR2 DEFAULT 'N/A'
               , p_identifier   IN VARCHAR2 DEFAULT 'OTAP_ERROR'
               )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_has_sperrorlog  NUMBER;
  BEGIN
    -- check which type of log
    IF    p_identifier = 'OTAP_ERROR'
       OR otap_util.debug_active
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
          VALUES ( otap_constants.OTAP_SCHEMA
                 , SYSTIMESTAMP
                 , p_script
                 , p_identifier
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

  PROCEDURE set_debug(p_active IN BOOLEAN DEFAULT FALSE)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_debug_state VARCHAR2(1);
  BEGIN
    l_debug_state := CASE WHEN p_active THEN '1' ELSE '0' END;
    UPDATE otap_config
       SET config_value = l_debug_state
     WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE
    ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.set_debug', 'UPDATE otap_config DEBUG_MODE');
  END set_debug;

  FUNCTION preserve_days
    RETURN NUMBER
  IS
    l_return NUMBER;
  BEGIN
    l_return := 1;
    SELECT TO_NUMBER(config_value) INTO l_return FROM otap_config WHERE config_name = otap_constants.OTAP_CFG_PRESERVE_DAYS;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.preserve_days', 'SELECT otap_config PRESERVE_DAYS');
      RETURN 1;
  END preserve_days;

  PROCEDURE set_preserve_days(p_preserve_days IN NUMBER DEFAULT 1)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_preserve_days VARCHAR2(1);
  BEGIN
    IF      p_preserve_days >= 1
       AND  p_preserve_days <= 7
    THEN
      l_preserve_days := TRIM(TO_CHAR(p_preserve_days));
      UPDATE otap_config
        SET config_value = l_preserve_days
      WHERE config_name = otap_constants.OTAP_CFG_PRESERVE_DAYS
      ;
      COMMIT;
    ELSE
      otap_util.log('Wrong amount of preserve days ' || p_preserve_days || ' only 1 - 7 allowed. Nothing changed.', 'otap_util.set_preserve_days', 'UPDATE otap_config PRESERVE_DAYS');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.set_preserve_days', 'UPDATE otap_config PRESERVE_DAYS');
  END set_preserve_days;

  FUNCTION delete_delay
    RETURN NUMBER
  IS
    l_return NUMBER;
  BEGIN
    l_return := 10;
    SELECT TO_NUMBER(config_value) INTO l_return FROM otap_config WHERE config_name = otap_constants.OTAP_CFG_DELETE_DELAY;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.delete_delay', 'SELECT otap_config DELETE_DELAY');
      RETURN 10;
  END delete_delay;

  PROCEDURE set_delete_delay(p_delete_delay IN NUMBER DEFAULT 10)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_delete_delay VARCHAR2(3);
  BEGIN
    IF      p_delete_delay >= 1
       AND  p_delete_delay <= 600
    THEN
      l_delete_delay := TRIM(TO_CHAR(p_delete_delay));
      UPDATE otap_config
        SET config_value = l_delete_delay
      WHERE config_name = otap_constants.OTAP_CFG_DELETE_DELAY
      ;
      COMMIT;
    ELSE
      otap_util.log('Wrong amount of delete delay seconds ' || p_delete_delay || ' only 1 - 600 allowed. Nothing changed.', 'otap_util.set_delete_delay', 'UPDATE otap_config DELETE_DAY');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.set_delete_delay', 'UPDATE otap_config DELETE_DELAY');
  END set_delete_delay;

  FUNCTION delete_batch_size
    RETURN NUMBER
  IS
    l_return NUMBER;
  BEGIN
    l_return := 1000;
    SELECT TO_NUMBER(config_value) INTO l_return FROM otap_config WHERE config_name = otap_constants.OTAP_CFG_DELETE_BATCH_SIZE;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.delete_batch_size', 'SELECT otap_config DELETE_BATCH_SIZE');
      RETURN 1000;
  END delete_batch_size;

  PROCEDURE set_delete_batch_size(p_delete_batch_size IN NUMBER DEFAULT 1000)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_delete_batch_size VARCHAR2(5);
  BEGIN
    IF      p_delete_batch_size >= 100
       AND  p_delete_batch_size <= 10000
    THEN
      l_delete_batch_size := TRIM(TO_CHAR(p_delete_batch_size));
      UPDATE otap_config
        SET config_value = l_delete_batch_size
      WHERE config_name = otap_constants.OTAP_CFG_DELETE_BATCH_SIZE
      ;
      COMMIT;
    ELSE
      otap_util.log('Wrong amount of delete batch size ' || p_delete_batch_size || ' only 100 - 10000 allowed. Nothing changed.', 'otap_util.set_delete_batch_size', 'UPDATE otap_config DELETE_BATCH_SIZE');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.set_delete_batch_size', 'UPDATE otap_config DELETE_BATCH_SIZE');
  END set_delete_batch_size;

  PROCEDURE result_cleanup
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_delete_before     DATE;
    l_delete_start      DATE;
    l_delete_batch_size NUMBER;
    l_delete_delay      NUMBER;
    l_row_counter       NUMBER;
    l_processed         NUMBER;
    l_delete_msg        VARCHAR2(32767);
    CURSOR cur_delete_tests(cp_delete_before IN DATE)
    IS
      SELECT *
        FROM otap_results
       WHERE otap_test_date < cp_delete_before
         AND to_delete      = otap_constants.OTAP_NUM_TRUE
    ;
  BEGIN
    -- read config values before starting, values will not change until finished
    l_delete_start      := SYSDATE;
    l_delete_before     := TRUNC(SYSDATE - otap_util.preserve_days);
    l_delete_batch_size := otap_util.delete_batch_size;
    l_delete_delay      := otap_util.delete_delay;
    l_row_counter       := 0;
    l_processed         := 0;
    l_delete_msg        := 'Start delete with batch size ' || l_delete_batch_size || ', delay ' || l_delete_delay || ' seconds. Delete all marked records older than ' || TO_CHAR(l_delete_before, 'YYYY-MM-DD HH24:MI:SS') || '.';
    otap_util.log(l_delete_msg, 'otap_util.result_cleanup', 'Procedure start', 'OTAP_DEBUG');
    FOR rec IN cur_delete_tests(l_delete_before)
    LOOP
      IF l_row_counter >= l_delete_batch_size
      THEN
        l_delete_msg := 'Batch size reached, commit and wait. Processed records ' || l_processed || '.';
        otap_util.log(l_delete_msg, 'otap_util.result_cleanup', 'Batch size reached and wait', 'OTAP_DEBUG');
        -- commit the batch
        COMMIT;
        -- reset counter
        l_row_counter := 0;
        -- wait defined time
        DBMS_SESSION.SLEEP(l_delete_delay);
      END IF;
      DELETE FROM otap_results WHERE otap_testrun_id = rec.otap_testrun_id AND otap_test_date = rec.otap_test_date;
      l_row_counter := l_row_counter + 1;
      l_processed   := l_processed + 1;
    END LOOP;
    l_delete_msg := 'Processed ' || l_processed || ' records for delete. Started at ' || TO_CHAR(l_delete_start, 'YYYY-MM-DD HH24:MI:SS') || ' finished at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS');
    otap_util.log(l_delete_msg, 'otap_util.result_cleanup', 'Procedure end', 'OTAP_DEBUG');
    DBMS_OUTPUT.PUT_LINE(l_delete_msg);
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_util.result_cleanup', 'DELETE FROM otap_results');
  END result_cleanup;

END;
/