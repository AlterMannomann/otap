-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Verify otap_test.has_table') FROM dual;

SELECT otap_test.has_table('DUAL', 'SYS', 'DUAL table') FROM dual;
SELECT otap_test.has_table('NO VALID NAME', 'SYS', 'Invalid table name', otap_constants.get_otap_num_test_failed) FROM dual;
SELECT otap_test.has_table(NULL, 'SYS', 'NULL table name', otap_constants.get_otap_num_test_undefined) FROM dual;
SELECT otap_test.has_table( p_table_name => 'SPERRORLOG'
                          , p_description => 'Default schema'
                          )
  FROM dual;
SELECT otap_test.has_table( p_table_name => 'SPERRORLOG'
                          , p_schema => NULL
                          , p_description => 'Fallback schema'
                          )
  FROM dual;
-- test default description
SELECT otap_test.has_table('DUAL', 'SYS') FROM dual;