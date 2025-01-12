-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Internal view for otap labels. Cast to 128 length as config names.
-- Materialized to improve performance, if object types change in the database, refresh the view manually.
CREATE MATERIALIZED VIEW otap_labels_mv
  REFRESH FORCE ON DEMAND WITH ROWID USING TRUSTED CONSTRAINTS
AS
    WITH grp AS (SELECT CAST(TRIM(object_type) AS VARCHAR2(128 CHAR)) AS object_type FROM dba_objects GROUP BY object_type
                  UNION ALL
                 SELECT CAST(TRIM(keyword) AS VARCHAR2(128 CHAR)) AS object_type FROM v$reserved_words WHERE keyword IN ( 'COLUMN'
                                                                                                                        , 'USER'
                                                                                                                        , 'ROLE'
                                                                                                                        )
                )
  SELECT object_type                                                            AS oracle_type
       , CAST('LABEL_' || REPLACE(object_type, ' ', '_') AS VARCHAR2(128 CHAR)) AS otap_identifier
       , LOWER(object_type)                                                     AS otap_label_lower
       , INITCAP(object_type)                                                   AS otap_label_cap
       , UPPER(object_type)                                                     AS otap_label_upper
       , object_type                                                            AS otap_label_source
    FROM grp
;
