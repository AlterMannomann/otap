-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
SELECT otap_test.set_test_name('Verify otap_plan intrusive') FROM dual;
-- only test the parts of wrappers that are not tested already
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return        VARCHAR2(4000 CHAR);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_start         DATE;
  l_otap_session  OTAP_SESSION;
  l_alt_session   OTAP_SESSION;
  l_want          VARCHAR2(4000 CHAR);
  l_have          VARCHAR2(4000 CHAR);
  l_testing_id    NUMBER;
BEGIN
  -- use a negative session id for test writes
  l_testing_id := otap_test.get_session_id * -1;
  l_start      := SYSDATE;
  -- session object fake
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , 'otap_plan intrusive'
                                , 'otap_plan intrusive'
                                , 'otap_plan intrusive'
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , 'INTR'
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , l_start
                                , l_testing_id
                                , 0
                                , l_testing_id
                                )
  ;
  -- otap_plan.write_test_result
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result('Sample test', l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_PASSED, l_stamp, NULL);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check passed')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = 'Sample test'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result('Sample failed test', l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_FAILED, l_stamp, 'Failed');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check failed')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_FAILED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = 'Sample failed test'
     AND test_errors     = 'Failed'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_return := otap_test.ok((l_otap_session.test_count = 2 AND l_otap_session.error_count = 1), 'otap_plan.write_test_result check session var counts');
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result('Sample undefined test', l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_UNDEFINED, l_stamp, 'Undefined');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check undefined')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_UNDEFINED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = 'Sample undefined test'
     AND test_errors     = 'Undefined'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result(NULL, l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_PASSED, l_stamp, NULL);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check description fallback')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc    LIKE 'Unspecified test%'
     AND test_errors  LIKE 'Missing test description%'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result(RPAD('Oje', 300, 'a'), l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_PASSED, l_stamp, NULL);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check description too long')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = RPAD('Oje', 256, 'a')
     AND test_errors  LIKE 'Test description too long, cutted%'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result('Sample test wrong state', l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), 100, l_stamp, NULL);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check invalid test state')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_FAILED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = 'Sample test wrong state'
     AND test_errors  LIKE 'Invalid test passed value%'
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.write_test_result('Sample failed test', l_otap_session, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_FAILED, l_stamp, RPAD('Failed', 6000, 'a'));
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_test_result check error too long')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_FAILED
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_desc       = 'Sample failed test'
     AND test_errors     = RPAD('Failed', 4000, 'a')
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  -- write_count_result
  l_stamp  := SYSTIMESTAMP;
  otap_plan.write_count_result(l_otap_session);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_plan.write_count_result check no intended count')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  -- will create a failed count due tests run before
  l_otap_session.intended_count := 1;
  l_stamp  := SYSTIMESTAMP;
  otap_plan.write_count_result(l_otap_session);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_count_result check intended count failed')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_FAILED
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_otap_session.intended_count := 2;
  l_otap_session.test_count     := 1;
  l_otap_session.error_count    := 0;
  l_stamp  := SYSTIMESTAMP;
  otap_plan.write_count_result(l_otap_session);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.write_count_result check intended count match')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  -- init_test reset
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , 'otap_plan init'
                                , 'otap_plan init'
                                , 'otap_plan init'
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , 'INTR'
                                , otap_constants.OTAP_INTERNAL_NA
                                , 1
                                , 2
                                , FALSE
                                , TRUE
                                , FALSE
                                , l_start
                                , l_testing_id
                                , 0
                                , l_testing_id
                                )
  ;
  l_alt_session := otap_objects.otap_session_copy(l_otap_session);
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_plan.init_test( 10
                                 , 'otap_plan new'
                                 , 'otap_plan new'
                                 , 'otap_plan new'
                                 , 'NEW'
                                 , otap_constants.OTAP_INTERNAL_NA
                                 , NULL
                                 , NULL
                                 , NULL
                                 , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                 , SYS_CONTEXT('USERENV', 'SESSION_USER')
                                 , l_otap_session
                                 )
  ;
  l_finish := SYSTIMESTAMP;
  l_return := otap_test.alike(l_return, 'Closed test session summary%', otap_constants.OTAP_NUM_FALSE, 'otap_plan.init_test reset check return value');
  l_return := otap_test.ok((l_alt_session.session_id != l_otap_session.session_id), 'otap_plan.init_test reset check session id change');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_plan.init_test reset check intended count match')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;

EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_PLAN intrusive failed', 'otap_plan.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_PLAN intrusive failed', SQLERRM);
END;
/
