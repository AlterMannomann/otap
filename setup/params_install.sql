-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Parameter DEFAULT user name (1) and role name (2)
SET TERMOUT ON
ACCEPT OTAP_USER CHAR DEFAULT '&1' PROMPT 'DB user name for otap (default is OTAP if no value is given): '
ACCEPT OTAP_PASS CHAR PROMPT 'Mandatory db password for &OTAP_USER.: ' HIDE
ACCEPT OTAP_TS CHAR DEFAULT 'OTAP_TABLESPACE' PROMPT 'Table space name for otap (default is OTAP_TABLESPACE if no value is given): '
ACCEPT OTAP_DBF CHAR DEFAULT 'otap.dbf' PROMPT 'Table space data file name for otap (default is otap.dbf if no value is given): '
ACCEPT OTAP_ROLE CHAR DEFAULT '&2' PROMPT 'User role name for otap (default is OTAP_USER if no value is given): '