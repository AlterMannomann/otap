-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- basic internal interface between session variable and concrete test calls.
-- WARNING package will probably get huge due to bundling functionality
CREATE OR REPLACE PACKAGE otap_api
AS

  /**
  * The package is fail save in the sense that it will try to capture all errors and execptions and
  * influence the test result. On exceptions, otap is not stable, so the test result gets undefined
  * exceptions and errors and the test_errors content is set. Still it is possible on severe database
  * errors will raise an exception. Every error passing the double begin-end blocks used are exceptions
  * that otap can't and won't handle. The begin-end blocks define the otap code that can be controlled,
  * but if database is unstable, e.g. running out of tablespace, it makes no sense to consume exceptions.
  *
  * Main functionality is to prepare the parameters considering session settings and then call the functions
  * to keep the basic test functions short and concentrated on their real work. The return of the test
  * functions should always be NUMBER, limited to otap_constants.OTAP_NUM_TEST_PASSED,
  * otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED or exception.
  *
  * Test results, after persisting, are always delivered to the caller of OTAP_API as VARCHAR2 test result text.
  *
  * Comments are kept short, as this package gets huge. See wrapped functions for details.
  */

  /** PROCEDURE otap_api.validate_otap
  * Validates the basic system of otap, checks if objects are valid, triggers enabled and
  * no illegal content in OTAP_TRANSLATE.
  *
  * Will change the session id to ensure that every user has a unique id within the sequence borders.
  *
  * @param o_otap_session A valid OTAP_SESSION object to be used for update of session id if not set.
  *
  * @throws -20099 The otap system is not valid. Ask your admin to fix the system before testing.
  */
  PROCEDURE validate_otap(o_otap_session IN OUT NOCOPY OTAP_SESSION);

  /** FUNCTION otap_api.init_test
  * @see otap_plan.init_test and otap_test.init_test
  */
  FUNCTION init_test( p_test_count          IN            NUMBER
                    , p_test_set            IN            VARCHAR2
                    , p_test_group          IN            VARCHAR2
                    , p_test_name           IN            VARCHAR2
                    , p_prefix              IN            VARCHAR2
                    , p_language_id         IN            VARCHAR2
                    , p_name_precedence     IN            NUMBER
                    , p_include_pkg         IN            NUMBER
                    , p_persist             IN            NUMBER
                    , p_schema              IN            VARCHAR2
                    , p_user                IN            VARCHAR2
                    , p_executor            IN            VARCHAR2
                    , o_otap_session        IN OUT NOCOPY OTAP_SESSION
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.finish_test
  * @see otap_plan.finish_test and otap_test.finish_test
  */
  FUNCTION finish_test( p_write_count_rec IN            NUMBER
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.finish_test_with_exit_code
  * @see otap_plan.finish_test_with_exit_code and otap_test.finish_test_with_exit_code
  */
  FUNCTION finish_test_with_exit_code( p_write_count_rec IN            NUMBER
                                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.otap_session_show
  * @see otap_objects.otap_session_show and otap_test.current_settings
  */
  FUNCTION otap_session_show(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_summary
  * @see otap_objects.otap_session_summary and otap_test.current_summary
  */
  FUNCTION otap_session_summary(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_name
  * @see otap_objects.otap_session_set_test_name and otap_test.set_test_name
  */
  FUNCTION otap_session_set_test_name( p_test_name    IN            VARCHAR2
                                     , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_group
  * @see otap_objects.otap_session_set_test_group and otap_test.set_test_group
  */
  FUNCTION otap_session_set_test_group( p_test_group   IN            VARCHAR2
                                      , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_set
  * @see otap_objects.otap_session_set_test_set and otap_test.set_test_set
  */
  FUNCTION otap_session_set_test_set( p_test_set     IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_set
  * @see otap_objects.otap_session_set_language and otap_test.set_language
  */
  FUNCTION otap_session_set_language( p_language_id  IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_get_language
  * @see otap_objects.otap_session_get_language and otap_test.get_language
  */
  FUNCTION otap_session_get_language(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_get_test_id
  * @see otap_objects.otap_session_get_test_id and otap_test.otap_session_get_test_id
  */
  FUNCTION otap_session_get_test_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.otap_session_get_report_id
  * @see otap_objects.otap_session_get_report_id and otap_test.otap_session_get_report_id
  */
  FUNCTION otap_session_get_report_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.set_active_report_id
  * @see otap_objects.otap_session_get_report_id and otap_test.set_active_report_id
  * Does an extra check if TEST_SESSION_ID exists in OTAP_RESULTS.
  */
  FUNCTION set_active_report_id( p_report_id    IN            NUMBER
                               , o_otap_session IN OUT NOCOPY OTAP_SESSION
                               )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.max_text_size
  * @see otap_util.max_text_size and otap_test.max_text_size
  */
  FUNCTION max_text_size( p_session_id  IN NUMBER
                        , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                        )
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.get_report_header
  * @see otap_report.get_report_header
  */
  FUNCTION get_report_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_session_id_text
  * @see otap_report.get_session_id_text
  */
  FUNCTION get_session_id_text( p_session_id  IN NUMBER
                              , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                              , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                              )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_set_text
  * @see otap_report.get_set_text
  */
  FUNCTION get_set_text( p_test_set    IN VARCHAR2
                       , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                       , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                       )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_summary_header
  * @see otap_report.get_summary_header
  */
  FUNCTION get_summary_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_summary
  * @see otap_report.get_summary
  * Calculates overall status by given errors and issues.
  */
  FUNCTION get_summary( p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_exectime    IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_runs        IN NUMBER   DEFAULT 0
                      , p_errors      IN NUMBER   DEFAULT 0
                      , p_issues      IN NUMBER   DEFAULT 0
                      , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                      , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_group_text
  * @see otap_report.get_group_text
  */
  FUNCTION get_group_text( p_test_group  IN VARCHAR2
                         , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                         , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_test_name_text
  * @see otap_report.get_test_name_text
  */
  FUNCTION get_test_name_text( p_test_name   IN VARCHAR2
                             , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_header
  * @see otap_report.get_result_header
  */
  FUNCTION get_result_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_underline
  * @see otap_report.get_result_underline
  */
  FUNCTION get_result_underline( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                               , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                               )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_line
  * @see otap_report.get_result_line
  */
  FUNCTION get_result_line( p_test_state  IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_issue_state IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                          , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.test_result_to_text
  * @see otap_util.test_result_to_text and otap_test.test_result_to_text
  */
  FUNCTION test_result_to_text( p_test_passed IN NUMBER
                              , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                              )
    RETURN VARCHAR
  ;

  /** FUNCTION otap_api.get_error_result_header
  * @see otap_report.get_error_result_header
  */
  FUNCTION get_error_result_header( p_test_name   IN VARCHAR2
                                  , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                  , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_error_details
  * @see otap_report.get_error_details
  */
  FUNCTION get_error_details( p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_error_info  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_no_data_text
  * @see otap_report.get_no_data_text
  */
  FUNCTION get_no_data_text( p_session_id  IN NUMBER
                           , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_report_footer
  * @see otap_report.get_report_footer
  */
  FUNCTION get_report_footer( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_version_info
  * @see otap_string.decorate_blank
  */
  FUNCTION get_version_info( p_info        IN VARCHAR2
                           , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.flatten
  * @see otap_string.flatten and otap_test.flatten
  */
  FUNCTION flatten( p_string VARCHAR2 DEFAULT NULL
                  , p_size   INTEGER  DEFAULT 0
                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_test_count_header
  * @see otap_report.get_test_count_header
  */
  FUNCTION get_test_count_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_report_total
  * @see otap_report.get_report_total
  */
  FUNCTION get_report_total( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_report_total_details
  * @see otap_report.get_report_total_details
  */
  FUNCTION get_report_total_details( p_sets         IN INTEGER  DEFAULT 0
                                   , p_groups       IN INTEGER  DEFAULT 0
                                   , p_names        IN INTEGER  DEFAULT 0
                                   , p_descriptions IN INTEGER  DEFAULT 0
                                   , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                   , p_language_id  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.result_view
  * @see otap_test.result_view
  */
  FUNCTION result_view( p_session_id   IN NUMBER
                      , p_language_id  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_api.has_table
  * @see otap_schema.has_table and otap_test.has_column
  */
  FUNCTION has_table( p_table_name      IN            VARCHAR2
                    , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                    , p_schema          IN            VARCHAR2     DEFAULT NULL
                    , p_description     IN            VARCHAR2     DEFAULT NULL
                    , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_column
  * @see otap_schema.has_column and otap_test.has_column
  */
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
  ;

  /** FUNCTION otap_api.has_package
  * @see otap_schema.has_package and otap_test.has_package
  */
  FUNCTION has_package( p_package_name    IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_schema          IN            VARCHAR2      DEFAULT NULL
                      , p_description     IN            VARCHAR2      DEFAULT NULL
                      , p_package_type    IN            VARCHAR2      DEFAULT 'PACKAGE'
                      , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_procedure
  * @see otap_schema.has_procedure and otap_test.has_procedure
  */
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
  ;

  /** FUNCTION otap_schema.has_trigger
  * @see otap_schema.has_trigger and otap_test.has_trigger
  */
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
  ;

  /** FUNCTION otap_api.has_object
  * @see otap_schema.has_object and otap_test.has_object
  */
  FUNCTION has_object( p_object_name     IN            VARCHAR2
                     , p_object_type     IN            VARCHAR2
                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                     , p_schema          IN            VARCHAR2     DEFAULT NULL
                     , p_description     IN            VARCHAR2     DEFAULT NULL
                     , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_constraint
  * @see otap_schema.has_constraint and otap_test.has_constraint
  */
  FUNCTION has_constraint( p_table_name      IN            VARCHAR2
                         , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                         , p_constraint_type IN            VARCHAR2     DEFAULT 'C'
                         , p_column_name     IN            VARCHAR2     DEFAULT NULL
                         , p_constraint      IN            VARCHAR2     DEFAULT NULL
                         , p_schema          IN            VARCHAR2     DEFAULT NULL
                         , p_description     IN            VARCHAR2     DEFAULT NULL
                         , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_ref_constraint
  * @see otap_schema.has_ref_constraint and otap_test.has_ref_constraint
  */
  FUNCTION has_ref_constraint( p_table_name      IN            VARCHAR2
                             , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                             , p_constraint_type IN            VARCHAR2     DEFAULT 'R'
                             , p_column_name     IN            VARCHAR2     DEFAULT NULL
                             , p_constraint      IN            VARCHAR2     DEFAULT NULL
                             , p_schema          IN            VARCHAR2     DEFAULT NULL
                             , p_r_table_name    IN            VARCHAR2     DEFAULT NULL
                             , p_r_column_name   IN            VARCHAR2     DEFAULT NULL
                             , p_r_constraint    IN            VARCHAR2     DEFAULT NULL
                             , p_r_schema        IN            VARCHAR2     DEFAULT NULL
                             , p_description     IN            VARCHAR2     DEFAULT NULL
                             , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_not_null_constraint
  * @see otap_schema.has_not_null_constraint and otap_test.has_not_null_constraint
  */
  FUNCTION has_not_null_constraint( p_table_name      IN            VARCHAR2
                                  , p_column_name     IN            VARCHAR2
                                  , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                                  , p_constraint      IN            VARCHAR2     DEFAULT NULL
                                  , p_schema          IN            VARCHAR2     DEFAULT NULL
                                  , p_description     IN            VARCHAR2     DEFAULT NULL
                                  , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_index
  * @see otap_schema.has_index and otap_test.has_index
  */
  FUNCTION has_index( p_table_name      IN            VARCHAR2
                    , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                    , p_column_name     IN            VARCHAR2 DEFAULT NULL
                    , p_index_name      IN            VARCHAR2 DEFAULT NULL
                    , p_index_type      IN            VARCHAR2 DEFAULT NULL
                    , p_table_type      IN            VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN            VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN            VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN            VARCHAR2 DEFAULT NULL
                    , p_schema          IN            VARCHAR2 DEFAULT NULL
                    , p_description     IN            VARCHAR2 DEFAULT NULL
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_type
  * @see otap_schema.has_type and otap_test.has_type
  */
  FUNCTION has_type( p_type_name       IN            VARCHAR2
                   , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                   , p_typecode        IN            VARCHAR2 DEFAULT NULL
                   , p_attributes      IN            NUMBER   DEFAULT NULL
                   , p_methods         IN            NUMBER   DEFAULT NULL
                   , p_predefined      IN            VARCHAR2 DEFAULT NULL
                   , p_incomplete      IN            VARCHAR2 DEFAULT NULL
                   , p_final           IN            VARCHAR2 DEFAULT NULL
                   , p_persistable     IN            VARCHAR2 DEFAULT NULL
                   , p_schema          IN            VARCHAR2 DEFAULT NULL
                   , p_description     IN            VARCHAR2 DEFAULT NULL
                   , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  ;


  /** FUNCTION otap_api.has_sequence
  * @see otap_schema.has_sequence and otap_test.has_sequence
  */
  FUNCTION has_sequence( p_sequence_name   IN            VARCHAR2
                       , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                       , p_table_name      IN            VARCHAR2 DEFAULT NULL
                       , p_column_name     IN            VARCHAR2 DEFAULT NULL
                       , p_min_value       IN            NUMBER   DEFAULT NULL
                       , p_max_value       IN            NUMBER   DEFAULT NULL
                       , p_increment_by    IN            NUMBER   DEFAULT NULL
                       , p_cycle_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_order_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_cache_size      IN            NUMBER   DEFAULT NULL
                       , p_scale_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_extend_flag     IN            VARCHAR2 DEFAULT NULL
                       , p_sharded_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_session_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_keep_value      IN            VARCHAR2 DEFAULT NULL
                       , p_table_owner     IN            VARCHAR2 DEFAULT NULL
                       , p_schema          IN            VARCHAR2 DEFAULT NULL
                       , p_description     IN            VARCHAR2 DEFAULT NULL
                       , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                       )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_scheduler_job
  * @see otap_schema.has_scheduler_job and otap_test.has_scheduler_job
  */
  FUNCTION has_scheduler_job( p_job_name        IN            VARCHAR2
                            , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                            , p_job_style       IN            VARCHAR2 DEFAULT NULL
                            , p_job_type        IN            VARCHAR2 DEFAULT NULL
                            , p_job_action      IN            VARCHAR2 DEFAULT NULL
                            , p_schedule_type   IN            VARCHAR2 DEFAULT NULL
                            , p_repeat_interval IN            VARCHAR2 DEFAULT NULL
                            , p_job_class       IN            VARCHAR2 DEFAULT NULL
                            , p_logging_level   IN            VARCHAR2 DEFAULT NULL
                            , p_store_output    IN            VARCHAR2 DEFAULT NULL
                            , p_schema          IN            VARCHAR2 DEFAULT NULL
                            , p_description     IN            VARCHAR2 DEFAULT NULL
                            , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_user
  * @see otap_schema.has_user and otap_test.has_user
  */
  FUNCTION has_user( p_username              IN            VARCHAR2
                   , o_otap_session          IN OUT NOCOPY OTAP_SESSION
                   , p_account_status        IN            VARCHAR2 DEFAULT NULL
                   , p_default_tablespace    IN            VARCHAR2 DEFAULT NULL
                   , p_temporary_tablespace  IN            VARCHAR2 DEFAULT NULL
                   , p_local_temp_tablespace IN            VARCHAR2 DEFAULT NULL
                   , p_profile               IN            VARCHAR2 DEFAULT NULL
                   , p_password_versions     IN            VARCHAR2 DEFAULT NULL
                   , p_authentication_type   IN            VARCHAR2 DEFAULT NULL
                   , p_proxy_only_connect    IN            VARCHAR2 DEFAULT NULL
                   , p_protected             IN            VARCHAR2 DEFAULT NULL
                   , p_read_only             IN            VARCHAR2 DEFAULT NULL
                   , p_description           IN            VARCHAR2 DEFAULT NULL
                   , p_expected_result       IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.ok
  * @see otap_logic.ok and otap_test.ok
  */
  FUNCTION ok( p_boolean         IN            BOOLEAN
             , o_otap_session    IN OUT NOCOPY OTAP_SESSION
             , p_description     IN            VARCHAR2     DEFAULT NULL
             , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             , p_schema          IN            VARCHAR2     DEFAULT NULL
             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.is_eq
  * @see otap_logic.is_eq and otap_test.is_eq
  */
  FUNCTION is_eq( p_have            IN            VARCHAR2
                , p_want            IN            VARCHAR2
                , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                , p_description     IN            VARCHAR2      DEFAULT NULL
                , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN            VARCHAR2      DEFAULT NULL
                )
    RETURN VARCHAR2
  ;
  FUNCTION is_eq( p_have            IN            NUMBER
                , p_want            IN            NUMBER
                , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                , p_description     IN            VARCHAR2      DEFAULT NULL
                , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN            VARCHAR2      DEFAULT NULL
                )
    RETURN VARCHAR2
  ;
  FUNCTION is_eq( p_have            IN            DATE
                , p_want            IN            DATE
                , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                , p_description     IN            VARCHAR2      DEFAULT NULL
                , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN            VARCHAR2      DEFAULT NULL
                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.match_regex
  * @see otap_logic.match_regex and otap_test.match_regex
  */
  FUNCTION match_regex( p_have            IN            VARCHAR2
                      , p_regex           IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_description     IN            VARCHAR2      DEFAULT NULL
                      , p_param           IN            VARCHAR2      DEFAULT NULL
                      , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      , p_schema          IN            VARCHAR2      DEFAULT NULL
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.alike
  * @see otap_logic.alike and otap_test.alike
  */
  FUNCTION alike( p_have            IN            VARCHAR2
                , p_like            IN            VARCHAR2
                , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                , p_case_sensitive  IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_FALSE
                , p_description     IN            VARCHAR2      DEFAULT NULL
                , p_expected_result IN            NUMBER        DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                , p_schema          IN            VARCHAR2      DEFAULT NULL
                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.throws_ok
  * @see otap_logic.throws_ok and otap_test.throws_ok
  */
  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlerrm         IN            VARCHAR2
                    , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                    , p_header_def      IN            VARCHAR2     DEFAULT NULL
                    , p_description     IN            VARCHAR2     DEFAULT NULL
                    , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  ;
  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlcode         IN            NUMBER
                    , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                    , p_header_def      IN            VARCHAR2     DEFAULT NULL
                    , p_description     IN            VARCHAR2     DEFAULT NULL
                    , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    , p_schema          IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.throws_matches
  * @see otap_logic.throws_matches and otap_test.throws_matches
  */
  FUNCTION throws_matches( p_statement       IN            VARCHAR2
                         , p_regex_sqlerrm   IN            VARCHAR2
                         , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                         , p_param           IN            VARCHAR2     DEFAULT NULL
                         , p_header_def      IN            VARCHAR2     DEFAULT NULL
                         , p_description     IN            VARCHAR2     DEFAULT NULL
                         , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         , p_schema          IN            VARCHAR2     DEFAULT NULL
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_logic.throws_like
  * @see otap_logic.throws_like and otap_test.throws_like
  */
  FUNCTION throws_like( p_statement       IN            VARCHAR2
                      , p_like_sqlerrm    IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_case_sensitive  IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_FALSE
                      , p_header_def      IN            VARCHAR2     DEFAULT NULL
                      , p_description     IN            VARCHAR2     DEFAULT NULL
                      , p_expected_result IN            NUMBER       DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      , p_schema          IN            VARCHAR2     DEFAULT NULL
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.test_error
  * @see otap_test.test_error
  */
  FUNCTION test_error( p_description     IN            VARCHAR2
                     , p_errors          IN            VARCHAR2
                     , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                     , p_schema          IN            VARCHAR2     DEFAULT NULL
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.test_error_check
  * @see otap_test.test_error_check
  */
  FUNCTION test_error_check( p_have        IN NUMBER
                           , p_want        IN NUMBER
                           , p_description IN VARCHAR2
                           , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                           , p_schema      IN VARCHAR2 DEFAULT NULL
                           )
    RETURN VARCHAR2
  ;

END;
/