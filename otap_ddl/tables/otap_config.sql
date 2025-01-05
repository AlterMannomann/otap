-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct schema, using CHAR for different language support
-- table is NOT qualified and created in the schema active at execution, columns ordered by access and then space consumption
CREATE TABLE otap_config
  ( config_name         VARCHAR2(128 CHAR)                                             NOT NULL
  , config_value        VARCHAR2(4000 CHAR)                                            NOT NULL
  , config_max_length   NUMBER               DEFAULT -1                                NOT NULL
  , config_type         VARCHAR2(6 CHAR)     DEFAULT 'CHAR'                            NOT NULL
  , created             DATE                 DEFAULT SYSDATE                           NOT NULL
  , updated             DATE                 DEFAULT SYSDATE                           NOT NULL
  , created_by          VARCHAR2(256 CHAR)   DEFAULT USER                              NOT NULL
  , created_by_os       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , updated_by          VARCHAR2(256 CHAR)   DEFAULT USER                              NOT NULL
  , updated_by_os       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , config_description  VARCHAR2(4000 CHAR)
  )
;
-- description
COMMENT ON TABLE otap_config IS 'Holds the configuration used by otap. Will use the alias ocfg.';
COMMENT ON COLUMN otap_config.config_name IS 'The unique case sensitive name of the otap configuration object.';
COMMENT ON COLUMN otap_config.config_value IS 'The configuration value always as VARCHAR2. Type handling and conversion must be done by the caller.';
COMMENT ON COLUMN otap_config.config_type IS 'Defines how the config value has to be interpreted. Currently supports CHAR and NUMBER.';
COMMENT ON COLUMN otap_config.config_max_length IS 'Defines a maximum length for CHAR type config values if set to a number > 0. Default is -1, do not not check length.';
COMMENT ON COLUMN otap_config.config_description IS 'Optional description of the otap config object.';
COMMENT ON COLUMN otap_config.created IS 'Date created, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated IS 'Date updated, managed by default and trigger.';
COMMENT ON COLUMN otap_config.created_by IS 'DB user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.created_by_os IS 'OS user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated_by IS 'DB user who updated the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated_by_os IS 'OS user who updated the record, managed by default and trigger.';

-- primary key
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_pk
  PRIMARY KEY (config_name)
  ENABLE
;
-- constraints
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_chk_type
  CHECK (config_type IN ('CHAR', 'NUMBER'))
;
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_chk_max_length
  CHECK (config_max_length = -1 OR config_max_length > 0)
;

-- trigger
CREATE OR REPLACE TRIGGER otap_config_ins_trg
  BEFORE INSERT ON otap_config
  FOR EACH ROW
DECLARE
  l_ok                BOOLEAN;
BEGIN
  -- only allow defined configuration names
  IF :NEW.config_name NOT IN ( 'PRESERVE_DAYS'
                             , 'DELETE_DELAY'
                             , 'DELETE_BATCH_SIZE'
                             , 'DEBUG_MODE'
                             , 'FORMAT_HEADER_CHAR'
                             , 'FORMAT_SET_CHAR'
                             , 'FORMAT_GROUP_CHAR'
                             , 'FORMAT_NAME_CHAR'
                             , 'TEXT_TRUE'
                             , 'TEXT_FALSE'
                             , 'TEXT_TRUE_YES'
                             , 'TEXT_FALSE_NO'
                             , 'TEXT_TEST_PASSED'
                             , 'TEXT_TEST_FAILED'
                             , 'TEXT_TEST_UNDEFINED'
                             , 'DEFAULT_PREFIX'
                             , 'DEFAULT_TEST_SET'
                             , 'DEFAULT_TEST_GROUP'
                             , 'DEFAULT_TEST_NAME'
                             , 'DEFAULT_LAYOUT'
                             , 'DEFAULT_RESULT_LAYOUT'
                             , 'DEFAULT_BORDER'
                             , 'TEXT_REPORT_START'
                             , 'TEXT_REPORT_END'
                             , 'TEXT_RESULT_HEADER'
                             , 'FORMAT_RESULT_HEADER'
                             , 'TEXT_SUMMARY_SUCCESS'
                             , 'TEXT_SUMMARY_ERROR'
                             , 'SUMMARY_TEMPLATE'
                             , 'ERRORS_TEMPLATE'
                             , 'ERROR_DETAILS_TEMPLATE'
                             , 'NO_DATA_TEMPLATE'
                             , 'SESSION_ID_TEMPLATE'
                             , 'SET_TEMPLATE'
                             , 'GROUP_TEMPLATE'
                             , 'TEST_NAME_TEMPLATE'
                             , 'RESULT_LINE_TEMPLATE'
                             , 'FN_HAS_TABLE_TEMPLATE'
                             )
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'The configuration name ' || :NEW.config_name || ' is not supported.');
  END IF;
  -- remove any leading and trailing blanks from config_value
  :NEW.config_value   := TRIM(:NEW.config_value);
  -- check empty strings contained only spaces
  IF :NEW.config_value IS NULL OR LENGTH(:NEW.config_value) = 0
  THEN
    RAISE_APPLICATION_ERROR(-20002, 'The given config_value is not supported. Empty or only spaces.');
  END IF;
  :NEW.created        := SYSDATE;
  :NEW.created_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.created_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
  -- check max length if defined
  IF :NEW.config_type = 'CHAR'
  THEN
    IF :NEW.config_max_length > 0
    THEN
      IF LENGTH(:NEW.config_value) > :NEW.config_max_length
      THEN
        RAISE_APPLICATION_ERROR(-20003, 'The config_value exceeds the defined config_max_length. Current length: ' || LENGTH(:NEW.config_value));
      END IF;
    END IF;
  END IF;
  -- check number type
  IF :NEW.config_type = 'NUMBER'
  THEN
    l_ok := TRUE;
    -- compare TO_NUMBER with implicite conversion, if it fails the config_value cannot be interpreted correctly
    BEGIN
      l_ok := (TO_NUMBER(:NEW.config_value) = :NEW.config_value);
    EXCEPTION
      WHEN OTHERS THEN
        l_ok := FALSE;
    END;
    IF NOT l_ok
    THEN
      RAISE_APPLICATION_ERROR(-20004, 'The given config_value "' || NVL(:NEW.config_value, 'NULL') || '" could not be converted successfully to a number.');
    END IF;
  END IF;
  -- handle NULLs
  IF :NEW.config_name = 'PRESERVE_DAYS'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, TO_CHAR(otap_constants.OTAP_PRESERVE_DAYS));
  END IF;
  IF :NEW.config_name = 'DELETE_DELAY'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, TO_CHAR(otap_constants.OTAP_DELETE_DELAY));
  END IF;
  IF :NEW.config_name = 'DELETE_BATCH_SIZE'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, TO_CHAR(otap_constants.OTAP_DELETE_BATCH_SIZE));
  END IF;
  IF :NEW.config_name = 'DEBUG_MODE'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, TO_CHAR(otap_constants.OTAP_DEBUG_MODE));
  END IF;
  -- check layout options
  IF     :NEW.config_name = 'DEFAULT_LAYOUT'
     AND :NEW.config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_RIGHT)
  THEN
    :NEW.config_value := otap_constants.OTAP_LAYOUT_MIDDLE;
  END IF;
  IF     :NEW.config_name = 'DEFAULT_RESULT_LAYOUT'
     AND :NEW.config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_RIGHT)
  THEN
    :NEW.config_value := otap_constants.OTAP_LAYOUT_LEFT;
  END IF;
  -- check border options
  IF     :NEW.config_name = 'DEFAULT_BORDER'
     AND (   TO_NUMBER(:NEW.config_value) < 2
          OR TO_NUMBER(:NEW.config_value) > 10
         )
  THEN
    :NEW.config_value := otap_constants.OTAP_BORDER_DEFAULT;
  END IF;
END;
/
CREATE OR REPLACE TRIGGER otap_config_upd_trg
  BEFORE UPDATE ON otap_config
  FOR EACH ROW
DECLARE
  l_ok                BOOLEAN;
BEGIN
  -- only allow defined configuration names
  IF :NEW.config_name NOT IN ( 'PRESERVE_DAYS'
                             , 'DELETE_DELAY'
                             , 'DELETE_BATCH_SIZE'
                             , 'DEBUG_MODE'
                             , 'FORMAT_HEADER_CHAR'
                             , 'FORMAT_SET_CHAR'
                             , 'FORMAT_GROUP_CHAR'
                             , 'FORMAT_NAME_CHAR'
                             , 'TEXT_TRUE'
                             , 'TEXT_FALSE'
                             , 'TEXT_TRUE_YES'
                             , 'TEXT_FALSE_NO'
                             , 'TEXT_TEST_PASSED'
                             , 'TEXT_TEST_FAILED'
                             , 'TEXT_TEST_UNDEFINED'
                             , 'DEFAULT_PREFIX'
                             , 'DEFAULT_TEST_SET'
                             , 'DEFAULT_TEST_GROUP'
                             , 'DEFAULT_TEST_NAME'
                             , 'DEFAULT_LAYOUT'
                             , 'DEFAULT_RESULT_LAYOUT'
                             , 'DEFAULT_BORDER'
                             , 'TEXT_REPORT_START'
                             , 'TEXT_REPORT_END'
                             , 'TEXT_RESULT_HEADER'
                             , 'FORMAT_RESULT_HEADER'
                             , 'TEXT_SUMMARY_SUCCESS'
                             , 'TEXT_SUMMARY_ERROR'
                             , 'SUMMARY_TEMPLATE'
                             , 'ERRORS_TEMPLATE'
                             , 'ERROR_DETAILS_TEMPLATE'
                             , 'NO_DATA_TEMPLATE'
                             , 'SESSION_ID_TEMPLATE'
                             , 'SET_TEMPLATE'
                             , 'GROUP_TEMPLATE'
                             , 'TEST_NAME_TEMPLATE'
                             , 'RESULT_LINE_TEMPLATE'
                             , 'FN_HAS_TABLE_TEMPLATE'
                             )
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'The configuration name ' || :NEW.config_name || ' is not supported.');
  END IF;
  -- remove any leading and trailing blanks from config_value, do not accept NULLS, overwrite with OLD in this case
  :NEW.config_value := NVL(TRIM(:NEW.config_value), :OLD.config_value);
  -- ensure some values are not overwritten
  :NEW.created        := :OLD.created;
  :NEW.created_by     := :OLD.created_by;
  :NEW.created_by_os  := :OLD.created_by_os;
  -- check max length if defined
  IF :NEW.config_type = 'CHAR'
  THEN
    IF :NEW.config_max_length > 0
    THEN
      IF LENGTH(:NEW.config_value) > :NEW.config_max_length
      THEN
        RAISE_APPLICATION_ERROR(-20003, 'The config_value exceeds the defined config_max_length. Current length: ' || LENGTH(:NEW.config_value));
      END IF;
    END IF;
  END IF;
  -- check number type
  IF :NEW.config_type = 'NUMBER'
  THEN
    l_ok := TRUE;
    -- compare TO_NUMBER with implicite conversion, if it fails the config_value cannot be interpreted correctly
    BEGIN
      l_ok := (TO_NUMBER(:NEW.config_value) = :NEW.config_value);
    EXCEPTION
      WHEN OTHERS THEN
        l_ok := FALSE;
    END;
    IF NOT l_ok
    THEN
      RAISE_APPLICATION_ERROR(-20004, 'The given config_value "' || NVL(:NEW.config_value, 'NULL') || '" could not be converted successfully to a number.');
    END IF;
  END IF;
  -- check range if value changed
  IF :NEW.config_value != :OLD.config_value
  THEN
    IF :NEW.config_name = 'PRESERVE_DAYS'
    THEN
      IF    TO_NUMBER(:NEW.config_value) > 7
         OR TO_NUMBER(:NEW.config_value) < 1
      THEN
        :NEW.config_value := '1';
      END IF;
    END IF;
    IF :NEW.config_name = 'DELETE_DELAY'
    THEN
      IF    TO_NUMBER(:NEW.config_value) > 600
         OR TO_NUMBER(:NEW.config_value) < 1
      THEN
        :NEW.config_value := '10';
      END IF;
    END IF;
    IF :NEW.config_name = 'DELETE_BATCH_SIZE'
    THEN
      IF    TO_NUMBER(:NEW.config_value) > 10000
         OR TO_NUMBER(:NEW.config_value) < 100
      THEN
        :NEW.config_value := '1000';
      END IF;
    END IF;
    IF :NEW.config_name = 'DEBUG_MODE'
    THEN
      IF TO_NUMBER(:NEW.config_value) NOT IN (0, 1)
      THEN
        :NEW.config_value := '0';
      END IF;
    END IF;
    IF :NEW.config_name = 'DEFAULT_PREFIX'
    THEN
      IF INSTR(:NEW.config_value, '_') > 0
      THEN
        -- do not change if prefix contains invalid char
        :NEW.config_value := :OLD.config_value;
      END IF;
    END IF;
    -- check layout options
    IF    :NEW.config_name = 'DEFAULT_LAYOUT'
      AND :NEW.config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_RIGHT)
    THEN
      :NEW.config_value := otap_constants.OTAP_LAYOUT_MIDDLE;
    END IF;
    IF     :NEW.config_name = 'DEFAULT_RESULT_LAYOUT'
       AND :NEW.config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_RIGHT)
    THEN
      :NEW.config_value := otap_constants.OTAP_LAYOUT_LEFT;
    END IF;
    -- check border options
     IF     :NEW.config_name = 'DEFAULT_BORDER'
        AND (   TO_NUMBER(:NEW.config_value) < 2
             OR TO_NUMBER(:NEW.config_value) > 10
            )
    THEN
      :NEW.config_value := otap_constants.OTAP_BORDER_DEFAULT;
    END IF;
  END IF;
END;
/
CREATE OR REPLACE TRIGGER otap_config_del_trg
  BEFORE DELETE ON otap_config
  FOR EACH ROW
BEGIN
  -- deny delete of defined configuration names
  IF :OLD.config_name IN ( 'PRESERVE_DAYS'
                         , 'DELETE_DELAY'
                         , 'DELETE_BATCH_SIZE'
                         , 'DEBUG_MODE'
                         , 'FORMAT_HEADER_CHAR'
                         , 'FORMAT_SET_CHAR'
                         , 'FORMAT_GROUP_CHAR'
                         , 'FORMAT_NAME_CHAR'
                         , 'TEXT_TRUE'
                         , 'TEXT_FALSE'
                         , 'TEXT_TRUE_YES'
                         , 'TEXT_FALSE_NO'
                         , 'TEXT_TEST_PASSED'
                         , 'TEXT_TEST_FAILED'
                         , 'TEXT_TEST_UNDEFINED'
                         , 'DEFAULT_PREFIX'
                         , 'DEFAULT_TEST_SET'
                         , 'DEFAULT_TEST_GROUP'
                         , 'DEFAULT_TEST_NAME'
                         , 'DEFAULT_LAYOUT'
                         , 'DEFAULT_RESULT_LAYOUT'
                         , 'DEFAULT_BORDER'
                         , 'TEXT_REPORT_START'
                         , 'TEXT_REPORT_END'
                         , 'TEXT_RESULT_HEADER'
                         , 'FORMAT_RESULT_HEADER'
                         , 'TEXT_SUMMARY_SUCCESS'
                         , 'TEXT_SUMMARY_ERROR'
                         , 'SUMMARY_TEMPLATE'
                         , 'ERRORS_TEMPLATE'
                         , 'ERROR_DETAILS_TEMPLATE'
                         , 'NO_DATA_TEMPLATE'
                         , 'SESSION_ID_TEMPLATE'
                         , 'SET_TEMPLATE'
                         , 'GROUP_TEMPLATE'
                         , 'TEST_NAME_TEMPLATE'
                         , 'RESULT_LINE_TEMPLATE'
                         , 'FN_HAS_TABLE_TEMPLATE'
                         )
  THEN
    RAISE_APPLICATION_ERROR(-20005, 'The configuration name ' || :OLD.config_name || ' cannot be deleted.');
  END IF;
END;
/
-- create base entries
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('PRESERVE_DAYS', '1', 'NUMBER', 'The number of days otap will keep test result records. Maximum is 7 days, minimum 1 day. Default is 1.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DELETE_DELAY', '10', 'NUMBER', 'The seconds to wait between batch size delete commits to give other applications and requests room to execute. Maximum is 600, minimum is 1. Default is 10.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DELETE_BATCH_SIZE', '1000', 'NUMBER', 'The records to delete before commit. Maximum is 10000, minimum is 100. Default is 1000.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DEBUG_MODE', '0', 'NUMBER', 'Enables debugging on demand, logged in SPERRORLOG. Either 0 (disable) or 1 (enabled). Default is 0.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FORMAT_HEADER_CHAR', '=', 'CHAR', 1, 'Used to format the report header line. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FORMAT_SET_CHAR', '*', 'CHAR', 1, 'Used to separate the report set information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FORMAT_GROUP_CHAR', '+', 'CHAR', 1, 'Used to separate the report group information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FORMAT_NAME_CHAR', '-', 'CHAR', 1, 'Used to separate the report test name information. Limited to 1 char.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_TRUE', 'true', 'CHAR', 20, 'Used as text representation for the boolean/numerical value for TRUE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_FALSE', 'false', 'CHAR', 20, 'Used as text representation for the boolean/numerical value for FALSE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_TRUE_YES', 'Yes', 'CHAR', 20, 'Used as text representation for the boolean/numerical value for TRUE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_FALSE_NO', 'No', 'CHAR', 20, 'Used as text representation for the boolean/numerical value for FALSE. Limited to 20 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_TEST_PASSED', 'Passed', 'CHAR', 50, 'Used as text representation for tests executed successfully. If you change the length, you need to adapt also TEXT_RESULT_HEADER and FORMAT_RESULT_HEADER. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_TEST_FAILED', 'Failed', 'CHAR', 50, 'Used as text representation for tests executed with errors. If you change the length, you need to adapt also TEXT_RESULT_HEADER and FORMAT_RESULT_HEADER. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_TEST_UNDEFINED', 'Undefined', 'CHAR', 50, 'Used as text representation for tests with undefined state, e.g. due to setup errors. If you change the length, you need to adapt also TEXT_RESULT_HEADER and FORMAT_RESULT_HEADER. Limited to 50 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_PREFIX', 'TEST', 'CHAR', 4, 'The default prefix without any _ delimiter, to identify test procedures for OTAP. Limited to 4 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_TEST_SET', 'OTAP test set', 'CHAR', 256, 'The default name for a test set if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_TEST_GROUP', 'OTAP test group', 'CHAR', 256, 'The default name for a test group if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('DEFAULT_TEST_NAME', 'OTAP test name', 'CHAR', 256, 'The default name for a test name if not otherwise specified. Limited to 256 chars, recommended as short as possible.')
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
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DEFAULT_BORDER', '5', 'NUMBER', 'Defines the default minimum border chars to use for decorating report lines. Only values between 2 and 10 supported. Wrong values lead to otap_constants.OTAP_BORDER_DEFAULT as default.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_REPORT_START', 'OTAP test summary report', 'CHAR', 256, 'Used as report title. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_REPORT_END', 'OTAP test summary report finished', 'CHAR', 256, 'Used as report footer. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_RESULT_HEADER', 'Result    Setup     Runtime             Test', 'CHAR', 256, 'Used as result header, depending on formatting and size of test passed, setup passed and runtime. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FORMAT_RESULT_HEADER', '--------- --------- ------------------- ----------------------------------------', 'CHAR', 256, 'Used as result header underlining, depending on formatting and size of test passed, setup passed and runtime. Limited to 256 chars, recommended equal or shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_SUMMARY_SUCCESS', 'SUCCESS', 'CHAR', 256, 'Used in templates as information text if a set, group or test name has executed without errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEXT_SUMMARY_ERROR', 'ERROR', 'CHAR', 256, 'Used in templates as information text if a set, group or test name has executed with errors. Extended by the category specific information. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @status@ represents SNIPPET_SUMMARY_ERROR or SNIPPET_SUMMARY_SUCCESS
-- @runtime@ represents the runtime as Oracle interval
-- @runs@ represent the amount of tests executed for the set, group or test name
-- @errors@ represent the amount of tests with errors for the set, group or test name
-- @issues@ represent the amount of test setup or internal errors for the set, group or test name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('SUMMARY_TEMPLATE', '@status@ runtime: @runtime@ (runs: @runs@ errors: @errors@ issues: @issues@)', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testname@ represents the test name for the summary of errors under this test name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('ERRORS_TEMPLATE', '@testname@ error details', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testdesc@ represents the test description for the test in error
-- @error_info@ represents the error information for the specific test description
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('ERROR_DETAILS_TEMPLATE', '@testdesc@: @errorinfo@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @sessionid@ represents the current session id used to filter test results
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('NO_DATA_TEMPLATE', 'NO_DATA - no tests found for test session id @sessionid@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('SESSION_ID_TEMPLATE', 'Session id: @sessionid@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testset@ represents the name of the current test set
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('SET_TEMPLATE', 'Test set: @testset@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testgroup@ represents the name of the current test group
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('GROUP_TEMPLATE', 'Test group: @testgroup@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @testname@ represents the name of the current test
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('TEST_NAME_TEMPLATE', 'Test name: @testname@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @teststate@ represents the text representation of test passed, failed or undefined
-- @issuestate@ represents the text representation of otap issues, equal to test state
-- @runtime@ represents the runtime as Oracle interval
-- @testdesc@ represents the test description of the test
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('RESULT_LINE_TEMPLATE', '@teststate@ @issuestate@ @runtime@ @testdesc@', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;
-- @schema@ represents the schema of the table
-- @tablename@ represents the table name
INSERT INTO otap_config
  (config_name, config_value, config_type, config_max_length, config_description)
  VALUES
  ('FN_HAS_TABLE_TEMPLATE', 'TEST if table @schema@.@tablename@ exists', 'CHAR', 256, 'Used as a template, all @variables@ will be replaced by corresponding values. The @variablename@ cannot be changed. Limited to 256 chars, recommended shorter than 80 chars.')
;

COMMIT;