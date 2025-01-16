-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_test
AS
  -- for description see header file
  --========= package session variables =========--
  -- define private package sesstion variables and set defaults
  session_record OTAP_SESSION := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                             , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                             , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                             , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                             , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                             , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                             , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                             , 0
                                             , 0
                                             , FALSE
                                             , TRUE
                                             , FALSE
                                             , SYSDATE
                                             , 0
                                             , 0
                                             , 0
                                             )
  ;

  FUNCTION init_test( p_test_count      IN NUMBER   DEFAULT 0
                    , p_test_set        IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                    , p_test_group      IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                    , p_test_name       IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                    , p_prefix          IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
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
    otap_api.validate_otap(session_record);
    l_message := otap_api.init_test( NVL(p_test_count, 0)
                                   , NVL(p_test_set, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET)
                                   , NVL(p_test_group, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP)
                                   , NVL(p_test_name, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME)
                                   , NVL(p_prefix, otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX)
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
    otap_api.validate_otap(session_record);
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

  FUNCTION finish_test_with_exit_code(p_write_count_rec IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    otap_api.validate_otap(session_record);
    l_return := otap_api.finish_test_with_exit_code(p_write_count_rec, session_record);
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.finish_test_with_exit_code', 'l_message := otap_api.finish_test_with_exit_code(p_write_count_rec, session_record)');
      END IF;
      RAISE;
  END finish_test_with_exit_code;

  FUNCTION result_view(p_session_id IN NUMBER)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_text_column  VARCHAR2(4000 CHAR);
    CURSOR cur_report(cp_session_id IN NUMBER)
    IS
      SELECT result_text
           , result_errors
        FROM TABLE(otap_api.result_view(cp_session_id))
    ;
  BEGIN
    FOR rec IN cur_report(p_session_id)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, rec.result_errors));
    END LOOP;
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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

  FUNCTION set_active_report_id(p_report_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.set_active_report_id(p_report_id, session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.set_active_report_id', 'l_message := otap_api.set_active_report_id(p_report_id, session_record)');
      END IF;
      RAISE;
  END set_active_report_id;

  FUNCTION has_table( p_table_name      IN VARCHAR2
                    , p_schema          IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
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
    otap_api.validate_otap(session_record);
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
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_package(p_package_name, session_record, p_schema, p_description, p_package_type, p_expected_result);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_package', 'l_message := otap_api.has_package(p_package_name, session_record, ...');
      END IF;
      RAISE;
  END has_package;

  FUNCTION has_procedure( p_procedure_name  IN     VARCHAR2
                        , p_schema          IN     VARCHAR2 DEFAULT NULL
                        , p_description     IN     VARCHAR2 DEFAULT NULL
                        , p_procedure_type  IN     VARCHAR2 DEFAULT 'FUNCTION'
                        , p_package_name    IN     VARCHAR2 DEFAULT NULL
                        , p_return_type     IN     VARCHAR2 DEFAULT NULL
                        , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_procedure( p_procedure_name
                                       , session_record
                                       , p_schema
                                       , p_description
                                       , p_procedure_type
                                       , p_package_name
                                       , p_return_type
                                       , p_expected_result
                                       )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_procedure', 'l_message := otap_api.has_procedure(p_procedure_name, session_record, ...');
      END IF;
      RAISE;
  END has_procedure;

  FUNCTION has_trigger( p_trigger_name    IN     VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT NULL
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_type    IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_event   IN     VARCHAR2 DEFAULT NULL
                      , p_table_owner     IN     VARCHAR2 DEFAULT NULL
                      , p_table_name      IN     VARCHAR2 DEFAULT NULL
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_trigger( p_trigger_name
                                     , session_record
                                     , p_schema
                                     , p_description
                                     , p_trigger_type
                                     , p_trigger_event
                                     , p_table_owner
                                     , p_table_name
                                     , p_expected_result
                                     )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_trigger', 'l_message := otap_api.has_trigger( p_trigger_name, session_record, ...');
      END IF;
      RAISE;
  END has_trigger;

  FUNCTION has_object( p_object_name     IN     VARCHAR2
                     , p_object_type     IN     VARCHAR2
                     , p_schema          IN     VARCHAR2 DEFAULT NULL
                     , p_description     IN     VARCHAR2 DEFAULT NULL
                     , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_object( p_object_name
                                    , p_object_type
                                    , session_record
                                    , p_schema
                                    , p_description
                                    , p_expected_result
                                    )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_object', 'l_message := otap_api.has_object( p_object_name, p_object_type, ...');
      END IF;
      RAISE;
  END has_object;

  FUNCTION ok( p_boolean         IN     BOOLEAN
             , p_description     IN     VARCHAR2 DEFAULT NULL
             , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.ok( p_boolean
                            , session_record
                            , p_description
                            , p_expected_result
                            )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.ok', 'l_message := otap_api.ok( p_boolean, ...');
      END IF;
      RAISE;
  END ok;

  FUNCTION is_eq( p_have            IN     VARCHAR2
                , p_want            IN     VARCHAR2
                , p_description     IN     VARCHAR2 DEFAULT NULL
                , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.is_eq( p_have
                               , p_want
                               , session_record
                               , p_description
                               , p_expected_result
                               )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.is_eq', '(VARCHAR2) l_message := otap_api.is_eq( p_have, ...');
      END IF;
      RAISE;
  END is_eq;

  FUNCTION is_eq( p_have            IN     NUMBER
                , p_want            IN     NUMBER
                , p_description     IN     VARCHAR2 DEFAULT NULL
                , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.is_eq( p_have
                               , p_want
                               , session_record
                               , p_description
                               , p_expected_result
                               )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.is_eq', '(NUMBER) l_message := otap_api.is_eq( p_have, ...');
      END IF;
      RAISE;
  END is_eq;

  FUNCTION is_eq( p_have            IN     DATE
                , p_want            IN     DATE
                , p_description     IN     VARCHAR2 DEFAULT NULL
                , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.is_eq( p_have
                               , p_want
                               , session_record
                               , p_description
                               , p_expected_result
                               )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.is_eq', '(DATE) l_message := otap_api.is_eq( p_have, ...');
      END IF;
      RAISE;
  END is_eq;

  FUNCTION match_regex( p_have            IN     VARCHAR2
                      , p_regex           IN     VARCHAR2
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_param           IN     VARCHAR2 DEFAULT NULL
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.match_regex( p_have
                                     , p_regex
                                     , session_record
                                     , p_description
                                     , p_param
                                     , p_expected_result
                                     )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.match_regex', 'l_message := otap_api.match_regex( p_have, ...');
      END IF;
      RAISE;
  END match_regex;

  FUNCTION match_like( p_have            IN     VARCHAR2
                     , p_like            IN     VARCHAR2
                     , p_description     IN     VARCHAR2 DEFAULT NULL
                     , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.match_like( p_have
                                    , p_like
                                    , session_record
                                    , p_description
                                    , p_expected_result
                                    )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.match_like', 'l_message := otap_api.match_like( p_have, ...');
      END IF;
      RAISE;
  END match_like;

  -- debug function
  FUNCTION get_session_var
    RETURN OTAP_SESSION
  IS
  BEGIN
    RETURN session_record;
  END get_session_var;

END;
/