-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- no checks if table exists, cleanup otap objects
@@util/log_visible.sql
CLEAR COLUMNS
COLUMN IDENT NEW_VAL IDENT
SELECT 'otap_cleanup' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') AS IDENT
  FROM dual;
-- error logging to default SPERRORLOG, first entry only to guarantee that SPERRORLOG is created
SET ERRORLOGGING ON
-- try again with identifier
SET ERRORLOGGING ON IDENTIFIER &IDENT
-- ==============UNINSTALL start==============
SPOOL logs/otap_cleanup.log
-- jobs
@@../otap_ddl/jobs/drop/drop_OTAP_MAINTENANCE.sql
-- package objects
@@../otap_ddl/packages/drop/drop_otap_test_pkb.sql
@@../otap_ddl/packages/drop/drop_otap_test_pks.sql
@@../otap_ddl/packages/drop/drop_otap_schema_pkb.sql
@@../otap_ddl/packages/drop/drop_otap_schema_pks.sql
@@../otap_ddl/packages/drop/drop_otap_plan_pkb.sql
@@../otap_ddl/packages/drop/drop_otap_plan_pks.sql
@@../otap_ddl/packages/drop/drop_otap_util_pkb.sql
@@../otap_ddl/packages/drop/drop_otap_util_pks.sql
@@../otap_ddl/packages/drop/drop_otap_constants_pkb.sql
@@../otap_ddl/packages/drop/drop_otap_constants_pks.sql
-- table objects including associated table trigger
@@../otap_ddl/tables/drop/drop_otap_results.sql
@@../otap_ddl/tables/drop/drop_otap_config.sql
-- types
@@../otap_ddl/types/drop/drop_otap_session.sql
-- ==============UNINSTALL end==============
@@util/log_silent.sql
-- check errors and display them, if so
SELECT CASE
         WHEN COUNT(*) = 0
         THEN 'SUCCESS - no errors found during cleanup'
         ELSE 'ERROR - cleanup script has errors'
       END AS info
  FROM sperrorlog
 WHERE identifier = '&IDENT'
;
SELECT TO_CHAR(SUBSTR(message, 1, 2000)) AS error_messages
  FROM sperrorlog
 WHERE identifier = '&IDENT'
;
SELECT '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1' || CHR(10) ||
       'Not allowed to be used as AI training material without explicite permission.' AS disclaimer
  FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
