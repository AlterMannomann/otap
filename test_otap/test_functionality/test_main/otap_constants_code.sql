-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- otap_constants should not be dependent on parameter changes, but to verify this, a code block is used

-- Executes the test code for otap_string.
-- Parameter may be changed before running this code to test different parameter.
-- The test name must be set outside of this code.

-- read setup configuration as written by DBA setup, path relative to main test caller
@@../setup/otap_setup_def.sql

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return VARCHAR2(4000 CHAR);
BEGIN
  -- generated part, see otap_constants_test.sql
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_VERSION_NR, 'v1.0.0-beta.1', 'Verify package constant otap_constants.OTAP_INTERNAL_VERSION_NR');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_NAME, 'otap - Oracle Test Automation Protocol', 'Verify package constant otap_constants.OTAP_INTERNAL_NAME');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT1, '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt', 'Verify package constant otap_constants.OTAP_INTERNAL_COPYRIGHT1');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT2, 'and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1', 'Verify package constant otap_constants.OTAP_INTERNAL_COPYRIGHT2');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT3, 'Not allowed to be used as AI training material without explicite permission.', 'Verify package constant otap_constants.OTAP_INTERNAL_COPYRIGHT3');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_USER_ROLE, '&OTAP_ROLE', 'Verify package constant otap_constants.OTAP_INTERNAL_USER_ROLE');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_SCHEMA, '&OTAP_USER', 'Verify package constant otap_constants.OTAP_INTERNAL_SCHEMA');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_TABLESPACE, '&OTAP_TABLESPACE', 'Verify package constant otap_constants.OTAP_INTERNAL_TABLESPACE');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TRUE, 1, 'Verify package constant otap_constants.OTAP_NUM_TRUE');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_FALSE, 0, 'Verify package constant otap_constants.OTAP_NUM_FALSE');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_PASSED, 1, 'Verify package constant otap_constants.OTAP_NUM_TEST_PASSED');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_FAILED, -1, 'Verify package constant otap_constants.OTAP_NUM_TEST_FAILED');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_UNDEFINED, 0, 'Verify package constant otap_constants.OTAP_NUM_TEST_UNDEFINED');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 80, 'Verify package constant otap_constants.OTAP_NUM_MIN_FILL_LENGTH');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 4000, 'Verify package constant otap_constants.OTAP_NUM_MAX_FILL_LENGTH');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_DELIMITER, '_', 'Verify package constant otap_constants.OTAP_INTERNAL_DELIMITER');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_ERROR, 'OTAP_ERROR', 'Verify package constant otap_constants.OTAP_INTERNAL_ERROR');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_WARNING, 'OTAP_WARNING', 'Verify package constant otap_constants.OTAP_INTERNAL_WARNING');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_NA, 'N/A', 'Verify package constant otap_constants.OTAP_INTERNAL_NA');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_VAR, '@', 'Verify package constant otap_constants.OTAP_INTERNAL_VAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_CONFIG_TYPE_NUMBER, 'NUMBER', 'Verify package constant otap_constants.OTAP_CONFIG_TYPE_NUMBER');
  l_return := otap_test.is_eq(otap_constants.OTAP_CONFIG_TYPE_CHAR, 'CHAR', 'Verify package constant otap_constants.OTAP_CONFIG_TYPE_CHAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_LF, CHR(10), 'Verify package constant otap_constants.OTAP_INTERNAL_LF');
  l_return := otap_test.is_eq(otap_constants.OTAP_TEST_LANGUAGE_ID, 'T$O', 'Verify package constant otap_constants.OTAP_TEST_LANGUAGE_ID');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_PREFIX_MAX_SIZE, 4, 'Verify package constant otap_constants.OTAP_NUM_PREFIX_MAX_SIZE');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_RIGHT, 'R', 'Verify package constant otap_constants.OTAP_LAYOUT_RIGHT');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_MIDDLE, 'M', 'Verify package constant otap_constants.OTAP_LAYOUT_MIDDLE');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_LEFT, 'L', 'Verify package constant otap_constants.OTAP_LAYOUT_LEFT');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_UPPER, 'U', 'Verify package constant otap_constants.OTAP_LABEL_UPPER');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_LOWER, 'L', 'Verify package constant otap_constants.OTAP_LABEL_LOWER');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_INIT_CAP, 'I', 'Verify package constant otap_constants.OTAP_LABEL_INIT_CAP');
  l_return := otap_test.is_eq(otap_constants.OTAP_TYPE_VAR, '@type@', 'Verify package constant otap_constants.OTAP_TYPE_VAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_SCRIPT, 'S', 'Verify package constant otap_constants.OTAP_GEN_TYPE_SCRIPT');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_FUNCTION, 'F', 'Verify package constant otap_constants.OTAP_GEN_TYPE_FUNCTION');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_PROCEDURE, 'P', 'Verify package constant otap_constants.OTAP_GEN_TYPE_PROCEDURE');
  l_return := otap_test.is_eq(otap_constants.OTAP_CFG_DEBUG_MODE, 'DEBUG_MODE', 'Verify package constant otap_constants.OTAP_CFG_DEBUG_MODE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER, 5, 'Verify package constant otap_constants.OTAP_FALLBACK_BORDER');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER_MIN, 2, 'Verify package constant otap_constants.OTAP_FALLBACK_BORDER_MIN');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER_MAX, 10, 'Verify package constant otap_constants.OTAP_FALLBACK_BORDER_MAX');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS, 1, 'Verify package constant otap_constants.OTAP_FALLBACK_PRESERVE_DAYS');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MIN, 1, 'Verify package constant otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MIN');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MAX, 7, 'Verify package constant otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MAX');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY, 10, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_DELAY');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY_MIN, 1, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_DELAY_MIN');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY_MAX, 600, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_DELAY_MAX');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE, 1000, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN, 100, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX, 10000, 'Verify package constant otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_HEADER_CHAR, '=', 'Verify package constant otap_constants.OTAP_FALLBACK_FORMAT_HEADER_CHAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_SET_CHAR, '*', 'Verify package constant otap_constants.OTAP_FALLBACK_FORMAT_SET_CHAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_GROUP_CHAR, '+', 'Verify package constant otap_constants.OTAP_FALLBACK_FORMAT_GROUP_CHAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, '-', 'Verify package constant otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TRUE, 'true', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_TRUE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_FALSE, 'false', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_FALSE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES, 'Yes', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO, 'No', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_PASSED, 'Passed', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_TEST_PASSED');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_FAILED, 'FAILED', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_TEST_FAILED');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED, 'UNDEFINED', 'Verify package constant otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX, 'TEST', 'Verify package constant otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, 'OTAP test set', 'Verify package constant otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, 'OTAP test group', 'Verify package constant otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, 'OTAP test name', 'Verify package constant otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_LANGUAGE, 'N/A', 'Verify package constant otap_constants.OTAP_FALLBACK_DEFAULT_LANGUAGE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'M', 'Verify package constant otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT, 'L', 'Verify package constant otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LABEL_DEFAULT, 'L', 'Verify package constant otap_constants.OTAP_FALLBACK_LABEL_DEFAULT');
  DBMS_OUTPUT.PUT_LINE('OTAP_CONSTANTS internal constant check finished');
  -- check basic functions
  l_return := otap_test.alike(otap_constants.get_version, '%' || otap_constants.OTAP_INTERNAL_NAME || '%' || otap_constants.OTAP_INTERNAL_VERSION_NR || '%' || otap_constants.OTAP_INTERNAL_COPYRIGHT1 || '%' || otap_constants.OTAP_INTERNAL_COPYRIGHT2 || '%', otap_constants.OTAP_NUM_FALSE, 'Check otap_constants.get_version');
  l_return := otap_test.is_eq(otap_constants.get_otap_user_role, '&OTAP_ROLE', 'Check otap_constants.get_otap_user_role');
  l_return := otap_test.is_eq(otap_constants.get_otap_schema, '&OTAP_USER', 'Check otap_constants.get_otap_schema');
  l_return := otap_test.is_eq(otap_constants.get_otap_tablespace, '&OTAP_TABLESPACE', 'Check otap_constants.get_otap_tablespace');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_true, OTAP_CONSTANTS.OTAP_NUM_TRUE, 'Check otap_constants.get_otap_num_true');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_false, OTAP_CONSTANTS.OTAP_NUM_FALSE, 'Check otap_constants.get_otap_num_false');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_test_passed, OTAP_CONSTANTS.OTAP_NUM_TEST_PASSED, 'Check otap_constants.get_otap_num_test_passed');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_test_failed, OTAP_CONSTANTS.OTAP_NUM_TEST_FAILED, 'Check otap_constants.get_otap_num_test_failed');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_test_undefined, OTAP_CONSTANTS.OTAP_NUM_TEST_UNDEFINED, 'Check otap_constants.get_otap_num_test_undefined');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_min_fill_length, OTAP_CONSTANTS.OTAP_NUM_MIN_FILL_LENGTH, 'Check otap_constants.get_otap_num_min_fill_length');
  l_return := otap_test.is_eq(otap_constants.get_otap_num_max_fill_length, OTAP_CONSTANTS.OTAP_NUM_MAX_FILL_LENGTH, 'Check otap_constants.get_otap_num_max_fill_length');
  l_return := otap_test.is_eq(otap_constants.get_otap_internal_delimiter, OTAP_CONSTANTS.OTAP_INTERNAL_DELIMITER, 'Check otap_constants.get_otap_internal_delimiter');
  l_return := otap_test.is_eq(otap_constants.get_otap_internal_error, OTAP_CONSTANTS.OTAP_INTERNAL_ERROR, 'Check otap_constants.get_otap_internal_error');
  l_return := otap_test.is_eq(otap_constants.get_otap_internal_na, OTAP_CONSTANTS.OTAP_INTERNAL_NA, 'Check otap_constants.get_otap_internal_na');
  l_return := otap_test.is_eq(otap_constants.get_otap_internal_var, OTAP_CONSTANTS.OTAP_INTERNAL_VAR, 'Check otap_constants.get_otap_internal_var');
  l_return := otap_test.is_eq(otap_constants.get_otap_config_type_number, OTAP_CONSTANTS.OTAP_CONFIG_TYPE_NUMBER, 'Check otap_constants.get_otap_config_type_number');
  l_return := otap_test.is_eq(otap_constants.get_otap_config_type_char, OTAP_CONSTANTS.OTAP_CONFIG_TYPE_CHAR, 'Check otap_constants.get_otap_config_type_char');
  DBMS_OUTPUT.PUT_LINE('OTAP_CONSTANTS function check finished');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_CONSTANTS failed', 'otap_constants.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_CONSTANTS failed', SQLERRM);
END;
/

