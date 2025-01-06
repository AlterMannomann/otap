-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- otap user create script for Oracle Test Automation Protocol installation.
-- Tested with SQLPlus and SQL Developer. Script must be called/opened from the git directory where this script resides.
-- The tablespace data file given is ignored, if the tablespace already exists. Does nothing if the given user exists,
-- we don't touch existing users. Must be executed with DBA rights.
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
ACCEPT OTAP_USER CHAR DEFAULT 'OTAP' PROMPT 'DB user name for otap (default is OTAP if no value is given): '
ACCEPT OTAP_PASS CHAR PROMPT 'Mandatory db password for &OTAP_USER.: ' HIDE
ACCEPT OTAP_TS CHAR DEFAULT 'OTAP_TABLESPACE' PROMPT 'Table space name for otap (default is OTAP_TABLESPACE if no value is given): '
ACCEPT OTAP_DBF CHAR DEFAULT 'otap.dbf' PROMPT 'Table space data file name for otap (default is otap.dbf if no value is given): '
ACCEPT OTAP_ROLE CHAR DEFAULT 'OTAP_USER' PROMPT 'User role name for otap (default is OTAP_USER if no value is given): '
SPOOL OFF
SET TERMOUT OFF
COLUMN OTAP_MSG NEW_VAL OTAP_MSG
SELECT '==== otap DBA setup ====' || '&LINE_FEED' ||
       'Create user/schema &OTAP_USER. with a password of length ' || LENGTH('&OTAP_PASS') || '? ' || '&LINE_FEED' ||
       '  If not exists, create tablespace &OTAP_TS. with 100 MB and' || '&LINE_FEED' ||
       '  data file &OTAP_DBF..' || '&LINE_FEED' ||
       '  If not exists, role &OTAP_ROLE. for otap users will be created.' || '&LINE_FEED' ||
       'ONLY ONE otap database user should exist per PDB.' || '&LINE_FEED' ||
       'Not allowed to be used as AI training material without explicite permission.' || '&LINE_FEED' ||
       'Use Ctrl-C to stop the script in sqlplus, Enter to continue.' AS OTAP_MSG
  FROM dual;
SET TERMOUT ON
SPOOL logs/otap_dba_setup.log APPEND
PAUSE &OTAP_MSG
SELECT 'Started ...' AS info FROM dual;
-- do most of the things dynamically
DECLARE
  l_statement VARCHAR2(32767);
  l_output    VARCHAR2(32767);
  l_lf        VARCHAR2(1) := CHR(10);
  l_count     NUMBER;
BEGIN
  l_output := '=== otap DBA install result ===' || l_lf;
  -- otap user
  SELECT COUNT(*) INTO l_count FROM dba_users WHERE username = UPPER('&OTAP_USER');
  IF l_count = 0
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
    -- roles
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
    -- basic grants
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
    l_output := l_output || 'SUCCESS no errors';
  ELSE
    l_output := l_output || 'WARNING User &OTAP_USER. already exists. NO CHANGES APPLIED.' || l_lf;
  END IF;
  DBMS_OUTPUT.PUT_LINE(l_output);
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
SELECT 'Created otap_setup_def.sql with current setup data.' AS info FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
