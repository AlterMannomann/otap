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
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.init_test( NVL(p_test_count, 0)
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
        otap_log.log(SQLERRM, 'otap_test.init_test', 'l_message := otap_api.init_test( p_test_count ...');
      END IF;
      RAISE;
  END init_test;

  FUNCTION finish_test(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.finish_test(p_write_count_rec, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.finish_test', 'l_message := otap_api.finish_test(p_write_count_rec, session_record)');
      END IF;
      RAISE;
  END finish_test;

  FUNCTION result_view(p_session_id IN NUMBER)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_delim_updown VARCHAR2(1 CHAR) := '=';
    l_delim_tests  VARCHAR2(1 CHAR) := '-';
    l_text_column  VARCHAR2(4000 CHAR);
    l_has_errors   INTEGER;
    l_has_records  INTEGER;
    l_report_size  INTEGER;
    CURSOR cur_test_sets(cp_session_id IN NUMBER)
    IS
      SELECT test_set
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM((MAX(test_end) - MIN(test_start)) DAY TO SECOND) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_name      != otap_api.get_text_test_count_name
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
           , TRIM((MAX(test_end) - MIN(test_start)) DAY TO SECOND) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
         AND test_name      != otap_api.get_text_test_count_name
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
           , TRIM((MAX(test_end) - MIN(test_start)) DAY TO SECOND) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
         AND test_group      = cp_test_group
         AND test_name      != otap_api.get_text_test_count_name
       GROUP BY test_name
       ORDER BY MIN(test_run_date)
    ;
    CURSOR cur_test_count(cp_session_id IN NUMBER)
    IS
      SELECT test_name
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM((MAX(test_end) - MIN(test_start)) DAY TO SECOND) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_name       = otap_api.get_text_test_count_name
       GROUP BY test_name
       ORDER BY MIN(test_run_date)
    ;
    CURSOR cur_session_total(cp_session_id IN NUMBER)
    IS
      SELECT test_session_id
           , COUNT(DISTINCT test_set) AS test_sets
           , COUNT(DISTINCT test_group) AS test_groups
           , COUNT(DISTINCT test_name) AS test_names
           , COUNT(DISTINCT test_desc) AS test_descs
           , COUNT(*) AS test_runs
           , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
           , SUM(CASE WHEN test_errors IS NOT NULL THEN 1 ELSE 0 END) AS setup_errors
           , TRIM((MAX(test_end) - MIN(test_start)) DAY TO SECOND) AS run_time
        FROM otap_results
       WHERE test_session_id = cp_session_id
             -- exclude optional extra total count test
         AND test_name      != otap_api.get_text_test_count_name
       GROUP BY test_session_id
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
           , otap_api.test_result_to_text(test_passed) AS test_state
           , TRIM(TO_CHAR(((test_end - test_start) DAY TO SECOND))) AS run_time
           , test_errors
           , otap_api.test_result_to_text(CASE WHEN test_errors IS NULL THEN 1 ELSE -1 END) AS issue_state
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_set        = cp_test_set
         AND test_group      = cp_test_group
         AND test_name       = cp_test_name
       ORDER BY test_run_date
    ;
    CURSOR cur_count_tests( cp_session_id IN NUMBER
                          , cp_test_name  IN VARCHAR2
                          )
    IS
      SELECT test_desc
           , test_passed
           , otap_api.test_result_to_text(test_passed) AS test_state
           , TRIM(TO_CHAR(((test_end - test_start) DAY TO SECOND))) AS run_time
           , test_errors
           , otap_api.test_result_to_text(CASE WHEN test_errors IS NULL THEN 1 ELSE -1 END) AS issue_state
        FROM otap_results
       WHERE test_session_id = cp_session_id
         AND test_name       = cp_test_name
       ORDER BY test_run_date
    ;
  BEGIN
    l_report_size := otap_api.max_text_size(p_session_id);
    -- header row
    l_text_column := otap_api.get_report_header(l_report_size);
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := otap_api.get_session_id_text(p_session_id, l_report_size);
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    -- check for records
    SELECT COUNT(*) INTO l_has_records FROM otap_results WHERE test_session_id = p_session_id;
    IF l_has_records > 0
    THEN
      -- loop through the set
      FOR rec_set IN cur_test_sets(p_session_id)
      LOOP
        -- build test set column
        l_text_column := otap_api.get_set_text(rec_set.test_set, l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        -- build test set summary
        l_text_column := otap_api.get_summary(rec_set.run_time, rec_set.test_runs, rec_set.test_errors, rec_set.setup_errors, l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        -- loop through the group
        FOR rec_grp IN cur_test_groups(p_session_id, rec_set.test_set)
        LOOP
          l_text_column := otap_api.get_group_text(rec_grp.test_group, l_report_size);
          PIPE ROW (otap_view_result_rec(l_text_column, NULL));
          -- build test set summary
          l_text_column := otap_api.get_summary(rec_grp.run_time, rec_grp.test_runs, rec_grp.test_errors, rec_grp.setup_errors, l_report_size);
          PIPE ROW (otap_view_result_rec(l_text_column, NULL));
          -- loop through the names
          FOR rec_nam IN cur_test_names(p_session_id, rec_set.test_set, rec_grp.test_group)
          LOOP
            l_text_column := otap_api.get_test_name_text(rec_nam.test_name, l_report_size);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- build test set summary
            l_text_column := otap_api.get_summary(rec_nam.run_time, rec_nam.test_runs, rec_nam.test_errors, rec_nam.setup_errors, l_report_size);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- build header
            l_text_column := otap_api.get_result_header(l_report_size);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            l_text_column := otap_api.get_result_underline(l_report_size);
            PIPE ROW (otap_view_result_rec(l_text_column, NULL));
            -- loop through the tests
            FOR rec_tst IN cur_tests(p_session_id, rec_set.test_set, rec_grp.test_group, rec_nam.test_name)
            LOOP
              l_text_column := otap_api.get_result_line(rec_tst.test_state, rec_tst.issue_state, rec_tst.run_time, rec_tst.test_desc, l_report_size);
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
              l_text_column := otap_api.get_error_result_header(rec_nam.test_name, l_report_size);
              PIPE ROW (otap_view_result_rec(l_text_column, NULL));
              FOR rec_tst IN cur_tests(p_session_id, rec_set.test_set, rec_grp.test_group, rec_nam.test_name)
              LOOP
                IF rec_tst.test_errors IS NOT NULL
                THEN
                  l_text_column := otap_api.get_error_details(rec_tst.test_desc, otap_api.flatten(rec_tst.test_errors, 4000), l_report_size);
                  PIPE ROW (otap_view_result_rec(l_text_column, rec_tst.test_errors));
                END IF;
              END LOOP;
            END IF;
          END LOOP;
        END LOOP;
      END LOOP;
      -- no loop through the test count if exists
      FOR rec IN cur_test_count(p_session_id)
      LOOP
        -- build header
        l_text_column := otap_api.get_test_count_header(l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        l_text_column := otap_api.get_summary(rec.run_time, rec.test_runs, rec.test_errors, rec.setup_errors, l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        -- build header
        l_text_column := otap_api.get_result_header(l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        l_text_column := otap_api.get_result_underline(l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        -- loop through the tests
        FOR rec_tst IN cur_count_tests(p_session_id, rec.test_name)
        LOOP
          l_text_column := otap_api.get_result_line(rec_tst.test_state, rec_tst.issue_state, rec_tst.run_time, rec_tst.test_desc, l_report_size);
          PIPE ROW (otap_view_result_rec(l_text_column, rec_tst.test_errors));
        END LOOP;
        SELECT COUNT(*)
          INTO l_has_errors
          FROM otap_results
         WHERE test_session_id = p_session_id
           AND test_name       = rec.test_name
           AND test_errors    IS NOT NULL
        ;
        IF l_has_errors > 0
        THEN
          -- build error delimiter for tests
          l_text_column := otap_api.get_error_result_header(rec.test_name, l_report_size);
          PIPE ROW (otap_view_result_rec(l_text_column, NULL));
          FOR rec_tst IN cur_count_tests(p_session_id, rec.test_name)
          LOOP
            IF rec_tst.test_errors IS NOT NULL
            THEN
              l_text_column := otap_api.get_error_details(rec_tst.test_desc, otap_api.flatten(rec_tst.test_errors, 4000), l_report_size);
              PIPE ROW (otap_view_result_rec(l_text_column, rec_tst.test_errors));
            END IF;
          END LOOP;
        END IF;
      END LOOP;
      -- eventually build the totals for the test session
      l_text_column := otap_api.get_report_total(l_report_size);
      PIPE ROW (otap_view_result_rec(l_text_column, NULL));
      FOR rec IN cur_session_total(p_session_id)
      LOOP
        l_text_column := otap_api.get_report_total_details(rec.test_sets, rec.test_groups, rec.test_names, rec.test_descs, l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
        l_text_column := otap_api.get_summary(rec.run_time, rec.test_runs, rec.test_errors, rec.setup_errors, l_report_size);
        PIPE ROW (otap_view_result_rec(l_text_column, NULL));
      END LOOP;
    ELSE
      l_text_column := otap_api.get_no_data_text(p_session_id, l_report_size);
      PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    END IF;
    -- footer row
    l_text_column := otap_api.get_report_footer(l_report_size);
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    -- add AI and copyrigth
    l_text_column := '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := 'and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := 'Not allowed to be used as AI training material without explicite permission.';
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.result_view', 'Unhandled exception otap_test.result_view');
      END IF;
      RAISE;
  END result_view;

  FUNCTION current_settings
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.otap_session_show(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.current_settings', 'l_message := otap_api.otap_session_show(session_record)');
      END IF;
      RAISE;
  END current_settings;

  FUNCTION current_summary
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.otap_session_summary(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.current_summary', 'l_message := otap_api.otap_session_summary(session_record)');
      END IF;
      RAISE;
  END current_summary;

  FUNCTION set_test_name(p_test_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.otap_session_set_test_name(p_test_name, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.set_test_name', 'l_message := otap_api.otap_session_set_test_name(p_test_name, session_record)');
      END IF;
      RAISE;
  END set_test_name;

  FUNCTION set_test_group(p_test_group IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.otap_session_set_test_group(p_test_group, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.set_test_group', 'l_message := otap_api.otap_session_set_test_group(p_test_group, session_record)');
      END IF;
      RAISE;
  END set_test_group;

  FUNCTION set_test_set(p_test_set IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.otap_session_set_test_set(p_test_set, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.set_test_set', 'l_message := otap_api.otap_session_set_test_set(p_test_set, session_record)');
      END IF;
      RAISE;
  END set_test_set;

  FUNCTION get_session_id
    RETURN NUMBER
  IS
    l_return NUMBER;
  BEGIN
    l_return := otap_api.otap_session_get_test_id(session_record);
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.get_session_id', 'l_message := otap_api.otap_session_get_test_id(session_record)');
      END IF;
      RAISE;
  END get_session_id;

  FUNCTION get_report_id
    RETURN NUMBER
  IS
    l_return NUMBER;
  BEGIN
    l_return := otap_api.otap_session_get_report_id(session_record);
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.get_report_id', 'l_message := otap_api.otap_session_get_report_id(session_record)');
      END IF;
      RAISE;
  END get_report_id;

  FUNCTION has_table( p_table_name      IN VARCHAR2
                    , p_schema          IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.has_table(p_table_name, session_record, p_schema, p_description, p_expected_result);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_table', 'l_message := otap_api.has_table(p_table_name, session_record, p_schema, p_description)');
      END IF;
      RAISE;
  END has_table;

  FUNCTION has_column( p_table_name      IN VARCHAR2
                     , p_column_name     IN VARCHAR2
                     , p_schema          IN VARCHAR2 DEFAULT NULL
                     , p_description     IN VARCHAR2 DEFAULT NULL
                     , p_data_type       IN VARCHAR2 DEFAULT NULL
                     , p_data_length     IN NUMBER   DEFAULT NULL
                     , p_data_precision  IN NUMBER   DEFAULT NULL
                     , p_data_scale      IN NUMBER   DEFAULT NULL
                     , p_nullable        IN VARCHAR2 DEFAULT NULL
                     , p_data_default    IN VARCHAR2 DEFAULT NULL
                     , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.has_column( p_table_name
                                    , p_column_name
                                    , session_record
                                    , p_schema
                                    , p_description
                                    , p_data_type
                                    , p_data_length
                                    , p_data_precision
                                    , p_data_scale
                                    , p_nullable
                                    , p_data_default
                                    , p_expected_result
                                    )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_column', 'l_message := otap_api.has_column(p_table_name, ...');
      END IF;
      RAISE;
  END has_column;

  FUNCTION has_package( p_package_name    IN     VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT NULL
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_package_type    IN     VARCHAR2 DEFAULT 'PACKAGE'
                      , p_package_state   IN     VARCHAR2 DEFAULT 'VALID'
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_api.has_package(p_package_name, session_record, p_schema, p_description, p_package_type, p_package_state, p_expected_result);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_package', 'l_message := otap_api.has_package(p_package_name, session_record, ...');
      END IF;
      RAISE;
  END has_package;


  -- debug function
  FUNCTION get_session_var
    RETURN OTAP_SESSION
  IS
  BEGIN
    RETURN session_record;
  END get_session_var;

END;
/