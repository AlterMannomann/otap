-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- set only test set
SELECT otap_test.set_test_set('OTAP main functionality') FROM dual;
-- call script sections
-- basic packages
SELECT otap_test.set_test_group('OTAP basic package functionality') FROM dual;
@@otap_constants.sql
-- @@otap_log.sql
-- @@otap_util.sql
-- table triggers
-- table contents
-- packages
