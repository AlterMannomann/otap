-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- A basic record type for result views
CREATE OR REPLACE TYPE otap_view_result_rec
  AS OBJECT
    ( result_text   VARCHAR2(4000)
    , result_errors VARCHAR2(4000)
    )
;
/