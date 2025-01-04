-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- basic internal interface between session variable and concrete test calls.
-- WARNING package will probably get huge due to bundling functionality
CREATE OR REPLACE PACKAGE otap_api
AS

  /**
  * The package is fail save in the sense that it will try to capture all errors and execptions and
  * influence the test result. On exceptions, otap is not stable, so the test result gets undefined
  * exceptions and errors and the test_errors content is set. Still it is possible on severe database
  * errors will raise an exception. Every error passing the double begin-end blocks used are exceptions
  * that otap can't and won't handle. The begin-end blocks define the otap code that can be controlled,
  * but if database is unstable, e.g. running out of tablespace, it makes no sense to consume exceptions.
  *
  * Main functionality is to prepare the parameters considering session settings and then call the functions
  * to keep the basic test functions short and concentrated on their real work. The return of the test
  * functions should always be NUMBER, limited to otap_constants.OTAP_NUM_TEST_PASSED,
  * otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED or exception.
  *
  * Test results, after persisting, are always delivered to the caller of OTAP_API as VARCHAR2 test result text.
  */

  /** FUNCTION otap_api.has_table
  * Tests if a table exists or not, writes the test result, add a test to the counter and outputs the test result.
  * Uses otap_schema to get a test result and testing for any exception, then writing the test result including the
  * internal issues of otap, if any and add a new test done to the session variable. If error is manageable, no exception
  * will be raised. Nevertheless there are still option that the construct may fail on user side by severe database errors.
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