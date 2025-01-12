-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_plan
AS
  -- for description see header file
  FUNCTION write_test_result( p_test_description IN            VARCHAR2
                            , o_otap_session     IN OUT NOCOPY OTAP_SESSION
                            , p_schema_used      IN            VARCHAR2
                            , p_test_passed      IN            NUMBER
                            , p_test_start       IN            TIMESTAMP
                            , p_test_errors      IN            VARCHAR2
                            )
    RETURN VARCHAR2
  IS
    l_script            VARCHAR2(1024 CHAR) := 'otap_plan.write_test_result';
    l_test_passed       INTEGER;
    l_test_description  VARCHAR2(256 CHAR);
    l_errors            VARCHAR2(4000 CHAR);
    l_to_delete         INTEGER;
    l_end               TIMESTAMP;
    l_return            VARCHAR2(4000 CHAR);
  BEGIN
    otap_objects.otap_session_verify(o_otap_session);
    IF LENGTH(TRIM(l_errors)) > 4000
    THEN
      l_errors := otap_string.reduce(p_test_errors, 4000);
    ELSE
      l_errors := TRIM(p_test_errors);
    END IF;
    IF p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)
    THEN
      l_test_passed := p_test_passed;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
      l_errors      := otap_string.reduce('Invalid test passed value: ' || p_test_passed || otap_constants.OTAP_INTERNAL_LF || l_errors, 4000);
      otap_log.log('ERROR The given value for test passed ' || p_test_passed || ' for test description ' || p_test_description || ' is not valid.', l_script, 'p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)');
    END IF;
    IF p_test_description IS NULL
    THEN
      l_test_description := 'Unspecified test ' || TIMESTAMP_TO_SCN(SYSTIMESTAMP);
      l_errors           := otap_string.reduce('Missing test description' || otap_constants.OTAP_INTERNAL_LF || l_errors, 4000);
    ELSE
      IF LENGTH(p_test_description) > 256
      THEN
        l_test_description := otap_string.reduce(p_test_description, 256);
        l_errors           := otap_string.reduce('Test description too long, cutted' || otap_constants.OTAP_INTERNAL_LF || l_errors, 4000);
      ELSE
        l_test_description := TRIM(p_test_description);
      END IF;
    END IF;
    -- set delete flag as stored
    l_to_delete := CASE WHEN o_otap_session.persist_test THEN otap_constants.OTAP_NUM_FALSE ELSE otap_constants.OTAP_NUM_TRUE END;
    l_end := SYSTIMESTAMP;
    -- ready to insert
    otap_util.write_test_result( l_to_delete
                               , l_test_passed
                               , o_otap_session.session_id
                               , o_otap_session.test_executor
                               , o_otap_session.test_set
                               , o_otap_session.db_user
                               , NVL(p_schema_used, o_otap_session.db_schema)
                               , o_otap_session.test_group
                               , p_test_start
                               , l_end
                               , o_otap_session.test_name
                               , l_test_description
                               , l_errors
                               )
    ;
    -- add test to session var
    otap_objects.otap_session_add_test(l_test_passed, o_otap_session);
    l_return := otap_string.reduce(otap_util.test_result_to_text(l_test_passed) || ' ' || l_test_description, 4000);
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END write_test_result;

  PROCEDURE write_count_result(p_otap_session IN OTAP_SESSION)
  IS
    l_script            VARCHAR2(1024 CHAR) := 'otap_plan.write_count_result';
    l_test_passed       INTEGER;
    l_test_description  VARCHAR2(256 CHAR);
    l_errors            VARCHAR2(4000 CHAR);
    l_start             TIMESTAMP;
    l_tmp_otap_session  OTAP_SESSION;
    l_return            VARCHAR2(4000 CHAR);
  BEGIN
    l_start := SYSTIMESTAMP;
    -- only write a record, if intended count is set, do nothing otherwise
    IF p_otap_session.intended_count > 0
    THEN
      l_test_passed      := CASE WHEN p_otap_session.test_count = p_otap_session.intended_count THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      l_test_description := otap_string.reduce(otap_report.get_count_desc(p_otap_session.test_count, p_otap_session.intended_count), 256);
      l_errors           := NULL;
      l_tmp_otap_session := otap_objects.otap_session_copy(p_otap_session);
      l_tmp_otap_session.test_name := otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_NAME);
      l_return := otap_plan.write_test_result(l_test_description, l_tmp_otap_session, NULL, l_test_passed, l_start, l_errors);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END write_count_result;

  FUNCTION init_test( p_test_count          IN            NUMBER
                    , p_test_set            IN            VARCHAR2
                    , p_test_group          IN            VARCHAR2
                    , p_test_name           IN            VARCHAR2
                    , p_prefix              IN            VARCHAR2
                    , p_name_precedence     IN            NUMBER
                    , p_include_pkg         IN            NUMBER
                    , p_persist             IN            NUMBER
                    , p_schema              IN            VARCHAR2
                    , p_user                IN            VARCHAR2
                    , p_executor            IN            VARCHAR2
                    , o_otap_session        IN OUT NOCOPY OTAP_SESSION
                    )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_plan.init_test';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    -- if test count is not 0 this is a reset, write a test count record, if intended count is set
    IF     o_otap_session.test_count      > 0
       AND (   o_otap_session.intended_count  > 0
            OR NVL(p_test_count, 0)           > 0
           )
    THEN
      -- write record with current values
      otap_plan.write_count_result(o_otap_session);
      l_message := 'Closed test session summary' || otap_constants.OTAP_INTERNAL_LF;
      l_message := l_message || otap_objects.otap_session_summary(o_otap_session) || otap_constants.OTAP_INTERNAL_LF;
    END IF;
    -- now start setting the new values
    l_message := l_message || otap_objects.otap_session_set( p_test_count
                                                           , p_test_set
                                                           , p_test_group
                                                           , p_test_name
                                                           , p_prefix
                                                           , p_name_precedence
                                                           , p_include_pkg
                                                           , p_persist
                                                           , p_schema
                                                           , p_user
                                                           , p_executor
                                                           , o_otap_session
                                                           )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END init_test;

  FUNCTION run_tests( p_like_expression   IN VARCHAR2 DEFAULT '%'
                    , p_schema_overwrite  IN VARCHAR2 DEFAULT NULL
                    , p_otap_session      IN OTAP_SESSION
                    )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_plan.run_tests';
    l_message VARCHAR2(4000 CHAR);
    l_schema  VARCHAR2(128 CHAR);
    l_like    VARCHAR2(256 CHAR);
    l_test    VARCHAR2(257 CHAR);
    CURSOR cur_tests_to_run( cp_schema IN VARCHAR2
                           , cp_like   IN VARCHAR2
                           )
    IS
      SELECT owner
           , object_name
        FROM dba_objects
       WHERE object_type    = 'PROCEDURE'
         AND owner          = cp_schema
         AND object_name LIKE cp_like ESCAPE '\'
    ;
  BEGIN
    l_schema := NVL(p_schema_overwrite, p_otap_session.db_schema);
    l_like   := p_otap_session.test_prefix || '\' || otap_constants.OTAP_INTERNAL_DELIMITER || NVL(p_like_expression, '%');
    -- loop over records found
    FOR rec IN cur_tests_to_run(l_schema, l_like)
    LOOP
      NULL;
    END LOOP;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END run_tests;

  FUNCTION finish_test( p_write_count_rec IN            NUMBER
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_plan.finish_test';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    IF p_write_count_rec = otap_constants.OTAP_NUM_TRUE
    THEN
      otap_plan.write_count_result(o_otap_session);
    END IF;
    l_message := otap_objects.otap_session_finish(o_otap_session);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END finish_test;

  FUNCTION finish_test_with_exit_code( p_write_count_rec IN            NUMBER
                                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN NUMBER
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_plan.finish_test_with_exit_code';
    l_message VARCHAR2(4000 CHAR);
    l_return  INTEGER;
  BEGIN
    IF p_write_count_rec = otap_constants.OTAP_NUM_TRUE
    THEN
      otap_plan.write_count_result(o_otap_session);
    END IF;
    -- check the test status of the current session before closing
      WITH trl AS
           (SELECT test_session_id
                 , CASE test_passed WHEN 1 THEN 0 WHEN -1 THEN 1 ELSE 2 END AS exit_code
              FROM otap_results
             WHERE test_session_id = o_otap_session.session_id
           )
    SELECT NVL(MAX(exit_code), 2)
      INTO l_return
      FROM trl
    ;
    -- finish the session
    l_message := otap_objects.otap_session_finish(o_otap_session);
    -- return exit code
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END finish_test_with_exit_code;

END;
/