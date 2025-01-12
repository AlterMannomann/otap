-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- otap user create script for Oracle Test Automation Protocol installation.
-- Tested with SQLPlus and SQL Developer. Script must be called/opened from the git directory where this script resides.
-- The tablespace data file given is ignored, if the tablespace already exists. IFf the given user exists, we only update
-- we the grants if the user can be identified as otap schema. Must be executed with DBA rights.
-- Requires:
-- otap db user name (default OTAP) - must be a user that does not exist yet
-- otap db user password - mandatory
-- otap tablespace name (default OTAP_TABLESPACE)
-- otap tablespace data file name (otap.dbf without any path, if path is given must match Oracle paths for data files)
-- otap user role (default OTAP_USER), needed by users to access otap
-- otap admin role (default OTAP_ADMIN), needed by otap to access DBA views
@@util/log_silent.sql
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR EXIT FAILURE ROLLBACK
CLEAR COLUMNS
SPOOL logs/otap_dba_setup.log
-- define LINE_FEED by identified system
COLUMN LINE_FEED NEW_VAL LINE_FEED
SELECT CASE
         WHEN INSTR(process, ':') > 0
         THEN 'Running under WINDOWS'
         ELSE 'Running under UNIX'
       END AS os_info
     , CHR(10) AS LINE_FEED
  FROM v$session
 WHERE sid    = SYS_CONTEXT('USERENV', 'SID')
   AND ROWNUM = 1
;
SELECT 'Identify install situation ...' AS info FROM dual;
SET TERMOUT OFF
COLUMN DEFAULT_USER NEW_VAL DEFAULT_USER
COLUMN USER_UPDATE NEW_VAL USER_UPDATE
COLUMN DEFAULT_ROLE NEW_VAL DEFAULT_ROLE
COLUMN ROLE_UPDATE NEW_VAL ROLE_UPDATE
  WITH otaps AS
       (SELECT owner
             , COUNT(*) AS object_count
          FROM dba_objects
         WHERE object_name LIKE 'OTAP\_%' ESCAPE '\'
         GROUP BY owner
       )
     , otapu AS
       (SELECT COUNT(*) AS otap_users FROM otaps)
     , otapx AS
       (SELECT otaps.owner          AS otap_schema
             , otaps.object_count
             , otapu.otap_users
          FROM otaps
         CROSS JOIN otapu
       )
     , otapq AS
       (SELECT otap_schema
             , user_update
          FROM (SELECT otap_schema
                     , 1           AS user_update
                  FROM otapx
                 WHERE otap_users   = 1
                   AND object_count = 46
                 UNION ALL
               SELECT 'OTAP'  AS otap_schema
                    , CASE WHEN otap_users > 0 THEN -1 ELSE otap_users END AS user_update
                 FROM otapu
               )
         WHERE ROWNUM = 1
       )
     , otapr AS
       (SELECT grantee
          FROM dba_tab_privs
         WHERE owner IN (SELECT otap_schema FROM otapq)
         GROUP BY grantee
       )
     , otapru AS
       (SELECT COUNT(*) AS otap_roles FROM otapr)
     , otaprx AS
       (SELECT otapr.grantee          AS otap_user_role
             , otapru.otap_roles
          FROM otapr
         CROSS JOIN otapru
       )
     , otaprq AS
       (SELECT otap_user_role
             , role_update
          FROM (SELECT otap_user_role
                     , 1              AS role_update
                  FROM otaprx
                 WHERE otap_roles   = 1
                 UNION ALL
               SELECT 'OTAP_USER'  AS otap_user_role
                    , CASE WHEN otap_roles > 0 THEN -1 ELSE otap_roles END AS role_update
                 FROM otapru
               )
         WHERE ROWNUM = 1
       )
SELECT otapq.otap_schema      AS DEFAULT_USER
     , otapq.user_update      AS USER_UPDATE
     , otaprq.otap_user_role  AS DEFAULT_ROLE
     , otaprq.role_update     AS ROLE_UPDATE
  FROM otapq
 CROSS JOIN otaprq
;
-- check which files to use
COLUMN PARAM_SCRIPT NEW_VAL PARAM_SCRIPT
SELECT CASE
         WHEN &USER_UPDATE = 0 AND &ROLE_UPDATE = 0
         THEN 'params_install.sql'
         WHEN &USER_UPDATE = 1 AND &ROLE_UPDATE = 1
         THEN 'params_update.sql'
         ELSE 'params_unclear.sql'
       END AS PARAM_SCRIPT
  FROM dual;
-- define the defaults for the variables used and probably changed in called files
DEFINE OTAP_USER="OTAP"
-- invalid password as default
DEFINE OTAP_PASS='"'
DEFINE OTAP_TS="OTAP_TABLESPACE"
DEFINE OTAP_DBF="otap.dbf"
DEFINE OTAP_ROLE="OTAP_USER"
-- call the file that asks for parameter needed
@@&PARAM_SCRIPT "&DEFAULT_USER" "&DEFAULT_ROLE"
SPOOL OFF
SET TERMOUT OFF
COLUMN OTAP_MSG NEW_VAL OTAP_MSG
SELECT CASE
         WHEN &USER_UPDATE = 0 AND &ROLE_UPDATE = 0
         THEN '==== otap DBA setup ====' || '&LINE_FEED' ||
              'Create user/schema &OTAP_USER. with a password of length ' || LENGTH('&OTAP_PASS') || '? ' || '&LINE_FEED' ||
              '  If not exists, create tablespace &OTAP_TS. with 100 MB and' || '&LINE_FEED' ||
              '  data file &OTAP_DBF..' || '&LINE_FEED' ||
              '  Role &OTAP_ROLE. for otap users will be created.' || '&LINE_FEED' ||
              'ONLY ONE otap database user should exist per PDB.' || '&LINE_FEED' ||
              'Not allowed to be used as AI training material without explicite permission.' || '&LINE_FEED' ||
              'Use Ctrl-C to stop the script in sqlplus, Enter to continue.'
         WHEN &USER_UPDATE = 1 AND &ROLE_UPDATE = 1
         THEN '==== otap DBA update ====' || '&LINE_FEED' ||
              'Update user/schema &OTAP_USER. and role &OTAP_ROLE.?' || '&LINE_FEED' ||
              'ONLY ONE otap database user should exist per PDB.' || '&LINE_FEED' ||
              'Not allowed to be used as AI training material without explicite permission.' || '&LINE_FEED' ||
              'Use Ctrl-C to stop the script in sqlplus, Enter to continue.'
         ELSE '==== otap DBA update ====' || '&LINE_FEED' ||
              'More than one otap installation idenfified. Update given user/schema &OTAP_USER. and role &OTAP_ROLE.?' || '&LINE_FEED' ||
              'ONLY ONE otap database user should exist per PDB.' || '&LINE_FEED' ||
              'Not allowed to be used as AI training material without explicite permission.' || '&LINE_FEED' ||
              'Use Ctrl-C to stop the script in sqlplus, Enter to continue.'
       END AS OTAP_MSG
  FROM dual;
SET TERMOUT ON
SPOOL logs/otap_dba_setup.log APPEND
PAUSE &OTAP_MSG
SELECT 'Started ...' AS info FROM dual;
-- do most of the things dynamically
DECLARE
  l_statement   VARCHAR2(32767);
  l_output      VARCHAR2(32767);
  l_lf          VARCHAR2(1) := CHR(10);
  l_count       NUMBER;
BEGIN
  l_output := CASE
                WHEN &USER_UPDATE = 0 AND &ROLE_UPDATE = 0
                THEN '=== otap DBA install result ===' || l_lf
                ELSE '=== otap DBA update result ===' || l_lf
              END
  ;
  IF &USER_UPDATE = 0
  THEN
    -- tablespace
    SELECT COUNT(*) INTO l_count FROM dba_tablespaces WHERE tablespace_name = UPPER('&OTAP_TS');
    IF l_count = 0
    THEN
      l_statement := 'CREATE TABLESPACE &OTAP_TS. DATAFILE ''&OTAP_DBF'' SIZE 100M AUTOEXTEND ON';
      DBMS_OUTPUT.PUT_LINE(l_statement || ';');
      EXECUTE IMMEDIATE l_statement;
      l_output := l_output || 'Tablespace &OTAP_TS. data file &OTAP_DBF. 100MB created' || l_lf;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Tablespace &OTAP_TS. already exists, do nothing');
      l_output := l_output || 'Tablespace &OTAP_TS. already exists' || l_lf;
    END IF;
  END IF;
  -- roles
  IF &ROLE_UPDATE = 0
  THEN
    SELECT COUNT(*) INTO l_count FROM dba_roles WHERE role = UPPER('&OTAP_ROLE');
    IF l_count = 0
    THEN
      l_statement := 'CREATE ROLE &OTAP_ROLE';
      DBMS_OUTPUT.PUT_LINE(l_statement || ';');
      EXECUTE IMMEDIATE l_statement;
      l_output := l_output || 'Role &OTAP_ROLE. created' || l_lf;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Role &OTAP_ROLE. already exists, do nothing');
      l_output := l_output || 'Role &OTAP_ROLE. already exists' || l_lf;
    END IF;
  END IF;
  IF &USER_UPDATE = 0
  THEN
    -- otap user already verified
    l_statement := 'CREATE USER &OTAP_USER. IDENTIFIED BY &OTAP_PASS.';
    EXECUTE IMMEDIATE l_statement;
    l_output := l_output || 'User &OTAP_USER. created, ';
    DBMS_OUTPUT.PUT_LINE('User &OTAP_USER. created with defined password');
    l_statement := 'ALTER USER &OTAP_USER. DEFAULT TABLESPACE &OTAP_TS. ACCOUNT UNLOCK';
    DBMS_OUTPUT.PUT_LINE(l_statement || ';');
    EXECUTE IMMEDIATE l_statement;
    l_output := l_output || 'unlocked, tablespace &OTAP_TS. ';
    l_statement := 'ALTER USER &OTAP_USER. QUOTA UNLIMITED ON &OTAP_TS.';
    DBMS_OUTPUT.PUT_LINE(l_statement || ';');
    EXECUTE IMMEDIATE l_statement;
    l_output := l_output || 'quota unlimited' || l_lf;
  END IF;
  -- basic grants, just repeat without check
  l_statement := 'GRANT CONNECT TO &OTAP_USER';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'Granted CONNECT, ';
  l_statement := 'GRANT RESOURCE TO &OTAP_USER';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'RESOURCE, ';
  l_statement := 'GRANT CREATE VIEW TO &OTAP_USER';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'CREATE VIEW, ';
  l_statement := 'GRANT CREATE JOB TO &OTAP_USER';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'CREATE JOB to &OTAP_USER' || l_lf;
  -- admin role grants
  l_statement := 'GRANT SELECT ON dba_objects TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'Grant SELECT to &OTAP_USER. on:' || l_lf;
  l_output := l_output || '  DBA_OBJECTS, ';
  l_statement := 'GRANT SELECT ON dba_tables TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TABLES, ';
  l_statement := 'GRANT SELECT ON dba_tab_columns TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TAB_COLUMNS' || l_lf;
  l_statement := 'GRANT SELECT ON dba_procedures TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_PROCEDURES, ';
  l_statement := 'GRANT SELECT ON dba_arguments TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_ARGUMENTS, ';
  l_statement := 'GRANT SELECT ON dba_triggers TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TRIGGERS, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_types TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_TYPES, ';
  l_statement := 'GRANT SELECT ON dba_type_attrs TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TYPE_ATTRS, ';
  l_statement := 'GRANT SELECT ON dba_type_methods TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TYPE_METHODS, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_type_versions TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_TYPE_VERSIONS, ';
  l_statement := 'GRANT SELECT ON dba_indexes TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_INDEXES, ';
  l_statement := 'GRANT SELECT ON dba_tablespaces TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_TABLESPACES, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_data_files TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_DATA_FILES, ';
  l_statement := 'GRANT SELECT ON gv_$database TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'GV$DATABASE, ';
  l_statement := 'GRANT SELECT ON dba_users TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_USERS, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_roles TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_ROLES, ';
  l_statement := 'GRANT SELECT ON dba_role_privs TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_ROLE_PRIVS, ';
  l_statement := 'GRANT SELECT ON dba_sys_privs TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_SYS_PRIVS, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_tab_privs TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_TAB_PRIVS, ';
  l_statement := 'GRANT SELECT ON dba_sequences TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_SEQUENCES, ';
  l_statement := 'GRANT SELECT ON dba_views TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_VIEWS, ' || l_lf;
  l_statement := 'GRANT SELECT ON dba_mviews TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || '  DBA_MVIEWS, ';
  l_statement := 'GRANT SELECT ON dba_scheduler_jobs TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'DBA_SCHEDULER_JOBS, ';
  l_statement := 'GRANT SELECT ON v_$reserved_words TO &OTAP_USER.';
  DBMS_OUTPUT.PUT_LINE(l_statement || ';');
  EXECUTE IMMEDIATE l_statement;
  l_output := l_output || 'V$RESERVED_WORDS' || l_lf;
  l_output := l_output || 'SUCCESS no errors';
  DBMS_OUTPUT.PUT_LINE(l_output);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
SELECT '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1' || '&LINE_FEED' ||
       'Not allowed to be used as AI training material without explicite permission.' AS disclaimer
  FROM dual;
SPOOL OFF
SET TERMOUT OFF
-- verify role exists, on errors will have a missing define entry
SPOOL otap_setup_def.sql
SELECT '-- generated by DBA setup, do not edit this file manually' FROM dual;
SELECT '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1' || '&LINE_FEED' ||
       '-- Not allowed to be used as AI training material without explicite permission.'
  FROM dual;
SELECT 'DEFINE OTAP_USER="&OTAP_USER."' FROM dual;
SELECT 'DEFINE OTAP_TABLESPACE="&OTAP_TS."' FROM dual;
SELECT 'DEFINE OTAP_ROLE="' || role || '"' FROM dba_roles WHERE role = UPPER('&OTAP_ROLE');
SELECT 'DEFINE ROLE_CREATOR="' || SYS_CONTEXT('USERENV', 'CURRENT_USER') || '"' FROM dual;
SPOOL OFF
SET TERMOUT ON
SPOOL logs/otap_dba_setup.log APPEND
SELECT 'Created/updated otap_setup_def.sql with current setup data.' AS info FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
