-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- provides functionality for formatting test report
CREATE OR REPLACE PACKAGE otap_report
AS

  /** FUNCTION otap_report.decorate
  * Main functionality to create a decorated output using the defined defaults in OTAP_CONFIG.
  *
  * @param p_string The string to display borderless in a report line using left or right layout.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_decoration The decoration char to use, which will surround the given string.
  * @param p_language_id A valid or existing language id.
  *
  * @return The decorated string according to the configured layout orientation.
  */
  FUNCTION decorate( p_string      IN VARCHAR2
                   , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_decoration  IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                   , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.borderless
  * Main functionality to create a borderless output using the defined defaults in OTAP_CONFIG.
  * Limited to layout orientation left and right. See also otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT.
  *
  * @param p_string The string to display borderless in a report line using left or right layout. If NULL or empty string, a space char is used.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted string according to the configured layout orientation.
  */
  FUNCTION borderless( p_string      IN VARCHAR2
                     , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                     , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_report_header
  * Build a decorated report header using the configured defaults in OTAP_CONFIG for text, layout
  * and border.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured and decorated report header.
  */
  FUNCTION get_report_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_report_total
  * Build a decorated report totals header using the configured defaults in OTAP_CONFIG for text, layout
  * and border.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured and decorated report totals header.
  */
  FUNCTION get_report_total( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_report_total_details
  * Build a decorated report total details header using the configured defaults in OTAP_CONFIG for text, layout
  * and border.
  *
  * @param p_sets The number of unique test sets processed in the test session.
  * @param p_groups The number of unique test groups processed in the test session.
  * @param p_names The number of unique test names processed in the test session.
  * @param p_descriptions The number of unique test descriptions processed in the test session. May differ from runs.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured and decorated report totals header.
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

  /** FUNCTION otap_report.get_report_footer
  * Build a decorated report footer using the configured defaults in OTAP_CONFIG for text, layout
  * and border.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured and decorated report footer as defined in OTAP_CONFIG.
  */
  FUNCTION get_report_footer( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_result_header
  * Build a padded result header using the configured defaults in OTAP_CONFIG for text, layout
  * and border. Padding char is space for result header.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured result header as defined in OTAP_CONFIG.
  */
  FUNCTION get_result_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_result_underline
  * Build a padded result header underline using the configured defaults in OTAP_CONFIG for text, layout
  * and border. Padding char is space for result header underline. Currently not in use. Adjust otap_api
  * package if needed.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured result header underline as defined in OTAP_CONFIG.
  */
  FUNCTION get_result_underline( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                               , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                               )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_test_count_header
  * Build a decorated test count header using the configured defaults in OTAP_CONFIG for text, layout
  * and border. Uses report level formatting as count is only for a complete session.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The decorated count header as defined in OTAP_CONFIG.
  */
  FUNCTION get_test_count_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_summary_header
  * The defined header line for summary reports.
  *
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The summary header as defined in OTAP_CONFIG.
  */
  FUNCTION get_summary_header( p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_summary
  * Does minor NVL handling, if status is NULL will result in ERROR, other NULLS
  * result in N/A.
  *
  * @param p_status A valid summary status as configured in OTAP_CONFIG.
  * @param p_runtime The runtime of set, group or test name as string. The time from start of tests to end of tests.
  * @param p_exectime The execution time of the tests in a set, group or test name as string. The pure test functions execution time.
  * @param p_runs The amount of executed test runs for set, group or test name.
  * @param p_errors The amount test runs with errors for set, group or test name.
  * @param p_issues The amount internal issues for set, group or test name.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The configured summary template in OTAP_CONFIG enriched with data.
  */
  FUNCTION get_summary( p_status      IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                      , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_exectime    IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_runs        IN NUMBER   DEFAULT 0
                      , p_errors      IN NUMBER   DEFAULT 0
                      , p_issues      IN NUMBER   DEFAULT 0
                      , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                      , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_error_result_header
  * Builds the error result header from template for current test name. Does minor NVL handling,
  * N/A for NULL.
  *
  * @param p_test_name The test name for the error section.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The decorated error result header for the given test name.
  */
  FUNCTION get_error_result_header( p_test_name   IN VARCHAR2
                                  , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                  , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_error_details
  * Builds the error detail info from template for current test description. Does minor NVL handling,
  * N/A for NULL.
  *
  * @param p_test_desc The test description of the test with errors.
  * @param p_error_info The error information for the test.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted error details for the given test description.
  */
  FUNCTION get_error_details( p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_error_info  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_no_data_text
  * Builds the no data message from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_session_id The session id that has been requested for a test result report.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted no data text for the given session id.
  */
  FUNCTION get_no_data_text( p_session_id  IN NUMBER
                           , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_session_id_text
  * Builds the session id message from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_session_id The session id that has been requested for a test result report.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted session id text for the given session id.
  */
  FUNCTION get_session_id_text( p_session_id  IN NUMBER
                              , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                              , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                              )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_set_text
  * Builds the decorated test set message from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_test_set The current test set for a test result report.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The decorated test set text for the given test set.
  */
  FUNCTION get_set_text( p_test_set    IN VARCHAR2
                       , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                       , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                       )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_group_text
  * Builds the decorated test group message from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_test_group The current test group for a test result report.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The decorated test group text for the given test group.
  */
  FUNCTION get_group_text( p_test_group  IN VARCHAR2
                         , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                         , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_test_name_text
  * Builds the test name message from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_test_name The current test name for a test result report.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The test name text for the given test name.
  */
  FUNCTION get_test_name_text( p_test_name   IN VARCHAR2
                             , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_result_line
  * Builds the test result line from template. Does minor NVL handling, N/A for NULL.
  *
  * @param p_test_state The test state as text representation for a test result report, e.g. passed, failed or undefined.
  * @param p_issue_state The issue state as text representation for a test result report, e.g. passed, failed or undefined.
  * @param p_runtime The runtime of the test as string.
  * @param p_test_desc The test description of the related test if any.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The result line for a given test.
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

  /** FUNCTION otap_report.get_count_desc
  * Builds the test count result string from template. Does minor NVL handling, N/A for NULL char, 0 for NULL number parameter.
  * Used as test description when writing the count result.
  *
  * @param p_tests_run The issue state as text representation for a test result report, e.g. passed, failed or undefined.
  * @param p_tests_expected The runtime of the test as string.
  * @param p_language_id A valid or existing language id.
  *
  * @return The count test result string for the given values.
  */
  FUNCTION get_count_desc( p_tests_run       IN INTEGER  DEFAULT 0
                         , p_tests_expected  IN INTEGER  DEFAULT 0
                         , p_language_id     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_separator_line
  * Builds a separator line from the given char. Only the first not space char is considered.
  * otap_util provides functions for current configuration access.
  *
  * @param p_char The char to build a line from. Default is the default char "-" for format test name.
  * @param p_min_fill Allows overwrite of minimum length for reports. Only considered if greater than current header maximum size.
  * @param p_language_id A valid or existing language id.
  *
  * @return The separator line. Length is calculated from configured headers or minimum fill.
  */
  FUNCTION get_separator_line( p_char        IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                             , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                             )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_exists_msg
  * Builds a user message for the schema exist test function based on given values from template. Will always
  * reduce the string. No report formatting options only template handling.
  *
  * @param p_object_name The name of the object tested for existance.
  * @param p_schema_name The schema of the object tested.
  * @param p_object_type The object type as label of the object that was tested. See otap_util.CFG_LABEL constants.
  * @param p_sub_object Optional sub object, like functions of a package or columns of a table. If set, TEMPLATE_XEXISTS is used.
  * @param p_test_desc The test description of the related test if any.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted and reduced exists test message. Restricted to 4000 chars.
  */
  FUNCTION get_exists_msg( p_object_name IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         , p_schema_name IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         , p_object_type IN VARCHAR2 DEFAULT NULL
                         , p_sub_object  IN VARCHAR2 DEFAULT NULL
                         , p_test_desc   IN VARCHAR2 DEFAULT NULL
                         , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_exists_c_msg
  * Builds a user message for the schema constraint exist test function based on given values from template. Will always
  * reduce the string. No report formatting options only template handling.
  *
  * @param p_table_name The name of the table tested for constraint existance.
  * @param p_schema_name The schema of the object tested.
  * @param p_cons_type The constraint type as label of the constraint that was tested. See otap_util.CFG_LABEL constants.
  * @param p_column Optional column specification for the constraint. If set, TEMPLATE_CXEXISTS is used.
  * @param p_constraint Optional constraint name.
  * @param p_test_desc The test description of the related test if any.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted and reduced exists test message. Restricted to 4000 chars.
  */
  FUNCTION get_exists_c_msg( p_table_name  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           , p_schema_name IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           , p_cons_type   IN VARCHAR2 DEFAULT NULL
                           , p_column      IN VARCHAR2 DEFAULT NULL
                           , p_constraint  IN VARCHAR2 DEFAULT NULL
                           , p_test_desc   IN VARCHAR2 DEFAULT NULL
                           , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_exists_f_msg
  * Builds a user message for the schema exist test functions with a related object, based on given values from template. Will always
  * reduce the string. No report formatting options only template handling.
  *
  * @param p_schema_name The schema of the object tested.
  * @param p_check_object The name of the object tested for existance.
  * @param p_check_type The object type as label of the object that was tested. See otap_util.CFG_LABEL constants.
  * @param p_rel_object_type The object type as label of the related object. See otap_util.CFG_LABEL constants.
  * @param p_rel_object The related object name.
  * @param p_rel_subobject Optional related subobject. If set, TEMPLATE_EXISTS_FX is used.
  * @param p_test_desc The test description of the related test if any.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted and reduced exists test message. Restricted to 4000 chars.
  */
  FUNCTION get_exists_f_msg( p_schema_name     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           , p_check_object    IN VARCHAR2 DEFAULT NULL
                           , p_check_type      IN VARCHAR2 DEFAULT NULL
                           , p_rel_object_type IN VARCHAR2 DEFAULT NULL
                           , p_rel_object      IN VARCHAR2 DEFAULT NULL
                           , p_rel_subobject   IN VARCHAR2 DEFAULT NULL
                           , p_test_desc       IN VARCHAR2 DEFAULT NULL
                           , p_language_id     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                           )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_report.get_match_msg
  * Builds a user message for the logic compare test function based on given values from template. Will always
  * reduce the string. No report formatting options only template handling.
  *
  * @param p_match_type The object type as label that was compared as defined by matching function (BOOLEAN, VARCHAR2, NUMBER, DATE). See otap_util.CFG_LABEL constants.
  * @param p_match_data The data of the compare as string, e.g. 'my string to compare', 2, TRUE ...
  * @param p_test_desc The test description of the related test if any.
  * @param p_language_id A valid or existing language id.
  *
  * @return The formatted and reduced matches test message. Restricted to 4000 chars.
  */
  FUNCTION get_match_msg( p_match_type  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                        , p_match_data  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                        , p_test_desc   IN VARCHAR2 DEFAULT NULL
                        , p_language_id IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                        )
    RETURN VARCHAR2
  ;

END;
/