-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name
SELECT otap_test.set_test_name('Verify otap_report functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return      VARCHAR2(4000);
  l_stamp       TIMESTAMP;
  l_finish      TIMESTAMP;
  l_layout      VARCHAR2(4000);
  l_border      INTEGER;
  l_want        VARCHAR2(4000);
  l_have        VARCHAR2(4000);
  l_strlen      INTEGER;
BEGIN
  -- otap_report uses configured values, get current values and build non intrusive tests on the current values
  l_layout := otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT);
  l_border := otap_util.get_config_number(otap_util.CFG_DEFAULT_BORDER);
-- should be independent from layout
  l_return := otap_test.is_eq(otap_report.decorate(NULL, NULL, '-'), RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-'), 'otap_report.decorate NULL parameter');
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 120, '-'), RPAD('-', 120, '-'), 'otap_report.decorate NULL parameter respect min length');
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 150, '*'), RPAD('*', 150, '*'), 'otap_report.decorate NULL parameter respect min length and decoration');
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 60, '-'), RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-'), 'otap_report.decorate NULL parameter guarantee otap min length');
  -- get decorate string for later checks
  l_strlen := otap_constants.OTAP_NUM_MIN_FILL_LENGTH - (2 * l_border);
  l_have   := otap_report.decorate(RPAD('a', l_strlen, 'a'), 80, '-');
  l_return := otap_test.is_eq(LENGTH(l_have), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_report.decorate length full min size min border');
  l_want   := LPAD(' ', l_border, '-') || RPAD('a', l_strlen, 'a') || RPAD(' ', l_border, '-');
  l_return := otap_test.is_eq(l_have, l_want, 'otap_report.decorate string full min size min border');
-- depends on layout

END;
/