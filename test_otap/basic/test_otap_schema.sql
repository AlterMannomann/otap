-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Creates a test function, identified by defaults, that checks the otap schema using otap functionality.
CREATE OR REPLACE PROCEDURE test_otap_schema
IS
  l_debug     VARCHAR2(15 CHAR)     := 'OTAP_TEST_DEBUG';
  l_test_proc VARCHAR2(28 CHAR)     := 'test_otap_schema';
  l_result    VARCHAR2(32767 CHAR);
  l_object    VARCHAR2(128 CHAR);
BEGIN
  -- We simulate to be limited to otap_test package, as tester this is your only interface.
  -- For logging implement your own logging.

  -- We have a full qualified name, no need to call test_init, we can rely on otap to solve this
  -- other defaults are fine for us now. Currently we do not set test count.
  -- prefix: TEST
  -- test set: OTAP
  -- test group: SCHEMA
  -- example call for the same result not relying on name of called procedure.
  -- l_result := otap_test.init_test( p_test_count => 0
  --                                , p_test_set => 'OTAP'
  --                                , p_test_group => 'SCHEMA'
  --                                , p_prefix => 'TEST'
  --                                , p_name_precedence => otap_constants.OTAP_NUM_TRUE
  --                                , p_include_pkg => otap_constants.OTAP_NUM_FALSE
  --                                , p_persist => otap_constants.OTAP_NUM_FALSE
  --                                )
  -- ;
  -- set test name: OTAP_CONFIG
  l_object := 'OTAP_CONFIG';
  l_result := otap_test.set_test_name(l_object);
  -- only pass the table name, expect default description and current schema set in session_record
  l_result := otap_test.has_table(l_object);
END;
/
