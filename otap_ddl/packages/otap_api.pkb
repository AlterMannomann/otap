-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_api
AS
  -- for description see header file
  PROCEDURE validate_otap(o_otap_session IN OUT NOCOPY OTAP_SESSION)
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.validate_otap';
    l_errors  INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO l_errors
      FROM dba_objects
     WHERE owner = otap_constants.get_otap_schema
       AND status != 'VALID'
    ;
    IF l_errors > 0
    THEN
      -- log the error
      otap_log.log('-20099 The otap system is not valid. INVALID objects exist. Ask your admin to fix the system before testing.', l_script);
      -- only direct testing could call this currently as table has a NOT NULL constraint
      RAISE_APPLICATION_ERROR(-20099, 'The otap system is not valid. INVALID objects exist. Ask your admin to fix the system before testing.');
    END IF;
    SELECT COUNT(*)
      INTO l_errors
      FROM dba_triggers
     WHERE owner = otap_constants.get_otap_schema
       AND status != 'ENABLED'
    ;
    IF l_errors > 0
    THEN
      -- log the error
      otap_log.log('-20099 The otap system is not valid. Triggers are not enabled. Ask your admin to fix the system before testing.', l_script);
      -- only direct testing could call this currently as table has a NOT NULL constraint
      RAISE_APPLICATION_ERROR(-20099, 'The otap system is not valid. Triggers are not enabled. Ask your admin to fix the system before testing.');
    END IF;
    SELECT COUNT(*)
      INTO l_errors
      FROM otap_translate
     WHERE TRIM(UPPER(otap_identifier)) IN (SELECT config_name FROM otap_config WHERE translatable = otap_constants.get_otap_num_false)
    ;
    IF l_errors > 0
    THEN
      -- log the error
      otap_log.log('-20099 The otap system is not valid. OTAP_TRANSLATE contains invalid entries. Ask your admin to fix the system before testing.', l_script);
      -- only direct testing could call this currently as table has a NOT NULL constraint
      RAISE_APPLICATION_ERROR(-20099, 'The otap system is not valid. OTAP_TRANSLATE contains invalid entries. Ask your admin to fix the system before testing.');
    END IF;
    -- if all passed, check the session id, if not set, fetch sequence next val for new user
    IF o_otap_session.session_id = 0
    THEN
      o_otap_session.session_id := otap_test_session_seq.NEXTVAL;
    END IF;
  END validate_otap;

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
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.init_test';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_plan.init_test(p_test_count, p_test_set, p_test_group, p_test_name, p_prefix, p_name_precedence, p_include_pkg, p_persist, p_schema, p_user, p_executor, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_plan.init_test');
        l_message := otap_string.reduce('Internal otap error init session variable: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END init_test;

  FUNCTION finish_test( p_write_count_rec IN            NUMBER
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.finish_test';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_plan.finish_test(p_write_count_rec, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_plan.finish_test');
        l_message := otap_string.reduce('Internal otap error finish test: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END finish_test;

  FUNCTION finish_test_with_exit_code( p_write_count_rec IN            NUMBER
                                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN NUMBER
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.finish_test_with_exit_code';
    l_return  INTEGER;
  BEGIN
    -- default undefined
    l_return := 2;
    BEGIN
      l_return := otap_plan.finish_test_with_exit_code(p_write_count_rec, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_plan.finish_test_with_exit_code');
        l_return := 2;
    END;
    -- return or let exception happen
    RETURN l_return;
  END finish_test_with_exit_code;

  FUNCTION otap_session_show(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_show';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_objects.otap_session_show(p_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_show');
        l_message := otap_string.reduce('Internal otap error session show: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END otap_session_show;

  FUNCTION otap_session_summary(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_summary';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_objects.otap_session_summary(p_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_summary');
        l_message := otap_string.reduce('Internal otap error session summary: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END otap_session_summary;

  FUNCTION otap_session_set_test_name( p_test_name    IN            VARCHAR2
                                     , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_set_test_name';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_objects.otap_session_set_test_name(p_test_name, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_set_test_name');
        l_message := otap_string.reduce('Internal otap error set test name: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END otap_session_set_test_name;

  FUNCTION otap_session_set_test_group( p_test_group   IN            VARCHAR2
                                      , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                      )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_objects.otap_session_set_test_group';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_objects.otap_session_set_test_group(p_test_group, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_set_test_group');
        l_message := otap_string.reduce('Internal otap error set group name: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END otap_session_set_test_group;

  FUNCTION otap_session_set_test_set( p_test_set     IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_set_test_set';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_objects.otap_session_set_test_set(p_test_set, o_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_set_test_set');
        l_message := otap_string.reduce('Internal otap error set test set name: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END otap_session_set_test_set;

  FUNCTION otap_session_get_test_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_get_test_id';
    l_return  NUMBER;
  BEGIN
    l_return := -1;
    -- execute the wrapped function in an extra block
    BEGIN
      l_return := otap_objects.otap_session_get_test_id(p_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_get_test_id');
        l_return := -1;
    END;
    -- return or let exception happen
    RETURN l_return;
  END otap_session_get_test_id;

  FUNCTION otap_session_get_report_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.otap_session_get_report_id';
    l_return  NUMBER;
  BEGIN
    l_return := -1;
    -- execute the wrapped function in an extra block
    BEGIN
      l_return := otap_objects.otap_session_get_report_id(p_otap_session);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_objects.otap_session_get_report_id');
        l_return := -1;
    END;
    -- return or let exception happen
    RETURN l_return;
  END otap_session_get_report_id;

  FUNCTION set_active_report_id( p_report_id    IN            NUMBER
                               , o_otap_session IN OUT NOCOPY OTAP_SESSION
                               )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.set_active_report_id';
    l_message VARCHAR2(4000);
    l_return  NUMBER;
    l_old_id  NUMBER;
    l_count   NUMBER;
  BEGIN
    l_return  := 0;
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      -- save the old id for compare
      l_old_id := otap_objects.otap_session_get_report_id(o_otap_session);
      IF l_old_id = p_report_id
      THEN
        -- nothing to do
        l_message := 'The report id ' || p_report_id || ' is currently active. No change.';
      ELSE
        -- check given id
        SELECT COUNT(*) INTO l_count FROM otap_results WHERE test_session_id = p_report_id;
        IF l_count > 0
        THEN
          l_return := otap_objects.otap_session_set_session_view_id(p_report_id, o_otap_session);
        ELSE
          otap_log.log('Invalid report id ' || p_report_id || ' does not exist in OTAP_RESULTS', l_script);
          l_return  := l_old_id;
          l_message := 'Report id ' || p_report_id || ' not found';
        END IF;
        IF l_return != l_old_id
        THEN
          l_message := 'New report id ' || l_return;
        ELSE
          l_message := 'ERROR report id ' || l_return || ' not changed. ' || l_message;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Checking and calling otap_objects.otap_session_set_session_view_id');
        l_message := otap_string.reduce('ERROR ' || l_script || ': ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END set_active_report_id;

  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  IS
    l_script    VARCHAR2(1024 CHAR) := 'otap_api.otap_session_get_test_id';
    l_return    NUMBER;
    l_interval  NUMBER;
  BEGIN
    l_return := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
    -- execute the wrapped function in an extra block
    BEGIN
      l_return := otap_util.max_text_size(p_session_id);
      -- now add the extra columns on the result line
      SELECT LENGTH(((SYSTIMESTAMP - SYSTIMESTAMP) DAY TO SECOND)) INTO l_interval FROM dual;
      l_return := l_return + l_interval + (2 * otap_util.get_length_test_state) + 3;
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_util.max_text_size');
        l_return := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
    END;
    -- return or let exception happen
    RETURN l_return;
  END max_text_size;

  FUNCTION get_report_header(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_report_header';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_report_header(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_report_header');
        l_message := otap_string.reduce('Internal otap error get report header: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_report_header;

  FUNCTION get_session_id_text( p_session_id IN NUMBER
                              , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                              )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_session_id_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_session_id_text(p_session_id, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_session_id_text');
        l_message := otap_string.reduce('Internal otap error get report session id text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_session_id_text;

  FUNCTION get_set_text( p_test_set IN VARCHAR2
                       , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                       )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_set_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_set_text(p_test_set, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_set_text');
        l_message := otap_string.reduce('Internal otap error get report test set text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_set_text;

  FUNCTION get_summary( p_runtime  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_runs     IN NUMBER   DEFAULT 0
                      , p_errors   IN NUMBER   DEFAULT 0
                      , p_issues   IN NUMBER   DEFAULT 0
                      , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                      )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_summary';
    l_message VARCHAR2(4000 CHAR);
    l_status  VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_status := CASE
                    WHEN p_issues > 0
                    THEN otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                    WHEN p_errors > 0 AND p_issues <= 0
                    THEN otap_constants.OTAP_FALLBACK_TEXT_TEST_FAILED
                    ELSE otap_constants.OTAP_FALLBACK_TEXT_TEST_PASSED
                  END
      ;
      l_message := otap_report.get_summary(l_status, p_runtime, p_runs, p_errors, p_issues, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_summary');
        l_message := otap_string.reduce('Internal otap error get report summary: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_summary;

  FUNCTION get_group_text( p_test_group IN VARCHAR2
                         , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                         )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_group_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_group_text(p_test_group, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_group_text');
        l_message := otap_string.reduce('Internal otap error get report group text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_group_text;

  FUNCTION get_test_name_text( p_test_name IN VARCHAR2
                             , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_test_name_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_test_name_text(p_test_name, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_test_name_text');
        l_message := otap_string.reduce('Internal otap error get report test name text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_test_name_text;

  FUNCTION get_result_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_result_header';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_result_header(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_result_header');
        l_message := otap_string.reduce('Internal otap error get result header: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_result_header;

  FUNCTION get_result_underline(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_result_underline';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_result_underline(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_result_underline');
        l_message := otap_string.reduce('Internal otap error get result underline: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_result_underline;

  FUNCTION get_result_line( p_test_state  IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_issue_state IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                          )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_result_line';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_result_line(p_test_state, p_issue_state, p_runtime, p_test_desc, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_result_line');
        l_message := otap_string.reduce('Internal otap error get result line: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_result_line;

  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.test_result_to_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_util.test_result_to_text(p_test_passed);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling  otap_util.test_result_to_text');
        l_message := otap_string.reduce('Internal otap error translate test result to text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END test_result_to_text;

  FUNCTION get_error_result_header( p_test_name IN VARCHAR2
                                  , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                  )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_error_result_header';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_error_result_header(p_test_name, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_error_result_header');
        l_message := otap_string.reduce('Internal otap error get error result header: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_error_result_header;

  FUNCTION get_error_details( p_test_desc  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_error_info IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_error_details';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_error_details(p_test_desc, p_error_info, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_error_details');
        l_message := otap_string.reduce('Internal otap error get error details: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_error_details;

  FUNCTION get_no_data_text( p_session_id IN NUMBER
                           , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_no_data_text';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_no_data_text(p_session_id, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_no_data_text');
        l_message := otap_string.reduce('Internal otap error get no data text: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_no_data_text;

  FUNCTION get_report_footer(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_report_footer';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_report_footer(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_report_footer');
        l_message := otap_string.reduce('Internal otap error get report footer: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_report_footer;

  FUNCTION flatten( p_string VARCHAR2 DEFAULT NULL
                  , p_size   INTEGER  DEFAULT 0
                  )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.flatten';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_string.flatten(p_string, p_size);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_string.flatten');
        l_message := otap_string.reduce('Internal otap error flatten string: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END flatten;

  FUNCTION get_text_test_count_name
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_text_test_count_name';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_NAME)');
        l_message := otap_string.reduce('Internal otap error get test count name: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_text_test_count_name;

  FUNCTION get_test_count_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_test_count_header';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_test_count_header(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_test_count_header');
        l_message := otap_string.reduce('Internal otap error get test count header: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_test_count_header;

  FUNCTION get_report_total(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_report_total';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_report_total(p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_report_total');
        l_message := otap_string.reduce('Internal otap error get total header: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_report_total;

  FUNCTION get_report_total_details( p_sets         IN INTEGER  DEFAULT 0
                                   , p_groups       IN INTEGER  DEFAULT 0
                                   , p_names        IN INTEGER  DEFAULT 0
                                   , p_descriptions IN INTEGER  DEFAULT 0
                                   , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                   )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_api.get_report_total_details';
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    l_message := otap_constants.OTAP_INTERNAL_ERROR;
    -- execute the wrapped function in an extra block
    BEGIN
      l_message := otap_report.get_report_total_details(p_sets, p_groups, p_names, p_descriptions, p_min_fill);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        otap_log.log(SQLERRM, l_script, 'Calling otap_report.get_report_total_details');
        l_message := otap_string.reduce('Internal otap error get total details: ' || SQLERRM, 4000);
    END;
    -- return or let exception happen
    RETURN l_message;
  END get_report_total_details;

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
    -- add AI and copyright
    l_text_column := LPAD(otap_constants.OTAP_INTERNAL_NAME, 59, ' ');
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := LPAD(otap_constants.OTAP_INTERNAL_VERSION_NR, 47, ' ');
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := otap_constants.OTAP_INTERNAL_COPYRIGHT1;
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := otap_constants.OTAP_INTERNAL_COPYRIGHT2;
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    l_text_column := otap_constants.OTAP_INTERNAL_COPYRIGHT3;
    PIPE ROW (otap_view_result_rec(l_text_column, NULL));
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_api.result_view', 'Unhandled exception otap_api.result_view');
      END IF;
      RAISE;
  END result_view;

  -- test functions

  FUNCTION has_table( p_table_name      IN            VARCHAR2
                    , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                    , p_schema          IN            VARCHAR2     DEFAULT NULL
                    , p_description     IN            VARCHAR2     DEFAULT NULL
                    , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_table';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => p_table_name
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.CFG_LABEL_TABLE
                                                                  , p_sub_object => NULL
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_table( p_table_name
                                         , l_errors
                                         , l_schema
                                         , p_expected_result
                                         )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_table;

  FUNCTION has_column( p_table_name      IN            VARCHAR2
                     , p_column_name     IN            VARCHAR2
                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                     , p_schema          IN            VARCHAR2     DEFAULT NULL
                     , p_description     IN            VARCHAR2     DEFAULT NULL
                     , p_data_type       IN            VARCHAR2     DEFAULT NULL
                     , p_data_length     IN            NUMBER       DEFAULT NULL
                     , p_data_precision  IN            NUMBER       DEFAULT NULL
                     , p_data_scale      IN            NUMBER       DEFAULT NULL
                     , p_nullable        IN            VARCHAR2     DEFAULT NULL
                     , p_data_default    IN            VARCHAR2     DEFAULT NULL
                     , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_column';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => p_table_name
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.CFG_LABEL_COLUMN
                                                                  , p_sub_object => p_column_name
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_column( p_table_name
                                          , p_column_name
                                          , l_errors
                                          , l_schema
                                          , p_data_type
                                          , p_data_length
                                          , p_data_precision
                                          , p_data_scale
                                          , p_nullable
                                          , p_data_default
                                          , p_expected_result
                                          )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_column;

  FUNCTION has_package( p_package_name    IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_schema          IN            VARCHAR2      DEFAULT NULL
                      , p_description     IN            VARCHAR2      DEFAULT NULL
                      , p_package_type    IN            VARCHAR2      DEFAULT 'PACKAGE'
                      , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_package';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => p_package_name
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.get_label_id(p_package_type)
                                                                  , p_sub_object => NULL
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_package( p_package_name
                                           , l_errors
                                           , l_schema
                                           , p_package_type
                                           , p_expected_result
                                           )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_package;

  FUNCTION has_procedure( p_procedure_name  IN            VARCHAR2
                        , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                        , p_schema          IN            VARCHAR2      DEFAULT NULL
                        , p_description     IN            VARCHAR2      DEFAULT NULL
                        , p_procedure_type  IN            VARCHAR2      DEFAULT 'FUNCTION'
                        , p_package_name    IN            VARCHAR2      DEFAULT NULL
                        , p_return_type     IN            VARCHAR2      DEFAULT NULL
                        , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_procedure';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        -- TODO get_label in otap_util only labels compared with value, search always upper as stored in db
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => NVL(p_package_name, p_procedure_name)
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.get_label_id(p_procedure_type)
                                                                  , p_sub_object => CASE WHEN p_package_name IS NOT NULL THEN p_procedure_name ELSE NULL END
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_procedure( p_procedure_name
                                             , l_errors
                                             , l_schema
                                             , p_procedure_type
                                             , p_package_name
                                             , p_return_type
                                             , p_expected_result
                                             )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_procedure;

  FUNCTION has_trigger( p_trigger_name    IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_schema          IN            VARCHAR2      DEFAULT NULL
                      , p_description     IN            VARCHAR2      DEFAULT NULL
                      , p_trigger_type    IN            VARCHAR2      DEFAULT NULL
                      , p_trigger_event   IN            VARCHAR2      DEFAULT NULL
                      , p_table_owner     IN            VARCHAR2      DEFAULT NULL
                      , p_table_name      IN            VARCHAR2      DEFAULT NULL
                      , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_trigger';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => p_trigger_name
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.CFG_LABEL_TRIGGER
                                                                  , p_sub_object => NULL
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_trigger( p_trigger_name
                                           , l_errors
                                           , l_schema
                                           , p_trigger_type
                                           , p_trigger_event
                                           , p_table_owner
                                           , p_table_name
                                           , p_expected_result
                                           )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_trigger;

  FUNCTION has_object( p_object_name     IN            VARCHAR2
                     , p_object_type     IN            VARCHAR2
                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                     , p_schema          IN            VARCHAR2     DEFAULT NULL
                     , p_description     IN            VARCHAR2     DEFAULT NULL
                     , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  IS
    l_script           VARCHAR2(1024 CHAR)                  := 'otap_api.has_object';
    l_start            TIMESTAMP;
    l_result           INTEGER;
    l_return           VARCHAR2(4000 CHAR);
    l_errors           otap_results.test_errors%TYPE;
    l_schema           otap_results.db_schema%TYPE;
    l_desc             otap_results.test_desc%TYPE;
    l_tmp_otap_session OTAP_SESSION;
  BEGIN
    l_start  := SYSTIMESTAMP;
    -- default return
    l_return := otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED) || ' ' || otap_constants.OTAP_INTERNAL_NA;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
        l_desc   := otap_string.reduce( otap_report.get_exists_msg( p_object_name => p_object_name
                                                                  , p_schema_name => l_schema
                                                                  , p_object_type => otap_util.get_label_id(p_object_type)
                                                                  , p_sub_object => NULL
                                                                  , p_desc => p_description
                                                                  )
                                      , 256
                                      )
        ;
        -- call function
        l_result := otap_schema.has_object( p_object_name
                                          , p_object_type
                                          , l_errors
                                          , l_schema
                                          , p_expected_result
                                          )
        ;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
      END;
      -- write result
      l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := otap_string.reduce('Internal error ' || l_script || ': ' || SQLERRM, 4000);
        otap_log.log(SQLERRM, l_script, 'Execute ' || l_script || ' function');
        -- try again
        l_return := otap_plan.write_test_result(l_desc, o_otap_session, l_schema, l_result, l_start, l_errors);
    END;
    -- return result or let exception happen
    RETURN l_return;
  END has_object;

END;
/