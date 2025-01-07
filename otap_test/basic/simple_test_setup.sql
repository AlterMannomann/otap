SET PAGESIZE 1000
SET LINESIZE 10000
SET LONG 4000
SET LONGCHUNKSIZE 4000
SET HEADING OFF
SET FEEDBACK OFF
SELECT otap_test.current_settings FROM dual;
SELECT otap_test.init_test(10, 'OTAP', 'SCHEMA', 'Table OTAP_CONFIG') FROM dual;
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
SELECT otap_test.has_table( p_table_name => NULL
                          , p_description => 'Check NULL table'
                          , p_expected_result => otap_constants.get_otap_num_test_undefined
                          ) FROM dual;
SELECT otap_test.has_table( p_table_name => 'HAB ICH NICHT'
                          , p_description => 'Check not existing table'
                          , p_expected_result => otap_constants.get_otap_num_test_failed
                          ) FROM dual;
SELECT otap_test.set_test_name('HAS_COLUMN') FROM dual;
SELECT otap_test.has_column( p_table_name => NULL
                           , p_column_name => NULL
                           , p_description => 'Check NULL table and column'
                           , p_expected_result => otap_constants.get_otap_num_test_undefined
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => NULL
                           , p_column_name => 'CONFIG_NAME'
                           , p_description => 'Check NULL table'
                           , p_expected_result => otap_constants.get_otap_num_test_undefined
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => NULL
                           , p_description => 'Check NULL column'
                           , p_expected_result => otap_constants.get_otap_num_test_undefined
                           ) FROM dual;
SELECT otap_test.has_column( p_table_name => 'OTAP_CONFIG'
                           , p_column_name => 'HAB ICH NICHT'
                           , p_description => 'Check column not exists'
                           , p_expected_result => otap_constants.get_otap_num_test_failed
                           ) FROM dual;
SELECT otap_test.finish_test FROM dual;

SELECT * FROM otap_latest_test_results_v;

-- system check, all triggers active and so on, if not, point out that otap is not stable -> report

/* DUMMIES
CREATE OR REPLACE FUNCTION DUMMY_FUNCTION(p_number IN NUMBER, p_char IN VARCHAR2, p_date IN DATE)
  RETURN VARCHAR2
IS
BEGIN
  RETURN 'Only Dummy for testing';
END;
/

CREATE OR REPLACE PROCEDURE DUMMY_PROCEDURE(p_number IN NUMBER, p_char IN VARCHAR2, p_date IN DATE)
IS
BEGIN
  NULL;
END;
/

*/