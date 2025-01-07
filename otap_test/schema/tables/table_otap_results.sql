-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Table OTAP_RESULTS') FROM dual;

SELECT otap_test.has_table('OTAP_RESULTS') FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TO_DELETE'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 1
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_RUN_ID'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 38
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_RUN_DATE'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_data_scale => 6
                           , p_nullable => 'N'
                           , p_data_default => 'SYSTIMESTAMP'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_PASSED'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 1
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_SESSION_ID'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 38
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_EXECUTOR'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'SESSION_USER')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_SET'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'['OTAP test set']'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DB_USER'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'CURRENT_USER')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DB_SCHEMA'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           , p_data_default => q'[SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')]'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_GROUP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'['OTAP test group']'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_START'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_scale => 6
                           , p_data_length => 11
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_END'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_scale => 6
                           , p_data_length => 11
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_NAME'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_DESC'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DELETED'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DELETED_BY'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           )
  FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_ERRORS'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           )
  FROM dual;
