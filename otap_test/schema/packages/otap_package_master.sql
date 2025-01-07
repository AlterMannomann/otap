-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- contains only basic tests on the test functions used for schema tests
-- to guarantee the needed functionality (as we are testing ourselves there is no good solution what first)

SELECT otap_test.set_test_group('OTAP packages') FROM dual;
@@pkg_otap_constants.sql
@@pkg_otap_log.sql
@@pkg_otap_string.sql
@@pkg_otap_config_util.sql
@@pkg_otap_results_util.sql
@@pkg_otap_report.sql
@@pkg_otap_objects.sql
@@pkg_otap_plan.sql
@@pkg_otap_schema.sql
@@pkg_otap_api.sql
@@pkg_otap_test.sql

