-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- The master test script, which calls the master scripts in the directories below.
-- Directories are organized equivalent to test set, test group and test name.
-- It will initialize the test session and save the test report to disk.

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
SELECT otap_test.init_test( p_test_count => 373
                          , p_test_set => 'OTAP system test'
                          )
  FROM dual
;

-- call directory master scripts
@@functionality/otap_testing_master.sql
@@schema/otap_schema_master.sql
--@@functionality/otap_functionality_master.sql

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