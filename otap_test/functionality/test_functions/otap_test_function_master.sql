-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets group name and calls the scripts that set the test name and execute the tests for this name

SELECT otap_test.set_test_group('OTAP test functions') FROM dual;
@@otap_has_table.sql
@@otap_has_column.sql
@@otap_has_package.sql
@@otap_has_procedure.sql
@@otap_has_trigger.sql
