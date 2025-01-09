-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Internal view for otap labels.
CREATE OR REPLACE VIEW otap_labels_v
AS
    WITH grp AS (SELECT object_type FROM dba_objects GROUP BY object_type
                  UNION ALL
                 SELECT keyword FROM v$reserved_words WHERE keyword IN ('COLUMN')
                )
  SELECT object_type                                AS oracle_type
       , 'LABEL_' || REPLACE(object_type, ' ', '_') AS otap_identifier
       , LOWER(object_type)                         AS otap_label_lower
       , INITCAP(object_type)                       AS otap_label_cap
       , UPPER(object_type)                         AS otap_label_upper
    FROM grp
;
