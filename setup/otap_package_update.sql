-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- updates packages of the otap environment
@@util/log_visible.sql
-- set CHAR semantics to get SPERRORLOG ready for bigger chars before creation
ALTER SESSION SET NLS_LENGTH_SEMANTICS=CHAR;
CLEAR COLUMNS
COLUMN IDENT NEW_VAL IDENT
SELECT 'otap_setup' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') AS IDENT
  FROM dual;
-- error logging to default SPERRORLOG, first entry only to guarantee that SPERRORLOG is created
SET ERRORLOGGING ON
-- try again with identifier
SET ERRORLOGGING ON IDENTIFIER &IDENT
-- ==============INSTALL start==============
SPOOL logs/otap_update.log
-- reinstall the materialized view to get all labels
@@../otap_ddl/views/drop/drop_otap_labels_mv.sql
@@../otap_ddl/views/otap_labels_mv.sql
-- independent packages
@@../otap_ddl/packages/otap_constants.pks
@@../otap_ddl/packages/otap_constants.pkb
-- packages
@@../otap_ddl/packages/otap_log.pks
@@../otap_ddl/packages/otap_log.pkb
@@../otap_ddl/packages/otap_string.pks
@@../otap_ddl/packages/otap_string.pkb
@@../otap_ddl/packages/otap_util.pks
@@../otap_ddl/packages/otap_util.pkb
@@../otap_ddl/packages/otap_report.pks
@@../otap_ddl/packages/otap_report.pkb
@@../otap_ddl/packages/otap_objects.pks
@@../otap_ddl/packages/otap_objects.pkb
@@../otap_ddl/packages/otap_plan.pks
@@../otap_ddl/packages/otap_plan.pkb
@@../otap_ddl/packages/otap_schema.pks
@@../otap_ddl/packages/otap_schema.pkb
@@../otap_ddl/packages/otap_logic.pks
@@../otap_ddl/packages/otap_logic.pkb
@@../otap_ddl/packages/otap_api.pks
@@../otap_ddl/packages/otap_api.pkb
@@../otap_ddl/packages/otap_generate.pks
@@../otap_ddl/packages/otap_generate.pkb
@@../otap_ddl/packages/otap_test.pks
@@../otap_ddl/packages/otap_test.pkb
-- ==============INSTALL end==============
@@util/log_silent.sql
-- check errors and display them, if so
SELECT CASE
         WHEN COUNT(*) = 0
         THEN 'SUCCESS - no errors found during package update'
         ELSE 'ERROR - update script has errors'
       END AS info
  FROM sperrorlog
 WHERE identifier = '&IDENT'
;
SELECT TO_CHAR(SUBSTR(message, 1, 2000)) AS error_messages
  FROM sperrorlog
 WHERE identifier = '&IDENT'
;
SELECT otap_constants.get_version AS otap_version
  FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
