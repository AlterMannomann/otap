-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Verify otap_test.has_package') FROM dual;

SELECT otap_test.has_package('DBMS_OUTPUT', 'SYS', 'DBMS_OUTPUT package') FROM dual;
SELECT otap_test.has_package( p_package_name => 'DBMS_OUPUT'
                            , p_schema => 'SYS'
                            , p_description => 'Invalid package'
                            , p_expected_result => otap_constants.get_otap_num_test_failed
                            )
  FROM dual;
SELECT otap_test.has_package( p_package_name => 'DBMS_OUTPUT'
                            , p_schema => 'SYS'
                            , p_description => 'Correct package type'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
SELECT otap_test.has_package( p_package_name => 'DBMS_OUTPUT'
                            , p_schema => 'SYS'
                            , p_description => 'Wrong package type'
                            , p_package_type => 'PACGEBODY'
                            , p_expected_result => otap_constants.get_otap_num_test_undefined
                            )
  FROM dual;
SELECT otap_test.has_package( p_package_name => NULL
                            , p_schema => 'SYS'
                            , p_description => 'NULL package name'
                            , p_expected_result => otap_constants.get_otap_num_test_undefined
                            )
  FROM dual;
SELECT otap_test.has_package( p_package_name => 'DBMS_OUTPUT'
                            , p_schema => 'SYS'
                            , p_description => 'NULL package type'
                            , p_package_type => NULL
                            , p_expected_result => otap_constants.get_otap_num_test_undefined
                            )
  FROM dual;
-- test default description
SELECT otap_test.has_package('DBMS_OUTPUT', 'SYS') FROM dual;
SELECT otap_test.has_package( p_package_name => 'DBMS_OUTPUT'
                            , p_schema => 'SYS'
                            , p_package_type => 'PACKAGE BODY'
                            )
  FROM dual;
