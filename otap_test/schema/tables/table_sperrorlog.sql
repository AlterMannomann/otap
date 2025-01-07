-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name
-- check data length for CHAR semantics

SELECT otap_test.set_test_name('Table SPERRORLOG') FROM dual;

SELECT otap_test.has_table('SPERRORLOG') FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'USERNAME'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'TIMESTAMP'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'SCRIPT'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'MESSAGE'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'STATEMENT'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           )
  FROM dual;
