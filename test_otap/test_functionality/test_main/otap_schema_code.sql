-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- independent code block, able to deal with different setup settings

-- non intrusive tests on otap_schema
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return      VARCHAR2(4000 CHAR);
  l_stamp       TIMESTAMP;
  l_finish      TIMESTAMP;
  l_want        VARCHAR2(4000 CHAR);
  l_have        VARCHAR2(4000 CHAR);
  l_error_msg   VARCHAR2(32767 CHAR);
BEGIN
  l_return := otap_test.is_eq(otap_schema.has_table('OTAP_RESULTS', l_error_msg), otap_constants.OTAP_NUM_TEST_PASSED, 'otap_schema.has_table simple check');
  l_return := otap_test.ok((l_error_msg IS NULL), 'otap_schema.has_table error message check');
  l_return := otap_test.is_eq(otap_schema.has_table('otap_results', l_error_msg), otap_constants.OTAP_NUM_TEST_FAILED, 'otap_schema.has_table case sensitive check');
  l_return := otap_test.alike(l_error_msg, 'Table does not exist:%', otap_constants.OTAP_NUM_FALSE, 'otap_schema.has_table case sensitive error message check');
  l_return := otap_test.is_eq(otap_schema.has_table(NULL, l_error_msg), otap_constants.OTAP_NUM_TEST_UNDEFINED, 'otap_schema.has_table NULL check');
  l_return := otap_test.is_eq(l_error_msg, 'Missing: p_table_name(NULL)', 'otap_schema.has_table NULL error message check');
  l_return := otap_test.is_eq(otap_schema.has_column('OTAP_RESULTS', 'TO_DELETE', l_error_msg), otap_constants.OTAP_NUM_TEST_PASSED, 'otap_schema.has_column simple check');
  l_return := otap_test.ok((l_error_msg IS NULL), 'otap_schema.has_column error message check');
  l_return := otap_test.is_eq(otap_schema.has_column('OTAP_RESULTS', 'to_delete', l_error_msg), otap_constants.OTAP_NUM_TEST_FAILED, 'otap_schema.has_column case sensitive check');
  l_return := otap_test.alike(l_error_msg, 'Column does not exist:%', otap_constants.OTAP_NUM_FALSE, 'otap_schema.has_column case sensitive error message check');
  l_return := otap_test.is_eq(otap_schema.has_column('OTAP_RESULTS', NULL, l_error_msg), otap_constants.OTAP_NUM_TEST_UNDEFINED, 'otap_schema.has_column column NULL check');
  l_return := otap_test.is_eq(l_error_msg, 'Missing: p_column_name(NULL)', 'otap_schema.has_column NULL column error message check');
  l_return := otap_test.is_eq(otap_schema.has_column(NULL, 'TO_DELETE', l_error_msg), otap_constants.OTAP_NUM_TEST_UNDEFINED, 'otap_schema.has_column table NULL check');
  l_return := otap_test.is_eq(l_error_msg, 'Missing: p_table_name(NULL)', 'otap_schema.has_column NULL table name error message check');
  l_return := otap_test.is_eq(otap_schema.has_column(NULL, NULL, l_error_msg), otap_constants.OTAP_NUM_TEST_UNDEFINED, 'otap_schema.has_column full NULL check');
  l_return := otap_test.is_eq(l_error_msg, 'Missing: p_table_name(NULL) p_column_name(NULL)', 'otap_schema.has_column full NULL error message check');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_SCHEMA failed', 'otap_report.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_SCHEMA failed', SQLERRM);
END;
/