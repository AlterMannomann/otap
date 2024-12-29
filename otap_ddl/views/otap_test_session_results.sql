-- experimenting

  WITH base AS
       (SELECT /*+MATERIALIZE*/
               ores.*
             , CASE WHEN test_errors IS NULL THEN otap_constants.get_otap_id_test_passed ELSE otap_constants.get_otap_id_test_failed END AS test_setup_num
          FROM otap_results ores
         WHERE ores.test_session_id = otap_test.get_session_id
         ORDER BY test_run_date
       )
     , details AS
       (SELECT otap_constants.translate_test_result(test_passed) AS status
             , test_desc
             , otap_constants.translate_test_result(test_setup_num) AS test_setup
             , test_run_date
             , test_set
             , test_group
             , test_name
             , test_executor
             , test_errors
             , test_session_id
             , test_passed
             , test_setup_num
          FROM base
       )
     , tset AS
       (SELECT test_set
             , COUNT(*) AS test_runs
             , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
             , SUM(CASE WHEN test_setup_num = -1 THEN 1 ELSE 0 END) AS setup_errors
          FROM base
         GROUP BY test_set
       )
     , tgroup AS
       (SELECT test_set
             , test_group
             , COUNT(*) AS test_runs
             , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
             , SUM(CASE WHEN test_setup_num = -1 THEN 1 ELSE 0 END) AS setup_errors
          FROM base
         GROUP BY test_set
                , test_group
       )
     , tname AS
       (SELECT test_set
             , test_group
             , test_name
             , COUNT(*) AS test_runs
             , SUM(CASE WHEN test_passed = -1 THEN 1 ELSE 0 END) AS test_errors
             , SUM(CASE WHEN test_setup_num = -1 THEN 1 ELSE 0 END) AS setup_errors
          FROM base
         GROUP BY test_set
                , test_group
                , test_name
       )
     , header AS
       (SELECT tset.test_set
             , tset.test_runs AS set_runs
             , tset.test_errors AS set_errors
             , tset.setup_errors AS set_setup_errors
             , tgroup.test_group
             , tgroup.test_runs AS group_runs
             , tgroup.test_errors AS group_errors
             , tgroup.setup_errors AS group_setup_errors
             , tname.test_name
             , tname.test_runs
             , tname.test_errors AS run_errors
             , tname.setup_errors AS setup_errors
          FROM tset
          LEFT OUTER JOIN tgroup
            ON tset.test_set = tgroup.test_set
          LEFT OUTER JOIN tname
            ON tgroup.test_set   = tname.test_set
           AND tgroup.test_group = tname.test_group
       )
SELECT *
  FROM header
;