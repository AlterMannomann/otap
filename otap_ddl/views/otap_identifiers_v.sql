-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Internal view for all otap identifiers that provides translations available from OTAP_TRANSLATE.
CREATE OR REPLACE VIEW otap_identifiers_v
AS
    WITH lbl AS
         (SELECT config_name AS otap_identifier
                 -- leave configuration unchanged
               , config_value AS label_text_lower
               , config_value AS label_text_cap
               , config_value AS label_text_upper
               , config_type  AS label_type
               , translatable AS label_translatable
            FROM otap_config
           UNION ALL
          SELECT otap_identifier
               , otap_label_lower                         AS label_text_lower
               , otap_label_cap                           AS label_text_cap
               , otap_label_upper                         AS label_text_upper
               , otap_constants.get_otap_config_type_char AS label_type
               , otap_constants.get_otap_num_true         AS label_translatable
            FROM otap_labels_v
         )
  SELECT lbl.otap_identifier
         -- leave translations unchanged
       , NVL(otr.label_text, lbl.label_text_lower) AS label_text_lower
       , NVL(otr.label_text, lbl.label_text_cap)   AS label_text_cap
       , NVL(otr.label_text, lbl.label_text_upper) AS label_text_upper
       , label_type
       , label_translatable
    FROM lbl
    LEFT OUTER JOIN otap_translate otr
      ON lbl.otap_identifier = otr.otap_identifier
     AND otr.language_id     = otap_constants.get_otap_internal_na
;