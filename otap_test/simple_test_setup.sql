SET PAGESIZE 1000
SET LINESIZE 10000
SET LONG 4000
SET LONGCHUNKSIZE 4000
SET HEADING OFF
SET FEEDBACK OFF
SELECT otap_test.current_settings FROM dual;
SELECT otap_test.init_test(5, 'OTAP', 'SCHEMA', 'Table OTAP_CONFIG') FROM dual;
SELECT otap_test.has_table('OTAP_CONFIG') FROM dual;
SELECT otap_test.has_column('OTAP_CONFIG', 'CONFIG_NAME') FROM dual;
SELECT otap_test.set_test_name('Table OTAP_RESULTS') FROM dual;
SELECT otap_test.has_table('OTAP_RESULTS') FROM dual;
SELECT otap_test.set_test_group('INTERNAL') FROM dual;
SELECT otap_test.set_test_name('Table SPERRORLOG') FROM dual;
SELECT otap_test.has_table('SPERRORLOG') FROM dual;
SELECT otap_test.set_test_set('ERRORS') FROM dual;
SELECT otap_test.set_test_group('ERROR reaction') FROM dual;
SELECT otap_test.set_test_name('HAS_TABLE') FROM dual;
SELECT otap_test.has_table(NULL) FROM dual;
SELECT otap_test.has_table('HAB ICH NICHT') FROM dual;
SELECT otap_test.set_test_name('HAS_COLUMN') FROM dual;
SELECT otap_test.has_column(NULL, NULL) FROM dual;
SELECT otap_test.has_column(NULL, 'CONFIG_NAME') FROM dual;
SELECT otap_test.has_column('OTAP_CONFIG', NULL) FROM dual;
SELECT otap_test.finish_test FROM dual;

SELECT * FROM otap_latest_test_results_v;

-- formatting (min fill 80) based on length, set, group and test name delimiter
-- summary after every section
-- empty lines
-- set:, group: and test: prefix instead of indentation
-- text constants in function or package, not in code
-- only raise on -20099 exception, wrapper for test functions to provide the exception to test_errors field
-- provide translations (only general, for all, no user defined translations)
-- system check, all triggers active and so on, if not, point out that otap is not stable -> report
