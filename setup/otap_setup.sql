-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- setup the otap environment
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
SPOOL logs/otap_setup.log
-- types
@@../otap_ddl/types/otap_session.sql
@@../otap_ddl/types/otap_view_result_rec.sql
@@../otap_ddl/types/otap_view_result_tbl.sql
-- sequences
@@../otap_ddl/sequences/otap_test_session_seq.sql
-- independent packages
@@../otap_ddl/packages/otap_constants.pks
@@../otap_ddl/packages/otap_constants.pkb
-- tables
@@../otap_ddl/tables/otap_config.sql
@@../otap_ddl/tables/otap_results.sql
@@../otap_ddl/tables/otap_translate.sql
-- views accessed by packages
@@../otap_ddl/views/otap_labels_v.sql
@@../otap_ddl/views/otap_identifiers_v.sql
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
@@../otap_ddl/packages/otap_api.pks
@@../otap_ddl/packages/otap_api.pkb
@@../otap_ddl/packages/otap_test.pks
@@../otap_ddl/packages/otap_test.pkb
@@../otap_ddl/packages/otap_generate.pks
@@../otap_ddl/packages/otap_generate.pkb
-- table trigger
@@../otap_ddl/triggers/otap_config_trg.sql
@@../otap_ddl/triggers/otap_results_trg.sql
@@../otap_ddl/triggers/otap_translate_trg.sql
-- jobs
@@../otap_ddl/jobs/OTAP_MAINTENANCE.sql
-- views
@@../otap_ddl/views/otap_latest_test_results_v.sql
-- setup defaults
@@otap_defaults.sql
-- ==============INSTALL end==============
@@util/log_silent.sql
-- check errors and display them, if so
SELECT CASE
         WHEN COUNT(*) = 0
         THEN 'SUCCESS - no errors found during setup'
         ELSE 'ERROR - setup script has errors'
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
