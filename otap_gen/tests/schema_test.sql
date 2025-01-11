-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- create a trigger exclude list for otap_config

@@../../setup/util/log_silent.sql
-- disable header as script is called from other scripts
SPOOL ../../otap_test/schema/generated_otap_schema_tests.sql
SELECT result_text FROM TABLE(otap_generate.schema_tests(p_show_header => 0));
SPOOL OFF
EXIT
