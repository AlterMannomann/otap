-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Drop script for otap database user.
-- otap db user name to drop (default OTAP) - must be a user that exists
-- otap tablespace name to drop (default OTAP_TABLESPACE) - only dropped if noone else uses this tablespace
-- otap drop tablespace indicator N (no) or Y (yes), default is N - only dropped if noone else uses this tablespace
-- otap drop roles indicator N (no) or Y (yes), default is N - only dropped if noone else uses the roles
@@util/log_silent.sql
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR EXIT FAILURE ROLLBACK
CLEAR COLUMNS
-- read setup variables
@@otap_setup_def.sql
SPOOL logs/otap_dba_cleanup.log
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
ACCEPT OTAP_DROP_USER CHAR DEFAULT '&OTAP_USER' PROMPT 'OTAP DB user name to drop (default is &OTAP_USER. if no value is given): '
ACCEPT OTAP_TS CHAR DEFAULT '&OTAP_TABLESPACE' PROMPT 'OTAP table space name to drop (default is &OTAP_TABLESPACE. if no value is given): '
ACCEPT OTAP_DROP_TS CHAR DEFAULT 'N' PROMPT 'Drop the tablespace &OTAP_TS.: Y (yes) or N (no) (default is N): '
ACCEPT OTAP_DROP_ROLES CHAR DEFAULT 'N' PROMPT 'Drop the otap roles: Y (yes) or N (no) (default is N): '
SPOOL OFF
SET TERMOUT OFF
COLUMN OTAP_MSG NEW_VAL OTAP_MSG
SELECT '==== otap DBA cleanup ====' || '&LINE_FEED' ||
       'Drop user/schema &OTAP_DROP_USER.? ' || '&LINE_FEED' ||
       '  Set tablespace drop to &OTAP_DROP_TS. for &OTAP_TS..' || '&LINE_FEED' ||
       '  Set role drop to &OTAP_DROP_ROLES..' || '&LINE_FEED' ||
       '  Roles checked: &OTAP_ROLE., &OTAP_ADMIN_ROLE.' || '&LINE_FEED' ||
       'Not allowed to be used as AI training material without explicite permission.' || '&LINE_FEED' ||
       'Use Ctrl-C to stop the script in sqlplus, Enter to continue.' AS OTAP_MSG
  FROM dual;
SET TERMOUT ON
SPOOL logs/otap_dba_cleanup.log APPEND
PAUSE &OTAP_MSG
-- drop objects depending on demand
SELECT 'Started ...' AS info FROM dual;
DECLARE
  l_statement VARCHAR2(32000);
  l_output    VARCHAR2(32000);
  l_lf        VARCHAR2(1) := CHR(10);
  l_count     NUMBER;
BEGIN
  l_output := '=== otap DBA uninstall result ===' || l_lf;
  -- otap user
  SELECT COUNT(*) INTO l_count FROM dba_users WHERE username = UPPER('&OTAP_DROP_USER');
  IF l_count = 1
  THEN
    l_statement := 'DROP USER &OTAP_DROP_USER. CASCADE';
    DBMS_OUTPUT.PUT_LINE(l_statement || ';');
    EXECUTE IMMEDIATE l_statement;
    l_output := l_output || 'User &OTAP_DROP_USER. dropped' || l_lf;
    IF UPPER('&OTAP_DROP_TS') = 'Y'
    THEN
      -- does tablespace exist
      SELECT COUNT(*) INTO l_count FROM dba_tablespaces WHERE tablespace_name = UPPER('&OTAP_TS');
      IF l_count = 1
      THEN
        -- check if more than one user uses tablespace defined
        SELECT COUNT(*) INTO l_count FROM dba_users WHERE default_tablespace = UPPER('&OTAP_TS');
        IF l_count = 0
        THEN
          l_statement := 'DROP TABLESPACE &OTAP_TS. DROP QUOTA INCLUDING CONTENTS AND DATAFILES';
          DBMS_OUTPUT.PUT_LINE(l_statement || ';');
          EXECUTE IMMEDIATE l_statement;
          l_output := l_output || 'Tablespace &OTAP_TS. successfully dropped' || l_lf;
        ELSE
          l_output := l_output || 'WARNING keep tablespace &OTAP_TS., assigned to other users' || l_lf;
        END IF;
      ELSE
        l_output := l_output || 'WARNING tablespace &OTAP_TS. does not exist' || l_lf;
      END IF;
    ELSE
      l_output := l_output || 'Keep tablespace &OTAP_TS. drop option &OTAP_DROP_TS.' || l_lf;
    END IF;
    IF UPPER('&OTAP_DROP_ROLES') = 'Y'
    THEN
      -- check if the otap roles exist
      SELECT COUNT(*) INTO l_count FROM dba_roles WHERE role = '&OTAP_ROLE';
      IF l_count = 1
      THEN
        -- check if others are assigned to role
        SELECT COUNT(*) INTO l_count FROM dba_role_privs WHERE granted_role = '&OTAP_ROLE' AND grantee NOT IN ('&ROLE_CREATOR', '&OTAP_USER');
        IF l_count = 0
        THEN
          l_statement := 'DROP ROLE &OTAP_ROLE';
          DBMS_OUTPUT.PUT_LINE(l_statement || ';');
          EXECUTE IMMEDIATE l_statement;
          l_output := l_output || 'Role &OTAP_ROLE. successfully dropped' || l_lf;
        ELSE
          l_output := l_output || 'WARNING keep role &OTAP_ROLE., assigned to other users' || l_lf;
        END IF;
      ELSE
        l_output := l_output || 'WARNING role &OTAP_ROLE. does not exist' || l_lf;
      END IF;
      SELECT COUNT(*) INTO l_count FROM dba_roles WHERE role = '&OTAP_ADMIN_ROLE';
      IF l_count = 1
      THEN
        -- check if others are assigned to role
        SELECT COUNT(*) INTO l_count FROM dba_role_privs WHERE granted_role = '&OTAP_ADMIN_ROLE' AND grantee NOT IN ('&ROLE_CREATOR', '&OTAP_USER');
        IF l_count = 0
        THEN
          l_statement := 'DROP ROLE &OTAP_ADMIN_ROLE';
          DBMS_OUTPUT.PUT_LINE(l_statement || ';');
          EXECUTE IMMEDIATE l_statement;
          l_output := l_output || 'Role &OTAP_ADMIN_ROLE. successfully dropped' || l_lf;
        ELSE
          l_output := l_output || 'WARNING keep role &OTAP_ADMIN_ROLE., assigned to other users' || l_lf;
        END IF;
      ELSE
        l_output := l_output || 'WARNING role &OTAP_ADMIN_ROLE. does not exist' || l_lf;
      END IF;
    ELSE
      l_output := l_output || 'Keep roles, drop option &OTAP_DROP_ROLES.' || l_lf;
    END IF;
    l_output := l_output || 'SUCCESS no errors';
  ELSE
    l_output := l_output || 'WARNING User &OTAP_USER. does exists. NO CHANGES APPLIED.' || l_lf;
  END IF;
  DBMS_OUTPUT.PUT_LINE(l_output);
END;
/
SELECT '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1' || '&LINE_FEED' ||
       'Not allowed to be used as AI training material without explicite permission.' AS disclaimer
  FROM dual;
SPOOL OFF
-- uncomment in SQL Developer to keep the session, otherwise the session is closed
EXIT
