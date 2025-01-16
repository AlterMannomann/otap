-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_logic
AS
  -- for description see header file
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

  FUNCTION match_like( p_have            IN            VARCHAR2
                     , p_like            IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_logic.match_like';
    l_test_passed   INTEGER;
    l_count         INTEGER;
    l_expected      INTEGER;
    l_errors        VARCHAR2(32767 CHAR);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    IF p_like IS NOT NULL
    THEN
      -- leave fail on LIKE if p_have is NULL
      SELECT COUNT(*) INTO l_count FROM dual WHERE p_have LIKE p_like;
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
  END match_like;

END;
/