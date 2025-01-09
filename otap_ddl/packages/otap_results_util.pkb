-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_results_util
AS
  -- for description see header file

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
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script      VARCHAR2(256 CHAR) := 'otap_results_util.write_test_result';
    l_to_delete   NUMBER;
    l_test_passed NUMBER;
  BEGIN
    l_to_delete   := CASE
                       WHEN p_to_delete IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
                       THEN p_to_delete
                       ELSE otap_constants.OTAP_NUM_TRUE
                     END
    ;
    l_test_passed := CASE
                       WHEN p_test_passed IN (otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED)
                       THEN p_test_passed
                       ELSE otap_constants.OTAP_NUM_TEST_UNDEFINED
                     END
    ;
    INSERT INTO otap_results
      ( to_delete
      , test_passed
      , test_session_id
      , test_executor
      , test_set
      , db_user
      , db_schema
      , test_group
      , test_start
      , test_end
      , test_name
      , test_desc
      , test_errors
      ) VALUES ( l_to_delete
               , l_test_passed
               , p_test_session_id
               , p_test_executor
               , p_test_set
               , p_db_user
               , p_db_schema
               , p_test_group
               , p_test_start
               , p_test_end
               , p_test_name
               , p_test_desc
               , p_test_errors
               )
    ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'INSERT into otap_results');
      RAISE;
  END write_test_result;

  PROCEDURE result_cleanup
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script            VARCHAR2(256 CHAR) := 'otap_results_util.result_cleanup';
    l_delete_before     DATE;
    l_delete_start      DATE;
    l_delete_batch_size NUMBER;
    l_delete_delay      NUMBER;
    l_row_counter       NUMBER;
    l_processed         NUMBER;
    l_delete_msg        VARCHAR2(32767 CHAR);
    CURSOR cur_delete_tests(cp_delete_before IN DATE)
    IS
      SELECT *
        FROM otap_results
       WHERE test_run_date < cp_delete_before
         AND to_delete     = otap_constants.OTAP_NUM_TRUE
    ;
  BEGIN
    -- read config values before starting, values will not change until finished
    l_delete_start      := SYSDATE;
    l_delete_before     := TRUNC(SYSDATE - otap_config_util.preserve_days);
    l_delete_batch_size := otap_config_util.delete_batch_size;
    l_delete_delay      := otap_config_util.delete_delay;
    l_row_counter       := 0;
    l_processed         := 0;
    l_delete_msg        := 'Start delete with batch size ' || l_delete_batch_size || ', delay ' || l_delete_delay || ' seconds. Delete all marked records older than ' || TO_CHAR(l_delete_before, 'YYYY-MM-DD HH24:MI:SS') || '.';
    otap_log.log(l_delete_msg, l_script, 'Procedure start', 'OTAP_DEBUG');
    FOR rec IN cur_delete_tests(l_delete_before)
    LOOP
      IF l_row_counter >= l_delete_batch_size
      THEN
        l_delete_msg := 'Batch size reached, commit and wait. Processed records ' || l_processed || '.';
        otap_log.log(l_delete_msg, l_script, 'Batch size reached and wait', 'OTAP_DEBUG');
        -- commit the batch
        COMMIT;
        -- reset counter
        l_row_counter := 0;
        -- wait defined time
        DBMS_SESSION.SLEEP(l_delete_delay);
      END IF;
      DELETE FROM otap_results WHERE test_run_id = rec.test_run_id AND test_run_date = rec.test_run_date;
      l_row_counter := l_row_counter + 1;
      l_processed   := l_processed + 1;
    END LOOP;
    l_delete_msg := 'Processed ' || l_processed || ' records for delete. Started at ' || TO_CHAR(l_delete_start, 'YYYY-MM-DD HH24:MI:SS') || ' finished at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS');
    otap_log.log(l_delete_msg, l_script, 'Procedure end', 'OTAP_DEBUG');
    DBMS_OUTPUT.PUT_LINE(l_delete_msg);
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'DELETE FROM otap_results');
  END result_cleanup;

  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  IS
    l_result NUMBER;
  BEGIN
    -- use UNION not GREATEST to get a result in any case
    SELECT MAX(str_length) AS max_length
      INTO l_result
      FROM (SELECT otap_constants.get_otap_num_min_fill_length AS str_length FROM dual
             UNION ALL
            SELECT MAX(LENGTH(test_set)) FROM otap_results WHERE test_session_id = 1
             UNION ALL
            SELECT MAX(LENGTH(test_group)) FROM otap_results WHERE test_session_id = 1
             UNION ALL
            SELECT MAX(LENGTH(test_name)) FROM otap_results WHERE test_session_id = 1
             UNION ALL
            SELECT MAX(LENGTH(test_desc)) FROM otap_results WHERE test_session_id = 1
           )
    ;
    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_results_util.max_text_size', 'Get max text size for a given session id');
      RAISE;
  END max_text_size;

END;
/
