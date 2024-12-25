-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Creates a test function, identified by defaults, that checks the otap schema using otap functionality.
CREATE OR REPLACE PROCEDURE test_otap_schema_otap_config
IS
  l_debug     VARCHAR2(15)     := 'OTAP_TEST_DEBUG';
  l_test_proc VARCHAR2(28)     := 'test_otap_schema_otap_config';
  l_result    VARCHAR2(32767);
  l_object    VARCHAR2(128);
BEGIN
  -- We simulate to be limited to otap_test package, as tester this is your only interface,
  -- but we use our own logging functionality, in testers case, you need your own logging functions
  -- if needed.

  -- We have a full qualified name, no need to call test_init, we can rely on otap to solve this
  -- other defaults are fine for us now. Currently we do not set test count.
  -- prefix: TEST
  -- test set: OTAP
  -- test group: SCHEMA
  -- test name: OTAP_CONFIG
  -- example call for the same result
  l_object := 'OTAP_CONFIG';
  -- replace this with your logging if needed or uncomment it, will only log in debug mode
  otap_util.log('Start has_table test with table ' || l_object, 'test_otap_schema_otap_config', 'debug before start', l_debug);
  l_result := otap_test.init_test( p_test_count => 0
                                 , p_test_set => 'OTAP'
                                 , p_test_group => 'SCHEMA'
                                 , p_prefix => 'TEST'
                                 , p_name_precedence => otap_constants.OTAP_NUM_TRUE
                                 , p_include_pkg => otap_constants.OTAP_NUM_FALSE
                                 , p_persist => otap_constants.OTAP_NUM_FALSE
                                 )
  ;
  otap_util.log('Init: ' || l_result, 'test_otap_schema_otap_config', 'debug before start', l_debug);
  l_result := otap_test.set_test_name('OTAP_CONFIG');
  otap_util.log('Test name: ' || l_result, 'test_otap_schema_otap_config', 'debug before start', l_debug);
  -- only pass the table name, expect default description and current schema set in session_record
  l_result := otap_test.has_table(l_object);
  otap_util.log('Result has_table test with table ' || l_object || ': ' || l_result, 'test_otap_schema_otap_config', 'debug after run', l_debug);
END;
/
