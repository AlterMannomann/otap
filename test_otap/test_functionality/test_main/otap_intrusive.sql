-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Contains all tests that temporarily change data for testing. Do not use while other users run tests.

-- first gather all current values for later reset, use default language
COLUMN ORG_DEBUG_MODE NEW_VAL ORG_DEBUG_MODE
COLUMN ORG_DEFAULT_PREFIX NEW_VAL ORG_DEFAULT_PREFIX
COLUMN ORG_DEFAULT_LABEL_COLUMN NEW_VAL ORG_DEFAULT_LABEL_COLUMN
COLUMN ORG_DEFAULT_LANGUAGE NEW_VAL ORG_DEFAULT_LANGUAGE
COLUMN ORG_PRESERVE_DAYS NEW_VAL ORG_PRESERVE_DAYS
COLUMN ORG_MAINTENANCE_JOB NEW_VAL ORG_MAINTENANCE_JOB
SELECT otap_util.get_config_value('DEBUG_MODE')                                       AS ORG_DEBUG_MODE
     , otap_util.get_config_value('DEFAULT_PREFIX')                                   AS ORG_DEFAULT_PREFIX
     , otap_util.get_config_value('DEFAULT_LABEL_COLUMN')                             AS ORG_DEFAULT_LABEL_COLUMN
     , otap_util.get_config_value('DEFAULT_LANGUAGE')                                 AS ORG_DEFAULT_LANGUAGE
     , otap_util.get_config_value('PRESERVE_DAYS')                                    AS ORG_PRESERVE_DAYS
     , (SELECT enabled FROM user_scheduler_jobs WHERE job_name = 'OTAP_MAINTENANCE')  AS ORG_MAINTENANCE_JOB
  FROM dual
;

SELECT otap_test.set_test_name('Verify otap_log functionality intrusive') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
-- otap_log
DECLARE
  l_return VARCHAR2(4000);
  l_stamp  TIMESTAMP;
  l_debug  VARCHAR2(1);
BEGIN
  -- disable debug mode
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE)));
  l_stamp := SYSTIMESTAMP;
  otap_log.log(p_log_message => 'OTAP_TEST: Should not log with identifier not OTAP_ERROR/OTAP_WARNING', p_identifier => 'MY DEBUG');
  SELECT otap_test.is_eq(COUNT(*), 0, 'Check only error logging if not debug mode')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Should not log with identifier not OTAP_ERROR/OTAP_WARNING'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = 'MY DEBUG'
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  -- enable debug mode
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, TRIM(TO_CHAR(otap_constants.OTAP_NUM_TRUE)));
  otap_log.log(p_log_message => 'OTAP_TEST: Should log with identifier not OTAP_ERROR/OTAP_WARNING', p_identifier => 'MY DEBUG');
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check debug logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Should log with identifier not OTAP_ERROR/OTAP_WARNING'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = 'MY DEBUG'
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  -- reset change
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '&ORG_DEBUG_MODE');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_LOG intrusive failed', 'otap_intrusive.sql', SQLERRM);
    l_return := otap_test.ok(FALSE, 'Complete test block OTAP_LOG intrusive failed');
END;
/
-- otap_util
SELECT otap_test.set_test_name('Verify otap_util functionality intrusive') FROM dual;
DECLARE
  l_return        VARCHAR2(4000);
  l_decimal       CHAR(1);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_translatable  NUMBER;
  l_label_style   VARCHAR2(1);
  l_testing_id    NUMBER        := -1;
  l_batch_size    NUMBER;
  l_batches       NUMBER;
  l_curr_date     DATE;
  l_setup_start   TIMESTAMP;
  l_setup_end     TIMESTAMP;
  l_runtime       NUMBER;
  l_exists        INTEGER;
BEGIN
  -- disable debug mode
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE)));
  -- set default prefix
  otap_util.set_config_value(otap_util.CFG_DEFAULT_PREFIX, 'TEST');
  -- now test it
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_DEFAULT_PREFIX), 'TEST', 'otap_util.get_config_value get config value prefix as text');
  l_return := otap_test.is_eq(otap_util.get_config_number(otap_constants.OTAP_CFG_DEBUG_MODE), 0, 'otap_util.get_config_number get config value debug mode as number');
  -- reset default prefix, leave debug mode off for now
  otap_util.set_config_value(otap_util.CFG_DEFAULT_PREFIX, '&ORG_DEFAULT_PREFIX');
  -- set the lower layout configuration temporarily and test this configuration
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, otap_constants.OTAP_LABEL_LOWER);
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'boolean', 'otap_util.get_config_value label as text format lower');
  -- set the upper layout configuration temporarily and test this configuration
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, otap_constants.OTAP_LABEL_UPPER);
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'BOOLEAN', 'otap_util.get_config_value label as text format upper');
  -- set the initial capitals layout configuration temporarily and test this configuration
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, otap_constants.OTAP_LABEL_INIT_CAP);
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'Boolean', 'otap_util.get_config_value label as text format initial capitals');
  -- restore the original value
  otap_util.set_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, '&ORG_DEFAULT_LABEL_COLUMN');

  -- ramp up result cleanup
  l_setup_start := SYSTIMESTAMP;
  IF '&ORG_MAINTENANCE_JOB' = 'TRUE'
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
  -- reset preserve days
  otap_util.set_config_value(otap_util.CFG_PRESERVE_DAYS, '&ORG_PRESERVE_DAYS');
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
  IF '&ORG_MAINTENANCE_JOB' = 'TRUE'
  THEN
    -- enable job again
    DBMS_SCHEDULER.ENABLE(name => 'OTAP_MAINTENANCE');
  END IF;
  -- reset debug mode
  otap_util.set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '&ORG_DEBUG_MODE');
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
    otap_log.log('Test block OTAP_UTIL intrusive failed', 'otap_intrusive.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_UTIL intrusive failed', SQLERRM);
END;
/
/*
SELECT otap_test.set_test_name('Verify otap_report functionality intrusive') FROM dual;
DECLARE
  l_return      VARCHAR2(4000);
  l_stamp       TIMESTAMP;
  l_finish      TIMESTAMP;
  l_layout_bkp  VARCHAR2(4000);
  l_border_bkp  VARCHAR2(4000);
BEGIN
  -- otap_report uses configured values, get current values and build non intrusive tests on the current values
  l_layout_bkp := otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT);
  l_border_bkp := otap_util.get_config_value(otap_util.CFG_DEFAULT_BORDER);
  -- set defined defaults
  UPDATE otap_config SET config_value = otap_constants.OTAP_LAYOUT_MIDDLE WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(NULL, NULL, '-')
                             , RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-')
                             , 'otap_report.decorate NULL parameter'
                             )
  ;
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 120, '-'), RPAD('-', 120, '-'), 'otap_report.decorate NULL parameter respect min length');
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 150, '*'), RPAD('*', 150, '*'), 'otap_report.decorate NULL parameter respect min length and decoration');
  l_return := otap_test.is_eq( otap_report.decorate(NULL, 60, '-')
                             , RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-')
                             , 'otap_report.decorate NULL parameter guarantee otap min length'
                             )
  ;
  l_return := otap_test.is_eq(otap_report.decorate('test', 80, '-'), (LPAD(' ', 38, '-') || 'test' || RPAD(' ', 38, '-')), 'otap_report.decorate even short title length');
  l_return := otap_test.is_eq(otap_report.decorate('teste', 80, '-'), (LPAD(' ', 37, '-') || 'teste' || RPAD(' ', 38, '-')), 'otap_report.decorate uneven short title length');
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER, '-') || RPAD('test', 3990, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER, '-'))
                             , 'otap_report.decorate overflow and border default'
                             )
  ;
  -- set border to minimum
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER_MIN)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MIN, '-') || RPAD('test', 3996, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MIN, '-'))
                             , 'otap_report.decorate overflow and border min'
                             )
  ;
  -- set border to maximum
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER_MAX)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MAX, '-') || RPAD('test', 3980, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MAX, '-'))
                             , 'otap_report.decorate overflow and border max'
                             )
  ;
  -- reset defaults
  UPDATE otap_config SET config_value = l_layout_bkp WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
  UPDATE otap_config SET config_value = l_border_bkp WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- try reset defaults
    UPDATE otap_config SET config_value = l_layout_bkp WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
    UPDATE otap_config SET config_value = l_border_bkp WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
    COMMIT;
    otap_log.log('Test block OTAP_REPORT failed', 'otap_report.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_REPORT failed', SQLERRM);
END;
/

*/