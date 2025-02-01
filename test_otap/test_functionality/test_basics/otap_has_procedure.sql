-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Verify otap_test.has_procedure') FROM dual;
-- ramp up, no normal functions and procedures in otap
CREATE OR REPLACE FUNCTION DUMMY_FUNCTION(p_number IN NUMBER, p_char IN VARCHAR2, p_date IN DATE)
  RETURN VARCHAR2
IS
BEGIN
  RETURN 'Only Dummy for testing';
END;
/

CREATE OR REPLACE PROCEDURE DUMMY_PROCEDURE(p_number IN NUMBER, p_char IN VARCHAR2, p_date IN DATE)
IS
BEGIN
  -- Only Dummy for testing
  NULL;
END;
/
-- start test
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_FUNCTION'
                              , p_description => 'Dummy function minimal test'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_PROCEDURE'
                              , p_description => 'Dummy procedure minimal test'
                              , p_procedure_type => 'PROCEDURE'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => NULL
                              , p_description => 'NULL procedure name'
                              , p_expected_result => otap_constants.get_otap_num_test_undefined
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_FUNCTION'
                              , p_description => 'NULL procedure type'
                              , p_procedure_type => NULL
                              , p_expected_result => otap_constants.get_otap_num_test_undefined
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_FUNCTION'
                              , p_description => 'Dummy function return type'
                              , p_return_type => 'VARCHAR2'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_FUNCTION'
                              , p_description => 'Dummy function wrong return type'
                              , p_return_type => 'NUMBER'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_FUNCTION'
                              , p_description => 'Dummy function wrong procedure type'
                              , p_procedure_type => 'PROCEDURE'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_PROCEDURE'
                              , p_description => 'Dummy procedure wrong procedure type'
                              , p_procedure_type => 'FUNCTION'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PUT_LINE'
                              , p_schema => 'SYS'
                              , p_description => 'Package procedure test minimal'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'DBMS_OUTPUT'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_ROLE_ENABLED'
                              , p_schema => 'SYS'
                              , p_description => 'Package function test minimal'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'DBMS_SESSION'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_ROLE_ENABLED'
                              , p_schema => 'SYS'
                              , p_description => 'Package function test return type'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'BOOLEAN'
                              , p_package_name => 'DBMS_SESSION'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PUT_LINE'
                              , p_schema => 'NO VALID NAME'
                              , p_description => 'Package procedure wrong schema'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'DBMS_OUTPUT'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PUT_LINE'
                              , p_schema => 'SYS'
                              , p_description => 'Package procedure wrong procedure type'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'DBMS_OUTPUT'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_ROLE_ENABLED'
                              , p_schema => 'SYS'
                              , p_description => 'Package function wrong return type'
                              , p_procedure_type => 'FUNCTION'
                              , p_return_type => 'NUMBER'
                              , p_package_name => 'DBMS_SESSION'
                              , p_expected_result => otap_constants.get_otap_num_test_failed
                              )
  FROM dual;
-- test default description IS_ROLE_ENABLED
SELECT otap_test.has_procedure('DUMMY_FUNCTION') FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DUMMY_PROCEDURE'
                              , p_procedure_type => 'PROCEDURE'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_ROLE_ENABLED'
                              , p_schema => 'SYS'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'DBMS_SESSION'
                              )
  FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PUT_LINE'
                              , p_schema => 'SYS'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'DBMS_OUTPUT'
                              )
  FROM dual;
-- tear down
DROP FUNCTION DUMMY_FUNCTION;
DROP PROCEDURE DUMMY_PROCEDURE;