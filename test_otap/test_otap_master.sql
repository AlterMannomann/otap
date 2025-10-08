-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- The master test script, which calls the master scripts in the directories below.
-- Directories are organized equivalent to test set, test group and test name.
-- It will initialize the test session and save the test report to disk.
-- Expected structure within a test name directory is
-- - directory master script
-- -- otap_(unit)(_intrusive).sql script handle test name and manage configuration if _intrusive
-- --- otap_(unit)_code.sql The code block and sql scripts that can run with any given configuration
-- This script also calls intrusive tests which change configurations and scheduler jobs for testing.
-- Therefore it should not be executed if other users are actively testing.

-- REWORK TESTS. Test code should run without expectations, based on the current setup
-- should have current setup in test description to distinguish intrusive and non intrusive runs
-- Intrusive only has additional setup changes before calling the test code otherwise only set the test name
-- otap_x.sql or otap_x_instrusive.sql
--- otap_x_code.sql
-- intrusive must check current configuration and avoid setting this configuration as it will only duplicate tests already done
-- WRITING LOG ENTRIES is NOT INTRUSIVE

-- setup SQLPlus
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

@@../setup/util/log_visible.sql
CLEAR COLUMNS
COLUMN IDENT NEW_VAL IDENT
SELECT 'otap_test_run' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') AS IDENT
  FROM dual;
-- try again with identifier
SET ERRORLOGGING ON IDENTIFIER &IDENT
-- spool the test run
SPOOL otap_test_run.log
-- init the session
-- do not make a count test, set some defaults
SELECT otap_test.init_test( p_test_count => 2450
                          , p_test_set => 'OTAP full system test'
                          )
  FROM dual
;

-- call directory master scripts
@@test_functionality/test_basics/test_basic_master.sql
@@test_schema/test_schema_master.sql
@@test_functionality/test_main/test_main_master.sql

-- get setup test script execution summary
SELECT otap_test.test_error_check(COUNT(*), 0, 'Check script errors in SPERRORLOG')
  FROM sperrorlog
 WHERE identifier = '&IDENT'
;
-- get errors if any
SELECT otap_test.test_error('Script errors ' || TO_CHAR(TRIM(script)), TO_CHAR(message)) AS error_msg
  FROM sperrorlog
 WHERE identifier = '&IDENT'
 ORDER BY timestamp
;

-- finish test
SELECT otap_test.finish_test FROM dual;
SPOOL OFF
-- write report
@@../setup/util/log_silent.sql
SPOOL otap_test_result.log
SELECT result_text FROM otap_latest_test_results_v;
SPOOL OFF
-- exit
EXIT