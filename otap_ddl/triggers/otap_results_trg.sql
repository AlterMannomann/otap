-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- OTAP_RESULTS trigger
CREATE OR REPLACE TRIGGER otap_results_ins_trg
  BEFORE INSERT ON otap_results
  FOR EACH ROW
BEGIN
  :NEW.test_run_date   := SYSTIMESTAMP;
  :NEW.test_executor   := SYS_CONTEXT('USERENV', 'SESSION_USER');
  IF :NEW.to_delete = otap_constants.OTAP_NUM_TRUE
  THEN
    :NEW.deleted    := SYSTIMESTAMP;
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
  IF :NEW.test_run_date != :OLD.test_run_date
  THEN
    :NEW.test_run_date := :OLD.test_run_date;
  END IF;
  IF     :OLD.test_session_id != 0
     AND :NEW.test_session_id != :OLD.test_session_id
  THEN
    :NEW.test_session_id := :OLD.test_session_id;
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
     AND :NEW.to_delete  = otap_constants.OTAP_NUM_TRUE
  THEN
    :NEW.deleted    := SYSTIMESTAMP;
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
  IF     :OLD.test_start IS NOT NULL
     AND :NEW.test_start != :OLD.test_start
  THEN
    :NEW.test_start := :OLD.test_start;
  END IF;
  IF     :OLD.test_end IS NOT NULL
     AND :NEW.test_end != :OLD.test_end
  THEN
    :NEW.test_end := :OLD.test_end;
  END IF;

END;
/

CREATE OR REPLACE TRIGGER otap_results_del_trg
  BEFORE DELETE ON otap_results
  FOR EACH ROW
BEGIN
  IF :OLD.to_delete != otap_constants.OTAP_NUM_TRUE
  THEN
    RAISE_APPLICATION_ERROR(-20010, 'Record must be marked with TO_DELETE = 1. Peristent records cannot be deleted. Set TO_DELETE for run id ' || :OLD.test_run_id || ' and timestamp ' || TO_CHAR(:OLD.test_run_date, 'YYYY-MM-DD HH24:MI:SS.FF9'));
  END IF;
END;
/