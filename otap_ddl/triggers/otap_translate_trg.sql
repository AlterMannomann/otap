-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- OTAP_TRANSLATE trigger
CREATE OR REPLACE TRIGGER otap_translate_ins_trg
  BEFORE INSERT ON otap_translate
  FOR EACH ROW
BEGIN
  :NEW.created        := SYSDATE;
  :NEW.created_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.created_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
  :NEW.language_id    := otap_constants.OTAP_INTERNAL_NA;
  -- check if the label is defined and translatable, deny if not, ignore if not in otap_config
  otap_util.validate_translatable(:NEW.otap_identifier);
END;
/

CREATE OR REPLACE TRIGGER otap_translate_upd_trg
  BEFORE UPDATE ON otap_translate
  FOR EACH ROW
BEGIN
  :NEW.created        := :OLD.created;
  :NEW.created_by     := :OLD.created_by;
  :NEW.created_by_os  := :OLD.created_by_os;
  :NEW.updated        := SYSDATE;
  :NEW.updated_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.updated_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
  :NEW.language_id    := otap_constants.OTAP_INTERNAL_NA;
  otap_util.validate_translatable(:NEW.otap_identifier);
END;
/