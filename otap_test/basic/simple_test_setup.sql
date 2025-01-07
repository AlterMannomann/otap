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

-- generate test functions, be careful you get current state not desired state
        WITH prc AS
             (SELECT dbo.owner
                   , dbp.procedure_name
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN 'FUNCTION'
                       ELSE 'PROCEDURE'
                     END AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , dbo.object_name AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.package_name
                 AND dbp.procedure_name = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = 'OTAP'
                 AND dbo.object_type  = 'PACKAGE'
                     -- exclude package itself
                 AND dbp.procedure_name IS NOT NULL
               UNION ALL
              SELECT dbo.owner
                   , dbo.object_name AS procedure_name
                   , dbo.object_type AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , NULL AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = 'OTAP'
                 AND dbo.object_type IN ('FUNCTION', 'PROCEDURE')
             )
      SELECT procedure_name
           , 'SELECT otap_test.has_procedure( p_procedure_name => ''' || procedure_name || '''' || CHR(10) ||
             '                              , p_procedure_type => ''' || procedure_type || '''' || CHR(10) ||
             CASE WHEN procedure_type = 'FUNCTION' THEN '                              , p_return_type => ''' || return_type || '''' || CHR(10) END ||
             '                              , p_package_name => ''' || package_name || '''' || CHR(10) ||
             '                              )' || CHR(10) ||
             '  FROM dual;' AS code
        FROM prc
       WHERE package_name = 'OTAP_CONFIG_UTIL'
      ;

*/