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

  FUNCTION has_constraint( p_table_name      IN VARCHAR2
                         , p_constraint_type IN VARCHAR2 DEFAULT 'C'
                         , p_column_name     IN VARCHAR2 DEFAULT NULL
                         , p_constraint      IN VARCHAR2 DEFAULT NULL
                         , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_description     IN VARCHAR2 DEFAULT NULL
                         , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_constraint( p_table_name
                                        , session_record
                                        , p_constraint_type
                                        , p_column_name
                                        , p_constraint
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
        otap_log.log(SQLERRM, 'otap_test.has_constraint', 'l_message := otap_api.has_constraint( p_table_name, ...');
      END IF;
      RAISE;
  END has_constraint;

  FUNCTION has_ref_constraint( p_table_name      IN VARCHAR2
                             , p_constraint_type IN VARCHAR2 DEFAULT 'R'
                             , p_column_name     IN VARCHAR2 DEFAULT NULL
                             , p_constraint      IN VARCHAR2 DEFAULT NULL
                             , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                             , p_r_table_name    IN VARCHAR2 DEFAULT NULL
                             , p_r_column_name   IN VARCHAR2 DEFAULT NULL
                             , p_r_constraint    IN VARCHAR2 DEFAULT NULL
                             , p_r_schema        IN VARCHAR2 DEFAULT NULL
                             , p_description     IN VARCHAR2 DEFAULT NULL
                             , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                             )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_ref_constraint( p_table_name
                                            , session_record
                                            , p_constraint_type
                                            , p_column_name
                                            , p_constraint
                                            , p_schema
                                            , p_r_table_name
                                            , p_r_column_name
                                            , p_r_constraint
                                            , p_r_schema
                                            , p_description
                                            , p_expected_result
                                            )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_ref_constraint', 'l_message := otap_api.has_ref_constraint( p_table_name, ...');
      END IF;
      RAISE;
  END has_ref_constraint;

  FUNCTION has_not_null_constraint( p_table_name      IN VARCHAR2
                                  , p_column_name     IN VARCHAR2
                                  , p_constraint      IN VARCHAR2 DEFAULT NULL
                                  , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_description     IN VARCHAR2 DEFAULT NULL
                                  , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                                  )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_not_null_constraint( p_table_name
                                                 , p_column_name
                                                 , session_record
                                                 , p_constraint
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
        otap_log.log(SQLERRM, 'otap_test.has_not_null_constraint', 'l_message := otap_api.has_not_null_constraint( p_table_name, ...');
      END IF;
      RAISE;
  END has_not_null_constraint;

  FUNCTION has_index( p_table_name      IN VARCHAR2
                    , p_column_name     IN VARCHAR2 DEFAULT NULL
                    , p_index_name      IN VARCHAR2 DEFAULT NULL
                    , p_index_type      IN VARCHAR2 DEFAULT NULL
                    , p_table_type      IN VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN VARCHAR2 DEFAULT NULL
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_index( p_table_name
                                   , session_record
                                   , p_column_name
                                   , p_index_name
                                   , p_index_type
                                   , p_table_type
                                   , p_uniqueness
                                   , p_tablespace_name
                                   , p_partitioned
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
        otap_log.log(SQLERRM, 'otap_test.has_index', 'l_message := otap_api.has_index( p_table_name, ...');
      END IF;
      RAISE;
  END has_index;

  FUNCTION has_type( p_type_name       IN VARCHAR2
                   , p_typecode        IN VARCHAR2 DEFAULT NULL
                   , p_attributes      IN NUMBER   DEFAULT NULL
                   , p_methods         IN NUMBER   DEFAULT NULL
                   , p_predefined      IN VARCHAR2 DEFAULT NULL
                   , p_incomplete      IN VARCHAR2 DEFAULT NULL
                   , p_final           IN VARCHAR2 DEFAULT NULL
                   , p_persistable     IN VARCHAR2 DEFAULT NULL
                   , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                   , p_description     IN VARCHAR2 DEFAULT NULL
                   , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_type( p_type_name
                                  , session_record
                                  , p_typecode
                                  , p_attributes
                                  , p_methods
                                  , p_predefined
                                  , p_incomplete
                                  , p_final
                                  , p_persistable
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
        otap_log.log(SQLERRM, 'otap_test.has_type', 'l_message := otap_api.has_type( p_type_name, ...');
      END IF;
      RAISE;
  END has_type;

  FUNCTION has_sequence( p_sequence_name   IN VARCHAR2
                       , p_table_name      IN VARCHAR2 DEFAULT NULL
                       , p_column_name     IN VARCHAR2 DEFAULT NULL
                       , p_min_value       IN NUMBER   DEFAULT NULL
                       , p_max_value       IN NUMBER   DEFAULT NULL
                       , p_increment_by    IN NUMBER   DEFAULT NULL
                       , p_cycle_flag      IN VARCHAR2 DEFAULT NULL
                       , p_order_flag      IN VARCHAR2 DEFAULT NULL
                       , p_cache_size      IN NUMBER   DEFAULT NULL
                       , p_scale_flag      IN VARCHAR2 DEFAULT NULL
                       , p_extend_flag     IN VARCHAR2 DEFAULT NULL
                       , p_sharded_flag    IN VARCHAR2 DEFAULT NULL
                       , p_session_flag    IN VARCHAR2 DEFAULT NULL
                       , p_keep_value      IN VARCHAR2 DEFAULT NULL
                       , p_table_owner     IN VARCHAR2 DEFAULT NULL
                       , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_description     IN VARCHAR2 DEFAULT NULL
                       , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                       )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_sequence( p_sequence_name
                                      , session_record
                                      , p_table_name
                                      , p_column_name
                                      , p_min_value
                                      , p_max_value
                                      , p_increment_by
                                      , p_cycle_flag
                                      , p_order_flag
                                      , p_cache_size
                                      , p_scale_flag
                                      , p_extend_flag
                                      , p_sharded_flag
                                      , p_session_flag
                                      , p_keep_value
                                      , p_table_owner
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
        otap_log.log(SQLERRM, 'otap_test.has_sequence', 'l_message := otap_api.has_sequence( p_sequence_name, ...');
      END IF;
      RAISE;
  END has_sequence;

  FUNCTION has_scheduler_job( p_job_name        IN VARCHAR2
                            , p_job_style       IN VARCHAR2 DEFAULT NULL
                            , p_job_type        IN VARCHAR2 DEFAULT NULL
                            , p_job_action      IN VARCHAR2 DEFAULT NULL
                            , p_schedule_type   IN VARCHAR2 DEFAULT NULL
                            , p_repeat_interval IN VARCHAR2 DEFAULT NULL
                            , p_job_class       IN VARCHAR2 DEFAULT NULL
                            , p_logging_level   IN VARCHAR2 DEFAULT NULL
                            , p_store_output    IN VARCHAR2 DEFAULT NULL
                            , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                            , p_description     IN VARCHAR2 DEFAULT NULL
                            , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                            )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_scheduler_job( p_job_name
                                           , session_record
                                           , p_job_style
                                           , p_job_type
                                           , p_job_action
                                           , p_schedule_type
                                           , p_repeat_interval
                                           , p_job_class
                                           , p_logging_level
                                           , p_store_output
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
        otap_log.log(SQLERRM, 'otap_test.has_scheduler_job', 'l_message := otap_api.has_scheduler_job( p_job_name, ...');
      END IF;
      RAISE;
  END has_scheduler_job;

  FUNCTION has_user( p_username              IN VARCHAR2
                   , p_account_status        IN VARCHAR2 DEFAULT NULL
                   , p_default_tablespace    IN VARCHAR2 DEFAULT NULL
                   , p_temporary_tablespace  IN VARCHAR2 DEFAULT NULL
                   , p_local_temp_tablespace IN VARCHAR2 DEFAULT NULL
                   , p_profile               IN VARCHAR2 DEFAULT NULL
                   , p_password_versions     IN VARCHAR2 DEFAULT NULL
                   , p_authentication_type   IN VARCHAR2 DEFAULT NULL
                   , p_proxy_only_connect    IN VARCHAR2 DEFAULT NULL
                   , p_protected             IN VARCHAR2 DEFAULT NULL
                   , p_read_only             IN VARCHAR2 DEFAULT NULL
                   , p_description           IN VARCHAR2 DEFAULT NULL
                   , p_expected_result       IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.has_user( p_username
                                  , session_record
                                  , p_account_status
                                  , p_default_tablespace
                                  , p_temporary_tablespace
                                  , p_local_temp_tablespace
                                  , p_profile
                                  , p_password_versions
                                  , p_authentication_type
                                  , p_proxy_only_connect
                                  , p_protected
                                  , p_read_only
                                  , p_description
                                  , p_expected_result
                                  )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.has_user', 'l_message := otap_api.has_user( p_username, ...');
      END IF;
      RAISE;
  END has_user;

  FUNCTION ok( p_boolean         IN BOOLEAN
             , p_description     IN VARCHAR2 DEFAULT NULL
             , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
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
                            , p_schema
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

  FUNCTION is_eq( p_have            IN VARCHAR2
                , p_want            IN VARCHAR2
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
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
                               , p_schema
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

  FUNCTION is_eq( p_have            IN NUMBER
                , p_want            IN NUMBER
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
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
                               , p_schema
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

  FUNCTION is_eq( p_have            IN DATE
                , p_want            IN DATE
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
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
                               , p_schema
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

  FUNCTION match_regex( p_have            IN VARCHAR2
                      , p_regex           IN VARCHAR2
                      , p_description     IN VARCHAR2 DEFAULT NULL
                      , p_param           IN VARCHAR2 DEFAULT NULL
                      , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
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
                                     , p_schema
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

  FUNCTION alike( p_have            IN VARCHAR2
                , p_like            IN VARCHAR2
                , p_case_sensitive  IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                , p_description     IN VARCHAR2 DEFAULT NULL
                , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.alike( p_have
                               , p_like
                               , session_record
                               , p_case_sensitive
                               , p_description
                               , p_expected_result
                               , p_schema
                               )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.alike', 'l_message := otap_api.alike( p_have, ...');
      END IF;
      RAISE;
  END alike;

  FUNCTION throws_ok( p_statement       IN VARCHAR2
                    , p_sqlerrm         IN VARCHAR2
                    , p_header_def      IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.throws_ok( p_statement
                                   , p_sqlerrm
                                   , session_record
                                   , p_header_def
                                   , p_description
                                   , p_expected_result
                                   , p_schema
                                   )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.throws_ok', 'l_message := otap_api.throws_ok( p_statement, ...');
      END IF;
      RAISE;
  END throws_ok;

  FUNCTION throws_ok( p_statement       IN VARCHAR2
                    , p_sqlcode         IN NUMBER
                    , p_header_def      IN VARCHAR2 DEFAULT NULL
                    , p_description     IN VARCHAR2 DEFAULT NULL
                    , p_expected_result IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000 CHAR);
  BEGIN
    otap_api.validate_otap(session_record);
    l_message := otap_api.throws_ok( p_statement
                                   , p_sqlcode
                                   , session_record
                                   , p_header_def
                                   , p_description
                                   , p_expected_result
                                   , p_schema
                                   )
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_log.log(SQLERRM, 'otap_test.throws_ok', 'l_message := otap_api.throws_ok( p_statement, ...');
      END IF;
      RAISE;
  END throws_ok;

  -- generate functions
  PROCEDURE generate_set_type(p_gen_type IN VARCHAR2)
  IS
  BEGIN
    otap_generate.set_gen_type(p_gen_type);
  END generate_set_type;

  FUNCTION generate_type
    RETURN VARCHAR2
  IS
    l_return VARCHAR2(1);
  BEGIN
    l_return := otap_generate.get_gen_type;
    RETURN l_return;
  END generate_type;

  FUNCTION generate_schema_tests( p_like_schema   IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_required_user IN VARCHAR2 DEFAULT NULL
                                , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like   IN VARCHAR2
                    , cp_users  IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_show   IN NUMBER
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.schema_tests(cp_like, cp_users, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_schema, p_required_user, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_schema_tests;

  FUNCTION generate_table_tests( p_like_table    IN VARCHAR2 DEFAULT '%'
                               , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                               , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                               , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like   IN VARCHAR2
                    , cp_schema IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_show   IN NUMBER
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.table_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_table, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_table_tests;

  FUNCTION generate_column_tests( p_table         IN VARCHAR2
                                , p_like_column   IN VARCHAR2 DEFAULT '%'
                                , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_table  IN VARCHAR2
                    , cp_like   IN VARCHAR2
                    , cp_schema IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_show   IN NUMBER
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.column_tests(cp_table, cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_table, p_like_column, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_column_tests;

  FUNCTION generate_trigger_tests( p_like_trigger  IN VARCHAR2 DEFAULT '%'
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like   IN VARCHAR2
                    , cp_schema IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_show   IN NUMBER
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.trigger_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_trigger, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_trigger_tests;

  FUNCTION generate_package_tests( p_like_package  IN VARCHAR2 DEFAULT '%'
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like   IN VARCHAR2
                    , cp_schema IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_show   IN NUMBER
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.package_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_package, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_package_tests;

  FUNCTION generate_procedure_tests( p_like_procedure IN VARCHAR2 DEFAULT '%'
                                   , p_package_name   IN VARCHAR  DEFAULT NULL
                                   , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                   , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                                   , p_show_header    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                   , p_excl_sysgen    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                   )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like     IN VARCHAR2
                    , cp_package  IN VARCHAR2
                    , cp_schema   IN VARCHAR2
                    , cp_prefix   IN VARCHAR2
                    , cp_show     IN NUMBER
                    , cp_excl     IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.procedure_tests(cp_like, cp_package, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_procedure, p_package_name, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_procedure_tests;

  FUNCTION generate_view_tests( p_like_view     IN VARCHAR2 DEFAULT '%'
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like     IN VARCHAR2
                    , cp_schema   IN VARCHAR2
                    , cp_prefix   IN VARCHAR2
                    , cp_show     IN NUMBER
                    , cp_excl     IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.view_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_view, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_view_tests;

  FUNCTION generate_schema_user_test( p_schema        IN VARCHAR2 DEFAULT NULL
                                    , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                    , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_schema   IN VARCHAR2
                    , cp_prefix   IN VARCHAR2
                    , cp_show     IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.schema_user_test(cp_schema, cp_prefix, cp_show))
    ;
  BEGIN
    FOR rec IN cur_tests(p_schema, p_title_prefix, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_schema_user_test;

  FUNCTION generate_related_user_tests( p_user_list     IN VARCHAR2 DEFAULT NULL
                                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                      , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                      )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_user_list IN VARCHAR2
                    , cp_prefix    IN VARCHAR2
                    , cp_show      IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.related_user_tests(cp_user_list, cp_prefix, cp_show))
    ;
  BEGIN
    FOR rec IN cur_tests(p_user_list, p_title_prefix, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_related_user_tests;

  FUNCTION generate_constraint_tests( p_table            IN VARCHAR2
                                    , p_like_constraints IN VARCHAR2 DEFAULT '%'
                                    , p_schema           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                    , p_title_prefix     IN VARCHAR2 DEFAULT NULL
                                    , p_show_header      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    , p_excl_sysgen      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                    )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_table   IN VARCHAR2
                    , cp_like    IN VARCHAR2
                    , cp_schema  IN VARCHAR2
                    , cp_prefix  IN VARCHAR2
                    , cp_show    IN NUMBER
                    , cp_excl    IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.constraint_tests(cp_table, cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_table, p_like_constraints, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_constraint_tests;

  FUNCTION generate_index_tests( p_table         IN VARCHAR2
                               , p_like_index    IN VARCHAR2 DEFAULT '%'
                               , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                               , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                               , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                               )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_table   IN VARCHAR2
                    , cp_like    IN VARCHAR2
                    , cp_schema  IN VARCHAR2
                    , cp_prefix  IN VARCHAR2
                    , cp_show    IN NUMBER
                    , cp_excl    IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.index_tests(cp_table, cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_table, p_like_index, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_index_tests;

  FUNCTION generate_type_tests( p_like_type     IN VARCHAR2 DEFAULT '%'
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like    IN VARCHAR2
                    , cp_schema  IN VARCHAR2
                    , cp_prefix  IN VARCHAR2
                    , cp_show    IN NUMBER
                    , cp_excl    IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.type_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_type, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_type_tests;

  FUNCTION generate_sequence_tests( p_like_sequence IN VARCHAR2 DEFAULT '%'
                                  , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                  , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                  , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                  )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like    IN VARCHAR2
                    , cp_schema  IN VARCHAR2
                    , cp_prefix  IN VARCHAR2
                    , cp_show    IN NUMBER
                    , cp_excl    IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.sequence_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_sequence, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_sequence_tests;

  FUNCTION generate_scheduler_job_tests( p_like_job      IN VARCHAR2 DEFAULT '%'
                                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                                       )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_tests( cp_like    IN VARCHAR2
                    , cp_schema  IN VARCHAR2
                    , cp_prefix  IN VARCHAR2
                    , cp_show    IN NUMBER
                    , cp_excl    IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.sched_job_tests(cp_like, cp_schema, cp_prefix, cp_show, cp_excl))
    ;
  BEGIN
    FOR rec IN cur_tests(p_like_job, p_schema, p_title_prefix, p_show_header, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END generate_scheduler_job_tests;

END;
/