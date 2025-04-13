-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- independent code block, able to deal with different setup settings

-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return      VARCHAR2(4000 CHAR);
  l_stamp       TIMESTAMP;
  l_finish      TIMESTAMP;
  l_layout      VARCHAR2(4000 CHAR);
  l_border      INTEGER;
  l_want        VARCHAR2(4000 CHAR);
  l_have        VARCHAR2(4000 CHAR);
  l_strlen      INTEGER;
  l_xpad        INTEGER;
  l_lpad        INTEGER;
  l_rpad        INTEGER;
  l_fmt_len     INTEGER;
  l_deco        VARCHAR2(1 CHAR);
  l_title       VARCHAR2(4000 CHAR);
  l_template    VARCHAR2(256 CHAR);
  l_variable    VARCHAR2(4000 CHAR);
  l_ext         VARCHAR2(128 CHAR);
BEGIN
  -- otap_report uses configured values, get current values and build non intrusive tests on the current values
  l_layout := otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT, otap_constants.OTAP_INTERNAL_NA);
  l_border := otap_util.get_config_number(otap_util.CFG_DEFAULT_BORDER);
  l_ext    := ' layout/border(' || l_layout || '/' || TRIM(TO_CHAR(l_border)) || ')';
  l_return := otap_test.ok((l_layout IN (otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_RIGHT)), 'otap_report loaded layout check' || l_ext);
  l_return := otap_test.ok((l_border BETWEEN 1 AND 10), 'otap_report loaded border check' || l_ext);
  l_deco   := otap_util.get_config_value(otap_util.CFG_FORMAT_NAME_CHAR, otap_constants.OTAP_INTERNAL_NA);
  -- should be independent from layout
  l_return := otap_test.is_eq(otap_report.decorate(NULL, NULL, l_deco, otap_constants.OTAP_INTERNAL_NA), RPAD(l_deco, otap_constants.OTAP_NUM_MIN_FILL_LENGTH, l_deco), 'otap_report.decorate NULL parameter' || l_ext);
  l_return := otap_test.is_eq(otap_report.decorate(NULL, NULL, NULL, NULL), RPAD(l_deco, otap_constants.OTAP_NUM_MIN_FILL_LENGTH, l_deco), 'otap_report.decorate full NULL check' || l_ext);
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 120, '-', otap_constants.OTAP_INTERNAL_NA), RPAD('-', 120, '-'), 'otap_report.decorate NULL parameter respect min length' || l_ext);
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 150, '*', otap_constants.OTAP_INTERNAL_NA), RPAD('*', 150, '*'), 'otap_report.decorate NULL parameter respect min length and decoration' || l_ext);
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 60, '-', otap_constants.OTAP_INTERNAL_NA), RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-'), 'otap_report.decorate NULL parameter guarantee otap min length' || l_ext);
  -- get decorate string for later checks
  l_strlen := otap_constants.OTAP_NUM_MIN_FILL_LENGTH - (2 * l_border);
  l_have   := otap_report.decorate(RPAD('a', l_strlen, 'a'), 80, '-', otap_constants.OTAP_INTERNAL_NA);
  l_return := otap_test.is_eq(LENGTH(l_have), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_report.decorate length full min size min border' || l_ext);
  l_want   := LPAD(' ', l_border, '-') || RPAD('a', l_strlen, 'a') || RPAD(' ', l_border, '-');
  l_return := otap_test.is_eq(l_have, l_want, 'otap_report.decorate string full min size min border' || l_ext);
-- depends on layout
  l_have   := otap_report.decorate(RPAD('a', 60, 'a'), 80, '-', otap_constants.OTAP_INTERNAL_NA);
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', (20 - l_border), '-') || RPAD('a', 60, 'a') || RPAD(' ', l_border, '-')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, '-') || RPAD('a', 60, 'a') || RPAD(' ', (20 - l_border), '-')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', 10, '-') || RPAD('a', 60, 'a') || RPAD(' ', 10, '-')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(l_have, l_want, 'otap_report.decorate title length 60' || l_ext);
  l_return := otap_test.is_eq(otap_report.decorate(RPAD('a', 60, 'a')), l_want, 'otap_report.decorate title length default parameter check' || l_ext);
  l_strlen := otap_constants.OTAP_NUM_MIN_FILL_LENGTH - LENGTH(otap_constants.OTAP_INTERNAL_NA);
  l_have   := otap_report.borderless(NULL, NULL, NULL);
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_strlen, ' ') || otap_constants.OTAP_INTERNAL_NA
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN otap_constants.OTAP_INTERNAL_NA || RPAD(' ', l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN otap_constants.OTAP_INTERNAL_NA || RPAD(' ', l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(l_have, l_want, 'otap_report.borderless full NULL check' || l_ext);
  l_have   := otap_report.borderless(RPAD('a', 10, 'a'), 80, otap_constants.OTAP_INTERNAL_NA);
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', 70, ' ') || RPAD('a', 10, 'a')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD('a', 10, 'a') || RPAD(' ', 70, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD('a', 10, 'a') || RPAD(' ', 70, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(l_have, l_want, 'otap_report.borderless title length 10' || l_ext);
  l_return := otap_test.is_eq(otap_report.borderless(RPAD('a', 10, 'a')), l_want, 'otap_report.borderless title length 10 default parameter check' || l_ext);
  l_return := otap_test.is_eq(LENGTH(l_have), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_report.borderless string length for title length 10' || l_ext);
  l_return := otap_test.is_eq(otap_report.borderless(RPAD('a', 100, 'a')), RPAD('a', 100, 'a'), 'otap_report.borderless title length 100' || l_ext);
  l_return := otap_test.is_eq(LENGTH(otap_report.borderless(RPAD('a', 100, 'a'))), 100, 'otap_report.borderless string length title length 100' || l_ext);
  l_deco   := otap_util.get_config_value(otap_util.CFG_FORMAT_HEADER_CHAR, otap_constants.OTAP_INTERNAL_NA);
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_START, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_header, l_want, 'otap_report.get_report_header check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_report_header(NULL, NULL), l_want, 'otap_report.get_report_header full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_header(l_strlen), l_want, 'otap_report.get_report_header with min fill ' || l_strlen || l_ext);
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_TOTAL, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_total, l_want, 'otap_report.get_report_total check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_report_total(NULL, NULL), l_want, 'otap_report.get_report_total full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_total(l_strlen), l_want, 'otap_report.get_report_total with min fill ' || l_strlen || l_ext);
  l_title  := otap_util.get_config_value(otap_util.CFG_TEMPLATE_REPORT_TOTAL, otap_constants.OTAP_INTERNAL_NA);
  -- replace vars with default
  l_title  := REPLACE(l_title, '@sets@', '0');
  l_title  := REPLACE(l_title, '@groups@', '0');
  l_title  := REPLACE(l_title, '@names@', '0');
  l_title  := REPLACE(l_title, '@descs@', '0');
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_total_details, l_want, 'otap_report.get_report_total_details check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_report_total_details(NULL, NULL, NULL, NULL, NULL, NULL), l_want, 'otap_report.get_report_total_details full NULL check' || l_ext);
  l_title  := otap_util.get_config_value(otap_util.CFG_TEMPLATE_REPORT_TOTAL, otap_constants.OTAP_INTERNAL_NA);
  -- replace vars with default
  l_title  := REPLACE(l_title, '@sets@', '99999999999999999999');
  l_title  := REPLACE(l_title, '@groups@', '99999999999999999999');
  l_title  := REPLACE(l_title, '@names@', '99999999999999999999');
  l_title  := REPLACE(l_title, '@descs@', '99999999999999999999');
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_total_details(99999999999999999999, 99999999999999999999, 99999999999999999999, 99999999999999999999), l_want, 'otap_report.get_report_total_details big numbers' || l_ext);
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_REPORT_END, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_footer, l_want, 'otap_report.get_report_footer check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_report_footer(NULL, NULL), l_want, 'otap_report.get_report_footer full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_report_footer(l_strlen), l_want, 'otap_report.get_report_footer with min fill ' || l_strlen || l_ext);
  -- get_result_header
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_HEADER, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_result_header, l_want, 'otap_report.get_result_header check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_result_header(NULL, NULL), l_want, 'otap_report.get_result_header full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_result_header(l_strlen), l_want, 'otap_report.get_result_header with min fill ' || l_strlen || l_ext);
  -- get_result_underline
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_RESULT_LINE, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_result_underline, l_want, 'otap_report.get_result_underline check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_result_underline(NULL, NULL), l_want, 'otap_report.get_result_underline full NULL check' || l_ext);
  l_strlen := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_result_underline(l_strlen), l_want, 'otap_report.get_result_underline with min fill ' || l_strlen || l_ext);
  -- get_test_count_header
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_TEST_SETUP_SET, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_test_count_header, l_want, 'otap_report.get_test_count_header check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_test_count_header(NULL, NULL), l_want, 'otap_report.get_test_count_header full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_test_count_header(l_strlen), l_want, 'otap_report.get_test_count_header with min fill ' || l_strlen || l_ext);
  -- get_summary_header
  l_title  := otap_util.get_config_value(otap_util.CFG_TEXT_SUMMARY_HEADER, otap_constants.OTAP_INTERNAL_NA);
  l_strlen := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_summary_header, l_want, 'otap_report.get_summary_header check' || l_ext);
  l_return := otap_test.is_eq(otap_report.get_summary_header(NULL, NULL), l_want, 'otap_report.get_summary_header full NULL check' || l_ext);
  l_strlen := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN RPAD(l_title, l_strlen, ' ')
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN RPAD(l_title, l_strlen, ' ')
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_summary_header(l_strlen), l_want, 'otap_report.get_summary_header with min fill ' || l_strlen || l_ext);
  -- get_summary
  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SUMMARY, otap_constants.OTAP_INTERNAL_NA);
  l_fmt_len  := otap_util.get_length_test_state(otap_constants.OTAP_INTERNAL_NA);
  -- replace variables before getting length
  l_variable := otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED, otap_constants.OTAP_INTERNAL_NA);
  IF l_layout = otap_constants.OTAP_LAYOUT_RIGHT
  THEN
    l_title := REPLACE(l_template, '@status@', LPAD(l_variable, l_fmt_len, ' '));
  ELSE
    l_title := REPLACE(l_template, '@status@', RPAD(l_variable, l_fmt_len, ' '));
  END IF;
  l_title    := REPLACE(l_title, '@runtime@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@exectime@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@runs@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@errors@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@issues@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_summary(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL), l_want, 'otap_report.get_summary full NULL check' || l_ext);
  IF l_layout = otap_constants.OTAP_LAYOUT_RIGHT
  THEN
    l_title := REPLACE(l_template, '@status@', LPAD(l_variable, l_fmt_len, ' '));
  ELSE
    l_title := REPLACE(l_template, '@status@', RPAD(l_variable, l_fmt_len, ' '));
  END IF;
  l_title    := REPLACE(l_title, '@runtime@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@exectime@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@runs@', '0');
  l_title    := REPLACE(l_title, '@errors@', '0');
  l_title    := REPLACE(l_title, '@issues@', '0');
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_summary, l_want, 'otap_report.get_summary check' || l_ext);
  l_strlen   := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_summary(p_min_fill => l_strlen), l_want, 'otap_report.get_summary with min fill ' || l_strlen || l_ext);
  IF l_layout = otap_constants.OTAP_LAYOUT_RIGHT
  THEN
    l_title := REPLACE(l_template, '@status@', LPAD('-1', l_fmt_len, ' '));
  ELSE
    l_title := REPLACE(l_template, '@status@', RPAD('-1', l_fmt_len, ' '));
  END IF;
  l_title    := REPLACE(l_title, '@runtime@', 'Bla');
  l_title    := REPLACE(l_title, '@exectime@', 'Bla');
  l_title    := REPLACE(l_title, '@runs@', '-1');
  l_title    := REPLACE(l_title, '@errors@', '0');
  l_title    := REPLACE(l_title, '@issues@', '-2');
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_summary('-1', 'Bla', 'Bla', -1, -0, -2), l_want, 'otap_report.get_summary verify no value check' || l_ext);
  -- get_error_result_header
  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERRORS, otap_constants.OTAP_INTERNAL_NA);
  l_deco     := otap_util.get_config_value(otap_util.CFG_FORMAT_NAME_CHAR, otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_template, '@testname@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad     := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad     := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad     := l_strlen - LENGTH(l_title) - l_lpad;
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_error_result_header(otap_constants.OTAP_INTERNAL_NA), l_want, 'otap_report.get_error_result_header check' || l_ext);
  l_return   := otap_test.is_eq(otap_report.get_error_result_header(NULL, NULL, NULL), l_want, 'otap_report.get_error_result_header full NULL check' || l_ext);
  l_strlen := GREATEST(150, (LENGTH(l_title) + (6 * l_border)));
  l_xpad   := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad   := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad   := l_strlen - LENGTH(l_title) - l_lpad;
  l_want   := CASE
                WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                ELSE 'INVALID LAYOUT'
              END
  ;
  l_return := otap_test.is_eq(otap_report.get_error_result_header(otap_constants.OTAP_INTERNAL_NA, l_strlen), l_want, 'otap_report.get_error_result_header with min fill ' || l_strlen || l_ext);
  -- get_error_details
  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_ERROR_DETAILS, otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_template, '@testdesc@', otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_title, '@errorinfo@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_error_details, l_want, 'otap_report.get_error_details check' || l_ext);
  l_return   := otap_test.is_eq(otap_report.get_error_details(NULL, NULL, NULL, NULL), l_want, 'otap_report.get_error_details full NULL check' || l_ext);
  l_strlen   := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return := otap_test.is_eq(otap_report.get_error_details(p_min_fill => l_strlen), l_want, 'otap_report.get_error_details with min fill ' || l_strlen || l_ext);
  -- get_no_data_text
  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_NO_DATA, otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_template, '@sessionid@', '1');
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_no_data_text(1), l_want, 'otap_report.get_no_data_text check' || l_ext);
  l_title    := REPLACE(l_template, '@sessionid@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_no_data_text(NULL, NULL, NULL), l_want, 'otap_report.get_no_data_text full NULL check' || l_ext);
  l_title    := REPLACE(l_template, '@sessionid@', '1');
  l_strlen   := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return := otap_test.is_eq(otap_report.get_no_data_text(1, l_strlen), l_want, 'otap_report.get_no_data_text with min fill ' || l_strlen || l_ext);
  -- get_session_id_text
  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SESSION_ID, otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_template, '@sessionid@', '1');
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_session_id_text(1), l_want, 'otap_report.get_session_id_text check' || l_ext);
  l_title    := REPLACE(l_template, '@sessionid@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_session_id_text(NULL, NULL, NULL), l_want, 'otap_report.get_session_id_text full NULL check' || l_ext);
  l_title    := REPLACE(l_template, '@sessionid@', '1');
  l_strlen   := GREATEST(150, LENGTH(l_title));
  -- might be left or right oriented
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN RPAD(l_title, l_strlen, ' ')
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN RPAD(l_title, l_strlen, ' ')
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return := otap_test.is_eq(otap_report.get_session_id_text(1, l_strlen), l_want, 'otap_report.get_session_id_text with min fill ' || l_strlen || l_ext);
  -- get_set_text, CFG_TEMPLATE_SET, CFG_FORMAT_SET_CHAR

  l_template := otap_util.get_config_value(otap_util.CFG_TEMPLATE_SET, otap_constants.OTAP_INTERNAL_NA);
  l_deco     := otap_util.get_config_value(otap_util.CFG_FORMAT_SET_CHAR, otap_constants.OTAP_INTERNAL_NA);
  l_title    := REPLACE(l_template, '@testset@', otap_constants.OTAP_INTERNAL_NA);
  l_strlen   := GREATEST(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, (LENGTH(l_title) + (2 * l_border)));
  l_xpad     := l_strlen - (LENGTH(l_title) + l_border);
  l_lpad     := FLOOR((l_strlen - LENGTH(l_title)) / 2);
  l_rpad     := l_strlen - LENGTH(l_title) - l_lpad;
  l_want     := CASE
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                  THEN LPAD(' ', l_xpad, l_deco) || l_title || RPAD(' ', l_border, l_deco)
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                  THEN LPAD(' ', l_border, l_deco) || l_title || RPAD(' ', l_xpad, l_deco)
                  WHEN l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
                  THEN LPAD(' ', l_lpad, l_deco) || l_title || RPAD(' ', l_rpad, l_deco)
                  ELSE 'INVALID LAYOUT'
                END
  ;
  l_return   := otap_test.is_eq(otap_report.get_set_text(otap_constants.OTAP_INTERNAL_NA), l_want, 'otap_report.get_set_text check' || l_ext);
  l_return   := otap_test.is_eq(otap_report.get_set_text(NULL, NULL, NULL), l_want, 'otap_report.get_set_text full null check' || l_ext);

END;
/