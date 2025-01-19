-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Provides test functions related to logical operations and special compares.
CREATE OR REPLACE PACKAGE otap_logic
AS
  /**
  * Packages provides mainly functions to compare inputs against given values.
  * Functions are basically simple, only chance for errors are exceptions. No error return.
  */

  /** FUNCTION otap_logic.ok
  * Checks if a boolean expression result is TRUE. To test for FALSE just set expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  *
  * @param p_boolean The result of a boolean expression to check.
  * @param o_error Error information, if any, on the test executed.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION ok( p_boolean         IN            BOOLEAN
             , o_errors             OUT NOCOPY VARCHAR2
             , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.is_eq
  * Checks given data of type VARCHAR2, NUMBER and DATE against a given value. As IS is a reserved word in Oracle
  * this is the equivalent of is and isnt. isnt is achieved by setting expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  *
  * Other types are more or less problematic, e.g. you can't declare in Oracle a function with date and timestamp parameter. If providing
  * TIMESTAMP Oracle gets confused which function to use. Try to convert or cast the types to the base types. CAST will probably not
  * preserve all information. TO_CHAR is almost always an option.
  *
  * @param p_have The data to check.
  * @param p_want The expected data. Must have the same datatype as p_have.
  * @param o_error Error information, if any, on the test executed.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION is_eq( p_have            IN            VARCHAR2
                , p_want            IN            VARCHAR2
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  ;
  FUNCTION is_eq( p_have            IN            NUMBER
                , p_want            IN            NUMBER
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  ;
  FUNCTION is_eq( p_have            IN            DATE
                , p_want            IN            DATE
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.match_regex
  * Checks given data of type VARCHAR2 against an Oracle REGEX expression. Uses REGEXP_LIKE.
  * ATTENTION Oracle REGEX implementation is not standard. Unix regex which work like charm take hours to implement in
  * Oracle REGEX to work as desired. Test your expression well with Oracle before using it. Keep it simple to get it work.
  *
  * Easiest way to check is SELECT COUNT(*) FROM dual WHERE regexp_like('your string', 'your regex', 'regex param');
  * Should result in 1 if successful checked. You may want to prepare a with block with different string to pass them
  * through the regular expression.
  *
  * @param p_have The data to check.
  * @param p_regex A valid Oracle regular expression that p_have must match. Mandatory.
  * @param o_error Error information, if any, on the test executed.
  * @param p_param Optional valid parameter for REGEXP_LIKE. 'i' means case insensitive. Parameters are case sensitive. See Oracle documentation for details, https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Pattern-matching-Conditions.html#GUID-D2124F3A-C6E4-4CCA-A40E-2FFCABFD8E19.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION match_regex( p_have            IN            VARCHAR2
                      , p_regex           IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_param           IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.match_like
  * Checks given data of type VARCHAR2 against an Oracle LIKE expression. LIKE is currently more reliable and easier
  * to use than Oracle REGEX implementation. But also much more limited.
  *
  * @param p_have The data to check.
  * @param p_like A valid Oracle like expression that p_have must match. Mandatory.
  * @param o_error Error information, if any, on the test executed.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION match_like( p_have            IN            VARCHAR2
                     , p_like            IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  ;

END;
/
