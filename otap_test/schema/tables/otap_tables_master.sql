-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- contains only basic tests on the test functions used for schema tests
-- to guarantee the needed functionality (as we are testing ourselves there is no good solution what first)

SELECT otap_test.set_test_group('OTAP tables') FROM dual;
@@table_otap_config.sql
@@table_otap_results.sql