-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides utility functions and procedures for table OTAP_CONFIG.
CREATE OR REPLACE PACKAGE otap_config_util
AS
  /**
  * Provides internal functions and procedures for OTAP_CONFIG.
  *
  * Package is not fail safe. Exceptions are raised after trying to log them.
  */

  /** FUNCTION otap_config_util.get_config_value
  * Gets the config value as defined in OTAP_CONFIG for the given config_name. The name
  * must match an existing name, will be transformed to upper case for search.
  *
  * @param p_config_name A valid OTAP configuration name.
  *
  * @return The configuration value for the given name. Errors that can be handled will return defaults. Exceptions will be raised.
  */
  FUNCTION get_config_value(p_config_name IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_config_util.set_config_value
  * Sets the config value as defined in OTAP_CONFIG for the given config_name. The name
  * must match an existing name, will be transformed to upper case for search. The value
  * must match type and length requirements. Errors that can be handled will set defaults
  * or leave value unchanged. Exceptions will be raised.
  *
  * @param p_config_name A valid OTAP configuration name.
  * @param p_config_value The new value for the given configuration name.
  */
  PROCEDURE set_config_value( p_config_name  IN VARCHAR2
                            , p_config_value IN VARCHAR2
                            )
  ;

  /** FUNCTION otap_config_util.get_debug
  * Returns the setting for DEBUG_MODE, defined in OTAP_CONFIG. Returns the numerical
  * representation of boolean, where TRUE = 1 and FALSE = 0.
  *
  * @return The setting of DEBUG_MODE in OTAP_CONFIG.
  */
  FUNCTION get_debug
    RETURN NUMBER
  ;

  /** PROCEDURE otap_config_util.set_debug
  * Sets the debug state in OTAP_CONFIG. On errors debug state will be deactivated or
  * left unchanged. Uses the numerical representation of boolean, where TRUE = 1 and
  * FALSE = 0. Does a basic validation.
  *
  * @param p_active The active (1) or inactive (0) debug state.
  */
  PROCEDURE set_debug(p_active IN NUMBER DEFAULT otap_constants.OTAP_NUM_FALSE);

  /** FUNCTION otap_config_util.preserve_days
  * @return The setting of PRESERVE_DAYS in OTAP_CONFIG.
  */
  FUNCTION preserve_days
    RETURN NUMBER
  ;

  /** PROCEDURE otap_config_util.set_preserve_days
  * Sets preserve days in OTAP_CONFIG. On errors preserve days will be set to default or
  * left unchanged. Allowed are values between 1 and 7 days as defined in otap_constants.
  * Does a basic validation.
  *
  * @param p_preserve_days The amount of days to preserve test results.
  */
  PROCEDURE set_preserve_days(p_preserve_days IN NUMBER DEFAULT otap_constants.OTAP_PRESERVE_DAYS);

  /** FUNCTION otap_config_util.delete_delay
  * @return The setting of DELETE_DELAY in OTAP_CONFIG.
  */
  FUNCTION delete_delay
    RETURN NUMBER
  ;
  /** PROCEDURE otap_config_util.set_delete_delay
  * Sets delete delay seconds in OTAP_CONFIG. On errors delete delay will be set to default or
  * left unchanged. Allowed are values between 1 and 600 seconds as defined in otap_constants.
  * Does a basic validation.
  *
  * @param p_delete_delay The amount of seconds to wait between batch size deletes.
  */
  PROCEDURE set_delete_delay(p_delete_delay IN NUMBER DEFAULT otap_constants.OTAP_DELETE_DELAY);

  /** FUNCTION otap_config_util.delete_batch_size
  * @return The setting of DELETE_BATCH_SIZE in OTAP_CONFIG.
  */
  FUNCTION delete_batch_size
    RETURN NUMBER
  ;

  /** PROCEDURE otap_config_util.set_delete_batch_size
  * Sets delete batch size in OTAP_CONFIG. On errors delete batch size will be set to default or
  * left unchanged. Allowed are values between 100 and 10000 rows to delete before commit as
  * defined in otap_constants. Does a basic validation.
  *
  * @param p_delete_batch_size The amount of rows to delete as batch before commit.
  */
  PROCEDURE set_delete_batch_size(p_delete_batch_size IN NUMBER DEFAULT otap_constants.OTAP_DELETE_BATCH_SIZE);

  /** FUNCTION otap_config_util.get_default_prefix
  * @return The setting of DEFAULT_PREFIX in OTAP_CONFIG.
  */
  FUNCTION get_default_prefix
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_config_util.set_default_prefix
  * Sets the default prefix in OTAP_CONFIG. On errors the default prefix will be set to default or
  * left unchanged. No underscore allowed in the prefix, limited to length 4 chars. Does a basic validation.
  *
  * @param p_default_prefix The default prefix identifying test procedures for otap test runs.
  */
  PROCEDURE set_default_prefix(p_default_prefix IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_PREFIX);

  /** FUNCTION otap_config_util.get_default_layout
  * @return The setting of DEFAULT_LAYOUT in OTAP_CONFIG.
  */
  FUNCTION get_default_layout
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_config_util.set_default_layout
  * Sets the default layout orientation, right, left, middle. See otap_constants.OTAP_LAYOUT_RIGHT,
  * otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE.
  *
  * @param p_default_layout A valid layout value for right, left and middle as defined in OTAP_CONSTANTS.
  */
  PROCEDURE set_default_layout(p_default_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_DEFAULT);

  /** FUNCTION otap_config_util.get_default_result_layout
  * @return The setting of DEFAULT_RESULT_LAYOUT in OTAP_CONFIG.
  */
  FUNCTION get_default_result_layout
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_config_util.set_default_result_layout
  * Sets the default result layout orientation, right or left. See otap_constants.OTAP_LAYOUT_RIGHT and
  * otap_constants.OTAP_LAYOUT_LEFT.
  *
  * @param p_default_layout A valid layout value for right or left as defined in OTAP_CONSTANTS.
  */
  PROCEDURE set_default_result_layout(p_default_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_RESULT_LAYOUT_DEFAULT);

  /** FUNCTION otap_config_util.get_default_border
  * @return The setting of DEFAULT_BORDER in OTAP_CONFIG.
  */
  FUNCTION get_default_border
    RETURN NUMBER
  ;

  /** PROCEDURE otap_config_util.set_default_border
  * Sets the default border for decoration with the related set, group or name report object. Minimum is
  * two chars, one for decoration, one space between text and decoration.
  *
  * The border set will lead to (p_default_border -1) decoration chars and one space between decoration
  * and text.
  *
  * @param p_default_border A valid decoration border value, minimum 2.
  */
  PROCEDURE set_default_border(p_default_border IN NUMBER DEFAULT otap_constants.OTAP_BORDER_DEFAULT);

  /** FUNCTION otap_config_util.get_default_test_group
  *  @return The setting of DEFAULT_TEST_GROUP in OTAP_CONFIG.
  */
  FUNCTION get_default_test_group
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_length_test_state
  * Checks the defined text representations of passed, failed and undefined to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of test states defined in OTAP_CONFIG.
  */
  FUNCTION get_length_test_state
    RETURN NUMBER
  ;

  /** FUNCTION otap_config_util.get_length_summary_state
  * Checks the defined text representations of summary state SUCCESS and ERROR to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of summary states defined in OTAP_CONFIG.
  */
  FUNCTION get_length_summary_state
    RETURN NUMBER
  ;

  /** FUNCTION otap_config_util.get_length_headers
  * Checks the defined text representations of report headers to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of report headers defined in OTAP_CONFIG.
  */
  FUNCTION get_length_headers
    RETURN NUMBER
  ;

  /** FUNCTION otap_config_util.get_length_result_headers
  * Checks the defined text representations of result headers to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of result headers defined in OTAP_CONFIG.
  */
  FUNCTION get_length_result_headers
    RETURN NUMBER
  ;

  /** FUNCTION otap_config_util.test_result_to_text
  * Translate the numeric test state to the defined text representation. If test state
  * is not valid, will return the otap error indicator OTAP_ERROR.
  *
  * @param p_test_passed The numeric test state indicator.
  *
  * @return The text representation as defined in OTAP_CONFIG for the given test state or OTAP_ERROR.
  */
  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  ;

  /** FUNCTION otap_config_util.bool_to_text
  * Translate a boolean value to text like true or false.
  *
  * @param p_bool The boolean value.
  *
  * @return The text representation as defined in OTAP_CONFIG for the given boolean value.
  */
  FUNCTION bool_to_text(p_bool IN BOOLEAN)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.bool_to_yes_no_text
  * Translate a boolean value to text like Yes or No.
  *
  * @param p_bool The boolean value.
  *
  * @return The yes/no text representation as defined in OTAP_CONFIG for the given boolean value.
  */
  FUNCTION bool_to_yes_no_text(p_bool IN BOOLEAN)
    RETURN VARCHAR2
  ;

  -- only for convenience and clearer code

  /** FUNCTION otap_config_util.get_default_test_name
  *  @return The setting of DEFAULT_TEST_NAME in OTAP_CONFIG.
  */
  FUNCTION get_default_test_name
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_default_test_set
  *  @return The setting of DEFAULT_TEST_SET in OTAP_CONFIG.
  */
  FUNCTION get_default_test_set
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_errors_template
  *  @return The setting of ERRORS_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_errors_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_error_details_template
  *  @return The setting of ERROR_DETAILS_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_error_details_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_format_group_char
  *  @return The setting of FORMAT_GROUP_CHAR in OTAP_CONFIG.
  */
  FUNCTION get_format_group_char
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_format_header_char
  *  @return The setting of FORMAT_HEADER_CHAR in OTAP_CONFIG.
  */
  FUNCTION get_format_header_char
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_format_name_char
  *  @return The setting of FORMAT_NAME_CHAR in OTAP_CONFIG.
  */
  FUNCTION get_format_name_char
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_format_result_header
  *  @return The setting of FORMAT_RESULT_HEADER in OTAP_CONFIG.
  */
  FUNCTION get_format_result_header
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_format_set_char
  *  @return The setting of FORMAT_SET_CHAR in OTAP_CONFIG.
  */
  FUNCTION get_format_set_char
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_group_template
  *  @return The setting of GROUP_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_group_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_no_data_template
  *  @return The setting of NO_DATA_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_no_data_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_session_id_template
  *  @return The setting of SESSION_ID_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_session_id_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_set_template
  *  @return The setting of SET_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_set_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_summary_template
  *  @return The setting of SUMMARY_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_summary_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_test_name_template
  *  @return The setting of TEST_NAME_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_test_name_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_result_line_template
  *  @return The setting of RESULT_LINE_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_result_line_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_count_desc_template
  *  @return The setting of COUNT_DESC_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_count_desc_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_report_total_template
  *  @return The setting of REPORT_TOTAL_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_report_total_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_fn_has_table_template
  *  @return The setting of FN_HAS_TABLE_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_fn_has_table_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_fn_has_column_template
  *  @return The setting of FN_HAS_COLUMN_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_fn_has_column_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_fn_has_package_template
  *  @return The setting of FN_HAS_PACKAGE_TEMPLATE in OTAP_CONFIG.
  */
  FUNCTION get_fn_has_package_template
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_false
  *  @return The setting of TEXT_FALSE in OTAP_CONFIG.
  */
  FUNCTION get_text_false
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_false_no
  *  @return The setting of TEXT_FALSE_NO in OTAP_CONFIG.
  */
  FUNCTION get_text_false_no
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_report_end
  *  @return The setting of TEXT_REPORT_END in OTAP_CONFIG.
  */
  FUNCTION get_text_report_end
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_report_total
  *  @return The setting of OTAP_TEXT_REPORT_TOTAL in OTAP_CONFIG.
  */
  FUNCTION get_text_report_total
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_report_start
  *  @return The setting of TEXT_REPORT_START in OTAP_CONFIG.
  */
  FUNCTION get_text_report_start
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_result_header
  *  @return The setting of TEXT_RESULT_HEADER in OTAP_CONFIG.
  */
  FUNCTION get_text_result_header
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_test_count_header
  *  @return The setting of TEXT_TEST_COUNT_HEADER in OTAP_CONFIG.
  */
  FUNCTION get_text_test_count_header
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_test_count_name
  *  @return The setting of TEXT_TEST_COUNT_NAME in OTAP_CONFIG.
  */
  FUNCTION get_text_test_count_name
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_summary_error
  *  @return The setting of TEXT_SUMMARY_ERROR in OTAP_CONFIG.
  */
  FUNCTION get_text_summary_error
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_summary_success
  *  @return The setting of TEXT_SUMMARY_SUCCESS in OTAP_CONFIG.
  */
  FUNCTION get_text_summary_success
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_test_failed
  *  @return The setting of TEXT_TEST_FAILED in OTAP_CONFIG.
  */
  FUNCTION get_text_test_failed
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_test_passed
  *  @return The setting of TEXT_TEST_PASSED in OTAP_CONFIG.
  */
  FUNCTION get_text_test_passed
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_test_undefined
  *  @return The setting of TEXT_TEST_UNDEFINED in OTAP_CONFIG.
  */
  FUNCTION get_text_test_undefined
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_true
  *  @return The setting of TEXT_TRUE in OTAP_CONFIG.
  */
  FUNCTION get_text_true
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_config_util.get_text_true_yes
  *  @return The setting of TEXT_TRUE_YES in OTAP_CONFIG.
  */
  FUNCTION get_text_true_yes
    RETURN VARCHAR2
  ;

END;
/