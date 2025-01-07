-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_STRING') FROM dual;

SELECT otap_test.has_package('OTAP_STRING') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_STRING'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'REDUCE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CUT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FLATTEN'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_BORDER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_LINE_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_TITLE_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_STRING_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_LAYOUT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_DECORATION'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'LINE_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'LEFT_DECO'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RIGHT_DECO'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DECORATE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BORDERLESS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_STRING'
                              )
  FROM dual;
