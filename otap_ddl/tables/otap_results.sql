-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct otap schema
-- table is NOT qualified and created in the schema active at execution
-- a private temporary table is no option as it does not support CLOB
CREATE TABLE otap_results
  ( otap_testrun_id NUMBER(38, 0)   GENERATED ALWAYS AS IDENTITY (NOCACHE CYCLE MAXVALUE 9999999999999999999999999999)
  , otap_test_date  DATE            DEFAULT SYSDATE                                   NOT NULL
  , to_delete       VARCHAR(1)      DEFAULT 'N'                                       NOT NULL
  , test_passed     NUMBER(1, 0)    DEFAULT 0                                         NOT NULL
  , test_executor   VARCHAR2(128)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER')    NOT NULL
  , test_set        VARCHAR2(256)   DEFAULT 'otap GENERIC test set'                   NOT NULL
  , db_user         VARCHAR2(128)   DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER')    NOT NULL
  , db_schema       VARCHAR2(128)   DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')  NOT NULL
  , test_group      VARCHAR2(256)   DEFAULT 'otap DEFAULT test group'                 NOT NULL
  , deleted         DATE
  , deleted_by      VARCHAR2(128)
  , test_name       VARCHAR2(256)
  , test_desc       VARCHAR2(4000)
  , test_errors     CLOB
  , test_trace      CLOB
  )
;
-- description
COMMENT ON TABLE otap_results IS 'Persist the results of otap test runs. Flat table. Restricted update by trigger. Will use the alias ores.';
COMMENT ON COLUMN otap_results.otap_testrun_id IS 'The generated id for each record, part of the primary key.';
COMMENT ON COLUMN otap_results.otap_test_date IS 'The date of executing the test, part of the primary key. Set by trigger.';
COMMENT ON COLUMN otap_results.to_delete IS 'Indicator for deletion of this record. Only N (no) and Y (yes) allowed.';
COMMENT ON COLUMN otap_results.test_passed IS 'Indicator for test passed. 0 test not started or incomplete, 1 test passed, -1 test failed. No other values allowed.';
COMMENT ON COLUMN otap_results.deleted IS 'The last date TO_DELETE was set to Y. Set by trigger.';
COMMENT ON COLUMN otap_results.deleted_by IS 'The session user that set TO_DELETE to Y. Set by trigger.';
COMMENT ON COLUMN otap_results.test_executor IS 'The session user that created the entry. Set by trigger.';
COMMENT ON COLUMN otap_results.test_set IS 'The name of the test set the entry belongs to. Default otap GENERIC test set. Use test sets to separate application tests.';
COMMENT ON COLUMN otap_results.test_group IS 'The name of the test group the entry belongs to. Default otap DEFAULT test group. Use test groups to separate functionality tests.';
COMMENT ON COLUMN otap_results.db_user IS 'The database user owning the test object. Set to current user by default. Can be overwritten.';
COMMENT ON COLUMN otap_results.db_schema IS 'The database schema of the test object. Set to current schema by default. Can be overwritten.';
COMMENT ON COLUMN otap_results.test_name IS 'The name of a single test. Use short names describing the test. Limited to 256 chars.';
COMMENT ON COLUMN otap_results.test_desc IS 'An optional test description with more comment space. Limited to 4000 chars.';
COMMENT ON COLUMN otap_results.test_errors IS 'Error text information that has been accessibly to otap.';
COMMENT ON COLUMN otap_results.test_trace IS 'Trace text information that has been supplied by otap.';
-- primary key
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_pk
  PRIMARY KEY (otap_testrun_id, otap_test_date)
  ENABLE
;
-- check constraints
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_chk_to_delete
  CHECK (to_delete IN ('Y', 'N'))
  ENABLE
;
ALTER TABLE otap_results
  ADD CONSTRAINT otap_results_chk_test_passed
  CHECK (test_passed IN (-1, 0, 1))
  ENABLE
;
-- trigger
CREATE OR REPLACE TRIGGER otap_results_ins_trg
  BEFORE INSERT ON otap_results
  FOR EACH ROW
BEGIN
  :NEW.otap_test_date   := SYSDATE;
  :NEW.test_executor    := SYS_CONTEXT('USERENV', 'SESSION_USER');
  IF :NEW.to_delete = 'Y'
  THEN
    :NEW.deleted    := SYSDATE;
    :NEW.deleted_by := SYS_CONTEXT('USERENV', 'SESSION_USER');
  ELSE
    :NEW.deleted    := NULL;
    :NEW.deleted_by := NULL;
  END IF;
END;
/
CREATE OR REPLACE TRIGGER otap_results_upd_trg
  BEFORE UPDATE ON otap_results
  FOR EACH ROW
BEGIN
  -- keep values already set
  IF :NEW.otap_test_date != :OLD.otap_test_date
  THEN
    :NEW.otap_test_date := :OLD.otap_test_date;
  END IF;
  IF :NEW.test_executor != :OLD.test_executor
  THEN
    :NEW.test_executor := :OLD.test_executor;
  END IF;
  IF :NEW.test_set != :OLD.test_set
  THEN
    :NEW.test_set := :OLD.test_set;
  END IF;
  IF :NEW.test_group != :OLD.test_group
  THEN
    :NEW.test_group := :OLD.test_group;
  END IF;
  IF     :NEW.to_delete != :OLD.to_delete
     AND :NEW.to_delete  = 'Y'
  THEN
    :NEW.deleted    := SYSDATE;
    :NEW.deleted_by := SYS_CONTEXT('USERENV', 'SESSION_USER');
  END IF;
  IF     :OLD.test_name IS NOT NULL
     AND :NEW.test_name != :OLD.test_name
  THEN
    :NEW.test_name := :OLD.test_name;
  END IF;
  IF     :OLD.test_desc IS NOT NULL
     AND :NEW.test_desc != :OLD.test_desc
  THEN
    :NEW.test_desc := :OLD.test_desc;
  END IF;
END;
/
