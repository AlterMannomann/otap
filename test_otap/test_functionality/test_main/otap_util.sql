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
  l_return        VARCHAR2(4000);
  l_decimal       CHAR(1);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_translatable  NUMBER;
  l_label_style   VARCHAR2(1);
  l_testing_id    NUMBER;
  l_batch_size    NUMBER;
  l_batches       NUMBER;
  l_curr_date     DATE;
  l_setup_start   TIMESTAMP;
  l_setup_end     TIMESTAMP;
  l_runtime       NUMBER;
BEGIN
  -- check util config constants
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_BORDER, 'DEFAULT_BORDER', 'otap_util constant config name default border');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LABEL_COLUMN, 'DEFAULT_LABEL_COLUMN', 'otap_util constant config name default label column');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LAYOUT, 'DEFAULT_LAYOUT', 'otap_util constant config name default layout');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_PREFIX, 'DEFAULT_PREFIX', 'otap_util constant config name default prefix');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_RESULT_LAYOUT, 'DEFAULT_RESULT_LAYOUT', 'otap_util constant config name default result layout');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_GROUP, 'DEFAULT_TEST_GROUP', 'otap_util constant config name default test group');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_NAME, 'DEFAULT_TEST_NAME', 'otap_util constant config name default test name');
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_SET, 'DEFAULT_TEST_SET', 'otap_util constant config name default test set');
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_BATCH_SIZE, 'DELETE_BATCH_SIZE', 'otap_util constant config name delete batch size');
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_DELAY, 'DELETE_DELAY', 'otap_util constant config name delete delay');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_GROUP_CHAR, 'FORMAT_GROUP_CHAR', 'otap_util constant config name formatting test group char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_HEADER_CHAR, 'FORMAT_HEADER_CHAR', 'otap_util constant config name formatting header char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_NAME_CHAR, 'FORMAT_NAME_CHAR', 'otap_util constant config name formatting test name char');
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_SET_CHAR, 'FORMAT_SET_CHAR', 'otap_util constant config name formatting test set char');
  l_return := otap_test.is_eq(otap_util.CFG_PRESERVE_DAYS, 'PRESERVE_DAYS', 'otap_util constant config name delete preserve days');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_COUNT_DESC, 'TEMPLATE_COUNT_DESC', 'otap_util constant config name template count description');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERRORS, 'TEMPLATE_ERRORS', 'otap_util constant config name template errors');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERROR_DETAILS, 'TEMPLATE_ERROR_DETAILS', 'otap_util constant config name template error details');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS, 'TEMPLATE_EXISTS', 'otap_util constant config name template object exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTSX, 'TEMPLATE_EXISTSX', 'otap_util constant config name template object exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_C, 'TEMPLATE_EXISTS_C', 'otap_util constant config name template constraint exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_CX, 'TEMPLATE_EXISTS_CX', 'otap_util constant config name template constraints exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_F, 'TEMPLATE_EXISTS_F', 'otap_util constant config name template function/procedure exists');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_FX, 'TEMPLATE_EXISTS_FX', 'otap_util constant config name template function/procedure exists extended');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_GROUP, 'TEMPLATE_GROUP', 'otap_util constant config name template test group');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_MATCH, 'TEMPLATE_MATCH', 'otap_util constant config name template match expression/value');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_NO_DATA, 'TEMPLATE_NO_DATA', 'otap_util constant config name template no data');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_REPORT_TOTAL, 'TEMPLATE_REPORT_TOTAL', 'otap_util constant config name template report totals');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_RESULT_LINE, 'TEMPLATE_RESULT_LINE', 'otap_util constant config name template result line');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SESSION_ID, 'TEMPLATE_SESSION_ID', 'otap_util constant config name template session id');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SET, 'TEMPLATE_SET', 'otap_util constant config name template test set');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SUMMARY, 'TEMPLATE_SUMMARY', 'otap_util constant config name template summary');
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_TEST_NAME, 'TEMPLATE_TEST_NAME', 'otap_util constant config name template test name');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE, 'TEXT_FALSE', 'otap_util constant config name text FALSE');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE_NO, 'TEXT_FALSE_NO', 'otap_util constant config name text NO');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_END, 'TEXT_REPORT_END', 'otap_util constant config name text report end');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_START, 'TEXT_REPORT_START', 'otap_util constant config name text report start');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_TOTAL, 'TEXT_REPORT_TOTAL', 'otap_util constant config name text report totals');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_HEADER, 'TEXT_RESULT_HEADER', 'otap_util constant config name text result header');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_LINE, 'TEXT_RESULT_LINE', 'otap_util constant config name text result line');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_SUMMARY_ERROR, 'TEXT_SUMMARY_ERROR', 'otap_util constant config name text summary error');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_SUMMARY_SUCCESS, 'TEXT_SUMMARY_SUCCESS', 'otap_util constant config name text summary success');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_COUNT_HEADER, 'TEXT_TEST_COUNT_HEADER', 'otap_util constant config name text test count header');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_COUNT_NAME, 'TEXT_TEST_COUNT_NAME', 'otap_util constant config name text test count name');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_FAILED, 'TEXT_TEST_FAILED', 'otap_util constant config name text test failed');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_PASSED, 'TEXT_TEST_PASSED', 'otap_util constant config name text test passed');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_UNDEFINED, 'TEXT_TEST_UNDEFINED', 'otap_util constant config name text test undefined');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE, 'TEXT_TRUE', 'otap_util constant config name text TRUE');
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE_YES, 'TEXT_TRUE_YES', 'otap_util constant config name text YES');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_BOOLEAN, 'LABEL_BOOLEAN', 'otap_util constant config label boolean');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CHECK, 'LABEL_CHECK', 'otap_util constant config label check');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CLUSTER, 'LABEL_CLUSTER', 'otap_util constant config label cluster');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_COLUMN, 'LABEL_COLUMN', 'otap_util constant config label column');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSTRAINT, 'LABEL_CONSTRAINT', 'otap_util constant config label constraint');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSUMER_GROUP, 'LABEL_CONSUMER_GROUP', 'otap_util constant config label consumer group');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONTEXT, 'LABEL_CONTEXT', 'otap_util constant config label context');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CREDENTIAL, 'LABEL_CREDENTIAL', 'otap_util constant config label credential');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATABASE, 'LABEL_DATABASE', 'otap_util constant config label database');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATE, 'LABEL_DATE', 'otap_util constant config label date');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DESTINATION, 'LABEL_DESTINATION', 'otap_util constant config label destination');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIMENSION, 'LABEL_DIMENSION', 'otap_util constant config label dimension');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIRECTORY, 'LABEL_DIRECTORY', 'otap_util constant config label directory');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DOMAIN, 'LABEL_DOMAIN', 'otap_util constant config label domain');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EDITION, 'LABEL_EDITION', 'otap_util constant config label edition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EVALUATION_CONTEXT, 'LABEL_EVALUATION_CONTEXT', 'otap_util constant config evaluation context');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EXCEPTION, 'LABEL_EXCEPTION', 'otap_util constant config label exception');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FOREIGN_KEY, 'LABEL_FOREIGN_KEY', 'otap_util constant config label foreign key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FUNCTION, 'LABEL_FUNCTION', 'otap_util constant config label function');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_HASH, 'LABEL_HASH', 'otap_util constant config label hash');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX, 'LABEL_INDEX', 'otap_util constant config label index');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEXTYPE, 'LABEL_INDEXTYPE', 'otap_util constant config label index type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_PARTITION, 'LABEL_INDEX_PARTITION', 'otap_util constant config label index partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_SUBPARTITION, 'LABEL_INDEX_SUBPARTITION', 'otap_util constant config label index subpartition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE, 'LABEL_INVALID_CONSTRAINT_TYPE', 'otap_util constant config label invalid constraint type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_CLASS, 'LABEL_JAVA_CLASS', 'otap_util constant config label java class');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_DATA, 'LABEL_JAVA_DATA', 'otap_util constant config label java data');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_RESOURCE, 'LABEL_JAVA_RESOURCE', 'otap_util constant config label java resource');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_SOURCE, 'LABEL_JAVA_SOURCE', 'otap_util constant config label java source');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB, 'LABEL_JOB', 'otap_util constant config label job');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB_CLASS, 'LABEL_JOB_CLASS', 'otap_util constant config label job class');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LIBRARY, 'LABEL_LIBRARY', 'otap_util constant config label library');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB, 'LABEL_LOB', 'otap_util constant config label LOB');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB_PARTITION, 'LABEL_LOB_PARTITION', 'otap_util constant config label LOB partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MATERIALIZED_VIEW, 'LABEL_MATERIALIZED_VIEW', 'otap_util constant config label materialized view');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MLE_LANGUAGE, 'LABEL_MLE_LANGUAGE', 'otap_util constant config label mle language');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NOT_NULL, 'LABEL_NOT_NULL', 'otap_util constant config label not null');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NULL, 'LABEL_NULL', 'otap_util constant config label null');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NUMBER, 'LABEL_NUMBER', 'otap_util constant config label number');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_OPERATOR, 'LABEL_OPERATOR', 'otap_util constant config label operator');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE, 'LABEL_PACKAGE', 'otap_util constant config label package');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE_BODY, 'LABEL_PACKAGE_BODY', 'otap_util constant config label package body');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PRIMARY_KEY, 'LABEL_PRIMARY_KEY', 'otap_util constant config label primary key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROCEDURE, 'LABEL_PROCEDURE', 'otap_util constant config label procedure');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROGRAM, 'LABEL_PROGRAM', 'otap_util constant config label program');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_QUEUE, 'LABEL_QUEUE', 'otap_util constant config label queue');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_REF_COLUMN, 'LABEL_REF_COLUMN', 'otap_util constant config label reference column');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RESOURCE_PLAN, 'LABEL_RESOURCE_PLAN', 'otap_util constant config label resource plan');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_ROLE, 'LABEL_ROLE', 'otap_util constant config label role');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE, 'LABEL_RULE', 'otap_util constant config label rule');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE_SET, 'LABEL_RULE_SET', 'otap_util constant config label rule set');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULE, 'LABEL_SCHEDULE', 'otap_util constant config label schedule');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_GROUP, 'LABEL_SCHEDULER_GROUP', 'otap_util constant config label scheduler group');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_JOB, 'LABEL_SCHEDULER_JOB', 'otap_util constant config label scheduler job');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SEQUENCE, 'LABEL_SEQUENCE', 'otap_util constant config label sequence');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING, 'LABEL_SUPPLEMENTAL_LOGGGING', 'otap_util constant config label supplemental logging');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SYNONYM, 'LABEL_SYNONYM', 'otap_util constant config label synonym');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE, 'LABEL_TABLE', 'otap_util constant config label table');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_PARTITION, 'LABEL_TABLE_PARTITION', 'otap_util constant config label table partition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_SUBPARTITION, 'LABEL_TABLE_SUBPARTITION', 'otap_util constant config label table subpartition');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TRIGGER, 'LABEL_TRIGGER', 'otap_util constant config label trigger');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE, 'LABEL_TYPE', 'otap_util constant config label type');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE_BODY, 'LABEL_TYPE_BODY', 'otap_util constant config label type body');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNDEFINED, 'LABEL_UNDEFINED', 'otap_util constant config label undefined');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIFIED_AUDIT_POLICY, 'LABEL_UNIFIED_AUDIT_POLICY', 'otap_util constant config label unified audit policy');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIQUE_KEY, 'LABEL_UNIQUE_KEY', 'otap_util constant config label unique key');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_USER, 'LABEL_USER', 'otap_util constant config label user');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VARCHAR2, 'LABEL_VARCHAR2', 'otap_util constant config label VARCHAR2');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW, 'LABEL_VIEW', 'otap_util constant config label view');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_CHECK, 'LABEL_VIEW_CHECK', 'otap_util constant config label view check');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_READONLY, 'LABEL_VIEW_READONLY', 'otap_util constant config label view readonly');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_WINDOW, 'LABEL_WINDOW', 'otap_util constant config label window');
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_XML_SCHEMA, 'LABEL_XML_SCHEMA', 'otap_util constant config label XML schema');
  -- check functionality is_number
  l_return := otap_test.ok(otap_util.is_number('1'), 'otap_util.is_number simple number');
  l_return := otap_test.ok((NOT otap_util.is_number('A')), 'otap_util.is_number simple char fails');
  l_return := otap_test.ok(p_boolean => otap_util.is_number('A'), p_description => 'otap_util.is_number simple char and expected result failed', p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.ok((NOT otap_util.is_number('-1-')), 'otap_util.is_number strange number -1- fails');
  l_return := otap_test.ok((NOT otap_util.is_number('-1*2+')), 'otap_util.is_number strange number -1*2+ fails');
  l_return := otap_test.ok((NOT otap_util.is_number('99999999999999999999999999999999999999999999999999')), 'otap_util.is_number too big number 99999999999999999999999999999999999999999999999999 fails');
  -- get correct current decimal points, thousands divider does not work with TO_NUMBER, without given format
  SELECT SUBSTR(value, 1, 1)
    INTO l_decimal
    FROM nls_session_parameters
   WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
  ;
  l_return := otap_test.ok(otap_util.is_number('1' || l_decimal || '234'), 'otap_util.is_number using current decimal point defined 1.234');
  l_return := otap_test.ok(otap_util.is_number(l_decimal || '234'), 'otap_util.is_number using leading current decimal point defined .234');
  -- this is something allowed in SQL with wrong results (decimals cut and zeroed) but not with PLSQL
  l_return := otap_test.ok((NOT otap_util.is_number('1e10')), 'otap_util.is_number scientific notation 1e10 fails');
  -- check functionality is_integer
  l_return := otap_test.ok(otap_util.is_integer('1'), 'otap_util.is_integer simple integer');
  l_return := otap_test.ok((NOT otap_util.is_integer('A')), 'otap_util.is_integer simple char fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('1.0')), 'otap_util.is_integer decimal 1.0 fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('.045')), 'otap_util.is_integer decimal .045 fails');
  l_return := otap_test.ok(otap_util.is_integer('-1'), 'otap_util.is_integer simple negative integer');
  l_return := otap_test.ok((NOT otap_util.is_integer('-1-')), 'otap_util.is_integer strange number -1- fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('-1*2+')), 'otap_util.is_integer strange number -1*2+ fails');
  l_return := otap_test.ok((NOT otap_util.is_integer('99999999999999999999999999999999999999999999999999')), 'otap_util.is_integer too big number 99999999999999999999999999999999999999999999999999 fails');
  -- check functionality validate_config_name
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'');', -20001, NULL, 'otap_util.validate_config_name invalid config name exception');
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER, TRUE);', -20006, NULL, 'otap_util.validate_config_name delete config name exception');
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'', TRUE);', -20006, NULL, 'otap_util.validate_config_name delete invalid config name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  -- check that defined config names do not cause exceptions
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_constants.OTAP_CFG_DEBUG_MODE);', -20001, NULL, 'otap_util.validate_config_name debug mode no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER);', -20001, NULL, 'otap_util.validate_config_name default border no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LABEL_COLUMN);', -20001, NULL, 'otap_util.validate_config_name default label column no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LAYOUT);', -20001, NULL, 'otap_util.validate_config_name default layout no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_PREFIX);', -20001, NULL, 'otap_util.validate_config_name default prefix no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_RESULT_LAYOUT);', -20001, NULL, 'otap_util.validate_config_name default result layout no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_GROUP);', -20001, NULL, 'otap_util.validate_config_name default test group no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_NAME);', -20001, NULL, 'otap_util.validate_config_name default test name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_SET);', -20001, NULL, 'otap_util.validate_config_name default test set no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LANGUAGE);', -20001, NULL, 'otap_util.validate_config_name default language no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_BATCH_SIZE);', -20001, NULL, 'otap_util.validate_config_name delete batch size no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_DELAY);', -20001, NULL, 'otap_util.validate_config_name delete delay no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_GROUP_CHAR);', -20001, NULL, 'otap_util.validate_config_name format group char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_HEADER_CHAR);', -20001, NULL, 'otap_util.validate_config_name format header char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_NAME_CHAR);', -20001, NULL, 'otap_util.validate_config_name format test name char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_SET_CHAR);', -20001, NULL, 'otap_util.validate_config_name format test set char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_PRESERVE_DAYS);', -20001, NULL, 'otap_util.validate_config_name preserve days no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_COUNT_DESC);', -20001, NULL, 'otap_util.validate_config_name template count description no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERRORS);', -20001, NULL, 'otap_util.validate_config_name template errors no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERROR_DETAILS);', -20001, NULL, 'otap_util.validate_config_name template error details no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS);', -20001, NULL, 'otap_util.validate_config_name template object exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTSX);', -20001, NULL, 'otap_util.validate_config_name extended template object exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_C);', -20001, NULL, 'otap_util.validate_config_name template constraints exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_CX);', -20001, NULL, 'otap_util.validate_config_name extended template constraint exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_F);', -20001, NULL, 'otap_util.validate_config_name template function exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_FX);', -20001, NULL, 'otap_util.validate_config_name extended template function exists no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_GROUP);', -20001, NULL, 'otap_util.validate_config_name template test group no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_MATCH);', -20001, NULL, 'otap_util.validate_config_name template match no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_NO_DATA);', -20001, NULL, 'otap_util.validate_config_name template no data no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_REPORT_TOTAL);', -20001, NULL, 'otap_util.validate_config_name template report total no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_RESULT_LINE);', -20001, NULL, 'otap_util.validate_config_name template result line no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SESSION_ID);', -20001, NULL, 'otap_util.validate_config_name template session id no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SET);', -20001, NULL, 'otap_util.validate_config_name template test set no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SUMMARY);', -20001, NULL, 'otap_util.validate_config_name template summary no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_TEST_NAME);', -20001, NULL, 'otap_util.validate_config_name template test name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE);', -20001, NULL, 'otap_util.validate_config_name config text false no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE_NO);', -20001, NULL, 'otap_util.validate_config_name config text false/no no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_END);', -20001, NULL, 'otap_util.validate_config_name config text report end no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_START);', -20001, NULL, 'otap_util.validate_config_name config text report start no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_TOTAL);', -20001, NULL, 'otap_util.validate_config_name config text report total no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_HEADER);', -20001, NULL, 'otap_util.validate_config_name config text result header no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_LINE);', -20001, NULL, 'otap_util.validate_config_name config text result line no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_SUMMARY_ERROR);', -20001, NULL, 'otap_util.validate_config_name config text summary error no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_SUMMARY_SUCCESS);', -20001, NULL, 'otap_util.validate_config_name config text summary success no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_COUNT_HEADER);', -20001, NULL, 'otap_util.validate_config_name config text test count header no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_COUNT_NAME);', -20001, NULL, 'otap_util.validate_config_name config text test count name no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_FAILED);', -20001, NULL, 'otap_util.validate_config_name config text test failed no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_PASSED);', -20001, NULL, 'otap_util.validate_config_name config text test passed no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_UNDEFINED);', -20001, NULL, 'otap_util.validate_config_name config text test undefined no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE);', -20001, NULL, 'otap_util.validate_config_name config text true no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE_YES);', -20001, NULL, 'otap_util.validate_config_name config text true/yes no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  -- reduced testing for validate_config_value, as used in trigger config_name must be valid for testing, as checked before
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, NULL, ''NUMBER'', l_translatable, NULL);', -20002, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value NULL exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''INTEGER'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''number'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type lower case number exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''char'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type lower case char exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''10'', ''NUMBER'', l_translatable, 1);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max defined length number exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''10'', ''CHAR'', l_translatable, 1);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max defined length char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, LPAD(''9'', 4001, ''9''), ''NUMBER'', l_translatable, NULL);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max length number exception');
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, LPAD(''9'', 4001, ''9''), ''CHAR'', l_translatable, NULL);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max length char no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''A'', ''NUMBER'', l_translatable, NULL);', -20005, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value not a number exception');
  l_translatable := 9;
  l_stamp        := SYSTIMESTAMP;
  l_return       := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '0', 'NUMBER', l_translatable, NULL);
  l_finish       := SYSTIMESTAMP;
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value default value on invalid translatable');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for TRANSLATABLE: 9%'
  ;
  l_translatable := otap_constants.OTAP_NUM_TRUE;
  l_stamp        := SYSTIMESTAMP;
  l_return       := otap_util.validate_config_value(otap_util.CFG_DEFAULT_PREFIX, otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX, 'CHAR', l_translatable, otap_constants.OTAP_NUM_PREFIX_MAX_SIZE);
  l_finish       := SYSTIMESTAMP;
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default prefix');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default prefix')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid config_name: ' || otap_util.CFG_DEFAULT_PREFIX || ' for TRANSLATABLE:%'
  ;
  l_translatable := otap_constants.OTAP_NUM_TRUE;
  l_stamp        := SYSTIMESTAMP;
  l_return       := otap_util.validate_config_value(otap_util.CFG_DEFAULT_LAYOUT, otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'CHAR', l_translatable, 1);
  l_finish       := SYSTIMESTAMP;
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default layout');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default layout')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid config_name: ' || otap_util.CFG_DEFAULT_LAYOUT || ' for TRANSLATABLE:%'
  ;
  l_translatable := otap_constants.OTAP_NUM_TRUE;
  l_stamp        := SYSTIMESTAMP;
  l_return       := otap_util.validate_config_value(otap_util.CFG_DEFAULT_RESULT_LAYOUT, otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT, 'CHAR', l_translatable, 1);
  l_finish       := SYSTIMESTAMP;
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default result layout');
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default result layout')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid config_name: ' || otap_util.CFG_DEFAULT_RESULT_LAYOUT || ' for TRANSLATABLE:%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '0', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid min value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days min value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 0%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '8', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid max value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days max value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 8%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '1.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid decimal value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days decimal value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 1.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '0', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid min value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay min value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 0%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '601', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid max value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay max value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 601%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '100.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid decimal value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay decimal value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 100.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '10', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid min value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size min value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 10%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '10001', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid max value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size max value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 10001%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '100.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid decimal value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size decimal value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 100.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '1', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid min value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size min value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 1%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '11', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid max value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size max value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 11%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '5.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid decimal value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size decimal value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 5.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '3', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE)), 'otap_util.validate_config_value default debug invalid value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid debug value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEBUG_MODE: 3%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_LAYOUT, 'X', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_LAYOUT_MIDDLE)), 'otap_util.validate_config_value default layout invalid value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid layout value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_LAYOUT: X%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_RESULT_LAYOUT, 'M', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT)), 'otap_util.validate_config_value default result layout invalid value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid result layout value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_RESULT_LAYOUT: M%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, 'X', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_LABEL_LOWER)), 'otap_util.validate_config_value default label layout invalid value');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid label layout value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_LABEL_LAYOUT: X%'
  ;
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_constants.OTAP_CFG_DEBUG_MODE);', -20020, NULL, 'otap_util.validate_translatable config value not translatable exception');
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_util.CFG_DEFAULT_TEST_SET);', -20020, NULL, 'otap_util.validate_translatable config value translatable no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_util.CFG_LABEL_BOOLEAN);', -20020, NULL, 'otap_util.validate_translatable label value translatable no exception', otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_DEFAULT_PREFIX), 'TEST', 'otap_util.get_config_value get config value as text');
  l_return := otap_test.is_eq(otap_util.get_config_value('Not exists'), 'OTAP_ERROR', 'otap_util.get_config_value get invalid config value as text');
  -- save the current configuration for style lower, upper, init capitals
  SELECT config_value INTO l_label_style FROM otap_config WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN;
  -- set the configuration temporarily and test this configuration
  UPDATE otap_config SET config_value = otap_constants.OTAP_LABEL_LOWER WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN;
  COMMIT;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'boolean', 'otap_util.get_config_value label as text format lower');
  UPDATE otap_config SET config_value = otap_constants.OTAP_LABEL_UPPER WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN;
  COMMIT;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'BOOLEAN', 'otap_util.get_config_value label as text format upper');
  UPDATE otap_config SET config_value = otap_constants.OTAP_LABEL_INIT_CAP WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN;
  COMMIT;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), 'Boolean', 'otap_util.get_config_value label as text format initial capitals');
  -- restore the original value
  UPDATE otap_config SET config_value = l_label_style WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN;
  COMMIT;
  l_return := otap_test.is_eq(otap_util.get_config_number(otap_constants.OTAP_CFG_DEBUG_MODE), 0, 'otap_util.get_config_number get config value as number');
  l_return := otap_test.ok((otap_util.get_config_number('Debuck_mode') IS NULL), 'otap_util.get_config_number get invalid config value as number');
  l_return := otap_test.is_eq(otap_util.get_label_id('BOOLEAN'), otap_util.CFG_LABEL_BOOLEAN, 'otap_util.get_label_id BOOLEAN');
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.get_label_id('BOOLEAN OHH MY GOD'), otap_util.CFG_LABEL_UNDEFINED, 'otap_util.get_label_id not existing BOOLEAN OHH MY GOD');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.get_label_id log entry invalid label value')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.get_label_id'
     AND message            LIKE 'Invalid object type: BOOLEAN OHH MY GOD%'
  ;
  SELECT otap_test.is_eq(otap_util.get_length_test_state, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_test_state')
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_TEST_UNDEFINED
                            , otap_util.CFG_TEXT_TEST_PASSED
                            , otap_util.CFG_TEXT_TEST_FAILED
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  SELECT otap_test.is_eq(otap_util.get_length_summary_state, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_summary_state')
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_SUMMARY_ERROR
                            , otap_util.CFG_TEXT_SUMMARY_SUCCESS
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  SELECT otap_test.is_eq(otap_util.get_length_headers, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_headers')
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_REPORT_START
                            , otap_util.CFG_TEXT_REPORT_END
                            , otap_util.CFG_TEXT_REPORT_TOTAL
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  SELECT otap_test.is_eq(otap_util.get_length_result_headers, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_result_headers')
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_RESULT_HEADER
                            , otap_util.CFG_TEXT_RESULT_LINE
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_PASSED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED), 'otap_util.test_result_to_text passed');
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_FAILED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_FAILED), 'otap_util.test_result_to_text failed');
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED), 'otap_util.test_result_to_text undefined');
  l_return := otap_test.is_eq(otap_util.test_result_to_text(99), otap_constants.OTAP_INTERNAL_ERROR, 'otap_util.test_result_to_text wrong test result number');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label, otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label default check');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('C'), otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label parameter C check');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('c'), otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label lower parameter c check');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('P'), otap_util.CFG_LABEL_PRIMARY_KEY, 'otap_util.constraint_type_to_label parameter P primary key');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('U'), otap_util.CFG_LABEL_UNIQUE_KEY, 'otap_util.constraint_type_to_label parameter U unique key');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('R'), otap_util.CFG_LABEL_FOREIGN_KEY, 'otap_util.constraint_type_to_label parameter R foreign key');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('V'), otap_util.CFG_LABEL_VIEW_CHECK, 'otap_util.constraint_type_to_label parameter V view check');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('O'), otap_util.CFG_LABEL_VIEW_READONLY, 'otap_util.constraint_type_to_label parameter O view readonly');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('F'), otap_util.CFG_LABEL_REF_COLUMN, 'otap_util.constraint_type_to_label parameter F ref column');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('H'), otap_util.CFG_LABEL_HASH, 'otap_util.constraint_type_to_label parameter H hash');
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('S'), otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING, 'otap_util.constraint_type_to_label parameter S supplemental logging');
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('X'), otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE, 'otap_util.constraint_type_to_label parameter X invalid');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.constraint_type_to_label log entry invalid parameter')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.constraint_type_to_label'
     AND message            LIKE 'Invalid constraint type: X%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => NULL, p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule missing template');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.build_msg description no log entry missing template identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%missing%template identifier%'
  ;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS, p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule given template');
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => 'I DO NOT EXIST', p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule invalid template');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.build_msg description no log entry invalid template identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%invalid template identifier%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(NULL), otap_constants.OTAP_INTERNAL_ERROR || ' otap_util.build_msg missing description and template identifier', 'otap_util.build_msg missing template');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry missing template identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%otap_util.build_msg missing description and template identifier'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg('I DO NOT EXIST'), otap_constants.OTAP_INTERNAL_ERROR || ' otap_util.build_msg invalid template identifier I DO NOT EXIST', 'otap_util.build_msg invalid template');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry invalid template identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%otap_util.build_msg invalid template identifier I DO NOT EXIST'
  ;
  l_return := otap_test.is_eq(otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS), '@type@ @object@ exists check (@schema@)', 'otap_util.build_msg template no parameter');
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN)
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template only type parameter'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, 'Type invalid'), '@type@ @object@ exists check (@schema@)', 'otap_util.build_msg template invalid type parameter');
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry invalid type identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Type ignored, Invalid label used: Type invalid%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for first variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@', 'My fanCY obJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@OBJECT@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, empty variable'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, 'object', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, no variable identifier'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no first variable identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: object%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@@object@@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, wrong variable identifier count'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong first variable identifier count')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: @@object@@%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param1_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first value without variable'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry first value without variable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: NULL%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@object@'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for second variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@object@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@object@'
                                                  , p_param2_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@OBJECT@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, empty variable'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => 'object'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, no variable identifier'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no second variable identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: object%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@@object@@'
                                                  , p_param2_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, wrong variable identifier count'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong second variable identifier count')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: @@object@@%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second value without variable'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry second value without variable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: NULL%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@object@'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for third variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@object@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@object@'
                                                  , p_param3_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@OBJECT@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, empty variable'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => 'object'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, no variable identifier'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no third variable identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: object%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@@object@@'
                                                  , p_param3_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, wrong variable identifier count'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong third variable identifier count')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: @@object@@%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third value without variable'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry third value without variable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: NULL%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@object@'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for fourth variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@object@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@object@'
                                                  , p_param4_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@OBJECT@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, empty variable'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => 'object'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, no variable identifier'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no fourth variable identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: object%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@@object@@'
                                                  , p_param4_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, wrong variable identifier count'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong fourth variable identifier count')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: @@object@@%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth value without variable'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry fourth value without variable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: NULL%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@object@'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for fifth variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@object@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@object@'
                                                  , p_param5_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@OBJECT@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, empty variable'
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => 'object'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, no variable identifier'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no fifth variable identifier')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: object%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@@object@@'
                                                  , p_param5_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, wrong variable identifier count'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong fifth variable identifier count')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: @@object@@%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth value without variable'
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry fifth value without variable')
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Value without variable name: MY_OBJECT or invalid parameter: NULL%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@object@'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' exists check (@schema@)'
                             , 'otap_util.build_msg template no value blank out for sixth variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@object@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@object@'
                                                  , p_param6n_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair value any case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@OBJECT@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, wrong variable case'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, empty variable'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => 'object'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, no variable identifier'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@@object@@'
                                                  , p_param6n_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, wrong variable identifier count'
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth value without variable'
                             )
  ;
  -- use a negative session id for test writes
  l_testing_id := otap_test.get_session_id * -1;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test set'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, NULL, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception db user'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception db schema'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test group'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test start'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test end'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test name'
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test description'
                                     )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_TEST_PASSED, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record no exception test'
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND db_user         = USER
     AND db_schema       = USER
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND test_group      = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
     AND test_name       = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
     AND test_desc       = otap_constants.OTAP_INTERNAL_NA
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(9, otap_constants.OTAP_NUM_TEST_PASSED, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record no exception wrong to_delete'
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written wrong to_delete')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_passed     = otap_constants.OTAP_NUM_TEST_PASSED
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND db_user         = USER
     AND db_schema       = USER
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND test_group      = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
     AND test_name       = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
     AND test_desc       = otap_constants.OTAP_INTERNAL_NA
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(otap_constants.OTAP_NUM_TRUE, 9, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record no exception wrong test_passed'
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written wrong test_passed')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
     AND to_delete       = otap_constants.OTAP_NUM_TRUE
     AND test_passed     = otap_constants.OTAP_NUM_TEST_UNDEFINED
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND db_user         = USER
     AND db_schema       = USER
     AND test_set        = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
     AND test_group      = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
     AND test_name       = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
     AND test_desc       = otap_constants.OTAP_INTERNAL_NA
     AND test_start     >= l_stamp
     AND test_end       <= l_finish
     AND test_errors    IS NOT NULL
  ;
  l_return := otap_test.is_eq(otap_util.max_text_size(l_testing_id), 80, 'otap_util.max_text_size expected max length');
  -- ramp up result cleanup
  l_setup_start := SYSTIMESTAMP;
  -- disable job, if active
  DBMS_SCHEDULER.DISABLE(name => 'OTAP_MAINTENANCE', force => TRUE);
  -- create batch size + 1 record for delete
  l_batch_size := otap_util.get_config_number(otap_util.CFG_DELETE_BATCH_SIZE) + 1;
  -- create batch size +1 records with simulated testing session id
  FOR rec IN 1..l_batch_size
  LOOP
    otap_util.write_test_result(otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_TEST_PASSED, l_testing_id, NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);
  END LOOP;
  -- turn off trigger to be able set an older date
  EXECUTE IMMEDIATE 'ALTER TRIGGER otap_results_upd_trg DISABLE';
  -- update to a date old enough to beat highest possible value
  UPDATE otap_results
     SET to_delete       = otap_constants.OTAP_NUM_TRUE
       , deleted_by      = USER
       , test_run_date   = TRUNC(SYSDATE - 9)
   WHERE test_session_id = l_testing_id
  ;
  COMMIT;
  -- enable trigger again
  EXECUTE IMMEDIATE 'ALTER TRIGGER otap_results_upd_trg ENABLE';
  -- get amount of batches to execute, might be more than only the test records
  SELECT FLOOR(COUNT(*) / otap_util.get_config_number(otap_util.CFG_DELETE_BATCH_SIZE))
    INTO l_batches
    FROM otap_results
   WHERE to_delete      = otap_constants.OTAP_NUM_TRUE
     AND test_run_date <= TRUNC(SYSDATE - otap_util.get_config_number(otap_util.CFG_PRESERVE_DAYS))
  ;
  -- set debug to be able to control debug log messages
  UPDATE otap_config SET config_value = '1' WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE;
  COMMIT;
  l_stamp  := SYSTIMESTAMP;
  -- run cleaunup, will delete all simulated session id records
  otap_util.result_cleanup;
  l_finish := SYSTIMESTAMP;
  -- disable debug mode again
  UPDATE otap_config SET config_value = '0' WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE;
  COMMIT;
  l_setup_end := SYSTIMESTAMP;
  -- now check otap_results
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.result_cleanup verify delete')
    INTO l_return
    FROM otap_results
   WHERE test_session_id = l_testing_id
  ;
  -- verify debug messages
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.result_cleanup verify debug start log message')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Procedure start'
     AND message   LIKE 'Start delete with batch size%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  SELECT otap_test.is_eq(COUNT(*), l_batches, 'otap_util.result_cleanup verify debug batch messages')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Batch size reached and wait'
     AND message   LIKE 'Batch size reached, commit and wait. Processed records%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.result_cleanup verify debug end log message')
    INTO l_return
    FROM sperrorlog
   WHERE identifier   = 'OTAP_DEBUG'
     AND script    LIKE 'otap_util.result_cleanup'
     AND statement LIKE 'Procedure end'
     AND message   LIKE 'Processed%records for delete%'
     AND timestamp   >= l_stamp
     AND timestamp   <= l_finish
  ;
  -- enable job again
  DBMS_SCHEDULER.ENABLE(name => 'OTAP_MAINTENANCE');
  -- time preparation diff seconds
  l_curr_date := SYSDATE;
  l_runtime   := l_curr_date + ((l_setup_end - l_setup_start) * 86400) - l_curr_date;
  l_return    := otap_test.ok(l_runtime < 20, 'otap_util.result_cleanup preparation performance seconds: ' || TO_CHAR(l_runtime, '90.09') || ' < 20');
END;
/