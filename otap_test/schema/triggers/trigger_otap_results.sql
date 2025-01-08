-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Trigger OTAP_RESULTS') FROM dual;

SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_INS_TRG'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'INSERT'
                            , p_table_owner => otap_constants.get_otap_schema
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_UPD_TRG'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'UPDATE'
                            , p_table_owner => otap_constants.get_otap_schema
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_RESULTS_DEL_TRG'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'DELETE'
                            , p_table_owner => otap_constants.get_otap_schema
                            , p_table_name => 'OTAP_RESULTS'
                            ) FROM dual;