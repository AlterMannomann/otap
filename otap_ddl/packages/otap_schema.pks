-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Provides test functions related to schema objects.
CREATE OR REPLACE PACKAGE otap_schema
AS

  /**
  * This package provides the internal available test functions for schema objects which
  * are used by OTAP_TEST. It has also dependencies to OTAP_PLAN, OTAP_UTIL and OTAP_CONSTANTS.
  */

  /** FUNCTION otap_schema.has_table
  * Tests if a table exists or not, writes the test result, add a test to the counter and outputs the test result.
  *
  * @param p_table_name The table name of the table, taken as is. If not case sensitive you must provide the table name in UPPERCASE.
  * @param o_otap_session The otap_session object from package OTAP_TEST.
  * @param p_schema A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. If not case sensitive you must provide the schema name in UPPERCASE.
  * @param p_description The test description if any. If not given, a description is generated: Test table x exists.
  *
  * @return The test result as text.
  */
  FUNCTION has_table( p_table_name   IN            VARCHAR2
                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                    , p_schema       IN            VARCHAR2     DEFAULT NULL
                    , p_description  IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  ;

END;
/