-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- create package constants from otap_label

@@../../setup/util/log_silent.sql
SPOOL tmp_generated.sql
  WITH len AS
       (SELECT MAX(LENGTH(otap_identifier)) AS maxlen FROM otap_labels_v)
SELECT RPAD(('  OTAP_' || otap_identifier), len.maxlen + 14, ' ') ||
       RPAD('CONSTANT CHAR(' || TRIM(TO_CHAR(LENGTH(otap_identifier))) || ')', 30) ||
       ':= ''' || TRIM(otap_identifier) || ''';' AS list_lbl_constants
  FROM otap_labels_v
 CROSS JOIN len
;
SPOOL OFF
EXIT
