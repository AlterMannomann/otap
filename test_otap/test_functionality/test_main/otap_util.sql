-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name

-- basic schema and otap_constants tests already done, test log entries will remain, logging is always committed on success
SELECT otap_test.set_test_name('Verify otap_util functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return  VARCHAR2(4000);
  l_decimal CHAR(1);
BEGIN
  -- check util config constants
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_BORDER, 'DEFAULT_BORDER', 'Check config name default border');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LABEL_COLUMN, 'DEFAULT_LABEL_COLUMN', 'Check config name default label column');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LAYOUT, 'DEFAULT_LAYOUT', 'Check config name default layout');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_PREFIX, 'DEFAULT_PREFIX', 'Check config name default prefix');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_RESULT_LAYOUT, 'DEFAULT_RESULT_LAYOUT', 'Check config name default result layout');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_GROUP, 'DEFAULT_TEST_GROUP', 'Check config name default test group');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_NAME, 'DEFAULT_TEST_NAME', 'Check config name default test name');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_SET, 'DEFAULT_TEST_SET', 'Check config name default test set');
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_BATCH_SIZE, 'DELETE_BATCH_SIZE', 'Check config name delete batch size');
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_DELAY, 'DELETE_DELAY', 'Check config name delete delay');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_GROUP_CHAR, 'FORMAT_GROUP_CHAR', 'Check config name formatting test group char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_HEADER_CHAR, 'FORMAT_HEADER_CHAR', 'Check config name formatting header char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_NAME_CHAR, 'FORMAT_NAME_CHAR', 'Check config name formatting test name char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_SET_CHAR, 'FORMAT_SET_CHAR', 'Check config name formatting test set char');
  l_return := otap_test.is_eq(otap_util.CFG_PRESERVE_DAYS, 'PRESERVE_DAYS', 'Check config name delete preserve days');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_COUNT_DESC, 'TEMPLATE_COUNT_DESC', 'Check config name template count description');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERRORS, 'TEMPLATE_ERRORS', 'Check config name template errors');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERROR_DETAILS, 'TEMPLATE_ERROR_DETAILS', 'Check config name template error details');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS, 'TEMPLATE_EXISTS', 'Check config name template object exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTSX, 'TEMPLATE_EXISTSX', 'Check config name template object exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_C, 'TEMPLATE_EXISTS_C', 'Check config name template constraint exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_CX, 'TEMPLATE_EXISTS_CX', 'Check config name template constraints exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_F, 'TEMPLATE_EXISTS_F', 'Check config name template function/procedure exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_FX, 'TEMPLATE_EXISTS_FX', 'Check config name template function/procedure exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_GROUP, 'TEMPLATE_GROUP', 'Check config name template test group');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_MATCH, 'TEMPLATE_MATCH', 'Check config name template match expression/value');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_NO_DATA, 'TEMPLATE_NO_DATA', 'Check config name template no data');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_REPORT_TOTAL, 'TEMPLATE_REPORT_TOTAL', 'Check config name template report totals');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_RESULT_LINE, 'TEMPLATE_RESULT_LINE', 'Check config name template result line');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SESSION_ID, 'TEMPLATE_SESSION_ID', 'Check config name template session id');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SET, 'TEMPLATE_SET', 'Check config name template test set');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SUMMARY, 'TEMPLATE_SUMMARY', 'Check config name template summary');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_TEST_NAME, 'TEMPLATE_TEST_NAME', 'Check config name template test name');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE, 'TEXT_FALSE', 'Check config name text FALSE');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE_NO, 'TEXT_FALSE_NO', 'Check config name text NO');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_END, 'TEXT_REPORT_END', 'Check config name text report end');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_START, 'TEXT_REPORT_START', 'Check config name text report start');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_TOTAL, 'TEXT_REPORT_TOTAL', 'Check config name text report totals');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_HEADER, 'TEXT_RESULT_HEADER', 'Check config name text result header');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_LINE, 'TEXT_RESULT_LINE', 'Check config name text result line');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_SUMMARY_ERROR, 'TEXT_SUMMARY_ERROR', 'Check config name text summary error');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_SUMMARY_SUCCESS, 'TEXT_SUMMARY_SUCCESS', 'Check config name text summary success');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_COUNT_HEADER, 'TEXT_TEST_COUNT_HEADER', 'Check config name text test count header');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_COUNT_NAME, 'TEXT_TEST_COUNT_NAME', 'Check config name text test count name');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_FAILED, 'TEXT_TEST_FAILED', 'Check config name text test failed');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_PASSED, 'TEXT_TEST_PASSED', 'Check config name text test passed');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_UNDEFINED, 'TEXT_TEST_UNDEFINED', 'Check config name text test undefined');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE, 'TEXT_TRUE', 'Check config name text TRUE');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE_YES, 'TEXT_TRUE_YES', 'Check config name text YES');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_BOOLEAN, 'LABEL_BOOLEAN', 'Check config label boolean');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CHECK, 'LABEL_CHECK', 'Check config label check');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CLUSTER, 'LABEL_CLUSTER', 'Check config label cluster');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_COLUMN, 'LABEL_COLUMN', 'Check config label column');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSTRAINT, 'LABEL_CONSTRAINT', 'Check config label constraint');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSUMER_GROUP, 'LABEL_CONSUMER_GROUP', 'Check config label consumer group');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONTEXT, 'LABEL_CONTEXT', 'Check config label context');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CREDENTIAL, 'LABEL_CREDENTIAL', 'Check config label credential');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATABASE, 'LABEL_DATABASE', 'Check config label database');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATE, 'LABEL_DATE', 'Check config label date');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DESTINATION, 'LABEL_DESTINATION', 'Check config label destination');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIMENSION, 'LABEL_DIMENSION', 'Check config label dimension');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIRECTORY, 'LABEL_DIRECTORY', 'Check config label directory');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DOMAIN, 'LABEL_DOMAIN', 'Check config label domain');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EDITION, 'LABEL_EDITION', 'Check config label edition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EVALUATION_CONTEXT, 'LABEL_EVALUATION_CONTEXT', 'Check config evaluation context');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EXCEPTION, 'LABEL_EXCEPTION', 'Check config label exception');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FOREIGN_KEY, 'LABEL_FOREIGN_KEY', 'Check config label foreign key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FUNCTION, 'LABEL_FUNCTION', 'Check config label function');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_HASH, 'LABEL_HASH', 'Check config label hash');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX, 'LABEL_INDEX', 'Check config label index');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEXTYPE, 'LABEL_INDEXTYPE', 'Check config label index type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_PARTITION, 'LABEL_INDEX_PARTITION', 'Check config label index partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_SUBPARTITION, 'LABEL_INDEX_SUBPARTITION', 'Check config label index subpartition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE, 'LABEL_INVALID_CONSTRAINT_TYPE', 'Check config label invalid constraint type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_CLASS, 'LABEL_JAVA_CLASS', 'Check config label java class');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_DATA, 'LABEL_JAVA_DATA', 'Check config label java data');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_RESOURCE, 'LABEL_JAVA_RESOURCE', 'Check config label java resource');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_SOURCE, 'LABEL_JAVA_SOURCE', 'Check config label java source');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB, 'LABEL_JOB', 'Check config label job');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB_CLASS, 'LABEL_JOB_CLASS', 'Check config label job class');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LIBRARY, 'LABEL_LIBRARY', 'Check config label library');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB, 'LABEL_LOB', 'Check config label LOB');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB_PARTITION, 'LABEL_LOB_PARTITION', 'Check config label LOB partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MATERIALIZED_VIEW, 'LABEL_MATERIALIZED_VIEW', 'Check config label materialized view');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MLE_LANGUAGE, 'LABEL_MLE_LANGUAGE', 'Check config label mle language');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NOT_NULL, 'LABEL_NOT_NULL', 'Check config label not null');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NULL, 'LABEL_NULL', 'Check config label null');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NUMBER, 'LABEL_NUMBER', 'Check config label number');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_OPERATOR, 'LABEL_OPERATOR', 'Check config label operator');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE, 'LABEL_PACKAGE', 'Check config label package');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE_BODY, 'LABEL_PACKAGE_BODY', 'Check config label package body');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PRIMARY_KEY, 'LABEL_PRIMARY_KEY', 'Check config label primary key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROCEDURE, 'LABEL_PROCEDURE', 'Check config label procedure');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROGRAM, 'LABEL_PROGRAM', 'Check config label program');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_QUEUE, 'LABEL_QUEUE', 'Check config label queue');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_REF_COLUMN, 'LABEL_REF_COLUMN', 'Check config label reference column');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RESOURCE_PLAN, 'LABEL_RESOURCE_PLAN', 'Check config label resource plan');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_ROLE, 'LABEL_ROLE', 'Check config label role');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE, 'LABEL_RULE', 'Check config label rule');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE_SET, 'LABEL_RULE_SET', 'Check config label rule set');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULE, 'LABEL_SCHEDULE', 'Check config label schedule');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_GROUP, 'LABEL_SCHEDULER_GROUP', 'Check config label scheduler group');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_JOB, 'LABEL_SCHEDULER_JOB', 'Check config label scheduler job');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SEQUENCE, 'LABEL_SEQUENCE', 'Check config label sequence');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING, 'LABEL_SUPPLEMENTAL_LOGGGING', 'Check config label supplemental logging');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SYNONYM, 'LABEL_SYNONYM', 'Check config label synonym');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE, 'LABEL_TABLE', 'Check config label table');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_PARTITION, 'LABEL_TABLE_PARTITION', 'Check config label table partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_SUBPARTITION, 'LABEL_TABLE_SUBPARTITION', 'Check config label table subpartition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TRIGGER, 'LABEL_TRIGGER', 'Check config label trigger');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE, 'LABEL_TYPE', 'Check config label type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE_BODY, 'LABEL_TYPE_BODY', 'Check config label type body');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNDEFINED, 'LABEL_UNDEFINED', 'Check config label undefined');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIFIED_AUDIT_POLICY, 'LABEL_UNIFIED_AUDIT_POLICY', 'Check config label unified audit policy');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIQUE_KEY, 'LABEL_UNIQUE_KEY', 'Check config label unique key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_USER, 'LABEL_USER', 'Check config label user');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VARCHAR2, 'LABEL_VARCHAR2', 'Check config label VARCHAR2');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW, 'LABEL_VIEW', 'Check config label view');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_CHECK, 'LABEL_VIEW_CHECK', 'Check config label view check');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_READONLY, 'LABEL_VIEW_READONLY', 'Check config label view readonly');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_WINDOW, 'LABEL_WINDOW', 'Check config label window');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_XML_SCHEMA, 'LABEL_XML_SCHEMA', 'Check config label XML schema');
  -- check functionality is_number
  l_return := otap_test.ok(otap_util.is_number('1'), 'Check otap_util.is_number with simple number');
  l_return := otap_test.ok((NOT otap_util.is_number('A')), 'Check otap_util.is_number with simple char fails');
  l_return := otap_test.ok(p_boolean => otap_util.is_number('A'), p_description => 'Check otap_util.is_number with simple char and expected result failed', p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.ok((NOT otap_util.is_number('-1-')), 'Check otap_util.is_number with strange number -1- fails');
  l_return := otap_test.ok((NOT otap_util.is_number('-1*2+')), 'Check otap_util.is_number with strange number -1*2+ fails');
  l_return := otap_test.ok((NOT otap_util.is_number('99999999999999999999999999999999999999999999999999')), 'Check otap_util.is_number with too big number 99999999999999999999999999999999999999999999999999 fails');
  -- get correct current decimal points, thousands divider does not work with TO_NUMBER, without given format
  SELECT SUBSTR(value, 1, 1)
    INTO l_decimal
    FROM nls_session_parameters
   WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
  ;
  l_return := otap_test.ok(otap_util.is_number('1' || l_decimal || '234'), 'Check otap_util.is_number with number using current decimal point defined, e.g. 1.234');
  l_return := otap_test.ok(otap_util.is_number(l_decimal || '234'), 'Check otap_util.is_number with number using leading current decimal point defined, e.g. .234');
  -- this is something allowed in SQL with wrong results (decimals cut and zeroed) but not with PLSQL
  l_return := otap_test.ok((NOT otap_util.is_number('1e10')), 'Check otap_util.is_number with scientific notation 1e10 fails');
  -- check functionality is_integer
  l_return := otap_test.ok(otap_util.is_integer('1'), 'Check otap_util.is_integer with simple integer');
  l_return := otap_test.ok((NOT otap_util.is_integer('A')), 'Check otap_util.is_integer with simple char fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('1.0')), 'Check otap_util.is_integer with decimal 1.0 fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('.045')), 'Check otap_util.is_integer with decimal .045 fails');
  l_return := otap_test.ok(otap_util.is_integer('-1'), 'Check otap_util.is_integer with simple negative integer');
  l_return := otap_test.ok((NOT otap_util.is_integer('-1-')), 'Check otap_util.is_integer with strange number -1- fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('-1*2+')), 'Check otap_util.is_integer with strange number -1*2+ fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('99999999999999999999999999999999999999999999999999')), 'Check otap_util.is_integer with too big number 99999999999999999999999999999999999999999999999999 fails');
  -- check functionality validate_config_name
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'');', -20001, NULL, 'Check invalid config name exception');
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER, TRUE);', -20006, NULL, 'Check delete config name exception');
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'', TRUE);', -20006, NULL, 'Check delete invalid config name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  -- check that defined config names do not cause exceptions
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_constants.OTAP_CFG_DEBUG_MODE);', -20001, NULL, 'Check debug mode no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER);', -20001, NULL, 'Check default border no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LABEL_COLUMN);', -20001, NULL, 'Check default label column no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LAYOUT);', -20001, NULL, 'Check default layout no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_PREFIX);', -20001, NULL, 'Check default prefix no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_RESULT_LAYOUT);', -20001, NULL, 'Check default result layout no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_GROUP);', -20001, NULL, 'Check default test group no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_NAME);', -20001, NULL, 'Check default test name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_SET);', -20001, NULL, 'Check default test set no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_BATCH_SIZE);', -20001, NULL, 'Check delete batch size no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_DELAY);', -20001, NULL, 'Check delete delay no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_GROUP_CHAR);', -20001, NULL, 'Check format group char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_HEADER_CHAR);', -20001, NULL, 'Check format header char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_NAME_CHAR);', -20001, NULL, 'Check format test name char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_SET_CHAR);', -20001, NULL, 'Check format test set char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_PRESERVE_DAYS);', -20001, NULL, 'Check preserve days no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_COUNT_DESC);', -20001, NULL, 'Check template count description no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERRORS);', -20001, NULL, 'Check template errors no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERROR_DETAILS);', -20001, NULL, 'Check template error details no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS);', -20001, NULL, 'Check template object exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTSX);', -20001, NULL, 'Check extended template object exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_C);', -20001, NULL, 'Check template constraints exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_CX);', -20001, NULL, 'Check extended template constraint exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_F);', -20001, NULL, 'Check template function exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_FX);', -20001, NULL, 'Check extended template function exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);

  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_GROUP);', -20001, NULL, 'Check template test group no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_MATCH);', -20001, NULL, 'Check template match no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_NO_DATA);', -20001, NULL, 'Check template no data no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_REPORT_TOTAL);', -20001, NULL, 'Check template report total no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_RESULT_LINE);', -20001, NULL, 'Check template result line no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SESSION_ID);', -20001, NULL, 'Check template session id no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SET);', -20001, NULL, 'Check template test set no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SUMMARY);', -20001, NULL, 'Check template summary no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_TEST_NAME);', -20001, NULL, 'Check template test name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE);', -20001, NULL, 'Check config text false no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE_NO);', -20001, NULL, 'Check config text false/no no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_END);', -20001, NULL, 'Check config text report end no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_START);', -20001, NULL, 'Check config text report start no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_TOTAL);', -20001, NULL, 'Check config text report total no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_HEADER);', -20001, NULL, 'Check config text result header no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_LINE);', -20001, NULL, 'Check config text result line no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_SUMMARY_ERROR);', -20001, NULL, 'Check config text summary error no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_SUMMARY_SUCCESS);', -20001, NULL, 'Check config text summary success no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_COUNT_HEADER);', -20001, NULL, 'Check config text test count header no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_COUNT_NAME);', -20001, NULL, 'Check config text test count name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_FAILED);', -20001, NULL, 'Check config text test failed no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_PASSED);', -20001, NULL, 'Check config text test passed no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_UNDEFINED);', -20001, NULL, 'Check config text test undefined no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE);', -20001, NULL, 'Check config text true no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE_YES);', -20001, NULL, 'Check config text true/yes no exception', otap_constants.OTAP_NUM_TEST_FAILED);
END;
/