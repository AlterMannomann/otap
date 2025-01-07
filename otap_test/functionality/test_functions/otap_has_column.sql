-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Verify otap_test.has_column') FROM dual;

SELECT otap_test.has_column('DUAL', 'DUMMY', 'SYS', 'DUAL table column DUMMY') FROM dual;
SELECT otap_test.has_column( p_table_name => 'NO VALID NAME'
                           , p_column_name => 'DUMMY'
                           , p_schema => 'SYS'
                           , p_description => 'Invalid table name'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'DUAL'
                           , p_column_name => 'NO VALID NAME'
                           , p_schema => 'SYS'
                           , p_description => 'Invalid column name'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => NULL
                           , p_column_name => 'DUMMY'
                           , p_schema => 'SYS'
                           , p_description => 'NULL table name'
                           , p_expected_result => otap_constants.get_otap_num_test_undefined
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'DUAL'
                           , p_column_name => NULL
                           , p_schema => 'SYS'
                           , p_description => 'NULL column name'
                           , p_expected_result => otap_constants.get_otap_num_test_undefined
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Default schema'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_schema => NULL
                           , p_description => 'Fallback schema'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Datatype correct'
                           , p_data_type => 'VARCHAR2'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Datatype wrong'
                           , p_data_type => 'NUMBER'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Data length correct'
                           , p_data_length => 1024
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Data length wrong'
                           , p_data_length => 4000
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Nullable correct'
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_description => 'Nullable wrong'
                           , p_nullable => 'N'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'TIMESTAMP'
                           , p_description => 'Data scale correct'
                           , p_data_scale => 6
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'TIMESTAMP'
                           , p_description => 'Data scale wrong'
                           , p_data_scale => 9
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TO_DELETE'
                           , p_description => 'Data precision correct'
                           , p_data_precision => 1
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TO_DELETE'
                           , p_description => 'Data precision wrong'
                           , p_data_precision => 3
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_EXECUTOR'
                           , p_description => 'Data default correct'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'SESSION_USER')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TO_DELETE'
                           , p_description => 'Data default wrong'
                           , p_data_default => 'SYS_CONTEXT(USERENV, SESSION_USER)'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           )
  FROM dual;

-- test default description
SELECT otap_test.has_column('DUAL', 'DUMMY', 'SYS') FROM dual;