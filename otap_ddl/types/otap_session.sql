-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- basic object for current otap test data
CREATE OR REPLACE TYPE otap_session
  AS OBJECT
     -- provides the current data from a test session as stored in OTAP_TEST
     -- values may change during the session
     ( test_executor    VARCHAR2(128)
     , test_set         VARCHAR2(256)
     , test_group       VARCHAR2(256)
     , test_name        VARCHAR2(256)
     , db_user          VARCHAR2(128)
     , db_schema        VARCHAR2(128)
     , test_prefix      VARCHAR2(4)
     , test_count       INTEGER
     , intended_count   INTEGER
     , persist_test     BOOLEAN
     , name_precedence  BOOLEAN
     , include_packages BOOLEAN
     )
;
/