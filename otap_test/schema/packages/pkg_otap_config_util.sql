-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_CONFIG_UTIL') FROM dual;

SELECT otap_test.has_package('OTAP_CONFIG_UTIL') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_CONFIG_UTIL'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CONFIG_VALUE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_CONFIG_VALUE'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEBUG'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DEBUG'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PRESERVE_DAYS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_PRESERVE_DAYS'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DELETE_DELAY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DELETE_DELAY'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DELETE_BATCH_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DELETE_BATCH_SIZE'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_PREFIX'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DEFAULT_PREFIX'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_LAYOUT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DEFAULT_LAYOUT'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_RESULT_LAYOUT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DEFAULT_RESULT_LAYOUT'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_BORDER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_DEFAULT_BORDER'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_TEST_GROUP'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_TEST_STATE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_SUMMARY_STATE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_HEADERS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_RESULT_HEADERS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TEST_RESULT_TO_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BOOL_TO_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BOOL_TO_YES_NO_TEXT'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_TEST_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DEFAULT_TEST_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_ERRORS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_ERROR_DETAILS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_FORMAT_GROUP_CHAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_FORMAT_HEADER_CHAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_FORMAT_NAME_CHAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_RESULT_LINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_FORMAT_SET_CHAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_GROUP'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_NO_DATA'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_SESSION_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_TEST_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_RESULT_LINE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_COUNT_DESC'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_REPORT_TOTAL'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_FN_HAS_TABLE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_FN_HAS_COLUMN'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_FN_HAS_PACKAGE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEMPLATE_FN_HAS_PROCEDURE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_FALSE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_FALSE_NO'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_REPORT_END'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_REPORT_TOTAL'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_REPORT_START'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_RESULT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_COUNT_HEADER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_COUNT_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_SUMMARY_ERROR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_SUMMARY_SUCCESS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_FAILED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_PASSED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_UNDEFINED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TRUE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TRUE_YES'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONFIG_UTIL'
                              )
  FROM dual;