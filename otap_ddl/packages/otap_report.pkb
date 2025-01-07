-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_report
AS

  -- for description see header file
  FUNCTION decorate( p_string     IN VARCHAR2
                   , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                   , p_decoration IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR
                   )
    RETURN VARCHAR2
  IS
    l_border           INTEGER;
    l_layout           VARCHAR2(1 CHAR);
    l_decoration       VARCHAR2(1 CHAR);
    l_string_size      INTEGER;
    l_max_title_length INTEGER;
    l_min_fill         INTEGER;
    l_min_length       INTEGER;
    l_string           VARCHAR2(32767 CHAR);
    l_return_text      VARCHAR2(32767 CHAR);
  BEGIN
    l_border           := otap_config_util.get_default_border;
    l_layout           := otap_string.check_layout(otap_config_util.get_default_layout);
    l_decoration       := otap_string.check_decoration(p_decoration);
    l_string_size      := otap_string.check_string_size(NVL(LENGTH(p_string), 0));
    l_string           := otap_string.reduce(p_string, l_string_size);
    l_max_title_length := otap_string.check_title_size(l_string_size, l_border);
    l_min_fill         := GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), l_max_title_length);
    l_min_length       := otap_string.line_size(l_max_title_length, l_border);
    l_return_text      := otap_string.decorate(l_string, l_decoration, l_min_length, l_layout, l_border);
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.decorate', 'Create decorated report line');
      RAISE;
  END decorate;

  FUNCTION borderless( p_string     IN VARCHAR2
                     , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                     )
    RETURN VARCHAR2
  IS
    l_border      INTEGER;
    l_layout      VARCHAR2(1 CHAR);
    l_string_size INTEGER;
    l_min_fill    INTEGER;
    l_min_length  INTEGER;
    l_string      VARCHAR2(32767 CHAR);
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_border      := otap_config_util.get_default_border;
    l_layout      := otap_string.check_layout(otap_config_util.get_default_layout);
    l_string_size := otap_string.check_string_size(NVL(LENGTH(p_string), 0));
    l_string      := otap_string.reduce(p_string, l_string_size);
    l_min_fill    := GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), l_string_size);
    l_min_length  := otap_string.line_size(l_string_size, l_border);
    l_return_text := otap_string.borderless(l_string, l_min_length, l_layout);
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.borderless', 'Create borderless report line');
      RAISE;
  END borderless;

  FUNCTION get_report_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_config_util.get_text_report_start
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_header_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_header', 'Create report header');
      RAISE;
  END get_report_header;

  FUNCTION get_report_total(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_config_util.get_text_report_total
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_header_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_total', 'Create report totals header');
      RAISE;
  END get_report_total;

  FUNCTION get_report_total_details( p_sets         IN INTEGER  DEFAULT 0
                                   , p_groups       IN INTEGER  DEFAULT 0
                                   , p_names        IN INTEGER  DEFAULT 0
                                   , p_descriptions IN INTEGER  DEFAULT 0
                                   , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                                   )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- fetch template: 'sets: @sets@ groups: @groups@ names: @names@ descriptions: @descs@'
    l_template_text := otap_config_util.get_report_total_template;
    -- replace variables
    l_template_text := REPLACE(l_template_text, '@sets@', TRIM(TO_CHAR(NVL(p_sets, 0))));
    l_template_text := REPLACE(l_template_text, '@groups@', TRIM(TO_CHAR(NVL(p_groups, 0))));
    l_template_text := REPLACE(l_template_text, '@names@', TRIM(TO_CHAR(NVL(p_names, 0))));
    l_template_text := REPLACE(l_template_text, '@descs@', TRIM(TO_CHAR(NVL(p_descriptions, 0))));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_total_details', 'Report totals template replacement');
      RAISE;
  END get_report_total_details;

  FUNCTION get_report_footer(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_config_util.get_text_report_end
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_header_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_footer', 'Create report footer');
      RAISE;
  END get_report_footer;

  FUNCTION get_result_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.borderless( otap_config_util.get_text_result_header
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_result_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_result_header', 'Create result header');
      RAISE;
  END get_result_header;

  FUNCTION get_result_underline(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.borderless( otap_config_util.get_format_result_header
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_result_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_result_underline', 'otap_config_util.get_format_result_header');
      RAISE;
  END get_result_underline;

  FUNCTION get_test_count_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_config_util.get_text_test_count_header
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_header_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_test_count_header', 'Create test count header');
      RAISE;
  END get_test_count_header;

  FUNCTION get_summary( p_status   IN VARCHAR2 DEFAULT otap_constants.OTAP_TEXT_TEST_UNDEFINED
                      , p_runtime  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                      , p_runs     IN NUMBER   DEFAULT 0
                      , p_errors   IN NUMBER   DEFAULT 0
                      , p_issues   IN NUMBER   DEFAULT 0
                      , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                      )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- fetch template
    l_template_text := otap_config_util.get_summary_template;
    -- replace variables
    l_template_text := REPLACE(l_template_text, '@status@', NVL(p_status, otap_config_util.get_text_summary_error));
    l_template_text := REPLACE(l_template_text, '@runtime@', NVL(p_runtime, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@runs@', NVL(TRIM(TO_CHAR(p_runs)), otap_constants.OTAP_CHAR_NA) );
    l_template_text := REPLACE(l_template_text, '@errors@', NVL(TRIM(TO_CHAR(p_errors)), otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@issues@', NVL(TRIM(TO_CHAR(p_issues)), otap_constants.OTAP_CHAR_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_summary', 'Summary template replacement');
      RAISE;
  END get_summary;

  FUNCTION get_error_result_header( p_test_name IN VARCHAR2
                                  , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                                  )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_config_util.get_errors_template;
    l_template_text := REPLACE(l_template_text, '@testname@', NVL(p_test_name, otap_constants.OTAP_CHAR_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_name_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_error_result_header', 'Build error result header by template');
      RAISE;
  END get_error_result_header;

  FUNCTION get_error_details( p_test_desc  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                            , p_error_info IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                            , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                            )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_config_util.get_error_details_template;
    l_template_text := REPLACE(l_template_text, '@testdesc@', NVL(p_test_desc, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@errorinfo@', NVL(p_error_info, otap_constants.OTAP_CHAR_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_error_details', 'Build error detail row by template');
      RAISE;
  END get_error_details;

  FUNCTION get_no_data_text( p_session_id IN NUMBER
                           , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                           )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text    := otap_config_util.get_no_data_template;
    l_template_text    := REPLACE(l_template_text, '@sessionid@', NVL(TRIM(TO_CHAR(p_session_id)), otap_constants.OTAP_CHAR_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_no_data_text', 'Build no data message by template');
      RAISE;
  END get_no_data_text;

  FUNCTION get_session_id_text( p_session_id IN NUMBER
                              , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                              )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text    := otap_config_util.get_session_id_template;
    l_template_text    := REPLACE(l_template_text, '@sessionid@', NVL(TRIM(TO_CHAR(p_session_id)), otap_constants.OTAP_CHAR_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_session_id_text', 'Build session id message by template');
      RAISE;
  END get_session_id_text;

  FUNCTION get_set_text( p_test_set IN VARCHAR2
                       , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                       )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_config_util.get_set_template;
    l_template_text := REPLACE(l_template_text, '@testset@', NVL(TRIM(p_test_set), otap_constants.OTAP_CHAR_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_set_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_set_text', 'Build test set message by template');
      RAISE;
  END get_set_text;

  FUNCTION get_group_text( p_test_group IN VARCHAR2
                         , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                         )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_config_util.get_group_template;
    l_template_text := REPLACE(l_template_text, '@testgroup@', NVL(TRIM(p_test_group), otap_constants.OTAP_CHAR_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_group_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_group_text', 'Build test group message by template');
      RAISE;
  END get_group_text;

  FUNCTION get_test_name_text( p_test_name IN VARCHAR2
                             , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_config_util.get_test_name_template;
    l_template_text := REPLACE(l_template_text, '@testname@', NVL(TRIM(p_test_name), otap_constants.OTAP_CHAR_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                         , otap_config_util.get_format_name_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_test_name_text', 'Build test name message by template');
      RAISE;
  END get_test_name_text;

  FUNCTION get_result_line( p_test_state  IN VARCHAR2 DEFAULT otap_constants.OTAP_TEXT_TEST_UNDEFINED
                          , p_issue_state IN VARCHAR2 DEFAULT otap_constants.OTAP_TEXT_TEST_UNDEFINED
                          , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                          , p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                          , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                          )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
    l_test_state    VARCHAR2(32767 CHAR);
    l_issue_state   VARCHAR2(32767 CHAR);
    l_runtime       VARCHAR2(32767 CHAR);
    l_desc          VARCHAR2(32767 CHAR);
    l_runtime_len   INTEGER;
    l_desc_len      INTEGER;
  BEGIN
    -- get and prepare template
    -- assigning directly the runtime length leads to different result 29 instead of 19 which is the expected value
    -- fetch by SQL
    SELECT LENGTH(TRIM((SYSTIMESTAMP - SYSTIMESTAMP) DAY TO SECOND)) INTO l_runtime_len FROM dual;
    -- DOES NOT WORK correct: l_runtime_len := LENGTH(TRIM((SYSTIMESTAMP - SYSTIMESTAMP) DAY TO SECOND));
    l_desc_len    := NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH) - ((2 * otap_config_util.get_length_test_state) + l_runtime_len + 3);
    IF l_desc_len <= 0
    THEN
      -- wrong configuration, use a default, display will be not correct but possible
      l_desc_len := otap_constants.OTAP_REPORT_MIN_FILL_LENGTH;
    END IF;
    -- states must be padded to max state size for correct formatting and consider the layout
    IF otap_config_util.get_default_layout = otap_constants.OTAP_LAYOUT_RIGHT
    THEN
      l_test_state  := otap_string.cut(LPAD(NVL(p_test_state, otap_constants.OTAP_CHAR_NA), otap_config_util.get_length_test_state, ' '), otap_config_util.get_length_test_state);
      l_issue_state := otap_string.cut(LPAD(NVL(p_issue_state, otap_constants.OTAP_CHAR_NA), otap_config_util.get_length_test_state, ' '), otap_config_util.get_length_test_state);
      l_runtime     := otap_string.cut(LPAD(NVL(p_runtime, otap_constants.OTAP_CHAR_NA), l_runtime_len, ' '), l_runtime_len);
      l_desc        := otap_string.cut(LPAD(NVL(p_test_desc, otap_constants.OTAP_CHAR_NA), l_desc_len, ' '), l_desc_len);
    ELSE
      -- treat middle and left the same way
      l_test_state  := otap_string.cut(RPAD(NVL(p_test_state, otap_constants.OTAP_CHAR_NA), otap_config_util.get_length_test_state, ' '), otap_config_util.get_length_test_state);
      l_issue_state := otap_string.cut(RPAD(NVL(p_issue_state, otap_constants.OTAP_CHAR_NA), otap_config_util.get_length_test_state, ' '), otap_config_util.get_length_test_state);
      l_runtime     := otap_string.cut(RPAD(NVL(p_runtime, otap_constants.OTAP_CHAR_NA), l_runtime_len, ' '), l_runtime_len);
      l_desc        := otap_string.cut(RPAD(NVL(p_test_desc, otap_constants.OTAP_CHAR_NA), l_desc_len, ' '), l_desc_len);
    END IF;
    l_template_text := otap_config_util.get_result_line_template;
    l_template_text := REPLACE(l_template_text, '@teststate@', l_test_state);
    l_template_text := REPLACE(l_template_text, '@issuestate@', l_issue_state);
    l_template_text := REPLACE(l_template_text, '@runtime@', l_runtime);
    l_template_text := REPLACE(l_template_text, '@testdesc@', l_desc);
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_config_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_result_line', 'Build result line by template');
      RAISE;
  END get_result_line;

  FUNCTION get_count_desc( p_tests_run       IN INTEGER  DEFAULT 0
                         , p_tests_expected  IN INTEGER  DEFAULT 0
                         )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_return_text := otap_config_util.get_count_desc_template;
    l_return_text := REPLACE(l_return_text, '@testsrun@', TRIM(TO_CHAR(NVL(p_tests_run, 0))));
    l_return_text := REPLACE(l_return_text, '@testsexpected@', TRIM(TO_CHAR(NVL(p_tests_expected, 0))));
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_count_desc', 'Build test count result by template');
      RAISE;
  END get_count_desc;

  FUNCTION get_separator_line( p_char     IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR
                             , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  IS
    l_char        VARCHAR2(1 CHAR);
    l_return_text VARCHAR2(32767 CHAR);
    l_line             otap_config.config_value%TYPE;
  BEGIN
    l_char := otap_string.check_decoration(p_char);
    l_return_text := otap_report.decorate( NULL
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_REPORT_MIN_FILL_LENGTH), otap_config_util.get_length_headers)
                                         , l_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_separator_line', 'Build separator line');
      RAISE;
  END get_separator_line;

  FUNCTION get_has_table_msg( p_table_name  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                            , p_schema_name IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                            )
    RETURN VARCHAR2
  IS
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    l_template_text := otap_config_util.get_fn_has_table_template;
    l_template_text := REPLACE(l_template_text, '@schema@', NVL(p_schema_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@tablename@', NVL(p_table_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := otap_string.reduce(l_template_text, 4000);
    RETURN l_template_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_has_table_msg', 'Build has_table result message');
      RAISE;
  END get_has_table_msg;

  FUNCTION get_has_column_msg( p_table_name  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                             , p_column_name IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                             , p_schema_name IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                             )
    RETURN VARCHAR2
  IS
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    l_template_text := otap_config_util.get_fn_has_column_template;
    l_template_text := REPLACE(l_template_text, '@schema@', NVL(p_schema_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@tablename@', NVL(p_table_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@column@', NVL(p_column_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := otap_string.reduce(l_template_text, 4000);
    RETURN l_template_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_has_column_msg', 'Build has_column result message');
      RAISE;
  END get_has_column_msg;

  FUNCTION get_has_package_msg( p_package_name  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                              , p_schema_name   IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                              , p_package_type  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                              )
    RETURN VARCHAR2
  IS
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    l_template_text := otap_config_util.get_fn_has_package_template;
    l_template_text := REPLACE(l_template_text, '@schema@', NVL(p_schema_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@package@', NVL(p_package_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@packagetype@', NVL(p_package_type, otap_constants.OTAP_CHAR_NA));
    l_template_text := otap_string.reduce(l_template_text, 4000);
    RETURN l_template_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_has_package_msg', 'Build has_package result message');
      RAISE;
  END get_has_package_msg;

  FUNCTION get_has_procedure_msg( p_procedure_name  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                                , p_schema_name     IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                                , p_procedure_type  IN VARCHAR2 DEFAULT otap_constants.OTAP_CHAR_NA
                                , p_package_name    IN VARCHAR2 DEFAULT NULL
                                )
    RETURN VARCHAR2
  IS
    l_template_text  VARCHAR2(32767 CHAR);
    l_procedure      VARCHAR2(1024 CHAR);
  BEGIN
    -- prepare
    l_procedure := NVL(p_procedure_name, otap_constants.OTAP_CHAR_NA);
    IF p_package_name IS NOT NULL
    THEN
      l_procedure := TRIM(p_package_name) || '.' || l_procedure;
    END IF;
    -- replace
    l_template_text := otap_config_util.get_fn_has_procedure_template;
    l_template_text := REPLACE(l_template_text, '@proctype@', NVL(INITCAP(p_procedure_type), otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@proc@', NVL(l_procedure, otap_constants.OTAP_CHAR_NA));
    l_template_text := REPLACE(l_template_text, '@schema@', NVL(p_schema_name, otap_constants.OTAP_CHAR_NA));
    l_template_text := otap_string.reduce(l_template_text, 4000);
    RETURN l_template_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_has_procedure_msg', 'Build has_procedure result message');
      RAISE;
  END get_has_procedure_msg;

END;
/
