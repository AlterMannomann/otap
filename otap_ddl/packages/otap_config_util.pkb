-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_config_util
AS
  -- for description see header file

  PROCEDURE set_config_value( p_config_name  IN VARCHAR2
                            , p_config_value IN VARCHAR2
                            )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE otap_config
       SET config_value = p_config_value
     WHERE config_name = UPPER(p_config_name)
    ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_config_util.set_config_value', 'UPDATE otap_config SET config_value = p_config_value WHERE config_name = UPPER(p_config_name)');
      RAISE;
  END set_config_value;

  FUNCTION get_debug
    RETURN NUMBER
  IS
  BEGIN
    RETURN TO_NUMBER(otap_util.get_config_value(otap_constants.OTAP_CFG_DEBUG_MODE));
  END get_debug;

  PROCEDURE set_debug(p_active IN NUMBER DEFAULT otap_constants.OTAP_NUM_FALSE)
  IS
    l_debug_mode otap_config.config_value%TYPE;
  BEGIN
    l_debug_mode := CASE
                      WHEN p_active = otap_constants.OTAP_NUM_TRUE
                      THEN TRIM(TO_CHAR(otap_constants.OTAP_NUM_TRUE))
                      ELSE TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE))
                    END
    ;
    set_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, l_debug_mode);
  END set_debug;

  FUNCTION preserve_days
    RETURN NUMBER
  IS
  BEGIN
    RETURN TO_NUMBER(otap_util.get_config_value(otap_util.CFG_PRESERVE_DAYS));
  END preserve_days;

  PROCEDURE set_preserve_days(p_preserve_days IN NUMBER DEFAULT otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)
  IS
    l_preserve otap_config.config_value%TYPE;
  BEGIN
    l_preserve := CASE
                    WHEN p_preserve_days BETWEEN otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MIN
                                             AND otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MAX
                    THEN TRIM(TO_CHAR(p_preserve_days))
                    ELSE TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS))
                  END
    ;
    set_config_value(otap_util.CFG_PRESERVE_DAYS, l_preserve);
  END set_preserve_days;

  FUNCTION delete_delay
    RETURN NUMBER
  IS
  BEGIN
    RETURN TO_NUMBER(otap_util.get_config_value(otap_util.CFG_DELETE_DELAY));
  END delete_delay;

  PROCEDURE set_delete_delay(p_delete_delay IN NUMBER DEFAULT otap_constants.OTAP_FALLBACK_DELETE_DELAY)
  IS
    l_delay otap_config.config_value%TYPE;
  BEGIN
    l_delay := CASE
                 WHEN p_delete_delay BETWEEN otap_constants.OTAP_FALLBACK_DELETE_DELAY_MIN
                                         AND otap_constants.OTAP_FALLBACK_DELETE_DELAY_MAX
                 THEN TRIM(TO_CHAR(p_delete_delay))
                 ELSE TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY))
               END
    ;
    set_config_value(otap_util.CFG_DELETE_DELAY, l_delay);
  END set_delete_delay;

  FUNCTION delete_batch_size
    RETURN NUMBER
  IS
  BEGIN
    RETURN TO_NUMBER(otap_util.get_config_value(otap_util.CFG_DELETE_BATCH_SIZE));
  END delete_batch_size;

  PROCEDURE set_delete_batch_size(p_delete_batch_size IN NUMBER DEFAULT otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)
  IS
    l_batch otap_config.config_value%TYPE;
  BEGIN
    l_batch := CASE
                 WHEN p_delete_batch_size BETWEEN otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN
                                              AND otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX
                 THEN TRIM(TO_CHAR(p_delete_batch_size))
                 ELSE TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE))
               END
    ;
    set_config_value(otap_util.CFG_DELETE_BATCH_SIZE, l_batch);
  END set_delete_batch_size;

  FUNCTION get_default_prefix
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_PREFIX);
  END get_default_prefix;

  PROCEDURE set_default_prefix(p_default_prefix IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX)
  IS
    l_prefix otap_config.config_value%TYPE;
  BEGIN
    l_prefix := CASE
                  WHEN LENGTH(p_default_prefix) > otap_constants.OTAP_NUM_PREFIX_MAX_SIZE
                    OR INSTR(p_default_prefix, '_') > 0
                  THEN otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                  ELSE p_default_prefix
                END
    ;
    set_config_value(otap_util.CFG_DEFAULT_PREFIX, l_prefix);
  END set_default_prefix;

  FUNCTION get_default_layout
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT);
  END get_default_layout;

  PROCEDURE set_default_layout(p_default_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT)
  IS
    l_layout otap_config.config_value%TYPE;
  BEGIN
    l_layout := CASE
                  WHEN p_default_layout NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_RIGHT)
                  THEN otap_constants.OTAP_LAYOUT_MIDDLE
                  ELSE p_default_layout
                END
    ;
    set_config_value(otap_util.CFG_DEFAULT_LAYOUT, l_layout);
  END set_default_layout;

  FUNCTION get_default_result_layout
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_RESULT_LAYOUT);
  END get_default_result_layout;

  PROCEDURE set_default_result_layout(p_default_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT)
  IS
    l_layout otap_config.config_value%TYPE;
  BEGIN
    l_layout := CASE
                  WHEN p_default_layout NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_RIGHT)
                  THEN otap_constants.OTAP_LAYOUT_LEFT
                  ELSE p_default_layout
                END
    ;
    set_config_value(otap_util.CFG_DEFAULT_RESULT_LAYOUT, l_layout);
  END set_default_result_layout;

  FUNCTION get_default_border
    RETURN NUMBER
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_BORDER);
  END get_default_border;

  PROCEDURE set_default_border(p_default_border IN NUMBER DEFAULT otap_constants.OTAP_FALLBACK_BORDER)
  IS
    l_border otap_config.config_value%TYPE;
  BEGIN
    l_border := CASE
                  WHEN p_default_border < 2
                  THEN TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)
                  ELSE TO_CHAR(p_default_border)
                END
    ;
    set_config_value(otap_util.CFG_DEFAULT_BORDER, l_border);
  END set_default_border;

  FUNCTION get_length_test_state
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_TEST_FAILED
                          , otap_util.CFG_TEXT_TEST_PASSED
                          , otap_util.CFG_TEXT_TEST_UNDEFINED
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_test_state', 'Get MAX length for config values');
      RAISE;
  END get_length_test_state;

  FUNCTION get_length_summary_state
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_SUMMARY_ERROR
                          , otap_util.CFG_TEXT_SUMMARY_SUCCESS
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_summary_state', 'Get MAX length for config values');
      RAISE;
  END get_length_summary_state;

  FUNCTION get_length_headers
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_REPORT_START
                          , otap_util.CFG_TEXT_REPORT_END
                          , otap_util.CFG_TEXT_REPORT_TOTAL
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_headers', 'Get MAX length for config values');
      RAISE;
  END get_length_headers;

  FUNCTION get_length_result_headers
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_RESULT_HEADER
                          , otap_util.CFG_TEXT_RESULT_LINE
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_result_headers', 'Get MAX length for config values');
      RAISE;
  END get_length_result_headers;

  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  IS
    l_translation otap_config.config_value%TYPE;
  BEGIN
    l_translation := CASE p_test_passed
                       WHEN otap_constants.OTAP_NUM_TEST_PASSED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED)
                       WHEN otap_constants.OTAP_NUM_TEST_FAILED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_FAILED)
                       WHEN otap_constants.OTAP_NUM_TEST_UNDEFINED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED)
                       ELSE otap_constants.OTAP_INTERNAL_ERROR
                     END
    ;
    RETURN l_translation;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_config_util.test_result_to_text', 'Translate test state to text');
      RAISE;
  END test_result_to_text;

  FUNCTION bool_to_text(p_bool IN BOOLEAN)
    RETURN VARCHAR2
  IS
    l_translation otap_config.config_value%TYPE;
  BEGIN
    l_translation := CASE
                       WHEN p_bool
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TRUE)
                       ELSE otap_util.get_config_value(otap_util.CFG_TEXT_FALSE)
                     END
    ;
    RETURN l_translation;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_config_util.bool_to_text', 'Translate boolean to text');
      RAISE;
  END bool_to_text;

  FUNCTION bool_to_yes_no_text(p_bool IN BOOLEAN)
    RETURN VARCHAR2
  IS
    l_translation otap_config.config_value%TYPE;
  BEGIN
    l_translation := CASE
                       WHEN p_bool
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TRUE_YES)
                       ELSE otap_util.get_config_value(otap_util.CFG_TEXT_FALSE_NO)
                     END
    ;
    RETURN l_translation;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_config_util.bool_to_yes_no_text', 'Translate boolean to yes-no text');
      RAISE;
  END bool_to_yes_no_text;

  -- convenience functions
  FUNCTION get_default_test_group
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_TEST_GROUP);
  END get_default_test_group;

  FUNCTION get_default_test_name
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_TEST_NAME);
  END get_default_test_name;

  FUNCTION get_default_test_set
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_DEFAULT_TEST_SET);
  END get_default_test_set;

  FUNCTION get_template_errors
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERRORS);
  END get_template_errors;

  FUNCTION get_template_error_details
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERROR_DETAILS);
  END get_template_error_details;

  FUNCTION get_format_group_char
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_FORMAT_GROUP_CHAR);
  END get_format_group_char;

  FUNCTION get_format_header_char
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR);
  END get_format_header_char;

  FUNCTION get_format_name_char
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_FORMAT_NAME_CHAR);
  END get_format_name_char;

  FUNCTION get_text_result_line
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_LINE);
  END get_text_result_line;

  FUNCTION get_format_set_char
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_FORMAT_SET_CHAR);
  END get_format_set_char;

  FUNCTION get_template_group
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_GROUP);
  END get_template_group;

  FUNCTION get_template_no_data
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_NO_DATA);
  END get_template_no_data;

  FUNCTION get_template_session_id
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_SESSION_ID);
  END get_template_session_id;

  FUNCTION get_template_set
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_SET);
  END get_template_set;

  FUNCTION get_template_summary
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_SUMMARY);
  END get_template_summary;

  FUNCTION get_template_test_name
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_TEST_NAME);
  END get_template_test_name;

  FUNCTION get_template_result_line
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_RESULT_LINE);
  END get_template_result_line;

  FUNCTION get_template_count_desc
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_COUNT_DESC);
  END get_template_count_desc;

  FUNCTION get_template_report_total
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_REPORT_TOTAL);
  END get_template_report_total;

  FUNCTION get_template_fn_has_table
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_FN_HAS_TABLE);
  END get_template_fn_has_table;

  FUNCTION get_template_fn_has_column
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_FN_HAS_COLUMN);
  END get_template_fn_has_column;

  FUNCTION get_template_fn_has_package
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_FN_HAS_PACKAGE);
  END get_template_fn_has_package;

  FUNCTION get_template_fn_has_procedure
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_FN_HAS_PROCEDURE);
  END get_template_fn_has_procedure;

  FUNCTION get_template_fn_has_trigger
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_FN_HAS_TRIGGER);
  END get_template_fn_has_trigger;

  FUNCTION get_template_exists
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_EXISTS);
  END get_template_exists;

  FUNCTION get_template_xexists
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEMPLATE_EXISTSX);
  END get_template_xexists;

  FUNCTION get_text_false
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_FALSE);
  END get_text_false;

  FUNCTION get_text_false_no
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_FALSE_NO);
  END get_text_false_no;

  FUNCTION get_text_report_end
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_END);
  END get_text_report_end;

  FUNCTION get_text_report_total
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_TOTAL);
  END get_text_report_total;

  FUNCTION get_text_report_start
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_START);
  END get_text_report_start;

  FUNCTION get_text_result_header
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_HEADER);
  END get_text_result_header;

  FUNCTION get_text_test_count_header
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_HEADER);
  END get_text_test_count_header;

  FUNCTION get_text_test_count_name
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_NAME);
  END get_text_test_count_name;

  FUNCTION get_text_summary_error
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_SUMMARY_ERROR);
  END get_text_summary_error;

  FUNCTION get_text_summary_success
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_SUMMARY_SUCCESS);
  END get_text_summary_success;

  FUNCTION get_text_test_failed
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_FAILED);
  END get_text_test_failed;

  FUNCTION get_text_test_passed
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED);
  END get_text_test_passed;

  FUNCTION get_text_test_undefined
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED);
  END get_text_test_undefined;

  FUNCTION get_text_true
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TRUE);
  END get_text_true;

  FUNCTION get_text_true_yes
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN otap_util.get_config_value(otap_util.CFG_TEXT_TRUE_YES);
  END get_text_true_yes;

END;
/