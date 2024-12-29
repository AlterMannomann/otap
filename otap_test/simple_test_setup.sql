SET PAGESIZE 1000
SET LINESIZE 10000
SET LONG 4000
SET LONGCHUNKSIZE 4000
SET HEADING OFF
SET FEEDBACK OFF
SELECT otap_test.current_settings FROM dual;
SELECT otap_test.init_test(3, 'OTAP', 'SCHEMA', 'Table OTAP_CONFIG') FROM dual;
SELECT otap_test.has_table('OTAP_CONFIG') FROM dual;
SELECT otap_test.set_test_name('Table OTAP_RESULTS') FROM dual;
SELECT otap_test.has_table('OTAP_RESULTS') FROM dual;
SELECT otap_test.set_test_name('Table SPERRORLOG') FROM dual;
SELECT otap_test.has_table('SPERRORLOG') FROM dual;
SELECT otap_test.finish_test FROM dual;

SELECT * FROM TABLE(otap_test.result_view(otap_test.get_session_id));

-- formatting (min fill 80) based on length, set, group and test name delimiter
-- summary after every section
-- empty lines
-- set:, group: and test: prefix instead of indentation
-- text constants in function or package, not in code