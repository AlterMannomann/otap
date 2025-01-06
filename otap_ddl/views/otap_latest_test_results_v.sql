-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Default view for test results.
-- Gets the latest finished test session or the current session if no test session finished.

-- read setup configuration as written by DBA setup, path relative to setup caller
@@../setup/otap_setup_def.sql

CREATE OR REPLACE VIEW otap_latest_test_results_v
AS
  SELECT result_text
    FROM TABLE(otap_test.result_view(otap_test.get_report_id))
;

GRANT SELECT ON otap_latest_test_results_v TO &OTAP_ROLE;