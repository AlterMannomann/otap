-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct otap schema
-- table is NOT qualified and created in the schema active at execution
-- a private temporary table is no option as it does not support CLOB
-- DO NOT ADJUST the defaults unless you adjust them as well in OTAP_CONSTANTS. Tables unluckily
-- do not support defaults from package variables or functions unless they are public. otap does
-- not manage what can be seen by whom. You may create public synonyms for otap, but this is your
-- responsibility and depends on your database policies.
-- As this is mainly some special sort of temporary table the delete marker is the first bit or byte
-- depending on database implementation, to make delete runs as fast as possible. An integer below 128
-- should not require more than a byte. If only 0 and 1 is possible a bit should be more than enough.
-- Using CHAR for different language support.
CREATE TABLE otap_results
  ( to_delete       NUMBER(1, 0)         DEFAULT 0                                         NOT NULL
  , test_run_id     NUMBER(38, 0)        GENERATED ALWAYS AS IDENTITY (NOCACHE CYCLE MAXVALUE 9999999999999999999999999999)
  , test_run_date   TIMESTAMP            DEFAULT SYSTIMESTAMP                              NOT NULL
  , test_passed     NUMBER(1, 0)         DEFAULT 0                                         NOT NULL
  , test_session_id NUMBER(38, 0)        DEFAULT 0                                         NOT NULL
  , test_executor   VARCHAR2(128 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER')    NOT NULL
  , test_set        VARCHAR2(256 CHAR)   DEFAULT 'OTAP test set'                           NOT NULL
  , db_user         VARCHAR2(128 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER')    NOT NULL
  , db_schema       VARCHAR2(128 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')  NOT NULL
  , test_group      VARCHAR2(256 CHAR)   DEFAULT 'OTAP test group'                         NOT NULL
  , test_start      TIMESTAMP                                                              NOT NULL
  , test_end        TIMESTAMP                                                              NOT NULL
  , test_name       VARCHAR2(256 CHAR)                                                     NOT NULL
  , test_desc       VARCHAR2(256 CHAR)                                                     NOT NULL
  , deleted         DATE
  , deleted_by      VARCHAR2(128 CHAR)
  , test_errors     VARCHAR2(4000 CHAR)
  )
;
-- description
COMMENT ON TABLE otap_results IS 'Persist the results of otap test runs. Flat table. Restricted update by trigger. Will use the alias ores.';
COMMENT ON COLUMN otap_results.to_delete IS 'Indicator for deletion of this record. Only 0 (no) and 1 (yes) allowed. Placed as first column to speed up test result cleanup.';
COMMENT ON COLUMN otap_results.test_run_id IS 'The generated id for each record, part of the primary key. The primary key is only implemented for correct DELETE access.';
COMMENT ON COLUMN otap_results.test_run_date IS 'The date of executing the test, part of the primary key. Set by trigger. The primary key is only implemented for correct DELETE access. Defines the persist duration, if TO_DELETE is set to 1.';
COMMENT ON COLUMN otap_results.test_passed IS 'Indicator for test passed. 0 test not started or incomplete, 1 test passed, -1 test failed. No other values allowed.';
COMMENT ON COLUMN otap_results.test_session_id IS 'The internal id for a test session. Keeping tests of a test session together. Managed by OTAP_TEST package and sequence OTAP_TEST_SESSION_SEQ. Once set to a value other then 0, not changed on updates.';
COMMENT ON COLUMN otap_results.deleted IS 'The last date TO_DELETE was set to 1. Set by trigger.';
COMMENT ON COLUMN otap_results.deleted_by IS 'The session user that set TO_DELETE to 1. Set by trigger.';
COMMENT ON COLUMN otap_results.test_executor IS 'The session user that created the entry. Set by trigger.';
COMMENT ON COLUMN otap_results.test_set IS 'The name of the test set the entry belongs to. Default OTAP test set. Use test sets to separate application tests.';
COMMENT ON COLUMN otap_results.test_group IS 'The name of the test group the entry belongs to. Default OTAP test group. Use test groups to separate functionality tests.';
COMMENT ON COLUMN otap_results.test_start IS 'The timestamp of the test start. To be set by test functions';
COMMENT ON COLUMN otap_results.test_end IS 'The timestamp of the test end. To be set by test functions';
COMMENT ON COLUMN otap_results.db_user IS 'The database user owning the test object. Set to current user by default. Can be overwritten.';
COMMENT ON COLUMN otap_results.db_schema IS 'The database schema of the test object. Set to current schema by default. Can be overwritten.';
COMMENT ON COLUMN otap_results.test_name IS 'The name of a test. Use short names describing the test. Limited to 256 chars.';
COMMENT ON COLUMN otap_results.test_desc IS 'A short and precise test description. Should be unique under the name, group and set running. Uniqueness not verified. Limited to 256 chars.';
COMMENT ON COLUMN otap_results.test_errors IS 'Error text information that has been accessibly to otap. Limited to 4000 chars.';
-- primary key
-- no index apart from primary key, just overhead not needed
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_pk
  PRIMARY KEY (test_run_id, test_run_date)
  ENABLE
;
-- check constraints
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_chk_to_delete
  CHECK (to_delete IN (0, 1))
  ENABLE
;
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_chk_test_passed
  CHECK (test_passed IN (-1, 0, 1))
  ENABLE
;
