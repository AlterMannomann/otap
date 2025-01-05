-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Provides test functions related to schema objects.
CREATE OR REPLACE PACKAGE otap_schema
AS

  /**
  * This package provides the internal available test functions for schema objects which
  * are used by OTAP_API. All functions use PLSQL variable types as they are behind OTAP_API.
  *
  * All functions return a numeric test result as defined in otap_constants.OTAP_NUM_TEST_PASSED,
  * otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED.
  *
  * Test functions never manage session variables, but they always provide an error output. Decisions
  * based on session objects, e.g. which schema to use, must be managed by OTAP_API.
  */

  /** FUNCTION otap_schema.has_table
  * Tests if a table exists and returns a numeric test result.
  *
  * @param p_table_name The table name of the table, taken as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_table( p_table_name   IN     VARCHAR2
                    , o_errors          OUT VARCHAR2
                    , p_schema       IN     VARCHAR2 DEFAULT NULL
                    )
    RETURN INTEGER
  ;

END;
/