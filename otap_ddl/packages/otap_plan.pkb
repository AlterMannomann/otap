-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_plan
AS
  -- for description see header file
  PROCEDURE write_test_result( p_test_description IN VARCHAR2
                             , p_otap_session     IN OTAP_SESSION
                             , p_test_passed      IN NUMBER
                             , p_test_start       IN TIMESTAMP
                             , p_test_end         IN TIMESTAMP
                             , p_test_errors      IN VARCHAR2
                             )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script            VARCHAR2(1024 CHAR) := 'otap_plan.write_test_result';
    l_test_passed       INTEGER;
    l_test_description  VARCHAR2(256 CHAR);
    l_errors            VARCHAR2(4000 CHAR);
    l_to_delete         INTEGER;
  BEGIN
    otap_objects.otap_session_verify(p_otap_session);
    IF LENGTH(TRIM(l_errors)) > 4000
    THEN
      l_errors := SUBSTR(TRIM(p_test_errors), 1, 4000);
    ELSE
      l_errors := TRIM(p_test_errors);
    END IF;
    IF p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)
    THEN
      l_test_passed := p_test_passed;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
      l_errors      := SUBSTR('Invalid test passed value: ' || p_test_passed || otap_constants.OTAP_LF || l_errors, 1, 4000);
      otap_log.log('ERROR The given value for test passed ' || p_test_passed || ' for test description ' || p_test_description || ' is not valid.', l_script, 'p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)');
    END IF;
    IF p_test_description IS NULL
    THEN
      l_test_description := 'Unspecified test ' || TIMESTAMP_TO_SCN(SYSTIMESTAMP);
      l_errors           := SUBSTR('Missing test description' || otap_constants.OTAP_LF || l_errors, 1, 4000);
    ELSE
      IF LENGTH(p_test_description) > 256
      THEN
        l_test_description := SUBSTR(TRIM(p_test_description), 1, 256);
        l_errors           := SUBSTR('Test description too long, cutted' || otap_constants.OTAP_LF || l_errors, 1, 4000);
      ELSE
        l_test_description := TRIM(p_test_description);
      END IF;
    END IF;
    -- set delete flag as stored
    l_to_delete := CASE WHEN p_otap_session.persist_test THEN otap_constants.OTAP_NUM_FALSE ELSE otap_constants.OTAP_NUM_TRUE END;
    -- ready to insert
    otap_results_util.write_test_result( l_to_delete
                                       , l_test_passed
                                       , p_otap_session.session_id
                                       , p_otap_session.test_executor
                                       , p_otap_session.test_set
                                       , p_otap_session.db_user
                                       , p_otap_session.db_schema
                                       , p_otap_session.test_group
                                       , p_test_start
                                       , p_test_end
                                       , p_otap_session.test_name
                                       , l_test_description
                                       , l_errors
                                       )
    ;
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
    l_end               TIMESTAMP;
    l_tmp_otap_session  OTAP_SESSION;
  BEGIN
    l_start := SYSTIMESTAMP;
    -- only write a record, if intended count is set, do nothing otherwise
    IF p_otap_session.intended_count > 0
    THEN
      l_test_passed      := CASE WHEN p_otap_session.test_count = p_otap_session.intended_count THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      l_test_description := otap_string.reduce(otap_report.get_count_desc(p_otap_session.test_count, p_otap_session.intended_count), 256);
      l_errors           := NULL;
      l_end              := SYSTIMESTAMP;
      l_tmp_otap_session := otap_objects.otap_session_copy(p_otap_session);
      l_tmp_otap_session.test_name := otap_config_util.get_text_test_count_name;
      otap_plan.write_test_result(l_test_description, l_tmp_otap_session, l_test_passed, l_start, l_end, l_errors);
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
      l_message := 'Closed test session summary' || otap_constants.OTAP_LF;
      l_message := l_message || otap_objects.otap_session_summary(o_otap_session) || otap_constants.OTAP_LF;
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
    l_like   := p_otap_session.test_prefix || '\' || otap_constants.OTAP_DEFAULT_DELIMITER || NVL(p_like_expression, '%');
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

END;
/