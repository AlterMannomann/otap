-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
SELECT otap_test.set_test_name('Verify otap_util set/get intrusive') FROM dual;
-- extra block for set function
DECLARE
  l_return VARCHAR2(4000 CHAR);
  l_temp   VARCHAR2(4000 CHAR);
BEGIN
  -- get current prefix
  SELECT config_value
    INTO l_temp
    FROM otap_config
   WHERE config_name = otap_util.CFG_DEFAULT_PREFIX
  ;
  -- set default prefix
  otap_util.set_config_value(otap_util.CFG_DEFAULT_PREFIX, 'OTAP');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.set_config_value changing default prefix')
    INTO l_return
    FROM otap_config
   WHERE config_name  = otap_util.CFG_DEFAULT_PREFIX
     AND config_value = 'OTAP'
  ;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_DEFAULT_PREFIX), 'OTAP', 'otap_util.get_config_value get changed config value');
  -- reset value
  otap_util.set_config_value(otap_util.CFG_DEFAULT_PREFIX, l_temp);
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_DEFAULT_PREFIX), l_temp, 'otap_util.get_config_value get restored config value');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_UTIL set/get intrusive failed', 'otap_intrusive.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_UTIL set/get intrusive failed', SQLERRM);
END;
/
COLUMN ORG_LABEL_LAYOUT NEW_VAL ORG_LABEL_LAYOUT
SELECT config_value AS ORG_LABEL_LAYOUT FROM otap_config WHERE config_name = 'DEFAULT_LABEL_COLUMN';
COLUMN FIRST_LABEL_LAYOUT NEW_VAL FIRST_LABEL_LAYOUT
  WITH layouts AS
       (SELECT 'U' AS layout_label FROM dual
         UNION ALL
        SELECT 'I' AS layout_label FROM dual
         UNION ALL
        SELECT 'L' AS layout_label FROM dual
       )
     , nxt AS
       (SELECT layout_label
             , ROW_NUMBER() OVER (ORDER BY layout_label ASC) AS rn
          FROM layouts
         WHERE layout_label != '&ORG_LABEL_LAYOUT'
       )
SELECT layout_label AS FIRST_LABEL_LAYOUT
  FROM nxt
 WHERE rn = 1
;
COLUMN LAST_LABEL_LAYOUT NEW_VAL LAST_LABEL_LAYOUT
  WITH layouts AS
       (SELECT 'U' AS layout_label FROM dual
         UNION ALL
        SELECT 'I' AS layout_label FROM dual
         UNION ALL
        SELECT 'L' AS layout_label FROM dual
       )
     , nxt AS
       (SELECT layout_label
             , ROW_NUMBER() OVER (ORDER BY layout_label ASC) AS rn
          FROM layouts
         WHERE layout_label  != '&ORG_LABEL_LAYOUT'
       )
SELECT layout_label AS LAST_LABEL_LAYOUT
  FROM nxt
 WHERE rn = 2
;
SELECT otap_test.set_test_name('Verify otap_util label layout &FIRST_LABEL_LAYOUT. intrusive') FROM dual;
BEGIN
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, '&FIRST_LABEL_LAYOUT');
END;
/
@@otap_util_code.sql
SELECT otap_test.set_test_name('Verify otap_util label layout &LAST_LABEL_LAYOUT. intrusive') FROM dual;
BEGIN
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, '&LAST_LABEL_LAYOUT');
END;
/
@@otap_util_code.sql
BEGIN
  -- reset to original value
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, '&ORG_LABEL_LAYOUT');
END;
/
SELECT otap_test.set_test_name('Verify otap_util maintenance intrusive') FROM dual;
DECLARE
  l_return        VARCHAR2(4000 CHAR);
  l_decimal       CHAR(1 CHAR);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_translatable  NUMBER;
  l_label_style   VARCHAR2(1 CHAR);
  l_testing_id    NUMBER        := -1;
  l_batch_size    NUMBER;
  l_batches       NUMBER;
  l_curr_date     DATE;
  l_setup_start   TIMESTAMP;
  l_setup_end     TIMESTAMP;
  l_runtime       NUMBER;
  l_exists        INTEGER;
  l_enabled       VARCHAR2(10);
BEGIN
  -- ramp up result cleanup
  SELECT enabled
    INTO l_enabled
    FROM user_scheduler_jobs
   WHERE job_name = 'OTAP_MAINTENANCE'
  ;
  l_setup_start := SYSTIMESTAMP;
  IF l_enabled = 'TRUE'
  THEN
    -- disable job, if active
    DBMS_SCHEDULER.DISABLE(name => 'OTAP_MAINTENANCE', force => TRUE);
  END IF;
  -- get current old records waiting over max delete delay to determine batch size to fake
    WITH base AS
         (SELECT otap_util.get_config_number(otap_util.CFG_DELETE_BATCH_SIZE) AS batch_size
               , COUNT(*) AS to_delete_recs
            FROM otap_results
           WHERE test_run_date < TRUNC(SYSDATE - 7)
         )
  SELECT CASE
           WHEN to_delete_recs > batch_size
           THEN 0
           ELSE (batch_size - to_delete_recs) + 1
         END
    INTO l_batch_size
    FROM base
  ;
  -- create batch size +1 records with simulated testing session id
  FOR rec IN 1..l_batch_size
  LOOP
    otap_util.write_test_result(otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_TEST_PASSED, l_testing_id, NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);
  END LOOP;
  -- turn off trigger to be able set an older date
  EXECUTE IMMEDIATE 'ALTER TRIGGER otap_results_upd_trg DISABLE';
  -- update to a date old enough to beat highest possible value
  UPDATE otap_results
     SET to_delete       = otap_constants.OTAP_NUM_TRUE
       , deleted_by      = USER
       , test_run_date   = TRUNC(SYSDATE - 9)
   WHERE test_session_id = l_testing_id
  ;
  COMMIT;
  -- enable trigger again
  EXECUTE IMMEDIATE 'ALTER TRIGGER otap_results_upd_trg ENABLE';
  -- get amount of batches to execute, might be more than only the test records
  SELECT FLOOR(COUNT(*) / otap_util.get_config_number(otap_util.CFG_DELETE_BATCH_SIZE))
    INTO l_batches
    FROM otap_results
   WHERE to_delete      = otap_constants.OTAP_NUM_TRUE
     AND test_run_date <= TRUNC(SYSDATE - 7)
  ;
  -- set max preserve days
  otap_util.set_config_value(otap_util.CFG_PRESERVE_DAYS, '7');
  -- set debug to be able to control debug log messages
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, TRIM(TO_CHAR(otap_constants.OTAP_NUM_TRUE)));
  l_stamp  := SYSTIMESTAMP;
  -- run cleaunup, will delete all simulated session id records
  otap_util.result_cleanup;
  l_finish := SYSTIMESTAMP;
  -- disable debug mode again
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE)));
  l_setup_end := SYSTIMESTAMP;
  -- now check otap_results
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.result_cleanup verify delete')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
  ;
  -- verify debug messages
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.result_cleanup verify debug start log message')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Procedure start'
     AND message   LIKE 'Start delete with batch size%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  SELECT otap_test.is_eq(COUNT(*), l_batches, 'otap_util.result_cleanup verify debug batch messages')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Batch size reached and wait'
     AND message   LIKE 'Batch size reached, commit and wait. Processed records%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.result_cleanup verify debug end log message')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Procedure end'
     AND message   LIKE 'Processed%records for delete%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  -- time preparation diff seconds
  l_curr_date := SYSDATE;
  l_runtime   := l_curr_date + ((l_setup_end - l_setup_start) * 86400) - l_curr_date;
  l_return    := otap_test.ok(l_runtime < 60, 'otap_util.result_cleanup preparation performance seconds: ' || TO_CHAR(l_runtime, '90.09') || ' < 60');
  IF l_enabled = 'TRUE'
  THEN
    -- enable job again
    DBMS_SCHEDULER.ENABLE(name => 'OTAP_MAINTENANCE');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_UTIL maintenance intrusive failed', 'otap_intrusive.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_UTIL maintenance intrusive failed', SQLERRM);
END;
/
SELECT otap_test.set_test_name('Verify otap_util translate intrusive') FROM dual;
DECLARE
  l_return        VARCHAR2(4000 CHAR);
BEGIN
  -- test language cleanup before
  DELETE FROM otap_translate WHERE language_id = otap_constants.OTAP_TEST_LANGUAGE_ID;
  COMMIT;
  -- test language setup
  INSERT INTO otap_translate (otap_identifier, label_text, language_id) VALUES (otap_util.CFG_TEXT_TEST_PASSED, 'SUCCESS', otap_constants.OTAP_TEST_LANGUAGE_ID);
  INSERT INTO otap_translate (otap_identifier, label_text, language_id) VALUES ('I_DO_NOT_EXIST', 'No one will call me', otap_constants.OTAP_TEST_LANGUAGE_ID);
  COMMIT;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED), otap_constants.OTAP_FALLBACK_TEXT_TEST_PASSED, 'Verify default language for test passed');
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED, otap_constants.OTAP_TEST_LANGUAGE_ID), 'SUCCESS', 'Verify test language for test passed');
  l_return := otap_test.is_eq(otap_util.get_config_value('I_DO_NOT_EXIST'), otap_constants.OTAP_INTERNAL_ERROR, 'Verify invaild translate identifier not called');
  -- test language cleanup after
  DELETE FROM otap_translate WHERE language_id = otap_constants.OTAP_TEST_LANGUAGE_ID;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_UTIL translate intrusive failed', 'otap_intrusive.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_UTIL translate intrusive failed', SQLERRM);
END;
/