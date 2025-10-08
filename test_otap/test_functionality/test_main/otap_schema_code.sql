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
  -- has_table
  l_return := otap_test.is_eq(otap_schema.has_table('OTAP_RESULTS', l_error_msg), otap_constants.OTAP_NUM_TEST_PASSED, 'otap_schema.has_table simple check');
  l_return := otap_test.ok((l_error_msg IS NULL), 'otap_schema.has_table error message check');
  l_return := otap_test.is_eq(otap_schema.has_table('otap_results', l_error_msg), otap_constants.OTAP_NUM_TEST_FAILED, 'otap_schema.has_table case sensitive check');
  l_return := otap_test.alike(l_error_msg, 'Table does not exist:%', otap_constants.OTAP_NUM_FALSE, 'otap_schema.has_table case sensitive error message check');
  l_return := otap_test.is_eq(otap_schema.has_table(NULL, l_error_msg), otap_constants.OTAP_NUM_TEST_UNDEFINED, 'otap_schema.has_table NULL check');
  l_return := otap_test.is_eq(l_error_msg, 'Missing: p_table_name(NULL)', 'otap_schema.has_table NULL error message check');
  l_return := otap_test.is_eq(otap_schema.has_table('otap_results', l_error_msg, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_FAILED), otap_constants.OTAP_NUM_TEST_PASSED, 'otap_schema.has_table inverse logic check');
  l_return := otap_test.is_eq(otap_schema.has_table('OTAP_IDENTIFIERS_V', l_error_msg, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), otap_constants.OTAP_NUM_TEST_FAILED), otap_constants.OTAP_NUM_TEST_PASSED, 'otap_schema.has_table ignore views check');
  -- has_column
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
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'to_delete'
                                                     , o_errors => l_error_msg
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column inverse logic check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_type => 'NUMBER'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column data type check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_length => 22
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column data length check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_scale => 0
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column data scale check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_precision => 1
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column data precision check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_nullable => 'N'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column nullable check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_default => '0'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column data default check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_type => 'NUMBER'
                                                     , p_data_length => 22
                                                     , p_data_precision => 1
                                                     , p_data_scale => 0
                                                     , p_nullable => 'N'
                                                     , p_data_default => '0'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column all parameters check'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_RESULTS'
                                                     , p_column_name => 'TO_DELETE'
                                                     , o_errors => l_error_msg
                                                     , p_data_type => 'NUMBER'
                                                     , p_data_length => 22
                                                     , p_data_precision => 2
                                                     , p_data_scale => 0
                                                     , p_nullable => 'N'
                                                     , p_data_default => '0'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column fail if a parameter is wrong'
                             )
  ;
  l_return := otap_test.is_eq( otap_schema.has_column( p_table_name => 'OTAP_IDENTIFIERS_V'
                                                     , p_column_name => 'LANGUAGE_ID'
                                                     , o_errors => l_error_msg
                                                     , p_data_type => 'VARCHAR2'
                                                     , p_data_length => 12
                                                     , p_nullable => 'Y'
                                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_PASSED
                                                     )
                             , otap_constants.OTAP_NUM_TEST_PASSED
                             , 'otap_schema.has_column verify view column'
                             )
  ;

EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_SCHEMA failed', 'otap_report.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_SCHEMA failed', SQLERRM);
END;
/