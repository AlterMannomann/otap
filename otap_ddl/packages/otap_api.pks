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

  /** FUNCTION otap_api.init_test
  * @see otap_plan.init_test
  */
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
  ;

  /** FUNCTION otap_api.finish_test
  * @see otap_plan.finish_test
  */
  FUNCTION finish_test( p_write_count_rec IN            NUMBER
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_show
  * @see otap_objects.otap_session_show
  */
  FUNCTION otap_session_show(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_summary
  * @see otap_objects.otap_session_summary
  */
  FUNCTION otap_session_summary(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_name
  * @see otap_objects.otap_session_set_test_name
  */
  FUNCTION otap_session_set_test_name( p_test_name    IN            VARCHAR2
                                     , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN VARCHAR2
  ;


  /** FUNCTION otap_api.otap_session_set_test_group
  * @see otap_objects.otap_session_set_test_group
  */
  FUNCTION otap_session_set_test_group( p_test_group   IN            VARCHAR2
                                      , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_set_test_set
  * @see otap_objects.otap_session_set_test_set
  */
  FUNCTION otap_session_set_test_set( p_test_set     IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.otap_session_get_test_id
  * @see otap_objects.otap_session_get_test_id
  */
  FUNCTION otap_session_get_test_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.otap_session_get_report_id
  * @see otap_objects.otap_session_get_report_id
  */
  FUNCTION otap_session_get_report_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.max_text_size
  * @see otap_results_util.max_text_size
  */
  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  ;

  /** FUNCTION otap_api.get_report_header
  * @see otap_report.get_report_header
  */
  FUNCTION get_report_header(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_session_id_text
  * @see otap_report.get_session_id_text
  */
  FUNCTION get_session_id_text( p_session_id IN NUMBER
                              , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                              )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_set_text
  * @see otap_report.get_set_text
  */
  FUNCTION get_set_text( p_test_set IN VARCHAR2
                       , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                       )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_summary
  * @see otap_report.get_summary
  * Calculates status needed by errors and issues.
  */
  FUNCTION get_summary( p_runtime  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_runs     IN NUMBER   DEFAULT 0
                      , p_errors   IN NUMBER   DEFAULT 0
                      , p_issues   IN NUMBER   DEFAULT 0
                      , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_group_text
  * @see otap_report.get_group_text
  */
  FUNCTION get_group_text( p_test_group IN VARCHAR2
                         , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_test_name_text
  * @see otap_report.get_test_name_text
  */
  FUNCTION get_test_name_text( p_test_name IN VARCHAR2
                             , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_header
  * @see otap_report.get_result_header
  */
  FUNCTION get_result_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_underline
  * @see otap_report.get_result_underline
  */
  FUNCTION get_result_underline(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_result_line
  * @see otap_report.get_result_line
  */
  FUNCTION get_result_line( p_test_state  IN VARCHAR2 DEFAULT otap_constants.OTAP_TEXT_TEST_UNDEFINED
                          , p_issue_state IN VARCHAR2 DEFAULT otap_constants.OTAP_TEXT_TEST_UNDEFINED
                          , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                          )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.test_result_to_text
  * @see otap_config_util.test_result_to_text
  */
  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  ;

  /** FUNCTION otap_api.get_error_result_header
  * @see otap_report.get_error_result_header
  */
  FUNCTION get_error_result_header( p_test_name IN VARCHAR2
                                  , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_error_details
  * @see otap_report.get_error_details
  */
  FUNCTION get_error_details( p_test_desc  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_error_info IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_no_data_text
  * @see otap_report.get_no_data_text
  */
  FUNCTION get_no_data_text( p_session_id IN NUMBER
                           , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_report_footer
  * @see otap_report.get_report_footer
  */
  FUNCTION get_report_footer(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.flatten
  * @see otap_string.flatten
  */
  FUNCTION flatten( p_string VARCHAR2 DEFAULT NULL
                  , p_size   INTEGER  DEFAULT 0
                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_text_test_count_name
  *  @see otap_config_util.get_text_test_count_name
  */
  FUNCTION get_text_test_count_name
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_test_count_header
  * @see otap_report.get_test_count_header
  */
  FUNCTION get_test_count_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.get_report_total
  * @see otap_report.get_report_total
  */
  FUNCTION get_report_total(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
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
                                   )
    RETURN VARCHAR2
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
                     , p_schema          IN            VARCHAR2 DEFAULT NULL
                     , p_description     IN            VARCHAR2 DEFAULT NULL
                     , p_data_type       IN            VARCHAR2 DEFAULT NULL
                     , p_data_length     IN            NUMBER   DEFAULT NULL
                     , p_data_precision  IN            NUMBER   DEFAULT NULL
                     , p_data_scale      IN            NUMBER   DEFAULT NULL
                     , p_nullable        IN            VARCHAR2 DEFAULT NULL
                     , p_data_default    IN            VARCHAR2 DEFAULT NULL
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_api.has_package
  * @see otap_schema.has_package and otap_test.has_package
  */
  FUNCTION has_package( p_package_name    IN            VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_schema          IN            VARCHAR2 DEFAULT NULL
                      , p_description     IN            VARCHAR2 DEFAULT NULL
                      , p_package_type    IN            VARCHAR2 DEFAULT 'PACKAGE'
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  ;


  /** FUNCTION otap_api.has_procedure
  * @see otap_schema.has_procedure and otap_test.has_procedure
  */
  FUNCTION has_procedure( p_procedure_name  IN            VARCHAR2
                        , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                        , p_schema          IN            VARCHAR2 DEFAULT NULL
                        , p_description     IN            VARCHAR2 DEFAULT NULL
                        , p_procedure_type  IN            VARCHAR2 DEFAULT 'FUNCTION'
                        , p_package_name    IN            VARCHAR2 DEFAULT NULL
                        , p_return_type     IN            VARCHAR2 DEFAULT NULL
                        , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_schema.has_trigger
  * @see otap_schema.has_trigger and otap_test.has_trigger
  */
  FUNCTION has_trigger( p_trigger_name    IN     VARCHAR2
                      , o_otap_session    IN OUT NOCOPY OTAP_SESSION
                      , p_schema          IN     VARCHAR2 DEFAULT NULL
                      , p_description     IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_type    IN     VARCHAR2 DEFAULT NULL
                      , p_trigger_event   IN     VARCHAR2 DEFAULT NULL
                      , p_table_owner     IN     VARCHAR2 DEFAULT NULL
                      , p_table_name      IN     VARCHAR2 DEFAULT NULL
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN VARCHAR2
  ;

END;
/