-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- read setup configuration as written by DBA setup, path relative to setup caller
@@../setup/otap_setup_def.sql
REVOKE SELECT ON otap_latest_test_results_v FROM &OTAP_ROLE;
DROP VIEW otap_latest_test_results_v;
