-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
@@../setup/otap_setup_def.sql
REVOKE EXECUTE ON otap_generate FROM &OTAP_ROLE;
DROP PACKAGE otap_generate;
