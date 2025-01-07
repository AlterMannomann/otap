-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test set name and calls the test group scripts

SELECT otap_test.set_test_set('OTAP functionality') FROM dual;
@@functionality/test_functions/otap_test_function_master.sql