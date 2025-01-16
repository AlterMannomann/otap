-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- create package constants from otap_config

@@../../setup/util/log_silent.sql
SPOOL tmp_generated.sql
  WITH len AS
       (SELECT MAX(LENGTH(config_name)) AS maxlen FROM otap_config)
     , res AS 
       (SELECT RPAD(('  CFG_' || config_name), len.maxlen + 14, ' ') ||
               RPAD('CONSTANT CHAR(' || TRIM(TO_CHAR(LENGTH(config_name))) || ')', 20) ||
               ':= ''' || TRIM(config_name) || ''';' AS list_cfg_constants
          FROM otap_config
         CROSS JOIN len
        WHERE config_name != 'DEBUG_MODE' -- belongs to OTAP_CONSTANTS
       )
SELECT list_cfg_constants 
  FROM res 
 ORDER BY list_cfg_constants 
;
SPOOL OFF
EXIT
