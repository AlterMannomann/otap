-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- ignore package states currently, extra function to validate objects to be created

SELECT otap_test.set_test_name('Package OTAP_RESULTS_UTIL') FROM dual;

SELECT otap_test.has_package('OTAP_RESULTS_UTIL') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_RESULTS_UTIL'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'WRITE_TEST_RESULT'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_RESULTS_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_TEXT_SIZE'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'OTAP_RESULTS_UTIL'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RESULT_CLEANUP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_RESULTS_UTIL'
                              )
  FROM dual;