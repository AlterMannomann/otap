-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- create a trigger exclude list for otap_config

@@../../setup/util/log_silent.sql
SPOOL tmp_generated.sql
SELECT ', ''' || config_name || '''' AS list_items
  FROM otap_config
;
SPOOL OFF
EXIT
