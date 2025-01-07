-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_API') FROM dual;

SELECT otap_test.has_package('OTAP_API') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_API'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'INIT_TEST'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SHOW'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_GROUP'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_TEST_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_REPORT_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_TEXT_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SET_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_GROUP_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_NAME_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_UNDERLINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_LINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TEST_RESULT_TO_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_RESULT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_DETAILS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_NO_DATA_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_FOOTER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FLATTEN'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_COUNT_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_COUNT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL_DETAILS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TABLE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_COLUMN'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PACKAGE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PROCEDURE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_API'
                              )
  FROM dual;