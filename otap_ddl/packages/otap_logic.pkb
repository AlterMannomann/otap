-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_logic
AS
  -- for description see header file
  FUNCTION check_header( p_header_def IN            VARCHAR2
                       , o_errors     IN OUT NOCOPY VARCHAR2
                       )
    RETURN BOOLEAN
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_logic.check_header';
    l_block   VARCHAR2(32767);
    l_return  BOOLEAN;
  BEGIN
    l_return := FALSE;
    l_block := 'DECLARE ' || p_header_def || ' BEGIN NULL; END;';
    -- check header
    BEGIN
      EXECUTE IMMEDIATE l_block;
      l_return := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        -- log error
        otap_log.log(SQLERRM, l_script, 'Header block not valid: ' || p_header_def);
        o_errors := o_errors || ' exception: ' || SQLERRM;
        l_return := FALSE;
    END;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END check_header;

  FUNCTION get_test_block( p_statement  IN VARCHAR2
                         , p_header_def IN VARCHAR2 DEFAULT NULL
                         )
    RETURN VARCHAR2
  IS
   l_block VARCHAR2(32767);
  BEGIN
    IF SUBSTR(UPPER(p_statement), 1, 6) = 'SELECT'
    THEN
      l_block := TRIM(p_statement);
      IF (SUBSTR(l_block, LENGTH(l_block)-1, 1) = ';')
      THEN
        l_block := SUBSTR(l_block, 1, LENGTH(l_block)-1);
      END IF;
      -- to get exceptions from SELECT statements without knowing the columns we use a FOR IN loop
      l_block := 'DECLARE BEGIN FOR rec IN (' || l_block || ') LOOP NULL; END LOOP; END;';
      RETURN l_block;
    ELSE
      RETURN 'DECLARE ' || p_header_def || ' BEGIN ' || p_statement || ' END;';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, 'otap_logic.get_test_block', 'Unhandled exception otap_logic.get_test_block call');
      END IF;
      RAISE;
  END get_test_block;

  FUNCTION has_exception( p_statement       IN            VARCHAR2
                        , o_errors          IN OUT NOCOPY VARCHAR2
                        , o_sqlcode            OUT NOCOPY NUMBER
                        , o_sqlerrm            OUT NOCOPY VARCHAR2
                        , p_header_def      IN            VARCHAR2 DEFAULT NULL
                        , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN BOOLEAN
  IS
    l_script  VARCHAR2(1024 CHAR) := 'otap_logic.has_exception';
    l_block   VARCHAR2(32767);
    l_return  BOOLEAN;
  BEGIN
    l_return := FALSE;
    IF otap_logic.check_header(p_header_def, o_errors)
    THEN
      -- header valid, check statement
      l_block := otap_logic.get_test_block(p_statement, p_header_def);
      BEGIN
        EXECUTE IMMEDIATE l_block;
        l_return := FALSE;
        IF p_expected_result = otap_constants.OTAP_NUM_TEST_PASSED
        THEN
          o_errors  := o_errors || 'Expected exception missing for ' || l_block || ' ';
          o_sqlcode := NULL;
          o_sqlerrm := NULL;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          o_sqlcode := SQLCODE;
          o_sqlerrm := SQLERRM;
          l_return  := TRUE;
      END;
    ELSE
      -- header not valid, o_errors should be set, return TRUE but user error
      otap_log.log('-20100 invalid header', l_script, 'User error invalid header ' || p_header_def);
      o_sqlcode := -20100;
      o_sqlerrm := 'User error invalid header ' || p_header_def;
      o_errors  := o_errors || 'User error invalid header ' || p_header_def || ' ';
      l_return  := TRUE;
    END IF;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END has_exception;

  FUNCTION ok( p_boolean         IN            BOOLEAN
             , o_errors             OUT NOCOPY VARCHAR2
             , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
             )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.ok';
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_boolean IS NOT NULL
    THEN
      l_test_passed := CASE WHEN p_boolean THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      -- NULL is not a valid boolean
      l_errors := 'Not allowed: p_boolean(NULL)';
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END ok;

  FUNCTION is_eq( p_have            IN            VARCHAR2
                , p_want            IN            VARCHAR2
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.is_eq';
    l_test_passed   INTEGER;
    l_result        INTEGER;
    l_expected      INTEGER;
  BEGIN
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_want IS NOT NULL
    THEN
      IF p_have IS NOT NULL
      THEN
        l_result := CASE WHEN p_have = p_want THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      ELSE
        l_result := otap_constants.OTAP_NUM_TEST_FAILED;
      END IF;
    ELSE
      -- compare against NULL, p_want already checked
      l_result := CASE WHEN p_have IS NULL THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    END IF;
    l_test_passed := CASE WHEN l_expected = l_result THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    -- we expect currently no usage error only raise
    o_errors      := NULL;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' varchar2 call');
      END IF;
      RAISE;
  END is_eq; -- VARCHAR2

  FUNCTION is_eq( p_have            IN            NUMBER
                , p_want            IN            NUMBER
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.is_eq';
    l_test_passed   INTEGER;
    l_result        INTEGER;
    l_expected      INTEGER;
  BEGIN
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_want IS NOT NULL
    THEN
      IF p_have IS NOT NULL
      THEN
        l_result := CASE WHEN p_have = p_want THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      ELSE
        l_result := otap_constants.OTAP_NUM_TEST_FAILED;
      END IF;
    ELSE
      -- compare against NULL, p_want already checked
      l_result := CASE WHEN p_have IS NULL THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    END IF;
    l_test_passed := CASE WHEN l_expected = l_result THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    -- we expect currently no usage error only raise
    o_errors      := NULL;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' number call');
      END IF;
      RAISE;
  END is_eq; -- NUMBER

  FUNCTION is_eq( p_have            IN            DATE
                , p_want            IN            DATE
                , o_errors             OUT NOCOPY VARCHAR2
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.is_eq';
    l_test_passed   INTEGER;
    l_result        INTEGER;
    l_expected      INTEGER;
  BEGIN
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_want IS NOT NULL
    THEN
      IF p_have IS NOT NULL
      THEN
        l_result := CASE WHEN p_have = p_want THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      ELSE
        l_result := otap_constants.OTAP_NUM_TEST_FAILED;
      END IF;
    ELSE
      -- compare against NULL, p_want already checked
      l_result := CASE WHEN p_have IS NULL THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    END IF;
    l_test_passed := CASE WHEN l_expected = l_result THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    -- we expect currently no usage error only raise
    o_errors      := NULL;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' date call');
      END IF;
      RAISE;
  END is_eq; -- DATE

  FUNCTION match_regex( p_have            IN            VARCHAR2
                      , p_regex           IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_param           IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.match_regex';
    l_test_passed   INTEGER;
    l_count         INTEGER;
    l_expected      INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_regex IS NOT NULL
    THEN
      IF p_param IS NOT NULL
      THEN
        -- check parameter
        SELECT COUNT(*) INTO l_count FROM dual WHERE REGEXP_LIKE(p_param, '^[icmnx]*$');
        IF l_count = 1
        THEN
          SELECT COUNT(*) INTO l_count FROM dual WHERE REGEXP_LIKE(p_have, p_regex, p_param);
          l_test_passed := CASE WHEN l_count = 1 THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
        ELSE
          -- invalid parameter
          l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
          l_errors      := 'Not allowed: p_param(' || p_param || ') only i, c, m, n or x supported. Case sensitive.';
          -- log error
          otap_log.log(l_errors, l_script);
        END IF;
      ELSE
        -- leave fail on REGEXP_LIKE if p_have is NULL or params are wrong
        SELECT COUNT(*) INTO l_count FROM dual WHERE REGEXP_LIKE(p_have, p_regex);
        l_test_passed := CASE WHEN l_count = 1 THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      END IF;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors      := 'Not allowed: p_regex(NULL)';
      -- log error
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END match_regex;

  FUNCTION alike( p_have            IN            VARCHAR2
                , p_like            IN            VARCHAR2
                , o_errors             OUT NOCOPY VARCHAR2
                , p_case_sensitive  IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.alike';
    l_test_passed   INTEGER;
    l_count         INTEGER;
    l_expected      INTEGER;
    l_like          VARCHAR2(32767 CHAR);
    l_have          VARCHAR2(32767 CHAR);
    l_errors        VARCHAR2(32767 CHAR);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_like        := CASE WHEN p_case_sensitive = otap_constants.OTAP_NUM_TRUE THEN p_like ELSE UPPER(p_like) END;
    l_have        := CASE WHEN p_case_sensitive = otap_constants.OTAP_NUM_TRUE THEN p_have ELSE UPPER(p_have) END;
    IF p_like IS NOT NULL
    THEN
      -- leave fail on LIKE if p_have is NULL
      SELECT COUNT(*) INTO l_count FROM dual WHERE l_have LIKE l_like;
      l_test_passed := CASE WHEN l_count = 1 THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors      := 'Not allowed: p_like(NULL)';
      -- log error
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END alike;

  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlerrm         IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_header_def      IN            VARCHAR2 DEFAULT NULL
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.throws_ok';
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
    l_sqlerrm       VARCHAR2(32767 CHAR);
    l_sqlcode       NUMBER;
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF otap_logic.has_exception(p_statement, l_errors, l_sqlcode, l_sqlerrm, p_header_def, l_expected)
    THEN
      IF l_sqlerrm = p_sqlerrm
      THEN
        l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      ELSE
        -- decide which case happened
        IF l_sqlcode = -20100
        THEN
          -- invalid header, l_errors should be set and logged already
          l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        ELSE
          -- exception happened but does not match
          l_errors      := l_errors || 'Given error message does not match with ' || l_sqlerrm;
          l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
          otap_log.log(l_errors, l_script);
        END IF;
      END IF;
    ELSE
      -- no exception raised, l_errors should be set and logged already
      l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END throws_ok;

  FUNCTION throws_ok( p_statement       IN            VARCHAR2
                    , p_sqlcode         IN            NUMBER
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_header_def      IN            VARCHAR2 DEFAULT NULL
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.throws_ok';
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
    l_sqlerrm       VARCHAR2(32767 CHAR);
    l_sqlcode       NUMBER;
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF otap_logic.has_exception(p_statement, l_errors, l_sqlcode, l_sqlerrm, p_header_def, l_expected)
    THEN
      IF l_sqlcode = p_sqlcode
      THEN
        l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      ELSE
        -- decide which case happened
        IF l_sqlcode = -20100
        THEN
          -- invalid header, l_errors should be set and logged already
          l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        ELSE
          -- exception happened but does not match
          l_errors      := l_errors || 'Given error message does not match with ' || l_sqlerrm;
          l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
          otap_log.log(l_errors, l_script);
        END IF;
      END IF;
    ELSE
      -- no exception raised, l_errors should be set and logged already
      l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END throws_ok;

  FUNCTION throws_matches( p_statement       IN            VARCHAR2
                         , p_regex_sqlerrm   IN            VARCHAR2
                         , o_errors             OUT NOCOPY VARCHAR2
                         , p_param           IN            VARCHAR2 DEFAULT NULL
                         , p_header_def      IN            VARCHAR2 DEFAULT NULL
                         , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.throws_matches';
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_count         INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
    l_sqlerrm       VARCHAR2(32767 CHAR);
    l_sqlcode       NUMBER;
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_param IS NOT NULL
    THEN
      -- check parameter
      SELECT COUNT(*) INTO l_count FROM dual WHERE REGEXP_LIKE(p_param, '^[icmnx]*$');
    ELSE
      l_count := 1;
    END IF;
    IF l_count = 1
    THEN
      -- process the statement
      IF otap_logic.has_exception(p_statement, l_errors, l_sqlcode, l_sqlerrm, p_header_def, l_expected)
      THEN
        SELECT COUNT(*) INTO l_count FROM dual WHERE REGEXP_LIKE(l_sqlerrm, p_regex_sqlerrm, p_param);
        IF l_count = 1
        THEN
          l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
        ELSE
          -- decide which case happened
          IF l_sqlcode = -20100
          THEN
            -- invalid header, l_errors should be set and logged already
            l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
          ELSE
            -- exception happened but does not match
            l_errors      := l_errors || 'Given regular expression does not match with ' || l_sqlerrm;
            l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
            otap_log.log(l_errors, l_script);
          END IF;
        END IF;
      ELSE
        -- no exception raised, l_errors should be set and logged already
        l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
        otap_log.log(l_errors, l_script);
      END IF;
    ELSE
      -- invalid parameter
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors      := l_errors || 'Not allowed: p_param(' || p_param || ') only i, c, m, n or x supported. Case sensitive.';
      -- log error
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END throws_matches;

  FUNCTION throws_like( p_statement       IN            VARCHAR2
                      , p_like_sqlerrm    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_case_sensitive  IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                      , p_header_def      IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.throws_like';
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_count         INTEGER;
    l_like          VARCHAR2(32767 CHAR);
    l_have          VARCHAR2(32767 CHAR);
    l_errors        VARCHAR2(32767 CHAR);
    l_sqlerrm       VARCHAR2(32767 CHAR);
    l_sqlcode       NUMBER;
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_like_sqlerrm IS NOT NULL
    THEN
      -- process the statement
      IF otap_logic.has_exception(p_statement, l_errors, l_sqlcode, l_sqlerrm, p_header_def, l_expected)
      THEN
        l_like := CASE WHEN p_case_sensitive = otap_constants.OTAP_NUM_TRUE THEN p_like_sqlerrm ELSE UPPER(p_like_sqlerrm) END;
        l_have := CASE WHEN p_case_sensitive = otap_constants.OTAP_NUM_TRUE THEN l_sqlerrm ELSE UPPER(l_sqlerrm) END;
        SELECT COUNT(*) INTO l_count FROM dual WHERE l_have LIKE l_like;
        IF l_count = 1
        THEN
          l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
        ELSE
          -- decide which case happened
          IF l_sqlcode = -20100
          THEN
            -- invalid header, l_errors should be set and logged already
            l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
          ELSE
            -- exception happened but does not match
            l_errors      := l_errors || 'Given like expression does not match with ' || l_sqlerrm;
            l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
            otap_log.log(l_errors, l_script);
          END IF;
        END IF;
      ELSE
        -- no exception raised, l_errors should be set and logged already
        l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
        otap_log.log(l_errors, l_script);
      END IF;
    ELSE
      -- invalid like expression
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors      := l_errors || 'Not allowed: p_like_sqlerrm(NULL)';
      -- log error
      otap_log.log(l_errors, l_script);
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END throws_like;

END;
/