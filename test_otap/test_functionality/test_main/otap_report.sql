-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name

-- basic schema and otap_constants tests already done, test log entries will remain, logging is always committed on success
SELECT otap_test.set_test_name('Verify otap_report functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return      VARCHAR2(4000);
  l_stamp       TIMESTAMP;
  l_finish      TIMESTAMP;
  l_layout_bkp  VARCHAR2(4000);
  l_border_bkp  VARCHAR2(4000);
BEGIN
  -- otap_report uses configured values, save them before testing, to reset them afterwards to the original value
  l_layout_bkp := otap_util.get_config_value(otap_util.CFG_DEFAULT_LAYOUT);
  l_border_bkp := otap_util.get_config_value(otap_util.CFG_DEFAULT_BORDER);
  -- set defined defaults
  UPDATE otap_config SET config_value = otap_constants.OTAP_LAYOUT_MIDDLE WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(NULL, NULL, '-')
                             , RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-')
                             , 'otap_report.decorate NULL parameter'
                             )
  ;
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 120, '-'), RPAD('-', 120, '-'), 'otap_report.decorate NULL parameter respect min length');
  l_return := otap_test.is_eq(otap_report.decorate(NULL, 150, '*'), RPAD('*', 150, '*'), 'otap_report.decorate NULL parameter respect min length and decoration');
  l_return := otap_test.is_eq( otap_report.decorate(NULL, 60, '-')
                             , RPAD('-', otap_constants.OTAP_NUM_MIN_FILL_LENGTH, '-')
                             , 'otap_report.decorate NULL parameter guarantee otap min length'
                             )
  ;
  l_return := otap_test.is_eq(otap_report.decorate('test', 80, '-'), (LPAD(' ', 38, '-') || 'test' || RPAD(' ', 38, '-')), 'otap_report.decorate even short title length');
  l_return := otap_test.is_eq(otap_report.decorate('teste', 80, '-'), (LPAD(' ', 37, '-') || 'teste' || RPAD(' ', 38, '-')), 'otap_report.decorate uneven short title length');
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER, '-') || RPAD('test', 3990, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER, '-'))
                             , 'otap_report.decorate overflow and border default'
                             )
  ;
  -- set border to minimum
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER_MIN)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MIN, '-') || RPAD('test', 3996, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MIN, '-'))
                             , 'otap_report.decorate overflow and border min'
                             )
  ;
  -- set border to maximum
  UPDATE otap_config SET config_value = TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER_MAX)) WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT; -- needed to be visible for autonomous transactions
  l_return := otap_test.is_eq( otap_report.decorate(RPAD('test', 5000, 'a'), 80, '-')
                             , (LPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MAX, '-') || RPAD('test', 3980, 'a') || RPAD(' ', otap_constants.OTAP_FALLBACK_BORDER_MAX, '-'))
                             , 'otap_report.decorate overflow and border max'
                             )
  ;


  -- reset defaults
  UPDATE otap_config SET config_value = l_layout_bkp WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
  UPDATE otap_config SET config_value = l_border_bkp WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- try reset defaults
    UPDATE otap_config SET config_value = l_layout_bkp WHERE config_name = otap_util.CFG_DEFAULT_LAYOUT;
    UPDATE otap_config SET config_value = l_border_bkp WHERE config_name = otap_util.CFG_DEFAULT_BORDER;
    COMMIT;
END;
/