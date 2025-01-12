-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Parameter DEFAULT user name (1) and role name (2)
SET TERMOUT ON
ACCEPT OTAP_USER CHAR DEFAULT '&1' PROMPT 'DB user name of otap for update (identified &1. if no value is given): '
ACCEPT OTAP_ROLE CHAR DEFAULT '&2' PROMPT 'User role name of otap for update (identified &2. if no value is given): '
SELECT '&OTAP_USER' FROM dual;