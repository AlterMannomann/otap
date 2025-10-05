-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name
SELECT otap_test.set_test_name('Verify otap_schema functionality') FROM dual;
-- call the independend code block without changing the current setup
@@otap_schema_code.sql
