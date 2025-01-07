-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_OBJECTS') FROM dual;

SELECT otap_test.has_package('OTAP_OBJECTS') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_OBJECTS'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_VERIFY'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SHOW'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_COPY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'OBJECT'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_SET'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_GROUP'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_NAME'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_TEST_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_REPORT_ID'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_ADD_TEST'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SUMMARY'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_FINISH'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'VARCHAR2'
                              , p_package_name => 'OTAP_OBJECTS'
                              )
  FROM dual;