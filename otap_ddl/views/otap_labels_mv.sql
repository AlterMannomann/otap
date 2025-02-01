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
                        -- add reserved word missing
                 SELECT CAST(TRIM(keyword) AS VARCHAR2(128 CHAR)) AS object_type FROM v$reserved_words WHERE keyword IN ( 'COLUMN'
                                                                                                                        , 'USER'
                                                                                                                        , 'ROLE'
                                                                                                                        , 'CONSTRAINT'
                                                                                                                        , 'VARCHAR2'
                                                                                                                        , 'NUMBER'
                                                                                                                        , 'BOOLEAN'
                                                                                                                        , 'DATE'
                                                                                                                        , 'NULL'
                                                                                                                        , 'DATABASE'
                                                                                                                        )
                  UNION ALL
                        -- add reserved words that are a combination of more than one word for constraint types
                 SELECT CAST('PRIMARY KEY' AS VARCHAR2(128 CHAR)) AS object_type FROM dual  -- P
                  UNION ALL
                 SELECT CAST('UNIQUE KEY' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- U
                  UNION ALL
                 SELECT CAST('FOREIGN KEY' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- R
                  UNION ALL
                 SELECT CAST('CHECK' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- C generic
                  UNION ALL
                 SELECT CAST('NOT NULL' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- C special
                  UNION ALL
                 SELECT CAST('VIEW CHECK' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- V
                  UNION ALL
                 SELECT CAST('VIEW READONLY' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- O
                  UNION ALL
                 SELECT CAST('REF COLUMN' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- F
                  UNION ALL
                 SELECT CAST('HASH' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- H
                  UNION ALL
                 SELECT CAST('SUPPLEMENTAL LOGGGING' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- S
                  UNION ALL
                 SELECT CAST('INVALID CONSTRAINT TYPE' AS VARCHAR2(128 CHAR)) AS object_type FROM dual -- S
                   -- scheduler job to differentiate from database job
                  UNION ALL
                 SELECT CAST('SCHEDULER JOB' AS VARCHAR2(128 CHAR)) AS object_type FROM dual
                   -- exception for logic matches on exceptions
                  UNION ALL
                 SELECT CAST('EXCEPTION' AS VARCHAR2(128 CHAR)) AS object_type FROM dual
                )
  SELECT object_type                                                            AS oracle_type
       , CAST('LABEL_' || REPLACE(object_type, ' ', '_') AS VARCHAR2(128 CHAR)) AS otap_identifier
       , LOWER(object_type)                                                     AS otap_label_lower
       , INITCAP(object_type)                                                   AS otap_label_cap
       , UPPER(object_type)                                                     AS otap_label_upper
       , object_type                                                            AS otap_label_source
    FROM grp
;
