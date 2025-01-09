-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Package OTAP_CONSTANTS') FROM dual;

SELECT otap_test.has_package('OTAP_CONSTANTS') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_CONSTANTS'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_VAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_NA'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_ERROR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_DELIMITER'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_MAX_FILL_LENGTH'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_MIN_FILL_LENGTH'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_UNDEFINED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_FAILED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_PASSED'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_FALSE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TRUE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_TABLESPACE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_SCHEMA'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_USER_ROLE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_CONSTANTS'
                              )
  FROM dual;
