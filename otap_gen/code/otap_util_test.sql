-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- create test statements for otap_util package constants
@@../../setup/util/log_silent.sql
SPOOL tmp_generated.sql
  WITH base AS
       (SELECT text AS src
             , INSTR(text, 'CONSTANT ') - 1 AS cut_pos1
             , INSTR(text, ':= ') + 3 AS cut_pos2
             , NVL(LENGTH(TRIM(text)), 0) + 1  AS str_end
          FROM user_source
         WHERE name = 'OTAP_UTIL'
           AND type = 'PACKAGE'
           AND INSTR(text, 'CONSTANT ') > 0
       )
     , vals AS
       (SELECT TRIM(SUBSTR(src, 1, cut_pos1)) AS const_name
             , TRIM(SUBSTR(src, cut_pos2, (str_end - cut_pos2))) AS const_value
             , src
             , '  l_return := otap_test.is_eq(otap_util.' AS line_start
          FROM base
       )
SELECT line_start || const_name || ', ' || const_value || ', ''Verify package constant otap_util.' || const_name || ''');'  AS test_line
  FROM vals
;
SPOOL OFF
EXIT
