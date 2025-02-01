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
  * Checks given data of type VARCHAR2 against an Oracle REGEX expression. Uses REGEXP_LIKE. As MATCHES is a reserved word
  * this is the equivalent of matches, imatches, doesnt_match and doesnt_imatch.
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

  /** FUNCTION otap_logic.alike
  * Checks given data of type VARCHAR2 against an Oracle LIKE expression. LIKE is currently more reliable and easier
  * to use than Oracle REGEX implementation. But also much more limited.
  *
  * @param p_have The data to check.
  * @param p_like A valid Oracle like expression that p_have must match. Mandatory.
  * @param o_error Error information, if any, on the test executed.
  * @param p_case_sensitive Optional defines that the compared result is handled as case sensitive, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION alike( p_have            IN            VARCHAR2
                , p_like            IN            VARCHAR2
                , o_errors             OUT NOCOPY VARCHAR2
                , p_case_sensitive  IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.throws_ok
  * Checks if a given statement or code block throws the expected error message. The expected error message must match
  * the SQLERRM returned from exception thrown. Use throws_match or throws_like if only parts of the error message must
  * match. If the statement starts with SELECT it is executed as is, without caring for returned columns or rows and ignoring
  * any given header definition. The header definition is a code block for the declare section defining variables that may be
  * needed by called functions or procedures. It is only used if the statement does not start with SELECT and if the declaration
  * block can be executed with a NULL procedure without throwing exceptions.
  *
  * Function comes in two flavors, comparing SQLERRM as VARCHAR2 or the error code SQLCODE as number. It can also be used to check
  * if a statement does not cause any exception by switching the expected result to otap_constants.OTAP_NUM_TEST_FAILED.
  *
  * SQL statements (SELECT, UPDATE, DELETE) MUST NOT have a trailing semicolon. otap will try to detect and remove it, but may fail.
  * Semicolon in dynamically executed SQL statements will cause an unexpected exception.
  *
  * Functions and procedures MUST have a trailing semicolon, especially if more than one command is executed in the block.
  *
  * Syntax errors will most likely cause a different exception as the expected one and fail the test. This is especially important if
  * you switch the expected test result. otap expects in this case, that the statement could be executed without any exception.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_sqlerrm Mandatory. The exact case sensitive expected error message as returned by SQLERRM after a provoked exception.
  * @param o_error Error information, if any, on the test executed.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlerrm         IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_header_def      IN            VARCHAR2 DEFAULT NULL
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.throws_ok
  * Flavor error code SQLCODE as number. Same behavior as flavor error message. Be aware that some Oracle error codes are group error codes where
  * the error message differs depending on the exact error cause.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_sqlcode Mandatory. The exact expected error code as returned by SQLCODE after a provoked exception.
  * @param o_error Error information, if any, on the test executed.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlcode         IN            NUMBER
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_header_def      IN            VARCHAR2 DEFAULT NULL
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.throws_matches
  * Same as otap_logic.throws_ok apart from using Oracle REGEXP to identify the error message.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_regex_sqlerrm Mandatory. The regular expression to match the expected error message as returned by SQLERRM after a provoked exception.
  * @param o_error Error information, if any, on the test executed.
  * @param p_param Optional valid parameter for REGEXP_LIKE. 'i' means case insensitive. Parameters are case sensitive. See Oracle documentation for details, https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Pattern-matching-Conditions.html#GUID-D2124F3A-C6E4-4CCA-A40E-2FFCABFD8E19.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION throws_matches( p_statement       IN            VARCHAR2
                         , p_regex_sqlerrm   IN            VARCHAR2
                         , o_errors             OUT NOCOPY VARCHAR2
                         , p_param           IN            VARCHAR2 DEFAULT NULL
                         , p_header_def      IN            VARCHAR2 DEFAULT NULL
                         , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN INTEGER
  ;

  /** FUNCTION otap_logic.throws_like
  * Same as otap_logic.throws_ok apart from using Oracle LIKE to identify the error message.
  *
  * @param p_statement Mandatory. The statement as string to execute. Can be a select statement or function/procedure call. No need to proovide a begin end block. Syntax should be checked or will cause unexpected exceptions.
  * @param p_like_sqlerrm Mandatory. The LIKE expression to match the expected error message as returned by SQLERRM after a provoked exception.
  * @param o_error Error information, if any, on the test executed.
  * @param p_case_sensitive Optional defines that the compared result is handled as case sensitive, if set to otap_constants.OTAP_NUM_TRUE.
  * @param p_header_def Optional valid header definition (test result is undefined if header is not valid) for function or procedure tests to support OUT and return variables.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION throws_like( p_statement       IN            VARCHAR2
                      , p_like_sqlerrm    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_case_sensitive  IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                      , p_header_def      IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  ;

  --=== internal functions exposed for testing
  /** FUNCTION otap_logic.check_header
  * Checks a header construct defining variables and defaults with a declare-begin-end block, if a header definition is
  * given. If the header definition is NULL, will always return TRUE.
  */
  FUNCTION check_header( p_header_def IN            VARCHAR2
                       , o_errors     IN OUT NOCOPY VARCHAR2
                       )
    RETURN BOOLEAN
  ;
  /** FUNCTION otap_logic.get_test_block
  * Creates a declare-begin-end block to execute, that contains the header and the given statement in the body.
  * The statement is used as given, leading comments are NOT checked for determination of script type (SQL or PLSQL)
  * If the statement starts with SELECT (case ignored), the block is just the SQL SELECT statement checked and
  * cleaned from ending with a semicolon.
  */
  FUNCTION get_test_block( p_statement  IN VARCHAR2
                         , p_header_def IN VARCHAR2 DEFAULT NULL
                         )
    RETURN VARCHAR2
  ;
  /** FUNCTION otap_logic.has_exception
  * Checks if a given statement and optional header cause an exception. Will return TRUE if an exception is raised, otherwise FALSE.
  * Returns the error code and message as provided by SQLCODE and SQLERRM as out variables.
  */
  FUNCTION has_exception( p_statement       IN            VARCHAR2
                        , o_errors          IN OUT NOCOPY VARCHAR2
                        , o_sqlcode            OUT NOCOPY NUMBER
                        , o_sqlerrm            OUT NOCOPY VARCHAR2
                        , p_header_def      IN            VARCHAR2 DEFAULT NULL
                        , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN BOOLEAN
  ;

END;
/
