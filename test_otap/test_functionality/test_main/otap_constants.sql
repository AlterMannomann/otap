-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- read setup configuration as written by DBA setup, path relative to main test caller
@@../setup/otap_setup_def.sql

-- sets the test name and calls the tests for this test name
-- basic schema tests already done
SELECT otap_test.set_test_name('Verify otap_constants functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return VARCHAR2(4000);
BEGIN
  -- this setting has to be adjusted with every version
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_VERSION_NR, 'v1.0.0-beta.1', 'Check internal version number');
  -- stable constants
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_NAME, 'otap - Oracle Test Automation Protocol', 'Check internal name');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT1, '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt', 'Check copyright line 1');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT2, 'and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1', 'Check copyright line 2');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_COPYRIGHT3, 'Not allowed to be used as AI training material without explicite permission.', 'Check copyright line 3');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_USER_ROLE, '&OTAP_ROLE', 'Check otap role');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_SCHEMA, '&OTAP_USER', 'Check otap user');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_TABLESPACE, '&OTAP_TABLESPACE', 'Check otap tablespace');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TRUE, 1, 'Check numeric true definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_FALSE, 0, 'Check numeric false definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_PASSED, 1, 'Check test passed definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_FAILED, -1, 'Check test failed definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_TEST_UNDEFINED, 0, 'Check test undefined definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 80, 'Check minimum report fill length');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 4000, 'Check maximum report fill length');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_DELIMITER, '_', 'Check default otap delimiter');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_ERROR, 'OTAP_ERROR', 'Check default otap error identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_NA, 'N/A', 'Check default otap n/a identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_VAR, '@', 'Check otap variable identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_CONFIG_TYPE_NUMBER, 'NUMBER', 'Check otap config number type');
  l_return := otap_test.is_eq(otap_constants.OTAP_CONFIG_TYPE_CHAR, 'CHAR', 'Check otap config character type');
  l_return := otap_test.is_eq(otap_constants.OTAP_INTERNAL_LF, CHR(10), 'Check default otap LF');
  l_return := otap_test.is_eq(otap_constants.OTAP_NUM_PREFIX_MAX_SIZE, 4, 'Check maximum otap prefix length');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_RIGHT, 'R', 'Check otap layout identifier right');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_MIDDLE, 'M', 'Check otap layout identifier center');
  l_return := otap_test.is_eq(otap_constants.OTAP_LAYOUT_LEFT, 'L', 'Check otap layout identifier left');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_UPPER, 'U', 'Check otap format identifier UPPER');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_LOWER, 'L', 'Check otap format identifier lower');
  l_return := otap_test.is_eq(otap_constants.OTAP_LABEL_INIT_CAP, 'I', 'Check otap format identifier Initial Capitals');
  l_return := otap_test.is_eq(otap_constants.OTAP_TYPE_VAR, '@type@', 'Check otap type variable');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_SCRIPT, 'S', 'Check otap script identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_FUNCTION, 'F', 'Check otap function identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_GEN_TYPE_PROCEDURE, 'P', 'Check otap procedure identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_CFG_DEBUG_MODE, 'DEBUG_MODE', 'Check otap debug mode identifier');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER, 5, 'Check otap fallback border size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER_MIN, 2, 'Check otap fallback minimum border size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_BORDER_MAX, 10, 'Check otap fallback maximum border size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS, 1, 'Check otap fallback preserve days');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MIN, 1, 'Check otap fallback minimum preserve days');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MAX, 7, 'Check otap fallback maximum preserve days');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY, 10, 'Check otap fallback delete delay');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY_MIN, 1, 'Check otap fallback minimum delete delay');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_DELAY_MAX, 600, 'Check otap fallback maximum delete delay');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE, 1000, 'Check otap fallback delete batch size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN, 100, 'Check otap fallback minimum delete batch size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX, 10000, 'Check otap fallback maximum delete batch size');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_HEADER_CHAR, '=', 'Check otap fallback format header char');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_SET_CHAR, '*', 'Check otap fallback format test set char');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_GROUP_CHAR, '+', 'Check otap fallback format test group char');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, '-', 'Check otap fallback format test name char');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TRUE, 'true', 'Check otap fallback text TRUE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_FALSE, 'false', 'Check otap fallback text FALSE');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES, 'Yes', 'Check otap fallback boolean true to yes text');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO, 'No', 'Check otap fallback boolean false to no text');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_PASSED, 'Passed', 'Check otap fallback text test passed');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_FAILED, 'FAILED', 'Check otap fallback text test failed');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_TEXT_TEST_UNDEFINED, 'UNDEFINED', 'Check otap fallback text test undefined');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX, 'TEST', 'Check otap fallback test identifier prefix');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, 'OTAP test set', 'Check otap fallback test set default name');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, 'OTAP test group', 'Check otap fallback test group default name');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, 'OTAP test name', 'Check otap fallback test name default name');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_DEFAULT_LANGUAGE, 'en', 'Check otap fallback default language');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'M', 'Check otap fallback default layout definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT, 'L', 'Check otap fallback default result layout definition');
  l_return := otap_test.is_eq(otap_constants.OTAP_FALLBACK_LABEL_DEFAULT, 'L', 'Check otap fallback default label layout definition');
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
END;
/

