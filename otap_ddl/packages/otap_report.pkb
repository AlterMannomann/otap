-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_report
AS

  -- for description see header file
  FUNCTION decorate( p_string     IN VARCHAR2
                   , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_decoration IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
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
    l_border           := otap_util.get_config_value(otap_util.CFG_DEFAULT_BORDER);
    l_layout           := otap_string.check_layout(otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT));
    l_decoration       := otap_string.check_decoration(p_decoration);
    l_string_size      := otap_string.check_string_size(NVL(LENGTH(p_string), 0));
    l_string           := otap_string.reduce(p_string, l_string_size);
    l_max_title_length := otap_string.check_title_size(l_string_size, l_border);
    l_min_fill         := GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), l_max_title_length);
    l_min_length       := otap_string.line_size(l_max_title_length, l_border);
    l_return_text      := otap_string.decorate(l_string, l_decoration, l_min_length, l_layout, l_border);
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.decorate', 'Create decorated report line');
      RAISE;
  END decorate;

  FUNCTION borderless( p_string     IN VARCHAR2
                     , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
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
    l_border      := otap_util.get_config_value(otap_util.CFG_DEFAULT_BORDER);
    l_layout      := otap_string.check_layout(otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT));
    l_string_size := otap_string.check_string_size(NVL(LENGTH(p_string), 0));
    l_string      := otap_string.reduce(p_string, l_string_size);
    l_min_fill    := GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), l_string_size);
    l_min_length  := otap_string.line_size(l_string_size, l_border);
    l_return_text := otap_string.borderless(l_string, l_min_length, l_layout);
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.borderless', 'Create borderless report line');
      RAISE;
  END borderless;

  FUNCTION get_report_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_START)
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_header', 'Create report header');
      RAISE;
  END get_report_header;

  FUNCTION get_report_total(p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_TOTAL)
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR)
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
                                   , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                   )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- fetch template: 'sets: @sets@ groups: @groups@ names: @names@ descriptions: @descs@'
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_REPORT_TOTAL);
    -- replace variables
    l_template_text := REPLACE(l_template_text, '@sets@', TRIM(TO_CHAR(NVL(p_sets, 0))));
    l_template_text := REPLACE(l_template_text, '@groups@', TRIM(TO_CHAR(NVL(p_groups, 0))));
    l_template_text := REPLACE(l_template_text, '@names@', TRIM(TO_CHAR(NVL(p_names, 0))));
    l_template_text := REPLACE(l_template_text, '@descs@', TRIM(TO_CHAR(NVL(p_descriptions, 0))));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_total_details', 'Report totals template replacement');
      RAISE;
  END get_report_total_details;

  FUNCTION get_report_footer(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_END)
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_report_footer', 'Create report footer');
      RAISE;
  END get_report_footer;

  FUNCTION get_result_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.borderless( otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_HEADER)
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_result_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_result_header', 'Create result header');
      RAISE;
  END get_result_header;

  FUNCTION get_result_underline(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.borderless( otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_LINE)
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_result_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_result_underline', 'otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_LINE)');
      RAISE;
  END get_result_underline;

  FUNCTION get_test_count_header(p_min_fill IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN VARCHAR2
  IS
    l_return_text VARCHAR2(32767 CHAR);
  BEGIN
    l_return_text := otap_report.decorate( otap_util.get_config_value(otap_util.CFG_TEXT_TEST_COUNT_HEADER)
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_test_count_header', 'Create test count header');
      RAISE;
  END get_test_count_header;

  FUNCTION get_summary( p_status   IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                      , p_runtime  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                      , p_runs     IN NUMBER   DEFAULT 0
                      , p_errors   IN NUMBER   DEFAULT 0
                      , p_issues   IN NUMBER   DEFAULT 0
                      , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                      )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- fetch template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SUMMARY);
    -- replace variables
    l_template_text := REPLACE(l_template_text, '@status@', NVL(p_status, otap_util.get_config_value(otap_util.CFG_TEXT_SUMMARY_ERROR)));
    l_template_text := REPLACE(l_template_text, '@runtime@', NVL(p_runtime, otap_constants.OTAP_INTERNAL_NA));
    l_template_text := REPLACE(l_template_text, '@runs@', NVL(TRIM(TO_CHAR(p_runs)), otap_constants.OTAP_INTERNAL_NA) );
    l_template_text := REPLACE(l_template_text, '@errors@', NVL(TRIM(TO_CHAR(p_errors)), otap_constants.OTAP_INTERNAL_NA));
    l_template_text := REPLACE(l_template_text, '@issues@', NVL(TRIM(TO_CHAR(p_issues)), otap_constants.OTAP_INTERNAL_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_summary', 'Summary template replacement');
      RAISE;
  END get_summary;

  FUNCTION get_error_result_header( p_test_name IN VARCHAR2
                                  , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                                  )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERRORS);
    l_template_text := REPLACE(l_template_text, '@testname@', NVL(p_test_name, otap_constants.OTAP_INTERNAL_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_NAME_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_error_result_header', 'Build error result header by template');
      RAISE;
  END get_error_result_header;

  FUNCTION get_error_details( p_test_desc  IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_error_info IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                            , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                            )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERROR_DETAILS);
    l_template_text := REPLACE(l_template_text, '@testdesc@', NVL(p_test_desc, otap_constants.OTAP_INTERNAL_NA));
    l_template_text := REPLACE(l_template_text, '@errorinfo@', NVL(p_error_info, otap_constants.OTAP_INTERNAL_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_error_details', 'Build error detail row by template');
      RAISE;
  END get_error_details;

  FUNCTION get_no_data_text( p_session_id IN NUMBER
                           , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                           )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text    := otap_util.get_config_value(otap_util.CFG_TEMPLATE_NO_DATA);
    l_template_text    := REPLACE(l_template_text, '@sessionid@', NVL(TRIM(TO_CHAR(p_session_id)), otap_constants.OTAP_INTERNAL_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_no_data_text', 'Build no data message by template');
      RAISE;
  END get_no_data_text;

  FUNCTION get_session_id_text( p_session_id IN NUMBER
                              , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                              )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text    := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SESSION_ID);
    l_template_text    := REPLACE(l_template_text, '@sessionid@', NVL(TRIM(TO_CHAR(p_session_id)), otap_constants.OTAP_INTERNAL_NA));
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                           )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_session_id_text', 'Build session id message by template');
      RAISE;
  END get_session_id_text;

  FUNCTION get_set_text( p_test_set IN VARCHAR2
                       , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                       )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SET);
    l_template_text := REPLACE(l_template_text, '@testset@', NVL(TRIM(p_test_set), otap_constants.OTAP_INTERNAL_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_SET_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_set_text', 'Build test set message by template');
      RAISE;
  END get_set_text;

  FUNCTION get_group_text( p_test_group IN VARCHAR2
                         , p_min_fill   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                         )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_GROUP);
    l_template_text := REPLACE(l_template_text, '@testgroup@', NVL(TRIM(p_test_group), otap_constants.OTAP_INTERNAL_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_GROUP_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_group_text', 'Build test group message by template');
      RAISE;
  END get_group_text;

  FUNCTION get_test_name_text( p_test_name IN VARCHAR2
                             , p_min_fill  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  IS
    l_return_text   VARCHAR2(32767 CHAR);
    l_template_text VARCHAR2(32767 CHAR);
  BEGIN
    -- get and fill template
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_TEST_NAME);
    l_template_text := REPLACE(l_template_text, '@testname@', NVL(TRIM(p_test_name), otap_constants.OTAP_INTERNAL_NA));
    -- get decorated
    l_return_text := otap_report.decorate( l_template_text
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
                                         , otap_util.get_config_value(otap_util.CFG_FORMAT_NAME_CHAR)
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_test_name_text', 'Build test name message by template');
      RAISE;
  END get_test_name_text;

  FUNCTION get_result_line( p_test_state  IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_issue_state IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED
                          , p_runtime     IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_test_desc   IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                          , p_min_fill    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
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
    l_desc_len    := NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH) - ((2 * otap_util.get_length_test_state) + l_runtime_len + 3);
    IF l_desc_len <= 0
    THEN
      -- wrong configuration, use a default, display will be not correct but possible
      l_desc_len := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
    END IF;
    -- states must be padded to max state size for correct formatting and consider the layout
    IF otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT) = otap_constants.OTAP_LAYOUT_RIGHT
    THEN
      l_test_state  := otap_string.cut(LPAD(NVL(p_test_state, otap_constants.OTAP_INTERNAL_NA), otap_util.get_length_test_state, ' '), otap_util.get_length_test_state);
      l_issue_state := otap_string.cut(LPAD(NVL(p_issue_state, otap_constants.OTAP_INTERNAL_NA), otap_util.get_length_test_state, ' '), otap_util.get_length_test_state);
      l_runtime     := otap_string.cut(LPAD(NVL(p_runtime, otap_constants.OTAP_INTERNAL_NA), l_runtime_len, ' '), l_runtime_len);
      l_desc        := otap_string.cut(LPAD(NVL(p_test_desc, otap_constants.OTAP_INTERNAL_NA), l_desc_len, ' '), l_desc_len);
    ELSE
      -- treat middle and left the same way
      l_test_state  := otap_string.cut(RPAD(NVL(p_test_state, otap_constants.OTAP_INTERNAL_NA), otap_util.get_length_test_state, ' '), otap_util.get_length_test_state);
      l_issue_state := otap_string.cut(RPAD(NVL(p_issue_state, otap_constants.OTAP_INTERNAL_NA), otap_util.get_length_test_state, ' '), otap_util.get_length_test_state);
      l_runtime     := otap_string.cut(RPAD(NVL(p_runtime, otap_constants.OTAP_INTERNAL_NA), l_runtime_len, ' '), l_runtime_len);
      l_desc        := otap_string.cut(RPAD(NVL(p_test_desc, otap_constants.OTAP_INTERNAL_NA), l_desc_len, ' '), l_desc_len);
    END IF;
    l_template_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_RESULT_LINE);
    l_template_text := REPLACE(l_template_text, '@teststate@', l_test_state);
    l_template_text := REPLACE(l_template_text, '@issuestate@', l_issue_state);
    l_template_text := REPLACE(l_template_text, '@runtime@', l_runtime);
    l_template_text := REPLACE(l_template_text, '@testdesc@', l_desc);
    -- get borderless
    l_return_text := otap_report.borderless( l_template_text
                                           , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), NVL(LENGTH(l_template_text), 0), otap_util.get_length_headers)
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
    l_return_text := otap_util.get_config_value(otap_util.CFG_TEMPLATE_COUNT_DESC);
    l_return_text := REPLACE(l_return_text, '@testsrun@', TRIM(TO_CHAR(NVL(p_tests_run, 0))));
    l_return_text := REPLACE(l_return_text, '@testsexpected@', TRIM(TO_CHAR(NVL(p_tests_expected, 0))));
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_count_desc', 'Build test count result by template');
      RAISE;
  END get_count_desc;

  FUNCTION get_separator_line( p_char     IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                             , p_min_fill IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                             )
    RETURN VARCHAR2
  IS
    l_char        VARCHAR2(1 CHAR);
    l_return_text VARCHAR2(32767 CHAR);
    l_line             otap_config.config_value%TYPE;
  BEGIN
    l_char := otap_string.check_decoration(p_char);
    l_return_text := otap_report.decorate( NULL
                                         , GREATEST(NVL(p_min_fill, otap_constants.OTAP_NUM_MIN_FILL_LENGTH), otap_util.get_length_headers)
                                         , l_char
                                         )
    ;
    RETURN l_return_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_separator_line', 'Build separator line');
      RAISE;
  END get_separator_line;

  FUNCTION get_exists_msg( p_object_name IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         , p_schema_name IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                         , p_object_type IN VARCHAR2 DEFAULT NULL
                         , p_sub_object  IN VARCHAR2 DEFAULT NULL
                         , p_desc        IN VARCHAR2 DEFAULT NULL
                         )
    RETURN VARCHAR2
  IS
    l_template_text VARCHAR2(32767 CHAR); -- '@type@ @object@ exists check (@schema@)'
  BEGIN
    IF p_sub_object IS NOT NULL
    THEN
      l_template_text := otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_XEXISTS
                                            , p_type_label => p_object_type
                                            , p_param1 => '@object@'
                                            , p_param1_value => p_object_name
                                            , p_param2 => '@schema@'
                                            , p_param2_value => p_schema_name
                                            , p_param3 => '@subobject@'
                                            , p_param3_value => p_sub_object
                                            , p_description => p_desc
                                            )
      ;
    ELSE
      l_template_text := otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                            , p_type_label => p_object_type
                                            , p_param1 => '@object@'
                                            , p_param1_value => p_object_name
                                            , p_param2 => '@schema@'
                                            , p_param2_value => p_schema_name
                                            , p_description => p_desc
                                            )
      ;
    END IF;
    RETURN l_template_text;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_report.get_exists_msg', 'Build exists result message');
      RAISE;
  END get_exists_msg;

END;
/
