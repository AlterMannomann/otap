-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- inserts default values for OTAP_CONFIG
-- create base entries
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('PRESERVE_DAYS', '1', 'NUMBER', 1, 'The number of days otap will keep test result records. Maximum is 7 days, minimum 1 day. Default is 1.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DELETE_DELAY', '10', 'NUMBER', 3, 'The seconds to wait between batch size delete commits to give other applications and requests room to execute. Maximum is 600, minimum is 1. Default is 10.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DELETE_BATCH_SIZE', '1000', 'NUMBER', 5, 'The records to delete before commit. Maximum is 10000, minimum is 100. Default is 1000.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEBUG_MODE', '0', 'NUMBER', 1, 'Enables debugging on demand, logged in SPERRORLOG. Either 0 (disable) or 1 (enabled). Default is 0.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_PREFIX', 'TEST', 'CHAR', 4, 'The default prefix without any _ delimiter, to identify test procedures for OTAP. Limited to 4 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('DEFAULT_TEST_SET', 'OTAP test set', 'CHAR', 256, 1, 'The default name for a test set if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('DEFAULT_TEST_GROUP', 'OTAP test group', 'CHAR', 256, 1, 'The default name for a test group if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('DEFAULT_TEST_NAME', 'OTAP test name', 'CHAR', 256, 1, 'The default name for a test name if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_LAYOUT', 'M', 'CHAR', 1, 'Defines the layout orientation in reports. Default M (middle), R (right), L (left) see OTAP_CONSTANTS. Wrong values lead to otap_constants.OTAP_LAYOUT_DEFAULT as default.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_RESULT_LAYOUT', 'L', 'CHAR', 1, 'Defines the result layout orientation in reports. Default L (left) or R (right), middle not supported, see OTAP_CONSTANTS. Wrong values lead to otap_constants.OTAP_LAYOUT_DEFAULT as default.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_BORDER', '5', 'NUMBER', 2, 'Defines the default minimum border chars to use for decorating report lines. Only values between 2 and 10 supported. Wrong values lead to otap_constants.OTAP_FALLBACK_BORDER as default.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('FORMAT_HEADER_CHAR', '=', 'CHAR', 1, 1, 'Used to format the report header line. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('FORMAT_SET_CHAR', '*', 'CHAR', 1, 1, 'Used to separate the report set information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('FORMAT_GROUP_CHAR', '+', 'CHAR', 1, 1, 'Used to separate the report group information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('FORMAT_NAME_CHAR', '-', 'CHAR', 1, 1, 'Used to separate the report test name information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TRUE', 'true', 'CHAR', 20, 1, 'Used as text representation for the boolean/numerical value for TRUE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_FALSE', 'false', 'CHAR', 20, 1, 'Used as text representation for the boolean/numerical value for FALSE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TRUE_YES', 'Yes', 'CHAR', 20, 1, 'Used as text representation for the boolean/numerical value for TRUE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_FALSE_NO', 'No', 'CHAR', 20, 1, 'Used as text representation for the boolean/numerical value for FALSE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TEST_PASSED', 'Passed', 'CHAR', 50, 1, 'Used as text representation for tests executed successfully. If you change the length, you need to adapt also TEXT_RESULT_HEADER and TEXT_RESULT_LINE. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TEST_FAILED', 'FAILED', 'CHAR', 50, 1, 'Used as text representation for tests executed with errors. If you change the length, you need to adapt also TEXT_RESULT_HEADER and TEXT_RESULT_LINE. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TEST_UNDEFINED', 'UNDEFINED', 'CHAR', 50, 1, 'Used as text representation for tests with undefined state, e.g. due to setup errors. If you change the length, you need to adapt also TEXT_RESULT_HEADER and TEXT_RESULT_LINE. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_REPORT_START', 'OTAP test summary report', 'CHAR', 256, 1, 'Used as report title. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_REPORT_TOTAL', 'OTAP test report totals', 'CHAR', 256, 1, 'Used as report title. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_REPORT_END', 'OTAP test summary report finished', 'CHAR', 256, 1, 'Used as report footer. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_RESULT_HEADER', 'Result    Setup     Runtime             Test', 'CHAR', 256, 1, 'Used as result header, depending on formatting and size of test passed, setup passed and runtime. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_RESULT_LINE', '--------- --------- ------------------- ----------------------------------------', 'CHAR', 256, 1, 'Used as result header underlining, depending on formatting and size of test passed, setup passed and runtime. Limited to 256 chars, recommended equal or shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TEST_COUNT_HEADER', 'Test count summary', 'CHAR', 256, 1, 'Used in templates as information text if a set, group or test name has executed without errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_TEST_COUNT_NAME', 'Session test count', 'CHAR', 256, 1, 'Used in templates as information text if a set, group or test name has executed without errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_SUMMARY_SUCCESS', 'SUCCESS', 'CHAR', 256, 1, 'Used in templates as information text if a set, group or test name has executed without errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEXT_SUMMARY_ERROR', 'ERROR', 'CHAR', 256, 1, 'Used in templates as information text if a set, group or test name has executed with errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @status@ represents SNIPPET_SUMMARY_ERROR or SNIPPET_SUMMARY_SUCCESS
-- @runtime@ represents the runtime as Oracle interval
-- @runs@ represent the amount of tests executed for the set, group or test name
-- @errors@ represent the amount of tests with errors for the set, group or test name
-- @issues@ represent the amount of test setup or internal errors for the set, group or test name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_SUMMARY', '@status@ runtime: @runtime@ (runs: @runs@ errors: @errors@ issues: @issues@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testname@ represents the test name for the summary of errors under this test name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_ERRORS', '@testname@ error details', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testdesc@ represents the test description for the test in error
-- @error_info@ represents the error information for the specific test description
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_ERROR_DETAILS', '@testdesc@: @errorinfo@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @sessionid@ represents the current session id used to filter test results
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_NO_DATA', 'NO_DATA - no tests found for test session id @sessionid@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_SESSION_ID', 'Session id: @sessionid@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testset@ represents the name of the current test set
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_SET', 'Test set: @testset@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testgroup@ represents the name of the current test group
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_GROUP', 'Test group: @testgroup@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testname@ represents the name of the current test
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_TEST_NAME', 'Test name: @testname@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @teststate@ represents the text representation of test passed, failed or undefined
-- @issuestate@ represents the text representation of otap issues, equal to test state
-- @runtime@ represents the runtime as Oracle interval
-- @testdesc@ represents the test description of the test
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_RESULT_LINE', '@teststate@ @issuestate@ @runtime@ @testdesc@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testsrun@ represents the executed tests
-- @testsexpected@ represents the expected tests
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_COUNT_DESC', '@testsrun@ from @testsexpected@ tests executed', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @sets@ represents the executed test sets
-- @groups@ represents the executed test groups
-- @names@ represents the executed test names
-- @descs@ represents the executed tests by discription (can differ from runs on equal descriptions)
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_REPORT_TOTAL', 'sets: @sets@ groups: @groups@ names: @names@ descriptions: @descs@', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @schema@ represents the schema of the table
-- @tablename@ represents the table name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_FN_HAS_TABLE', 'Table @schema@.@tablename@ exists', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @schema@ represents the schema of the table
-- @tablename@ represents the table name
-- @column@ represents the column name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_FN_HAS_COLUMN', 'Column @column@ (@schema@.@tablename@) exists', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @schema@ represents the schema of the package
-- @package@ represents the package name
-- @packagetype@ represents the package type, e.g. PACKAGE or PACKAGE BODY
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_FN_HAS_PACKAGE', 'Package @schema@.@package@ exists (@packagetype@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @type@ represents the procedure type FUNCTION or PROCEDURE
-- @proc@ represents the procedure name including a package prefix if given
-- @schema@ represents the schema of the procedure or function
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_FN_HAS_PROCEDURE', '@proctype@ @proc@ exists (@schema@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @trigger@ represents the trigger name
-- @schema@ represents the schema of the procedure or function
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_FN_HAS_TRIGGER', 'Trigger @trigger@ exists (@schema@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- generic exists template
-- @type@ represents the object type as defined in the database, see ALL_OBJECTS object_type.
-- @object@ represents the simple object name, package functions and procedures use GENERIC_SUB_TEMPLATE_EXISTS
-- @schema@ represents the schema of the object
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_EXISTS', '@type@ @object@ exists check (@schema@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- extended exists template
-- @type@ represents the object type as defined in the database, see ALL_OBJECTS object_type.
-- @object@ represents the leading object name like package or table name
-- @subobject@ represents the related subobject name like column or package function or procedure name
-- @schema@ represents the schema of the object
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, translatable, config_description)
  VALUES
  ('TEMPLATE_XEXISTS', '@type@ @object@.@subobject@ exists check (@schema@)', 'CHAR', 256, 1, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- LABEL_COLUMN, rest can be received from DBA_OBJECTS or other DBA views
-- rework API reduce sections to the max, like write and add, errorhandling (template?)
COMMIT;