-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- updates packages and data of the otap environment
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
-- update config data
UPDATE otap_config
   SET config_value = 'sets: @sets@ groups: @groups@ names: @names@ descriptions: @descs@'
 WHERE config_name = 'TEMPLATE_REPORT_TOTAL'
;
UPDATE otap_config
   SET config_value = '@status@ @runtime@ @exectime@ runs: @runs@ errors: @errors@ issues: @issues@'
 WHERE config_name = 'TEMPLATE_SUMMARY'
;
UPDATE otap_config
   SET config_max_length  = 50
     , config_description = 'Used in templates as information text if a set, group or test name has executed without errors. Extended by the category specific information. Adjust summary header if longer than 7 chars. Limited to 50 chars, recommended as short as possible.'
 WHERE config_name = 'TEXT_SUMMARY_SUCCESS'
;
UPDATE otap_config
   SET config_max_length  = 50
     , config_description = 'Used in templates as information text if a set, group or test name has executed with errors. Extended by the category specific information. Adjust summary header if longer than 7 chars. Limited to 50 chars, recommended as short as possible.'
 WHERE config_name = 'TEXT_SUMMARY_ERROR'
;
COMMIT;
-- reinstall session object
@@../otap_ddl/types/otap_session.sql
-- reinstall the materialized view to get all labels
@@../otap_ddl/views/drop/drop_otap_labels_mv.sql
@@../otap_ddl/views/otap_labels_mv.sql
-- reinstall changed views
@@../otap_ddl/views/otap_identifiers_v.sql
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
-- update trigger
@@../otap_ddl/triggers/otap_translate_trg.sql
-- insert new config values after supported by packages, if they do not exist yet
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  SELECT 'DEFAULT_LANGUAGE' AS config_name
       , 'N/A' AS config_value
       , 'CHAR' AS config_type
       , 3 AS config_max_length
       , 'Defines the default language to use for entries in the translation table. Will always be handled upper case internally.' AS config_description
    FROM dual
   WHERE (SELECT COUNT(*) FROM otap_config WHERE config_name = 'DEFAULT_LANGUAGE') = 0
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  SELECT 'TEXT_SUMMARY_HEADER' AS config_name
       , 'Overall   Runtime             Execution time      Details' AS config_value
       , 'CHAR' AS config_type
       , 256 AS config_max_length
       , 1 AS translatable
       , 'Used in templates as summary header, depending on formatting and size of summary success and error. If the strings are longer than 7 chars the header line must be adjusted. Limited to 256, recommended shorter than 80 chars.' AS config_description
    FROM dual
   WHERE (SELECT COUNT(*) FROM otap_config WHERE config_name = 'TEXT_SUMMARY_HEADER') = 0
;
-- delete unused config values after package update
DELETE FROM otap_config WHERE config_name IN ('TEXT_SUMMARY_SUCCESS', 'TEXT_SUMMARY_ERROR');
COMMIT;
-- recompile invalidated objects by package recreates
EXEC DBMS_UTILITY.COMPILE_SCHEMA(SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), FALSE);
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
