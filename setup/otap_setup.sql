-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- setup the otap environment
@@util/log_visible.sql
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
-- tables
@@../otap_ddl/tables/otap_config.sql
@@../otap_ddl/tables/otap_results.sql
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
SELECT '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1' || CHR(10) ||
       'Not allowed to be used as AI training material without explicite permission.' AS disclaimer
  FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
