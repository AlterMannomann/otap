-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Table OTAP_CONFIG') FROM dual;

SELECT otap_test.has_table('OTAP_CONFIG') FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_NAME'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_VALUE'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_MAX_LENGTH'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_nullable => 'N'
                           , p_data_default => '-1'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_TYPE'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 24
                           , p_nullable => 'N'
                           , p_data_default => q'['CHAR']'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED_BY'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => 'USER'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED_BY_OS'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'OS_USER')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED_BY'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => 'USER'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED_BY_OS'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'OS_USER')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_DESCRIPTION'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           )
  FROM dual;
