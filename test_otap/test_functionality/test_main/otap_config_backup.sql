-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- creates a temporary backup of the otap_config table

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_has_backup INTEGER;
BEGIN
  SELECT COUNT(*)
    INTO l_has_backup
    FROM user_tables
   WHERE table_name = 'OTAP_CONFIG_BACKUP'
  ;
  IF l_has_backup = 1
  THEN
    DBMS_OUTPUT.PUT_LINE('Old temporary backup detected and dropped');
    EXECUTE IMMEDIATE 'DROP TABLE otap_config_backup';
  END IF;
  EXECUTE IMMEDIATE 'CREATE TABLE otap_config_backup AS SELECT * FROM otap_config';
  DBMS_OUTPUT.PUT_LINE('Temporary backup created');
END;
/
