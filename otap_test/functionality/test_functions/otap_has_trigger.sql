-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- sets the test name and calls the tests for this test name

SELECT otap_test.set_test_name('Verify otap_test.has_trigger') FROM dual;
-- no default trigger available, use one from otap
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_CONFIG_INS_TRG'
                            , p_description => 'Trigger exists minimal test'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'OTAP_CONFIG_INS_TRG'
                            , p_description => 'Trigger exists full test'
                            , p_trigger_type => 'BEFORE EACH ROW'
                            , p_trigger_event => 'INSERT'
                            , p_table_owner => otap_constants.get_otap_schema
                            , p_table_name => 'OTAP_CONFIG'
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => NULL
                            , p_description => 'NULL trigger test'
                            , p_expected_result => otap_constants.get_otap_num_test_undefined
                            ) FROM dual;
SELECT otap_test.has_trigger( p_trigger_name => 'NO VALID NAME'
                            , p_description => 'Invalid trigger name'
                            , p_expected_result => otap_constants.get_otap_num_test_failed
                            ) FROM dual;
-- test default description
SELECT otap_test.has_trigger('OTAP_CONFIG_INS_TRG') FROM dual;