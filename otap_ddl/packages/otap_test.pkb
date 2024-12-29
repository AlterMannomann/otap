-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_test
AS
  -- for description see header file
  --========= package session variables =========--
  -- define private package sesstion variables and set defaults
  session_record OTAP_SESSION := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                             , otap_constants.OTAP_DEFAULT_TEST_SET
                                             , otap_constants.OTAP_DEFAULT_TEST_GROUP
                                             , otap_constants.OTAP_DEFAULT_TEST_NAME
                                             , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                             , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                             , otap_constants.OTAP_DEFAULT_PREFIX
                                             , 0
                                             , 0
                                             , FALSE
                                             , TRUE
                                             , FALSE
                                             , SYSDATE
                                             , otap_test_session_seq.NEXTVAL
                                             , 0
                                             , 0
                                             )
  ;

  FUNCTION init_test( p_test_count      IN NUMBER   DEFAULT 0
                    , p_test_set        IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_SET
                    , p_test_group      IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_GROUP
                    , p_test_name       IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_NAME
                    , p_prefix          IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_PREFIX
                    , p_name_precedence IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                    , p_include_pkg     IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    , p_persist         IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    -- internal variables from caller environment DO NOT SET them explicitely
                    -- you may want to set p_schema, which is the default schema used for object searches
                    -- but schema test functions provide a schema override, so in general there is no need
                    -- for overwritting this value
                    -- currently no save way exists to get the correct values from inside a procedure of function
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_user            IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER')
                    , p_executor        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER')
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_plan.init_test( NVL(p_test_count, 0)
                                    , NVL(p_test_set, otap_constants.OTAP_DEFAULT_TEST_SET)
                                    , NVL(p_test_group, otap_constants.OTAP_DEFAULT_TEST_GROUP)
                                    , NVL(p_test_name, otap_constants.OTAP_DEFAULT_TEST_NAME)
                                    , NVL(p_prefix, otap_constants.OTAP_DEFAULT_PREFIX)
                                    , NVL(p_name_precedence, otap_constants.OTAP_NUM_TRUE)
                                    , NVL(p_include_pkg, otap_constants.OTAP_NUM_FALSE)
                                    , NVL(p_persist, otap_constants.OTAP_NUM_FALSE)
                                    , p_schema
                                    , p_user
                                    , p_executor
                                    , session_record
                                    )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.init_test', 'l_message := otap_plan.init_test( p_test_count ...');
      END IF;
      RAISE;
  END init_test;

  FUNCTION finish_test(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_plan.finish_test(p_write_count_rec, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.finish_test', 'l_message := otap_plan.finish_test(p_write_count_rec, session_record)');
      END IF;
      RAISE;
  END finish_test;

  FUNCTION result_view(p_session_id IN NUMBER)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_delim_updown VARCHAR2(1) := '=';
    l_delim_tests  VARCHAR2(1) := '-';
    l_text_column  VARCHAR2(4000);
    l_has_errors   INTEGER;
    l_has_records  INTEGER;
    CURSOR cur_test_sets(cp_session_id IN NUMBER)
    IS
      SELECT test_set
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM(TO_CHAR(((MAX(test_run_date) - MIN(test_run_date)) DAY TO SECOND))) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
       GROUP BY test_set
       ORDER BY MIN(test_run_date)
    ;
    CURSOR cur_test_groups( cp_session_id IN NUMBER
                          , cp_test_set   IN VARCHAR2
                          )
    IS
      SELECT test_group
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM(TO_CHAR(((MAX(test_run_date) - MIN(test_run_date)) DAY TO SECOND))) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
       GROUP BY test_group
       ORDER BY MIN(test_run_date)
    ;
    CURSOR cur_test_names( cp_session_id IN NUMBER
                         , cp_test_set   IN VARCHAR2
                         , cp_test_group IN VARCHAR2
                         )
    IS
      SELECT test_name
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM(TO_CHAR(((MAX(test_run_date) - MIN(test_run_date)) DAY TO SECOND))) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
         AND test_group      = cp_test_group
       GROUP BY test_name
       ORDER BY MIN(test_run_date)
    ;
    CURSOR cur_tests( cp_session_id IN NUMBER
                    , cp_test_set   IN VARCHAR2
                    , cp_test_group IN VARCHAR2
                    , cp_test_name  IN VARCHAR2
                    )
    IS
      SELECT test_desc
           , test_passed
           , TRIM(TO_CHAR(((test_end - test_start) DAY TO SECOND))) AS run_time
           , test_errors
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
         AND test_group      = cp_test_group
         AND test_name       = cp_test_name
       ORDER BY test_run_date
    ;
  BEGIN
    -- header row
    l_text_column := RPAD(l_delim_updown, 27, l_delim_updown) || ' OTAP test summary start ' || RPAD(l_delim_updown, 28, l_delim_updown);
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := 'Test session id: ' || p_session_id;
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    -- check for records
    SELECT COUNT(*) INTO l_has_records FROM otap_results WHERE test_session_id = p_session_id;
    IF l_has_records > 0
    THEN
      -- loop through the set
      FOR rec_set IN cur_test_sets(p_session_id)
      LOOP
        -- build the set
        l_text_column := rec_set.test_set || ' ' ||
                         'run time: ' || rec_set.run_time || ' (' ||
                         'runs: ' || TRIM(TO_CHAR(rec_set.test_runs)) || ' ' ||
                         'errors: ' || TRIM(TO_CHAR(rec_set.test_errors)) || ' ' ||
                         'issues: ' || TRIM(TO_CHAR(rec_set.setup_errors)) || ')'
        ;
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        -- loop through the group
        FOR rec_grp IN cur_test_groups(p_session_id, rec_set.test_set)
        LOOP
          -- build the group
          l_text_column := ' - ' || rec_grp.test_group || ' ' ||
                           'run time: ' || rec_grp.run_time || ' (' ||
                           'runs: ' || TRIM(TO_CHAR(rec_grp.test_runs)) || ' ' ||
                           'errors: ' || TRIM(TO_CHAR(rec_grp.test_errors)) || ' ' ||
                           'issues: ' || TRIM(TO_CHAR(rec_grp.setup_errors)) || ')'
          ;
          PIPE ROW (otap_view_result_rec(l_text_column, NULL));
          -- loop through the names
          FOR rec_nam IN cur_test_names(p_session_id, rec_set.test_set, rec_grp.test_group)
          LOOP
            -- build the name
            l_text_column := '  - ' || rec_nam.test_name || ' ' ||
                             'run time: ' || rec_nam.run_time || ' (' ||
                             'runs: ' || TRIM(TO_CHAR(rec_nam.test_runs)) || ' ' ||
                             'errors: ' || TRIM(TO_CHAR(rec_nam.test_errors)) || ' ' ||
                             'issues: ' || TRIM(TO_CHAR(rec_nam.setup_errors)) || ')'
            ;
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- build delimiter for tests
            l_text_column := RPAD(l_delim_tests, 20, l_delim_tests) || ' ' || rec_nam.test_name || ' test results ' || RPAD(l_delim_tests, 20, l_delim_tests);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- build header
            l_text_column := 'Result    Setup     Runtime             Test';
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            l_text_column := '--------- --------- ------------------- ----------------------------------------';
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- loop through the tests
            FOR rec_tst IN cur_tests(p_session_id, rec_set.test_set, rec_grp.test_group, rec_nam.test_name)
            LOOP
              l_text_column := RPAD(otap_constants.translate_test_result(rec_tst.test_passed), 10) ||
                               RPAD(CASE WHEN rec_tst.test_errors IS NULL THEN otap_constants.OTAP_CHAR_TEST_PASSED ELSE otap_constants.OTAP_CHAR_TEST_FAILED END, 10) ||
                               rec_tst.run_time || ' ' ||
                               TRIM(rec_tst.test_desc)
              ;
              PIPE ROW (otap_view_result_rec(l_text_column, rec_tst.test_errors));
            END LOOP;
            SELECT COUNT(*)
              INTO l_has_errors
              FROM otap_results
             WHERE test_session_id = p_session_id
               AND test_set        = rec_set.test_set
               AND test_group      = rec_grp.test_group
               AND test_name       = rec_nam.test_name
               AND test_errors    IS NOT NULL
            ;
            IF l_has_errors > 0
            THEN
              -- build error delimiter for tests
              l_text_column := RPAD(l_delim_tests, 20, l_delim_tests) || ' ' || rec_nam.test_name || ' test errors ' || RPAD(l_delim_tests, 20, l_delim_tests);
              PIPE ROW (otap_view_result_rec(l_text_column, NULL));
              FOR rec_tst IN cur_tests(p_session_id, rec_set.test_set, rec_grp.test_group, rec_nam.test_name)
              LOOP
                IF rec_tst.test_errors IS NOT NULL
                THEN
                  l_text_column := '- ' || TRIM(rec_tst.test_desc) || ': ' || REGEXP_REPLACE(rec_tst.test_errors, '\s{2,}', ' ');
                  PIPE ROW (otap_view_result_rec(l_text_column, rec_tst.test_errors));
                END IF;
              END LOOP;
            END IF;
            -- build end delimiter for tests
            l_text_column := RPAD(l_delim_tests, 20, l_delim_tests) || ' ' || rec_nam.test_name || ' test done ' || RPAD(l_delim_tests, 20, l_delim_tests);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
          END LOOP;
        END LOOP;
      END LOOP;
    ELSE
      l_text_column := 'NO_DATA - no tests found for test session id ' || p_session_id;
      PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    END IF;
    -- footer row
    l_text_column := RPAD(l_delim_updown, 28, l_delim_updown) || ' OTAP test summary end ' || RPAD(l_delim_updown, 29, l_delim_updown);
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.result_view', 'Unhandled exception otap_test.result_view');
      END IF;
      RAISE;
  END result_view;

  FUNCTION current_settings
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_show(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.current_settings', 'l_message := otap_objects.otap_session_show(session_record)');
      END IF;
      RAISE;
  END current_settings;

  FUNCTION current_summary
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_summary(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.current_summary', 'l_message := otap_objects.otap_session_summary(session_record)');
      END IF;
      RAISE;
  END current_summary;

  FUNCTION set_test_name(p_test_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_set_test_name(p_test_name, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_name', 'l_message := otap_objects.otap_session_set_test_name(p_test_name, session_record)');
      END IF;
      RAISE;
  END set_test_name;

  FUNCTION set_test_group(p_test_group IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_set_test_group(p_test_group, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_group', 'l_message := otap_objects.otap_session_set_test_group(p_test_group, session_record)');
      END IF;
      RAISE;
  END set_test_group;

  FUNCTION set_test_set(p_test_set IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_set_test_set(p_test_set, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_set', 'l_message := otap_objects.otap_session_set_test_set(p_test_set, session_record)');
      END IF;
      RAISE;
  END set_test_set;

  FUNCTION get_session_id
    RETURN NUMBER
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_objects.otap_session_get_test_id(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.get_session_id', 'l_message := otap_objects.otap_session_get_test_id(session_record)');
      END IF;
      RAISE;
  END get_session_id;

  FUNCTION has_table( p_table_name   IN            VARCHAR2
                    , p_schema       IN            VARCHAR2     DEFAULT NULL
                    , p_description  IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := otap_schema.has_table(p_table_name, session_record, p_schema, p_description);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.has_table', 'l_message := otap_schema.has_table(p_table_name, session_record, p_schema, p_description)');
      END IF;
      RAISE;
  END has_table;

END;
/