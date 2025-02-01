SET PAGESIZE 1000
SET LINESIZE 10000
SET LONG 4000
SET LONGCHUNKSIZE 4000
SET HEADING OFF
SET FEEDBACK OFF
SELECT otap_test.current_settings FROM dual;
SELECT otap_test.init_test(9, 'OTAP examples' , 'Test functions', 'Tests passing') FROM dual;
SELECT otap_test.has_table('OTAP_CONFIG') FROM dual;
SELECT otap_test.has_column('OTAP_CONFIG', 'CONFIG_NAME') FROM dual;
SELECT otap_test.has_trigger('OTAP_TRANSLATE_INS_TRG') FROM dual;
SELECT otap_test.has_package('OTAP_STRING') FROM dual;
SELECT otap_test.has_procedure( p_procedure_name => 'REDUCE'
                              , p_package_name => 'OTAP_STRING'
                              ) FROM dual;
SELECT otap_test.set_test_name('Tests failing') FROM dual;
SELECT otap_test.has_table('I DONT EXIST') FROM dual;
SELECT otap_test.has_table(p_table_name => NULL, p_description => 'Give NULL as table name for has_tables') FROM dual;
SELECT otap_test.set_test_name('Tests failing but pass') FROM dual;
SELECT otap_test.has_table(p_table_name => 'I DONT EXIST', p_expected_result => otap_constants.get_otap_num_test_failed) FROM dual;
SELECT otap_test.has_table(p_table_name => NULL, p_expected_result => otap_constants.get_otap_num_test_undefined, p_description => 'Give NULL as table name for has_tables') FROM dual;
SELECT otap_test.finish_test FROM dual;

SELECT * FROM otap_latest_test_results_v;
