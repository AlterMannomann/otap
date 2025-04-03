-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- get data to configure, avoid already tested settings
COLUMN ORG_LAYOUT NEW_VAL ORG_LAYOUT
SELECT config_value AS ORG_LAYOUT FROM otap_config WHERE config_name = 'DEFAULT_LAYOUT';
COLUMN FIRST_LAYOUT NEW_VAL FIRST_LAYOUT
  WITH layouts AS
       (SELECT 'R' AS default_layout FROM dual
         UNION ALL
        SELECT 'M' AS default_layout FROM dual
         UNION ALL
        SELECT 'L' AS default_layout FROM dual
       )
     , nxt AS
       (SELECT default_layout
             , ROW_NUMBER() OVER (ORDER BY default_layout ASC) AS rn
          FROM layouts
         WHERE default_layout != '&ORG_LAYOUT'
       )
SELECT default_layout AS FIRST_LAYOUT
  FROM nxt
 WHERE rn = 1
;
COLUMN LAST_LAYOUT NEW_VAL LAST_LAYOUT
  WITH layouts AS
       (SELECT 'R' AS default_layout FROM dual
         UNION ALL
        SELECT 'M' AS default_layout FROM dual
         UNION ALL
        SELECT 'L' AS default_layout FROM dual
       )
     , nxt AS
       (SELECT default_layout
             , ROW_NUMBER() OVER (ORDER BY default_layout ASC) AS rn
          FROM layouts
         WHERE default_layout != '&ORG_LAYOUT'
       )
SELECT default_layout AS LAST_LAYOUT
  FROM nxt
 WHERE rn = 2
;
COLUMN ORG_BORDER NEW_VAL ORG_BORDER
SELECT config_value AS ORG_BORDER FROM otap_config WHERE config_name = 'DEFAULT_BORDER';
COLUMN FIRST_BORDER NEW_VAL FIRST_BORDER
  WITH borders AS
       (SELECT '2' AS default_border, 1 AS prio FROM dual
         UNION ALL
        SELECT '7' AS default_border, 2 AS prio FROM dual
         UNION ALL
        SELECT '10' AS default_border, 3 AS prio FROM dual
         UNION ALL
        SELECT '3' AS default_border, 4 AS prio FROM dual
         UNION ALL
        SELECT '4' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '5' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '6' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '8' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '9' AS default_border, 5 AS prio FROM dual
       )
     , nxt AS
       (
        SELECT default_border
             , prio
             , ROW_NUMBER() OVER (ORDER BY prio) AS rn
          FROM borders
         WHERE default_border != '&ORG_BORDER'
       )
SELECT default_border AS FIRST_BORDER
  FROM nxt
 WHERE rn = 1
;
COLUMN LAST_BORDER NEW_VAL LAST_BORDER
  WITH borders AS
       (SELECT '2' AS default_border, 1 AS prio FROM dual
         UNION ALL
        SELECT '7' AS default_border, 2 AS prio FROM dual
         UNION ALL
        SELECT '10' AS default_border, 3 AS prio FROM dual
         UNION ALL
        SELECT '3' AS default_border, 4 AS prio FROM dual
         UNION ALL
        SELECT '4' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '5' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '6' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '8' AS default_border, 5 AS prio FROM dual
         UNION ALL
        SELECT '9' AS default_border, 5 AS prio FROM dual
       )
     , nxt AS
       (
        SELECT default_border
             , prio
             , ROW_NUMBER() OVER (ORDER BY prio) AS rn
          FROM borders
         WHERE default_border != '&ORG_BORDER'
       )
SELECT default_border AS LAST_BORDER
  FROM nxt
 WHERE rn = 2
;
-- set configuration
UPDATE otap_config
   SET config_value = '&FIRST_LAYOUT'
 WHERE config_name = 'DEFAULT_LAYOUT'
;
UPDATE otap_config
   SET config_value = '&FIRST_BORDER'
 WHERE config_name = 'DEFAULT_BORDER'
;
COMMIT;
SELECT otap_test.set_test_name('Verify otap_report layout/border(&FIRST_LAYOUT./&FIRST_BORDER.) intrusive') FROM dual;
@@otap_report_code.sql
UPDATE otap_config
   SET config_value = '&LAST_BORDER'
 WHERE config_name = 'DEFAULT_BORDER'
;
COMMIT;
SELECT otap_test.set_test_name('Verify otap_report layout/border(&FIRST_LAYOUT./&LAST_BORDER.) intrusive') FROM dual;
@@otap_report_code.sql
UPDATE otap_config
   SET config_value = '&LAST_LAYOUT'
 WHERE config_name = 'DEFAULT_LAYOUT'
;
COMMIT;
SELECT otap_test.set_test_name('Verify otap_report layout/border(&LAST_LAYOUT./&LAST_BORDER.) intrusive') FROM dual;
@@otap_report_code.sql
UPDATE otap_config
   SET config_value = '&FIRST_BORDER'
 WHERE config_name = 'DEFAULT_BORDER'
;
COMMIT;
SELECT otap_test.set_test_name('Verify otap_report layout/border(&LAST_LAYOUT./&FIRST_BORDER.) intrusive') FROM dual;
@@otap_report_code.sql
