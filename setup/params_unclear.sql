-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Parameter DEFAULT user name (1) and role name (2)
SET TERMOUT ON
ACCEPT OTAP_USER CHAR PROMPT 'Specify DB user name of otap for update (no default): '
ACCEPT OTAP_ROLE CHAR PROMPT 'Specify user role name of otap for update (no default): '