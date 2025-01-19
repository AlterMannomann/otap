-- otap GENERATE test scripts OTAP schemas
-- LIKE scope: OTAP
-- set test set for schema
SELECT otap_test.set_test_set('schema OTAP') FROM dual;
-- otap GENERATE test scripts OTAP tables
-- LIKE scope: %
-- set test group for tables
SELECT otap_test.set_test_group('tables') FROM dual;
-- set test name for table
SELECT otap_test.set_test_name('table SPERRORLOG') FROM dual;
SELECT otap_test.has_table( p_table_name => 'SPERRORLOG'
                          , p_schema => 'OTAP'
                          ) FROM dual;
-- otap GENERATE test scripts OTAP columns SPERRORLOG
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'USERNAME'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'TIMESTAMP'
                           , p_schema => 'OTAP'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_data_scale => 6
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'SCRIPT'
                           , p_schema => 'OTAP'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'IDENTIFIER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'MESSAGE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'SPERRORLOG'
                           , p_column_name => 'STATEMENT'
                           , p_schema => 'OTAP'
                           , p_data_type => 'CLOB'
                           , p_data_length => 4000
                           , p_nullable => 'Y'
                           ) FROM dual;
-- set test name for table
SELECT otap_test.set_test_name('table OTAP_CONFIG') FROM dual;
SELECT otap_test.has_table( p_table_name => 'OTAP_CONFIG'
                          , p_schema => 'OTAP'
                          ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_CONFIG
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_NAME'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_VALUE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_MAX_LENGTH'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_nullable => 'N'
                           , p_data_default => '-1'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_TYPE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 24
                           , p_nullable => 'N'
                           , p_data_default => q'['CHAR']'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'TRANSLATABLE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 1
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED_BY'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CREATED_BY_OS'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED_BY'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'UPDATED_BY_OS'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'CONFIG_DESCRIPTION'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
-- set test name for table
SELECT otap_test.set_test_name('table OTAP_RESULTS') FROM dual;
SELECT otap_test.has_table( p_table_name => 'OTAP_RESULTS'
                          , p_schema => 'OTAP'
                          ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_RESULTS
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TO_DELETE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 1
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_RUN_ID'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 38
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_RUN_DATE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_data_scale => 6
                           , p_nullable => 'N'
                           , p_data_default => 'SYSTIMESTAMP'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_PASSED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 1
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_SESSION_ID'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_data_precision => 38
                           , p_data_scale => 0
                           , p_nullable => 'N'
                           , p_data_default => '0'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_EXECUTOR'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_SET'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'['OTAP test set']'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DB_USER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DB_SCHEMA'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_GROUP'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           , p_data_default => q'['OTAP test group']'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_START'
                           , p_schema => 'OTAP'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_data_scale => 6
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_END'
                           , p_schema => 'OTAP'
                           , p_data_type => 'TIMESTAMP(6)'
                           , p_data_length => 11
                           , p_data_scale => 6
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_NAME'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_DESC'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DELETED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'DELETED_BY'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_RESULTS'
                           , p_column_name => 'TEST_ERRORS'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
-- set test name for table
SELECT otap_test.set_test_name('table OTAP_TRANSLATE') FROM dual;
SELECT otap_test.has_table( p_table_name => 'OTAP_TRANSLATE'
                          , p_schema => 'OTAP'
                          ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_TRANSLATE
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'OTAP_IDENTIFIER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'LABEL_TEXT'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'LANGUAGE_ID'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 12
                           , p_nullable => 'N'
                           , p_data_default => q'['N/A']'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'CREATED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'UPDATED'
                           , p_schema => 'OTAP'
                           , p_data_type => 'DATE'
                           , p_data_length => 7
                           , p_nullable => 'N'
                           , p_data_default => 'SYSDATE'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'CREATED_BY'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'CREATED_BY_OS'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'UPDATED_BY'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_TRANSLATE'
                           , p_column_name => 'UPDATED_BY_OS'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 1024
                           , p_nullable => 'N'
                           ) FROM dual;
-- set test name for table
SELECT otap_test.set_test_name('table OTAP_LABELS_MV') FROM dual;
SELECT otap_test.has_table( p_table_name => 'OTAP_LABELS_MV'
                          , p_schema => 'OTAP'
                          ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_LABELS_MV
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'ORACLE_TYPE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_IDENTIFIER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_LOWER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_CAP'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_UPPER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_SOURCE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
-- otap GENERATE test scripts OTAP trigger
-- LIKE scope: %
SELECT otap_test.set_group_name('trigger') FROM dual;
-- set test name for table trigger
SELECT otap_test.set_test_name('table trigger OTAP_CONFIG') FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_CONFIG_DEL_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'DELETE'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_CONFIG'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_CONFIG_INS_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'INSERT'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_CONFIG'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_CONFIG_UPD_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'UPDATE'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_CONFIG'
                            ) FROM dual;
-- set test name for table trigger
SELECT otap_test.set_test_name('table trigger OTAP_RESULTS') FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_DEL_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'DELETE'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_INS_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'INSERT'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_UPD_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'UPDATE'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;
-- set test name for table trigger
SELECT otap_test.set_test_name('table trigger OTAP_TRANSLATE') FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_TRANSLATE_INS_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'INSERT'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_TRANSLATE'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_TRANSLATE_UPD_TRG'
                            , p_schema => 'OTAP'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'UPDATE'
                            , p_table_owner => 'OTAP'
                            , p_table_name => 'OTAP_TRANSLATE'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP packages
-- LIKE scope: %
-- set test group for package
SELECT otap_test.set_test_group('packages') FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_STRING') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_STRING'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_STRING'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'REDUCE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CUT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FLATTEN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_BORDER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_LINE_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_TITLE_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_STRING_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_LAYOUT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CHECK_DECORATION'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'LINE_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'LEFT_DECO'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RIGHT_DECO'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'DECORATE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BORDERLESS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_SYS_OBJECT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_STRING'
                              , p_return_type => 'BOOLEAN'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_REPORT') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_REPORT'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_REPORT'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'DECORATE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BORDERLESS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL_DETAILS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_UNDERLINE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_COUNT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SUMMARY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_RESULT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_DETAILS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_NO_DATA_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SET_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_GROUP_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_NAME_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_LINE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_COUNT_DESC'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SEPARATOR_LINE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_EXISTS_MSG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_EXISTS_C_MSG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_EXISTS_F_MSG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_MATCH_MSG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_REPORT'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_OBJECTS') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_OBJECTS'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_OBJECTS'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_VERIFY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_OBJECTS'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SHOW'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_COPY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'OBJECT'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_SET'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_GROUP'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_NAME'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_TEST_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_REPORT_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_SESSION_VIEW_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_ADD_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_OBJECTS'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SUMMARY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_FINISH'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_OBJECTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_PLAN') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_PLAN'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_PLAN'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'WRITE_TEST_RESULT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_PLAN'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'WRITE_COUNT_RESULT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_PLAN'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'INIT_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_PLAN'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RUN_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_PLAN'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_PLAN'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST_WITH_EXIT_CODE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_PLAN'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_SCHEMA') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_SCHEMA'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_SCHEMA'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TABLE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_COLUMN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PACKAGE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PROCEDURE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TRIGGER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_OBJECT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_REF_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_NOT_NULL_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_INDEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_SCHEMA'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_API') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_API'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_API'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'VALIDATE_OTAP'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_API'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'INIT_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST_WITH_EXIT_CODE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SHOW'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SUMMARY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_NAME'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_GROUP'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_SET_TEST_SET'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_TEST_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OTAP_SESSION_GET_REPORT_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_ACTIVE_REPORT_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_TEXT_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SET_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SUMMARY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_GROUP_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_NAME_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_UNDERLINE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_RESULT_LINE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TEST_RESULT_TO_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_RESULT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_ERROR_DETAILS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_NO_DATA_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FLATTEN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEXT_TEST_COUNT_NAME'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_TEST_COUNT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_TOTAL_DETAILS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RESULT_VIEW'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TABLE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_COLUMN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PACKAGE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PROCEDURE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TRIGGER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_OBJECT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_REF_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_NOT_NULL_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_INDEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OK'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_EQ'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_REGEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_LIKE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_API'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_TEST') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_TEST'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_TEST'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'INIT_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'FINISH_TEST_WITH_EXIT_CODE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CURRENT_SETTINGS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CURRENT_SUMMARY'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_NAME'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_GROUP'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_TEST_SET'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_SESSION_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_REPORT_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_ACTIVE_REPORT_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RESULT_VIEW'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TABLE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_COLUMN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PACKAGE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_PROCEDURE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_TRIGGER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_OBJECT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_REF_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_NOT_NULL_CONSTRAINT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'HAS_INDEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'OK'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_EQ'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_REGEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_LIKE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_SET_TYPE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_TEST'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_TYPE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_SCHEMA_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_TABLE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_COLUMN_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_TRIGGER_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_PACKAGE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_PROCEDURE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GENERATE_VIEW_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_TEST'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_UTIL') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_UTIL'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_UTIL'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'IS_NUMBER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'BOOLEAN'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_INTEGER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'BOOLEAN'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'VALIDATE_CONFIG_NAME'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_UTIL'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'VALIDATE_CONFIG_VALUE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'VALIDATE_TRANSLATABLE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_UTIL'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CONFIG_VALUE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CONFIG_NUMBER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LABEL_ID'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_TEST_STATE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_SUMMARY_STATE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_HEADERS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_LENGTH_RESULT_HEADERS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TEST_RESULT_TO_TEXT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'CONSTRAINT_TYPE_TO_LABEL'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_MSG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'WRITE_TEST_RESULT'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_UTIL'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MAX_TEXT_SIZE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_UTIL'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'RESULT_CLEANUP'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_UTIL'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_GENERATE') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_GENERATE'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_GENERATE'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'COLUMN_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TABLE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'TRIGGER_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PROCEDURE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PACKAGE_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'VIEW_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SCHEMA_TESTS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PREPARE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'PREPARE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_GENERATE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'SET_GEN_TYPE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_GENERATE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_GEN_TYPE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CODE_PREFIX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CODE_PREFIX_LEN'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CODE_POSTFIX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_CODE_PAD'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_SCRIPT_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_FUNCTION_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_PROCEDURE_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_HEADER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_SCRIPT_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_FUNCTION_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'BUILD_PROCEDURE_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_FOOTER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'TABLE'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_DBA_COL_DETAILS'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_GENERATE'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_CONSTANTS') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_CONSTANTS'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_CONSTANTS'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'GET_VERSION'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_USER_ROLE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_SCHEMA'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_TABLESPACE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TRUE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_FALSE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_PASSED'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_FAILED'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_TEST_UNDEFINED'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_MIN_FILL_LENGTH'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_NUM_MAX_FILL_LENGTH'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_DELIMITER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_ERROR'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_NA'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_INTERNAL_VAR'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_CONFIG_TYPE_NUMBER'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'GET_OTAP_CONFIG_TYPE_CHAR'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_CONSTANTS'
                              , p_return_type => 'VARCHAR2'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_LOG') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_LOG'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_LOG'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'LOG'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'PROCEDURE'
                              , p_package_name => 'OTAP_LOG'
                              ) FROM dual;
-- set test name for package
SELECT otap_test.set_test_name('package OTAP_LOGIC') FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_LOGIC'
                            , p_schema => 'OTAP'
                            ) FROM dual;
SELECT otap_test.has_package( p_package_name => 'OTAP_LOGIC'
                            , p_schema => 'OTAP'
                            , p_package_type => 'PACKAGE BODY'
                            ) FROM dual;
-- otap GENERATE test scripts OTAP procedures
-- LIKE scope: %
SELECT otap_test.has_procedure( p_procedure_name => 'OK'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_LOGIC'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'IS_EQ'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_LOGIC'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_REGEX'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_LOGIC'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'MATCH_LIKE'
                              , p_schema => 'OTAP'
                              , p_procedure_type => 'FUNCTION'
                              , p_package_name => 'OTAP_LOGIC'
                              , p_return_type => 'NUMBER'
                              ) FROM dual;
-- otap GENERATE test scripts OTAP views
-- LIKE scope: %
-- set test group for views
SELECT otap_test.set_test_group('views') FROM dual;
-- set test name for view
SELECT otap_test.set_test_name('view OTAP_IDENTIFIERS_V') FROM dual;
SELECT otap_test.has_object( p_object_name => 'OTAP_IDENTIFIERS_V'
                           , p_object_type => 'VIEW'
                           , p_schema => 'OTAP'
                           ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_IDENTIFIERS_V
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'OTAP_IDENTIFIER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_TEXT_LOWER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_TEXT_CAP'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_TEXT_UPPER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_SOURCE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_TYPE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 32767
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'LABEL_TRANSLATABLE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                           , p_column_name => 'FROM_CONFIG'
                           , p_schema => 'OTAP'
                           , p_data_type => 'NUMBER'
                           , p_data_length => 22
                           , p_nullable => 'Y'
                           ) FROM dual;
-- set test name for view
SELECT otap_test.set_test_name('view OTAP_LATEST_TEST_RESULTS_V') FROM dual;
SELECT otap_test.has_object( p_object_name => 'OTAP_LATEST_TEST_RESULTS_V'
                           , p_object_type => 'VIEW'
                           , p_schema => 'OTAP'
                           ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_LATEST_TEST_RESULTS_V
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_LATEST_TEST_RESULTS_V'
                           , p_column_name => 'RESULT_TEXT'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 16000
                           , p_nullable => 'Y'
                           ) FROM dual;
-- set test name for view
SELECT otap_test.set_test_name('view OTAP_LABELS_MV') FROM dual;
SELECT otap_test.has_object( p_object_name => 'OTAP_LABELS_MV'
                           , p_object_type => 'MATERIALIZED VIEW'
                           , p_schema => 'OTAP'
                           ) FROM dual;
-- otap GENERATE test scripts OTAP columns OTAP_LABELS_MV
-- LIKE scope: %
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'ORACLE_TYPE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_IDENTIFIER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_LOWER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_CAP'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_UPPER'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_LABELS_MV'
                           , p_column_name => 'OTAP_LABEL_SOURCE'
                           , p_schema => 'OTAP'
                           , p_data_type => 'VARCHAR2'
                           , p_data_length => 512
                           , p_nullable => 'Y'
                           ) FROM dual;
