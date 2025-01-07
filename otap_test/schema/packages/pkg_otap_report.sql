-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_REPORT') FROM dual;

SELECT otap_test.has_package('OTAP_REPORT') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_REPORT'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DECORATE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BORDERLESS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL_DETAILS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_FOOTER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_UNDERLINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_COUNT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_RESULT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_DETAILS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_NO_DATA_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SET_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_GROUP_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_NAME_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_LINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_COUNT_DESC'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SEPARATOR_LINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_HAS_TABLE_MSG'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_HAS_COLUMN_MSG'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_HAS_PACKAGE_MSG'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_HAS_PROCEDURE_MSG'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_REPORT'
                              )
  FROM dual;