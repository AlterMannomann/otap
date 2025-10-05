-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- first non intrusive
@@test_main_non_intrusive.sql
-- intrusive tests changing data
SELECT otap_test.set_test_group('OTAP data change functionality') FROM dual;
@@otap_intrusive.sql