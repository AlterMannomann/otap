-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_TEST') FROM dual;

SELECT otap_test.has_package('OTAP_TEST') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_TEST'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'INIT_TEST'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CURRENT_SETTINGS'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CURRENT_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_GROUP'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RESULT_VIEW'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'TABLE'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TABLE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_COLUMN'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PACKAGE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PROCEDURE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_VAR'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'OBJECT'
                              , p_package_name => 'OTAP_TEST'
                              )
  FROM dual;