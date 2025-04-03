-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Contains all tests that temporarily change data for testing. Do not use while other users run tests.

-- first make a backup
@@otap_config_backup.sql

-- otap_log intrusive
-- collect information
COLUMN OLD_DEBUG_MODE NEW_VAL OLD_DEBUG_MODE
COLUMN NEW_DEBUG_MODE NEW_VAL NEW_DEBUG_MODE
COLUMN TEXT_DEBUG NEW_VAL TEXT_DEBUG
SELECT config_value                                           AS OLD_DEBUG_MODE
     , CASE WHEN config_value = '0' THEN '1' ELSE '0' END     AS NEW_DEBUG_MODE
     , CASE WHEN config_value = '0' THEN 'ON' ELSE 'OFF' END  AS TEXT_DEBUG
  FROM otap_config
 WHERE config_name = 'DEBUG_MODE'
;
SELECT otap_test.set_test_name('Verify otap_log functionality intrusive switch debug mode &TEXT_DEBUG') FROM dual;
-- use update as long as otap_util is not fully tested
UPDATE otap_config
   SET config_value = '&NEW_DEBUG_MODE'
 WHERE config_name = 'DEBUG_MODE'
;
COMMIT;
-- now call code
@@otap_log_code.sql
-- ensure debug off for the following tests
UPDATE otap_config
   SET config_value = '0'
 WHERE config_name = 'DEBUG_MODE'
;
COMMIT;
-- otap_util
@@otap_util_intrusive.sql
-- otap_report
@@otap_report_intrusive.sql

-- restore from backup
@@otap_config_restore.sql
