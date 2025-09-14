-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- Executes the test code for otap_util. Should execute with all possible valid configuration settings.
-- Parameter may be changed before running this code to test different parameter.
-- The test name must be set outside of this code.
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return        VARCHAR2(4000 CHAR);
  l_value         VARCHAR2(4000 CHAR);
  l_comp          VARCHAR2(4000 CHAR);
  l_decimal       CHAR(1 CHAR);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_translatable  NUMBER;
  l_label_style   VARCHAR2(1 CHAR);
  l_testing_id    NUMBER;
  l_batch_size    NUMBER;
  l_batches       NUMBER;
  l_curr_date     DATE;
  l_setup_start   TIMESTAMP;
  l_setup_end     TIMESTAMP;
  l_runtime       NUMBER;
  l_ext           VARCHAR2(128 CHAR);
BEGIN
  -- get the text extension for used layout
  l_ext    := ' layout(' || otap_util.get_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN) || ')';
  -- util constants check generated
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_BORDER, 'DEFAULT_BORDER', 'Verify package constant otap_util.CFG_DEFAULT_BORDER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LABEL_COLUMN, 'DEFAULT_LABEL_COLUMN', 'Verify package constant otap_util.CFG_DEFAULT_LABEL_COLUMN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LANGUAGE, 'DEFAULT_LANGUAGE', 'Verify package constant otap_util.CFG_DEFAULT_LANGUAGE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_LAYOUT, 'DEFAULT_LAYOUT', 'Verify package constant otap_util.CFG_DEFAULT_LAYOUT' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_PREFIX, 'DEFAULT_PREFIX', 'Verify package constant otap_util.CFG_DEFAULT_PREFIX' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_RESULT_LAYOUT, 'DEFAULT_RESULT_LAYOUT', 'Verify package constant otap_util.CFG_DEFAULT_RESULT_LAYOUT' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_GROUP, 'DEFAULT_TEST_GROUP', 'Verify package constant otap_util.CFG_DEFAULT_TEST_GROUP' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_NAME, 'DEFAULT_TEST_NAME', 'Verify package constant otap_util.CFG_DEFAULT_TEST_NAME' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DEFAULT_TEST_SET, 'DEFAULT_TEST_SET', 'Verify package constant otap_util.CFG_DEFAULT_TEST_SET' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_BATCH_SIZE, 'DELETE_BATCH_SIZE', 'Verify package constant otap_util.CFG_DELETE_BATCH_SIZE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_DELETE_DELAY, 'DELETE_DELAY', 'Verify package constant otap_util.CFG_DELETE_DELAY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_GROUP_CHAR, 'FORMAT_GROUP_CHAR', 'Verify package constant otap_util.CFG_FORMAT_GROUP_CHAR' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_HEADER_CHAR, 'FORMAT_HEADER_CHAR', 'Verify package constant otap_util.CFG_FORMAT_HEADER_CHAR' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_NAME_CHAR, 'FORMAT_NAME_CHAR', 'Verify package constant otap_util.CFG_FORMAT_NAME_CHAR' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_FORMAT_SET_CHAR, 'FORMAT_SET_CHAR', 'Verify package constant otap_util.CFG_FORMAT_SET_CHAR' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_PRESERVE_DAYS, 'PRESERVE_DAYS', 'Verify package constant otap_util.CFG_PRESERVE_DAYS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_COUNT_DESC, 'TEMPLATE_COUNT_DESC', 'Verify package constant otap_util.CFG_TEMPLATE_COUNT_DESC' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERRORS, 'TEMPLATE_ERRORS', 'Verify package constant otap_util.CFG_TEMPLATE_ERRORS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_ERROR_DETAILS, 'TEMPLATE_ERROR_DETAILS', 'Verify package constant otap_util.CFG_TEMPLATE_ERROR_DETAILS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS, 'TEMPLATE_EXISTS', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTSX, 'TEMPLATE_EXISTSX', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTSX' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_C, 'TEMPLATE_EXISTS_C', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTS_C' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_CX, 'TEMPLATE_EXISTS_CX', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTS_CX' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_F, 'TEMPLATE_EXISTS_F', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTS_F' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_EXISTS_FX, 'TEMPLATE_EXISTS_FX', 'Verify package constant otap_util.CFG_TEMPLATE_EXISTS_FX' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_GROUP, 'TEMPLATE_GROUP', 'Verify package constant otap_util.CFG_TEMPLATE_GROUP' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_MATCH, 'TEMPLATE_MATCH', 'Verify package constant otap_util.CFG_TEMPLATE_MATCH' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_NO_DATA, 'TEMPLATE_NO_DATA', 'Verify package constant otap_util.CFG_TEMPLATE_NO_DATA' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_REPORT_TOTAL, 'TEMPLATE_REPORT_TOTAL', 'Verify package constant otap_util.CFG_TEMPLATE_REPORT_TOTAL' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_RESULT_LINE, 'TEMPLATE_RESULT_LINE', 'Verify package constant otap_util.CFG_TEMPLATE_RESULT_LINE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SESSION_ID, 'TEMPLATE_SESSION_ID', 'Verify package constant otap_util.CFG_TEMPLATE_SESSION_ID' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SET, 'TEMPLATE_SET', 'Verify package constant otap_util.CFG_TEMPLATE_SET' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_SUMMARY, 'TEMPLATE_SUMMARY', 'Verify package constant otap_util.CFG_TEMPLATE_SUMMARY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEMPLATE_TEST_NAME, 'TEMPLATE_TEST_NAME', 'Verify package constant otap_util.CFG_TEMPLATE_TEST_NAME' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE, 'TEXT_FALSE', 'Verify package constant otap_util.CFG_TEXT_FALSE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_FALSE_NO, 'TEXT_FALSE_NO', 'Verify package constant otap_util.CFG_TEXT_FALSE_NO' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_END, 'TEXT_REPORT_END', 'Verify package constant otap_util.CFG_TEXT_REPORT_END' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_START, 'TEXT_REPORT_START', 'Verify package constant otap_util.CFG_TEXT_REPORT_START' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_REPORT_TOTAL, 'TEXT_REPORT_TOTAL', 'Verify package constant otap_util.CFG_TEXT_REPORT_TOTAL' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_HEADER, 'TEXT_RESULT_HEADER', 'Verify package constant otap_util.CFG_TEXT_RESULT_HEADER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_RESULT_LINE, 'TEXT_RESULT_LINE', 'Verify package constant otap_util.CFG_TEXT_RESULT_LINE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_FAILED, 'TEXT_TEST_FAILED', 'Verify package constant otap_util.CFG_TEXT_TEST_FAILED' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_PASSED, 'TEXT_TEST_PASSED', 'Verify package constant otap_util.CFG_TEXT_TEST_PASSED' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TEST_UNDEFINED, 'TEXT_TEST_UNDEFINED', 'Verify package constant otap_util.CFG_TEXT_TEST_UNDEFINED' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE, 'TEXT_TRUE', 'Verify package constant otap_util.CFG_TEXT_TRUE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_TEXT_TRUE_YES, 'TEXT_TRUE_YES', 'Verify package constant otap_util.CFG_TEXT_TRUE_YES' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_BOOLEAN, 'LABEL_BOOLEAN', 'Verify package constant otap_util.CFG_LABEL_BOOLEAN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CHECK, 'LABEL_CHECK', 'Verify package constant otap_util.CFG_LABEL_CHECK' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CLUSTER, 'LABEL_CLUSTER', 'Verify package constant otap_util.CFG_LABEL_CLUSTER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_COLUMN, 'LABEL_COLUMN', 'Verify package constant otap_util.CFG_LABEL_COLUMN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSTRAINT, 'LABEL_CONSTRAINT', 'Verify package constant otap_util.CFG_LABEL_CONSTRAINT' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONSUMER_GROUP, 'LABEL_CONSUMER_GROUP', 'Verify package constant otap_util.CFG_LABEL_CONSUMER_GROUP' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CONTEXT, 'LABEL_CONTEXT', 'Verify package constant otap_util.CFG_LABEL_CONTEXT' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_CREDENTIAL, 'LABEL_CREDENTIAL', 'Verify package constant otap_util.CFG_LABEL_CREDENTIAL' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATABASE, 'LABEL_DATABASE', 'Verify package constant otap_util.CFG_LABEL_DATABASE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DATE, 'LABEL_DATE', 'Verify package constant otap_util.CFG_LABEL_DATE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DESTINATION, 'LABEL_DESTINATION', 'Verify package constant otap_util.CFG_LABEL_DESTINATION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIMENSION, 'LABEL_DIMENSION', 'Verify package constant otap_util.CFG_LABEL_DIMENSION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DIRECTORY, 'LABEL_DIRECTORY', 'Verify package constant otap_util.CFG_LABEL_DIRECTORY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_DOMAIN, 'LABEL_DOMAIN', 'Verify package constant otap_util.CFG_LABEL_DOMAIN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EDITION, 'LABEL_EDITION', 'Verify package constant otap_util.CFG_LABEL_EDITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EVALUATION_CONTEXT, 'LABEL_EVALUATION_CONTEXT', 'Verify package constant otap_util.CFG_LABEL_EVALUATION_CONTEXT' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_EXCEPTION, 'LABEL_EXCEPTION', 'Verify package constant otap_util.CFG_LABEL_EXCEPTION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FOREIGN_KEY, 'LABEL_FOREIGN_KEY', 'Verify package constant otap_util.CFG_LABEL_FOREIGN_KEY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_FUNCTION, 'LABEL_FUNCTION', 'Verify package constant otap_util.CFG_LABEL_FUNCTION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_HASH, 'LABEL_HASH', 'Verify package constant otap_util.CFG_LABEL_HASH' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX, 'LABEL_INDEX', 'Verify package constant otap_util.CFG_LABEL_INDEX' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEXTYPE, 'LABEL_INDEXTYPE', 'Verify package constant otap_util.CFG_LABEL_INDEXTYPE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_PARTITION, 'LABEL_INDEX_PARTITION', 'Verify package constant otap_util.CFG_LABEL_INDEX_PARTITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INDEX_SUBPARTITION, 'LABEL_INDEX_SUBPARTITION', 'Verify package constant otap_util.CFG_LABEL_INDEX_SUBPARTITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE, 'LABEL_INVALID_CONSTRAINT_TYPE', 'Verify package constant otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_CLASS, 'LABEL_JAVA_CLASS', 'Verify package constant otap_util.CFG_LABEL_JAVA_CLASS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_DATA, 'LABEL_JAVA_DATA', 'Verify package constant otap_util.CFG_LABEL_JAVA_DATA' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_RESOURCE, 'LABEL_JAVA_RESOURCE', 'Verify package constant otap_util.CFG_LABEL_JAVA_RESOURCE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JAVA_SOURCE, 'LABEL_JAVA_SOURCE', 'Verify package constant otap_util.CFG_LABEL_JAVA_SOURCE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB, 'LABEL_JOB', 'Verify package constant otap_util.CFG_LABEL_JOB' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_JOB_CLASS, 'LABEL_JOB_CLASS', 'Verify package constant otap_util.CFG_LABEL_JOB_CLASS' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LIBRARY, 'LABEL_LIBRARY', 'Verify package constant otap_util.CFG_LABEL_LIBRARY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB, 'LABEL_LOB', 'Verify package constant otap_util.CFG_LABEL_LOB' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_LOB_PARTITION, 'LABEL_LOB_PARTITION', 'Verify package constant otap_util.CFG_LABEL_LOB_PARTITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MATERIALIZED_VIEW, 'LABEL_MATERIALIZED_VIEW', 'Verify package constant otap_util.CFG_LABEL_MATERIALIZED_VIEW' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_MLE_LANGUAGE, 'LABEL_MLE_LANGUAGE', 'Verify package constant otap_util.CFG_LABEL_MLE_LANGUAGE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NOT_NULL, 'LABEL_NOT_NULL', 'Verify package constant otap_util.CFG_LABEL_NOT_NULL' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NULL, 'LABEL_NULL', 'Verify package constant otap_util.CFG_LABEL_NULL' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_NUMBER, 'LABEL_NUMBER', 'Verify package constant otap_util.CFG_LABEL_NUMBER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_OPERATOR, 'LABEL_OPERATOR', 'Verify package constant otap_util.CFG_LABEL_OPERATOR' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE, 'LABEL_PACKAGE', 'Verify package constant otap_util.CFG_LABEL_PACKAGE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PACKAGE_BODY, 'LABEL_PACKAGE_BODY', 'Verify package constant otap_util.CFG_LABEL_PACKAGE_BODY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PRIMARY_KEY, 'LABEL_PRIMARY_KEY', 'Verify package constant otap_util.CFG_LABEL_PRIMARY_KEY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROCEDURE, 'LABEL_PROCEDURE', 'Verify package constant otap_util.CFG_LABEL_PROCEDURE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_PROGRAM, 'LABEL_PROGRAM', 'Verify package constant otap_util.CFG_LABEL_PROGRAM' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_QUEUE, 'LABEL_QUEUE', 'Verify package constant otap_util.CFG_LABEL_QUEUE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_REF_COLUMN, 'LABEL_REF_COLUMN', 'Verify package constant otap_util.CFG_LABEL_REF_COLUMN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RESOURCE_PLAN, 'LABEL_RESOURCE_PLAN', 'Verify package constant otap_util.CFG_LABEL_RESOURCE_PLAN' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_ROLE, 'LABEL_ROLE', 'Verify package constant otap_util.CFG_LABEL_ROLE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE, 'LABEL_RULE', 'Verify package constant otap_util.CFG_LABEL_RULE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_RULE_SET, 'LABEL_RULE_SET', 'Verify package constant otap_util.CFG_LABEL_RULE_SET' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULE, 'LABEL_SCHEDULE', 'Verify package constant otap_util.CFG_LABEL_SCHEDULE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_GROUP, 'LABEL_SCHEDULER_GROUP', 'Verify package constant otap_util.CFG_LABEL_SCHEDULER_GROUP' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SCHEDULER_JOB, 'LABEL_SCHEDULER_JOB', 'Verify package constant otap_util.CFG_LABEL_SCHEDULER_JOB' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SEQUENCE, 'LABEL_SEQUENCE', 'Verify package constant otap_util.CFG_LABEL_SEQUENCE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING, 'LABEL_SUPPLEMENTAL_LOGGGING', 'Verify package constant otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_SYNONYM, 'LABEL_SYNONYM', 'Verify package constant otap_util.CFG_LABEL_SYNONYM' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE, 'LABEL_TABLE', 'Verify package constant otap_util.CFG_LABEL_TABLE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_PARTITION, 'LABEL_TABLE_PARTITION', 'Verify package constant otap_util.CFG_LABEL_TABLE_PARTITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TABLE_SUBPARTITION, 'LABEL_TABLE_SUBPARTITION', 'Verify package constant otap_util.CFG_LABEL_TABLE_SUBPARTITION' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TRIGGER, 'LABEL_TRIGGER', 'Verify package constant otap_util.CFG_LABEL_TRIGGER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE, 'LABEL_TYPE', 'Verify package constant otap_util.CFG_LABEL_TYPE' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_TYPE_BODY, 'LABEL_TYPE_BODY', 'Verify package constant otap_util.CFG_LABEL_TYPE_BODY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNDEFINED, 'LABEL_UNDEFINED', 'Verify package constant otap_util.CFG_LABEL_UNDEFINED' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIFIED_AUDIT_POLICY, 'LABEL_UNIFIED_AUDIT_POLICY', 'Verify package constant otap_util.CFG_LABEL_UNIFIED_AUDIT_POLICY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_UNIQUE_KEY, 'LABEL_UNIQUE_KEY', 'Verify package constant otap_util.CFG_LABEL_UNIQUE_KEY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_USER, 'LABEL_USER', 'Verify package constant otap_util.CFG_LABEL_USER' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VARCHAR2, 'LABEL_VARCHAR2', 'Verify package constant otap_util.CFG_LABEL_VARCHAR2' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW, 'LABEL_VIEW', 'Verify package constant otap_util.CFG_LABEL_VIEW' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_CHECK, 'LABEL_VIEW_CHECK', 'Verify package constant otap_util.CFG_LABEL_VIEW_CHECK' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_VIEW_READONLY, 'LABEL_VIEW_READONLY', 'Verify package constant otap_util.CFG_LABEL_VIEW_READONLY' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_WINDOW, 'LABEL_WINDOW', 'Verify package constant otap_util.CFG_LABEL_WINDOW' || l_ext);
  l_return := otap_test.is_eq(otap_util.CFG_LABEL_XML_SCHEMA, 'LABEL_XML_SCHEMA', 'Verify package constant otap_util.CFG_LABEL_XML_SCHEMA' || l_ext);
  -- check functionality is_number
  l_return := otap_test.ok(otap_util.is_number('1'), 'otap_util.is_number simple number' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_number('A')), 'otap_util.is_number simple char fails' || l_ext);
  l_return := otap_test.ok(p_boolean => otap_util.is_number('A'), p_description => 'otap_util.is_number simple char and expected result failed' || l_ext, p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.ok((NOT otap_util.is_number('-1-')), 'otap_util.is_number strange number -1- fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_number('-1*2+')), 'otap_util.is_number strange number -1*2+ fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_number('99999999999999999999999999999999999999999999999999')), 'otap_util.is_number too big number 99999999999999999999999999999999999999999999999999 fails' || l_ext);
  -- get correct current decimal points, thousands divider does not work with TO_NUMBER, without given format
  SELECT SUBSTR(value, 1, 1)
    INTO l_decimal
    FROM nls_session_parameters
   WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
  ;
  l_return := otap_test.ok(otap_util.is_number('1' || l_decimal || '234'), 'otap_util.is_number using current decimal point defined 1.234' || l_ext);
  l_return := otap_test.ok(otap_util.is_number(l_decimal || '234'), 'otap_util.is_number using leading current decimal point defined .234' || l_ext);
  -- this is something allowed in SQL with wrong results (decimals cut and zeroed) but not with PLSQL
  l_return := otap_test.ok((NOT otap_util.is_number('1e10')), 'otap_util.is_number scientific notation 1e10 fails' || l_ext);
  -- check functionality is_integer
  l_return := otap_test.ok(otap_util.is_integer('1'), 'otap_util.is_integer simple integer' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('A')), 'otap_util.is_integer simple char fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('1.0')), 'otap_util.is_integer decimal 1.0 fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('.045')), 'otap_util.is_integer decimal .045 fails' || l_ext);
  l_return := otap_test.ok(otap_util.is_integer('-1'), 'otap_util.is_integer simple negative integer' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('-1-')), 'otap_util.is_integer strange number -1- fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('-1*2+')), 'otap_util.is_integer strange number -1*2+ fails' || l_ext);
  l_return := otap_test.ok((NOT otap_util.is_integer('99999999999999999999999999999999999999999999999999')), 'otap_util.is_integer too big number 99999999999999999999999999999999999999999999999999 fails' || l_ext);
  -- check functionality validate_config_name
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'');', -20001, NULL, 'otap_util.validate_config_name invalid config name exception' || l_ext);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER, TRUE);', -20006, NULL, 'otap_util.validate_config_name delete config name exception' || l_ext);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(''Not valid'', TRUE);', -20006, NULL, 'otap_util.validate_config_name delete invalid config name no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  -- check that defined config names do not cause exceptions
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_constants.OTAP_CFG_DEBUG_MODE);', -20001, NULL, 'otap_util.validate_config_name debug mode no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_BORDER);', -20001, NULL, 'otap_util.validate_config_name default border no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LABEL_COLUMN);', -20001, NULL, 'otap_util.validate_config_name default label column no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LAYOUT);', -20001, NULL, 'otap_util.validate_config_name default layout no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_PREFIX);', -20001, NULL, 'otap_util.validate_config_name default prefix no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_RESULT_LAYOUT);', -20001, NULL, 'otap_util.validate_config_name default result layout no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_GROUP);', -20001, NULL, 'otap_util.validate_config_name default test group no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_NAME);', -20001, NULL, 'otap_util.validate_config_name default test name no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_TEST_SET);', -20001, NULL, 'otap_util.validate_config_name default test set no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DEFAULT_LANGUAGE);', -20001, NULL, 'otap_util.validate_config_name default language no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_BATCH_SIZE);', -20001, NULL, 'otap_util.validate_config_name delete batch size no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_DELETE_DELAY);', -20001, NULL, 'otap_util.validate_config_name delete delay no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_GROUP_CHAR);', -20001, NULL, 'otap_util.validate_config_name format group char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_HEADER_CHAR);', -20001, NULL, 'otap_util.validate_config_name format header char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_NAME_CHAR);', -20001, NULL, 'otap_util.validate_config_name format test name char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_FORMAT_SET_CHAR);', -20001, NULL, 'otap_util.validate_config_name format test set char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_PRESERVE_DAYS);', -20001, NULL, 'otap_util.validate_config_name preserve days no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_COUNT_DESC);', -20001, NULL, 'otap_util.validate_config_name template count description no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERRORS);', -20001, NULL, 'otap_util.validate_config_name template errors no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_ERROR_DETAILS);', -20001, NULL, 'otap_util.validate_config_name template error details no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS);', -20001, NULL, 'otap_util.validate_config_name template object exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTSX);', -20001, NULL, 'otap_util.validate_config_name extended template object exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_C);', -20001, NULL, 'otap_util.validate_config_name template constraints exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_CX);', -20001, NULL, 'otap_util.validate_config_name extended template constraint exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_F);', -20001, NULL, 'otap_util.validate_config_name template function exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_EXISTS_FX);', -20001, NULL, 'otap_util.validate_config_name extended template function exists no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_GROUP);', -20001, NULL, 'otap_util.validate_config_name template test group no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_MATCH);', -20001, NULL, 'otap_util.validate_config_name template match no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_NO_DATA);', -20001, NULL, 'otap_util.validate_config_name template no data no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_REPORT_TOTAL);', -20001, NULL, 'otap_util.validate_config_name template report total no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_RESULT_LINE);', -20001, NULL, 'otap_util.validate_config_name template result line no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SESSION_ID);', -20001, NULL, 'otap_util.validate_config_name template session id no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SET);', -20001, NULL, 'otap_util.validate_config_name template test set no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_SUMMARY);', -20001, NULL, 'otap_util.validate_config_name template summary no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEMPLATE_TEST_NAME);', -20001, NULL, 'otap_util.validate_config_name template test name no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE);', -20001, NULL, 'otap_util.validate_config_name config text false no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_FALSE_NO);', -20001, NULL, 'otap_util.validate_config_name config text false/no no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_END);', -20001, NULL, 'otap_util.validate_config_name config text report end no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_START);', -20001, NULL, 'otap_util.validate_config_name config text report start no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_REPORT_TOTAL);', -20001, NULL, 'otap_util.validate_config_name config text report total no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_HEADER);', -20001, NULL, 'otap_util.validate_config_name config text result header no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_RESULT_LINE);', -20001, NULL, 'otap_util.validate_config_name config text result line no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_FAILED);', -20001, NULL, 'otap_util.validate_config_name config text test failed no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_PASSED);', -20001, NULL, 'otap_util.validate_config_name config text test passed no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TEST_UNDEFINED);', -20001, NULL, 'otap_util.validate_config_name config text test undefined no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE);', -20001, NULL, 'otap_util.validate_config_name config text true no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_config_name(otap_util.CFG_TEXT_TRUE_YES);', -20001, NULL, 'otap_util.validate_config_name config text true/yes no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  -- reduced testing for validate_config_value, as used in trigger config_name must be valid for testing, as checked before
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, NULL, ''NUMBER'', l_translatable, NULL);', -20002, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value NULL exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''INTEGER'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''number'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type lower case number exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''1'', ''char'', l_translatable, NULL);', -20003, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value type lower case char exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''10'', ''NUMBER'', l_translatable, 1);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max defined length number exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''10'', ''CHAR'', l_translatable, 1);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max defined length char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, LPAD(''9'', 4001, ''9''), ''NUMBER'', l_translatable, NULL);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max length number exception' || l_ext);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, LPAD(''9'', 4001, ''9''), ''CHAR'', l_translatable, NULL);', -20004, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value max length char no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('l_config_value := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, ''A'', ''NUMBER'', l_translatable, NULL);', -20005, 'l_translatable NUMBER := 0; l_config_value VARCHAR2(4000);', 'otap_util.validate_config_value config value not a number exception' || l_ext);
  l_translatable := 9;
  l_stamp        := SYSTIMESTAMP;
  l_return       := otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '0', 'NUMBER', l_translatable, NULL);
  l_finish       := SYSTIMESTAMP;
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value default value on invalid translatable' || l_ext);
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable' || l_ext)
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
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default prefix' || l_ext);
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default prefix' || l_ext)
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
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default layout' || l_ext);
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default layout' || l_ext)
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
  l_return       := otap_test.is_eq(l_translatable, otap_constants.OTAP_NUM_FALSE, 'otap_util.validate_config_value invalid translatable default result layout' || l_ext);
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid translatable default result layout' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid config_name: ' || otap_util.CFG_DEFAULT_RESULT_LAYOUT || ' for TRANSLATABLE:%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '0', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid min value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days min value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 0%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '8', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid max value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days max value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 8%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_PRESERVE_DAYS, '1.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS)), 'otap_util.validate_config_value default preserve days invalid decimal value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid preserve days decimal value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for PRESERVE_DAYS: 1.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '0', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid min value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay min value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 0%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '601', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid max value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay max value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 601%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_DELAY, '100.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY)), 'otap_util.validate_config_value default delete delay invalid decimal value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete delay decimal value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_DELAY: 100.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '10', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid min value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size min value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 10%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '10001', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid max value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size max value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 10001%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DELETE_BATCH_SIZE, '100.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE)), 'otap_util.validate_config_value default delete batch size invalid decimal value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid delete batch size decimal value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DELETE_BATCH_SIZE: 100.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '1', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid min value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size min value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 1%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '11', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid max value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size max value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 11%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_BORDER, '5.5', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER)), 'otap_util.validate_config_value default border size invalid decimal value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid border size decimal value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_BORDER: 5.5%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_constants.OTAP_CFG_DEBUG_MODE, '3', 'NUMBER', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_NUM_FALSE)), 'otap_util.validate_config_value default debug invalid value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid debug value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEBUG_MODE: 3%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_LAYOUT, 'X', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_LAYOUT_MIDDLE)), 'otap_util.validate_config_value default layout invalid value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid layout value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_LAYOUT: X%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_RESULT_LAYOUT, 'M', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT)), 'otap_util.validate_config_value default result layout invalid value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid result layout value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_RESULT_LAYOUT: M%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.validate_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN, 'X', 'CHAR', l_translatable, NULL), TRIM(TO_CHAR(otap_constants.OTAP_LABEL_LOWER)), 'otap_util.validate_config_value default label layout invalid value' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.validate_config_value log entry invalid label layout value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.validate_config_value'
     AND message            LIKE 'Invalid value for DEFAULT_LABEL_LAYOUT: X%'
  ;
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_constants.OTAP_CFG_DEBUG_MODE);', -20020, NULL, 'otap_util.validate_translatable config value not translatable exception' || l_ext);
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_util.CFG_DEFAULT_TEST_SET);', -20020, NULL, 'otap_util.validate_translatable config value translatable no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.throws_ok('otap_util.validate_translatable(otap_util.CFG_LABEL_BOOLEAN);', -20020, NULL, 'otap_util.validate_translatable label value translatable no exception' || l_ext, otap_constants.OTAP_NUM_TEST_FAILED);
  l_return := otap_test.is_eq(otap_util.get_config_value('Not exists'), 'OTAP_ERROR', 'otap_util.get_config_value get invalid config value as text' || l_ext);
  l_return := otap_test.ok((otap_util.get_config_number('Debuck_mode') IS NULL), 'otap_util.get_config_number get invalid config value as number' || l_ext);
  l_return := otap_test.is_eq(otap_util.get_label_id('BOOLEAN'), otap_util.CFG_LABEL_BOOLEAN, 'otap_util.get_label_id BOOLEAN' || l_ext);
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.get_label_id('BOOLEAN OHH MY GOD'), otap_util.CFG_LABEL_UNDEFINED, 'otap_util.get_label_id not existing BOOLEAN OHH MY GOD' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.get_label_id log entry invalid label value' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.get_label_id'
     AND message            LIKE 'Invalid object type: BOOLEAN OHH MY GOD%'
  ;
  SELECT otap_test.is_eq(otap_util.get_length_test_state, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_test_state' || l_ext)
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_TEST_UNDEFINED
                            , otap_util.CFG_TEXT_TEST_PASSED
                            , otap_util.CFG_TEXT_TEST_FAILED
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  SELECT otap_test.is_eq(otap_util.get_length_headers, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_headers' || l_ext)
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_REPORT_START
                            , otap_util.CFG_TEXT_REPORT_END
                            , otap_util.CFG_TEXT_REPORT_TOTAL
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  SELECT otap_test.is_eq(otap_util.get_length_result_headers, MAX(LENGTH(label_text_lower)), 'otap_util.get_length_result_headers' || l_ext)
    INTO l_return
    FROM otap_identifiers_v
   WHERE otap_identifier IN ( otap_util.CFG_TEXT_RESULT_HEADER
                            , otap_util.CFG_TEXT_RESULT_LINE
                            )
     AND language_id      = otap_constants.OTAP_INTERNAL_NA
  ;
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_PASSED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED), 'otap_util.test_result_to_text passed' || l_ext);
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_FAILED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_FAILED), 'otap_util.test_result_to_text failed' || l_ext);
  l_return := otap_test.is_eq(otap_util.test_result_to_text(otap_constants.OTAP_NUM_TEST_UNDEFINED), otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED), 'otap_util.test_result_to_text undefined' || l_ext);
  l_return := otap_test.is_eq(otap_util.test_result_to_text(99), otap_constants.OTAP_INTERNAL_ERROR, 'otap_util.test_result_to_text wrong test result number' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label, otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label default check' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('C'), otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label parameter C check' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('c'), otap_util.CFG_LABEL_CHECK, 'otap_util.constraint_type_to_label lower parameter c check' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('P'), otap_util.CFG_LABEL_PRIMARY_KEY, 'otap_util.constraint_type_to_label parameter P primary key' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('U'), otap_util.CFG_LABEL_UNIQUE_KEY, 'otap_util.constraint_type_to_label parameter U unique key' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('R'), otap_util.CFG_LABEL_FOREIGN_KEY, 'otap_util.constraint_type_to_label parameter R foreign key' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('V'), otap_util.CFG_LABEL_VIEW_CHECK, 'otap_util.constraint_type_to_label parameter V view check' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('O'), otap_util.CFG_LABEL_VIEW_READONLY, 'otap_util.constraint_type_to_label parameter O view readonly' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('F'), otap_util.CFG_LABEL_REF_COLUMN, 'otap_util.constraint_type_to_label parameter F ref column' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('H'), otap_util.CFG_LABEL_HASH, 'otap_util.constraint_type_to_label parameter H hash' || l_ext);
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('S'), otap_util.CFG_LABEL_SUPPLEMENTAL_LOGGGING, 'otap_util.constraint_type_to_label parameter S supplemental logging' || l_ext);
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.constraint_type_to_label('X'), otap_util.CFG_LABEL_INVALID_CONSTRAINT_TYPE, 'otap_util.constraint_type_to_label parameter X invalid' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.constraint_type_to_label log entry invalid parameter' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.constraint_type_to_label'
     AND message            LIKE 'Invalid constraint type: X%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => NULL, p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule missing template' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.build_msg description no log entry missing template identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%missing%template identifier%'
  ;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS, p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule given template' || l_ext);
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS, p_description => '  '), otap_util.get_config_value(otap_util.CFG_TEMPLATE_EXISTS), 'otap_util.build_msg empty description with spaces ignored' || l_ext);
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => NULL, p_description => ' '), 'OTAP_ERROR otap_util.build_msg missing description and template identifier', 'otap_util.build_msg empty description and template' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg description log entry missing description and template identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%missing%description%template identifier%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(p_cfg_template => 'I DO NOT EXIST', p_description => 'Individual message'), 'Individual message', 'otap_util.build_msg description overrule invalid template' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 0, 'otap_util.build_msg description no log entry invalid template identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%invalid template identifier%'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(NULL), otap_constants.OTAP_INTERNAL_ERROR || ' otap_util.build_msg missing description and template identifier', 'otap_util.build_msg missing template' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry missing template identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%otap_util.build_msg missing description and template identifier'
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg('I DO NOT EXIST'), otap_constants.OTAP_INTERNAL_ERROR || ' otap_util.build_msg invalid template identifier I DO NOT EXIST', 'otap_util.build_msg invalid template' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry invalid template identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE '%otap_util.build_msg invalid template identifier I DO NOT EXIST'
  ;
  l_return := otap_test.is_eq(otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS), '@type@ @object@ exists check (@schema@)', 'otap_util.build_msg template no parameter' || l_ext);
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN)
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template only type parameter' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq(otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, 'Type invalid'), '@type@ @object@ exists check (@schema@)', 'otap_util.build_msg template invalid type parameter' || l_ext);
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry invalid type identifier' || l_ext)
    INTO l_return
    FROM sperrorlog
   WHERE timestamp            >= l_stamp
     AND timestamp            <= l_finish
     AND TRIM(TO_CHAR(script)) = 'otap_util.build_msg'
     AND message            LIKE 'Type ignored, Invalid label used: Type invalid%'
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template no value for first variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@object@', 'My fanCY obJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@OBJECT@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, '@@', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, empty variable' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg(otap_util.CFG_TEMPLATE_EXISTS, otap_util.CFG_LABEL_COLUMN, 'object', 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template first variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no first variable identifier' || l_ext)
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
                             , 'otap_util.build_msg template first variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong first variable identifier count' || l_ext)
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
                             , 'otap_util.build_msg template first value without variable' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry first value without variable' || l_ext)
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
                             , 'otap_util.build_msg template no value for second variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@object@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@object@'
                                                  , p_param2_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@OBJECT@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => '@@'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, empty variable' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param2 => 'object'
                                                  , p_param2_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template second variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no second variable identifier' || l_ext)
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
                             , 'otap_util.build_msg template second variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong second variable identifier count' || l_ext)
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
                             , 'otap_util.build_msg template second value without variable' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry second value without variable' || l_ext)
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
                             , 'otap_util.build_msg template no value for third variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@object@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@object@'
                                                  , p_param3_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@OBJECT@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => '@@'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, empty variable' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param3 => 'object'
                                                  , p_param3_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template third variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no third variable identifier' || l_ext)
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
                             , 'otap_util.build_msg template third variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong third variable identifier count' || l_ext)
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
                             , 'otap_util.build_msg template third value without variable' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry third value without variable' || l_ext)
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
                             , 'otap_util.build_msg template no value for fourth variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@object@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@object@'
                                                  , p_param4_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@OBJECT@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => '@@'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, empty variable' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param4 => 'object'
                                                  , p_param4_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fourth variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no fourth variable identifier' || l_ext)
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
                             , 'otap_util.build_msg template fourth variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong fourth variable identifier count' || l_ext)
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
                             , 'otap_util.build_msg template fourth value without variable' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry fourth value without variable' || l_ext)
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
                             , 'otap_util.build_msg template no value for fifth variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@object@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@object@'
                                                  , p_param5_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@OBJECT@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => '@@'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, empty variable' || l_ext
                             )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param5 => 'object'
                                                  , p_param5_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template fifth variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry no fifth variable identifier' || l_ext)
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
                             , 'otap_util.build_msg template fifth variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry wrong fifth variable identifier count' || l_ext)
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
                             , 'otap_util.build_msg template fifth value without variable' || l_ext
                             )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.build_msg log entry fifth value without variable' || l_ext)
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
                             , 'otap_util.build_msg template no value blank out for sixth variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@object@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' MY_OBJECT exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@object@'
                                                  , p_param6n_value => 'My fanCY obJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' My fanCY obJECT exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair value any case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@OBJECT@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, wrong variable case' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@@'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, empty variable' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => 'object'
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, no variable identifier' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n => '@@object@@'
                                                  , p_param6n_value => 'MY_OBJECT')
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth variable/value pair, wrong variable identifier count' || l_ext
                             )
  ;
  l_return := otap_test.is_eq( otap_util.build_msg( p_cfg_template => otap_util.CFG_TEMPLATE_EXISTS
                                                  , p_type_label => otap_util.CFG_LABEL_COLUMN
                                                  , p_param6n_value => 'MY_OBJECT'
                                                  )
                             , otap_util.get_config_value(otap_util.CFG_LABEL_COLUMN) || ' @object@ exists check (@schema@)'
                             , 'otap_util.build_msg template sixth value without variable' || l_ext
                             )
  ;
  -- use a negative session id for test writes
  l_testing_id := otap_test.get_session_id * -1;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test set' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, NULL, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception db user' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, NULL, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception db schema' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, NULL, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test group' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, NULL, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test start' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, NULL, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test end' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, NULL, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test name' || l_ext
                                     )
  ;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(1, 1, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, NULL);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record NULL exception test description' || l_ext
                                     )
  ;
  l_stamp  := SYSTIMESTAMP;
  l_return     := otap_test.throws_ok('otap_util.write_test_result(otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_TEST_PASSED, ' || l_testing_id || ', NULL, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET, USER, USER, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP, SYSTIMESTAMP, SYSTIMESTAMP, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME, otap_constants.OTAP_INTERNAL_NA);'
                                     , -1400
                                     , NULL
                                     , 'otap_util.write_test_result basic record no exception test' || l_ext
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written' || l_ext)
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
                                     , 'otap_util.write_test_result basic record no exception wrong to_delete' || l_ext
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written wrong to_delete' || l_ext)
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
                                     , 'otap_util.write_test_result basic record no exception wrong test_passed' || l_ext
                                     , p_expected_result => otap_constants.OTAP_NUM_TEST_FAILED
                                     )
  ;
  l_finish := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'otap_util.write_test_result record written wrong test_passed' || l_ext)
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
  l_return := otap_test.is_eq(otap_util.max_text_size(l_testing_id), 80, 'otap_util.max_text_size expected max length' || l_ext);
  SELECT otap_test.is_eq(LENGTH(TRIM((SYSTIMESTAMP - SYSTIMESTAMP) DAY TO SECOND)), otap_util.interval_size, 'otap_util.interval_size expected length' || l_ext)
    INTO l_return
    FROM dual
  ;
  -- check layout configuration
  l_value := otap_util.get_config_value(otap_util.CFG_DEFAULT_LABEL_COLUMN);
  l_comp  := CASE
               WHEN l_value = otap_constants.OTAP_LABEL_LOWER
               THEN 'boolean'
               WHEN l_value = otap_constants.OTAP_LABEL_UPPER
               THEN 'BOOLEAN'
               WHEN l_value = otap_constants.OTAP_LABEL_INIT_CAP
               THEN 'Boolean'
             END
  ;
  l_return := otap_test.is_eq(otap_util.get_config_value(otap_util.CFG_LABEL_BOOLEAN), l_comp, 'otap_util.get_config_value label boolean as text format ' || l_ext);
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_UTIL failed', 'otap_util.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_UTIL failed', SQLERRM);
END;
/