-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_util
AS
  -- for description see header file
  FUNCTION is_number(p_varchar_number IN VARCHAR2)
    RETURN BOOLEAN
  IS
    l_number NUMBER;
    l_char   VARCHAR2(128 CHAR);
  BEGIN
    -- try to convert the number, if it fails return FALSE
    l_number := TO_NUMBER(TRIM(p_varchar_number));
    l_char   := TRIM(TO_CHAR(l_number));
    IF l_char = TRIM(p_varchar_number)
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_number;

  FUNCTION is_integer(p_varchar_number IN VARCHAR2)
    RETURN BOOLEAN
  IS
    l_number  NUMBER;
    l_floored NUMBER;
  BEGIN
    IF is_number(p_varchar_number)
    THEN
      l_number  := TO_NUMBER(p_varchar_number);
      l_floored := FLOOR(l_number);
      RETURN (l_number = l_floored);
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_integer;

  PROCEDURE validate_config_name( p_config_name IN VARCHAR2
                                , p_del_trigger IN BOOLEAN  DEFAULT FALSE
                                )
  IS
    l_script VARCHAR2(1024 CHAR) := 'otap_util.validate_config_name';
  BEGIN

    IF NOT p_del_trigger
    THEN
      -- check name against a fixed list, disabled during development
      IF p_config_name IS NULL -- p_config_name NOT IN (...)
      THEN
        -- log the error
        otap_log.log('-20001 The configuration name: ' || NVL(p_config_name, 'NULL') || ' is not supported', l_script);
        -- only direct testing could call this currently as table has a NOT NULL constraint
        RAISE_APPLICATION_ERROR(-20001, 'The configuration name: ' || NVL(p_config_name, 'NULL') || ' is not supported.');
      END IF;
    ELSE
      -- check name against a fixed list, disabled during development
      IF p_config_name IS NOT NULL -- p_config_name IN (...)
      THEN
        -- log the error
        otap_log.log('-20006 The configuration name: ' || NVL(p_config_name, 'NULL') || ' cannot be deleted.', l_script);
        -- only direct testing could call this currently as table has a NOT NULL constraint
        RAISE_APPLICATION_ERROR(-20006, 'The configuration name: ' || NVL(p_config_name, 'NULL') || ' cannot be deleted.');
      END IF;
    END IF;
  END validate_config_name;

  FUNCTION validate_config_value( p_config_name   IN            VARCHAR2
                                , p_config_value  IN            VARCHAR2
                                , p_config_type   IN            VARCHAR2
                                , p_translatable  IN OUT NOCOPY NUMBER
                                , p_max_length    IN            NUMBER
                                , p_raise         IN            BOOLEAN  DEFAULT TRUE
                                )
    RETURN VARCHAR2
  IS
    l_script       VARCHAR2(1024 CHAR)  := 'otap_util.validate_config_value';
    l_config_value VARCHAR2(32767 CHAR);
    l_config_name  VARCHAR2(128 CHAR);
    l_integer      INTEGER;
  BEGIN
    l_config_value := TRIM(p_config_value);
    l_config_name  := otap_string.reduce(p_config_name, 128);
    -- we must check against NULL as we are in a before trigger
    IF    l_config_value        IS NULL
       OR LENGTH(l_config_value) = 0
    THEN
      -- no defaults for NULL values, always raise
      otap_log.log('-20002 The given config_value is not supported. Empty or only spaces.', l_script);
      RAISE_APPLICATION_ERROR(-20002, 'The given config_value is not supported. Empty or only spaces.');
    END IF;
    -- check type also mandatory, no default
    IF NVL(p_config_type, otap_constants.OTAP_INTERNAL_NA) NOT IN (otap_constants.OTAP_CONFIG_TYPE_CHAR, otap_constants.OTAP_CONFIG_TYPE_NUMBER)
    THEN
      otap_log.log('-20003 The given config_type: ' || NVL(p_config_type, 'NULL') || ' is not supported. Only CHAR or NUMBER supported.', l_script);
      RAISE_APPLICATION_ERROR(-20003, 'The given config_type: ' || NVL(p_config_type, 'NULL') || ' is not supported. Only CHAR or NUMBER supported.');
    END IF;
    -- check length if given
    IF     NVL(p_max_length, 0)   > 0
       AND LENGTH(l_config_value) > NVL(p_max_length, 0)
    THEN
      -- we do not cut numbers, raise
      IF    p_config_type = 'NUMBER'
         OR p_raise
      THEN
        otap_log.log('-20004 The given config_value: ' || l_config_value || ' exceeds the maximum length allowed: ' || p_max_length || '.', l_script);
        RAISE_APPLICATION_ERROR(-20004, 'The given config_value: ' || l_config_value || ' exceeds the maximum length allowed: ' || p_max_length || '.');
      ELSE
        -- cut the string if not raise
        l_config_value := otap_string.reduce(l_config_value, p_max_length);
      END IF;
    ELSIF LENGTH(l_config_value) > 4000
    THEN
      -- OTAP_CONFIG supports only 4000 chars
      -- we do not cut numbers, raise
      IF    p_config_type = 'NUMBER'
         OR p_raise
      THEN
        otap_log.log('-20004 The given config_value: ' || l_config_value || ' exceeds the maximum length allowed: 4000.', l_script);
        RAISE_APPLICATION_ERROR(-20004, 'The given config_value: ' || l_config_value || ' exceeds the maximum length allowed: 4000.');
      ELSE
        -- cut the string if not raise
        l_config_value := otap_string.reduce(l_config_value, 4000);
      END IF;
    END IF;
    -- check number, always raise
    IF     p_config_type = 'NUMBER'
       AND NOT is_number(l_config_value)
    THEN
      otap_log.log('-20005 The given config_value: ' || l_config_value || ' cannot be converted to a number.', l_script);
      RAISE_APPLICATION_ERROR(-20005, 'The given config_value: ' || l_config_value || ' cannot be converted to a number.');
    END IF;
    -- check translatable and correct it if needed
    IF p_translatable NOT IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
    THEN
      otap_log.log('Invalid value for TRANSLATABLE: ' || p_translatable || ' use default.', l_script);
      p_translatable := otap_constants.OTAP_NUM_FALSE;
    END IF;
    IF     (   p_config_type = 'NUMBER'
            OR l_config_name IN (otap_util.CFG_DEFAULT_PREFIX, otap_util.CFG_DEFAULT_LAYOUT, otap_util.CFG_DEFAULT_RESULT_LAYOUT)
           )
       AND p_translatable = TRIM(TO_CHAR(otap_constants.OTAP_NUM_TRUE))
    THEN
      otap_log.log('Invalid config_name: ' || l_config_name || ' for TRANSLATABLE: ' || p_translatable || ' use default.', l_script);
      p_translatable := otap_constants.OTAP_NUM_FALSE;
    END IF;
    -- now check constraints on specific config values not managed by other constraints
    IF l_config_name = otap_util.CFG_PRESERVE_DAYS
    THEN
      IF is_integer(l_config_value)
      THEN
        l_integer := TO_NUMBER(l_config_value);
        -- check range
        IF l_config_value NOT BETWEEN otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MIN AND otap_constants.OTAP_FALLBACK_PRESERVE_DAYS_MAX
        THEN
            otap_log.log('Invalid value for PRESERVE_DAYS: ' || l_config_value || ' use default.', l_script);
            l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS));
        END IF;
      ELSE
        -- set default
        otap_log.log('Invalid value for PRESERVE_DAYS: ' || l_config_value || ' use default.', l_script);
        l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_PRESERVE_DAYS));
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DELETE_DELAY
    THEN
      IF is_integer(l_config_value)
      THEN
        l_integer := TO_NUMBER(l_config_value);
        -- check range
        IF l_integer NOT BETWEEN otap_constants.OTAP_FALLBACK_DELETE_DELAY_MIN AND otap_constants.OTAP_FALLBACK_DELETE_DELAY_MAX
        THEN
          otap_log.log('Invalid value for DELETE_DELAY: ' || l_config_value || ' use default.', l_script);
          l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY));
        END IF;
      ELSE
        -- set default
        otap_log.log('Invalid value for DELETE_DELAY: ' || l_config_value || ' use default.', l_script);
        l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_DELAY));
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DELETE_BATCH_SIZE
    THEN
      IF is_integer(l_config_value)
      THEN
        l_integer := TO_NUMBER(l_config_value);
        -- check range
        IF l_integer NOT BETWEEN otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN AND otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX
        THEN
          otap_log.log('Invalid value for DELETE_BATCH_SIZE: ' || l_config_value || ' use default.', l_script);
          l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE));
        END IF;
      ELSE
        -- set default
        otap_log.log('Invalid value for DELETE_BATCH_SIZE: ' || l_config_value || ' use default.', l_script);
        l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_DELETE_BATCH_SIZE));
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DEFAULT_BORDER
    THEN
      IF is_integer(l_config_value)
      THEN
        l_integer := TO_NUMBER(l_config_value);
        -- check range
        IF l_integer NOT BETWEEN otap_constants.OTAP_FALLBACK_BORDER_MIN AND otap_constants.OTAP_FALLBACK_BORDER_MAX
        THEN
          otap_log.log('Invalid value for DEFAULT_BORDER: ' || l_config_value || ' use default.', l_script);
          l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER));
        END IF;
      ELSE
        -- set default
        otap_log.log('Invalid value for DEFAULT_BORDER: ' || l_config_value || ' use default.', l_script);
        l_config_value := TRIM(TO_CHAR(otap_constants.OTAP_FALLBACK_BORDER));
      END IF;
    END IF;
    IF l_config_name = otap_constants.OTAP_CFG_DEBUG_MODE
    THEN
      -- hardcoded minimal check, this is highly internal
      IF l_config_value NOT IN ('0', '1')
      THEN
        otap_log.log('Invalid value for DEBUG_MODE: ' || l_config_value || ' use default.', l_script);
        l_config_value := '0';
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DEFAULT_LAYOUT
    THEN
      IF l_config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_RIGHT)
      THEN
        otap_log.log('Invalid value for DEFAULT_LAYOUT: ' || l_config_value || ' use default.', l_script);
        l_config_value := otap_constants.OTAP_LAYOUT_MIDDLE;
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DEFAULT_RESULT_LAYOUT
    THEN
      IF l_config_value NOT IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_RIGHT)
      THEN
        otap_log.log('Invalid value for DEFAULT_RESULT_LAYOUT: ' || l_config_value || ' use default.', l_script);
        l_config_value := otap_constants.OTAP_LAYOUT_LEFT;
      END IF;
    END IF;
    IF l_config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN
    THEN
      IF l_config_value NOT IN (otap_constants.OTAP_LABEL_LOWER, otap_constants.OTAP_LABEL_INIT_CAP, otap_constants.OTAP_LABEL_UPPER)
      THEN
        otap_log.log('Invalid value for DEFAULT_LABEL_LAYOUT: ' || l_config_value || ' use default.', l_script);
        l_config_value := otap_constants.OTAP_LAYOUT_LEFT;
      END IF;
    END IF;
    RETURN l_config_value;
  END validate_config_value;

  PROCEDURE validate_translatable(p_otap_identifier IN VARCHAR2)
  IS
    l_script          VARCHAR2(1024 CHAR) := 'otap_util.validate_translatable';
    l_is_translatable INTEGER;
    l_exists          INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO l_exists
      FROM otap_config
     WHERE config_name = TRIM(UPPER(p_otap_identifier))
    ;
    IF l_exists > 0
    THEN
      SELECT COUNT(*)
        INTO l_is_translatable
        FROM otap_config
      WHERE config_name   = TRIM(UPPER(p_otap_identifier))
        AND translatable  = otap_constants.OTAP_NUM_TRUE
      ;
      IF l_is_translatable = 0
      THEN
        -- log the error
        otap_log.log('-20020 The given identifier: ' || NVL(p_otap_identifier, 'NULL') || ' cannot be translated. Ask your admin to adjust this configuration item.', l_script);
        -- only direct testing could call this currently as table has a NOT NULL constraint
        RAISE_APPLICATION_ERROR(-20020, 'The given identifier: ' || NVL(p_otap_identifier, 'NULL') || ' cannot be translated. Ask your admin to adjust this configuration item.');
      END IF;
    END IF;
  END validate_translatable;

  FUNCTION get_config_value(p_config_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_script      VARCHAR2(1024 CHAR)            := 'otap_util.get_config_value';
    l_return      otap_config.config_value%TYPE;
    l_has_config  INTEGER;
    l_has_label   INTEGER;
    l_label_col   VARCHAR2(1 CHAR);
  BEGIN
    l_return := otap_constants.OTAP_INTERNAL_ERROR;
    SELECT COUNT(*)
      INTO l_has_config
      FROM otap_identifiers_v
     WHERE otap_identifier = UPPER(p_config_name)
    ;
    SELECT COUNT(*)
      INTO l_has_label
      FROM otap_config
     WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN
    ;
    IF l_has_label = 1
    THEN
      SELECT config_value
        INTO l_label_col
        FROM otap_config
       WHERE config_name = otap_util.CFG_DEFAULT_LABEL_COLUMN
      ;
      l_label_col := NVL(l_label_col, otap_constants.OTAP_LABEL_LOWER);
    ELSE
      l_label_col := otap_constants.OTAP_LABEL_LOWER;
    END IF;
    IF l_has_config = 1
    THEN
      SELECT CASE l_label_col
               WHEN otap_constants.OTAP_LABEL_LOWER
               THEN label_text_lower
               WHEN otap_constants.OTAP_LABEL_INIT_CAP
               THEN label_text_cap
               WHEN otap_constants.OTAP_LABEL_UPPER
               THEN label_text_upper
               ELSE label_text_lower
             END
        INTO l_return
        FROM otap_identifiers_v
      WHERE otap_identifier = UPPER(p_config_name)
      ;
    ELSE
      l_return := otap_constants.OTAP_INTERNAL_ERROR;
      otap_log.log('Invalid config_name: ' || UPPER(p_config_name) || ' return error identifier. Count result: ' || l_has_config, l_script, 'SELECT COUNT(*) INTO l_has_config FROM otap_config WHERE config_name = UPPER(p_config_name)');
    END IF;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'SELECT config_value INTO l_return FROM otap_config WHERE config_name = UPPER(p_config_name)');
      RAISE;
  END get_config_value;

  FUNCTION get_config_number(p_config_name IN VARCHAR2)
    RETURN NUMBER
  IS
    l_script      VARCHAR2(1024 CHAR)             := 'otap_util.get_config_number';
    l_varchar     otap_config.config_value%TYPE;
    l_return      INTEGER; -- only integer in configuration
    l_has_config  INTEGER;
  BEGIN
    l_return := NULL;
    SELECT COUNT(*)
      INTO l_has_config
      FROM otap_config
     WHERE config_name = UPPER(p_config_name)
       AND config_type = 'NUMBER'
    ;
    IF l_has_config = 1
    THEN
      l_varchar := otap_util.get_config_value(p_config_name);
      IF otap_util.is_integer(l_varchar)
      THEN
        l_return := TO_NUMBER(l_varchar);
      ELSE
        l_return := NULL;
        otap_log.log('Invalid numeric value for config_name: ' || UPPER(p_config_name) || ' return NULL. Value: ' || l_varchar, l_script, 'otap_util.is_integer(l_varchar)');
      END IF;
    ELSE
      l_return := NULL;
      otap_log.log('Invalid numeric config_name: ' || UPPER(p_config_name) || ' return NULL. Count result: ' || l_has_config, l_script, 'SELECT COUNT(*) INTO l_has_config FROM otap_config WHERE config_name = UPPER(p_config_name) AND config_type = ''NUMBER''');
    END IF;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script);
      RAISE;
  END get_config_number;

  FUNCTION get_label_id(p_object_type IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_script VARCHAR2(1024 CHAR) := 'otap_util.get_label_id';
    l_return VARCHAR2(256 CHAR);
    l_count  INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO l_count
      FROM otap_labels_mv
     WHERE otap_label_source = UPPER(p_object_type)
    ;
    IF l_count = 1
    THEN
      SELECT otap_string.reduce(otap_identifier, 256)
        INTO l_return
        FROM otap_labels_mv
       WHERE otap_label_source = UPPER(p_object_type)
      ;
    ELSE
      otap_log.log('Invalid object type: ' || p_object_type, l_script);
      l_return := otap_util.CFG_LABEL_UNDEFINED;
    END IF;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script);
      RAISE;
  END get_label_id;

  FUNCTION get_length_test_state
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_TEST_FAILED
                          , otap_util.CFG_TEXT_TEST_PASSED
                          , otap_util.CFG_TEXT_TEST_UNDEFINED
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_test_state', 'Get MAX length for config values');
      RAISE;
  END get_length_test_state;

  FUNCTION get_length_summary_state
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_SUMMARY_ERROR
                          , otap_util.CFG_TEXT_SUMMARY_SUCCESS
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_summary_state', 'Get MAX length for config values');
      RAISE;
  END get_length_summary_state;

  FUNCTION get_length_headers
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_REPORT_START
                          , otap_util.CFG_TEXT_REPORT_END
                          , otap_util.CFG_TEXT_REPORT_TOTAL
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_headers', 'Get MAX length for config values');
      RAISE;
  END get_length_headers;

  FUNCTION get_length_result_headers
    RETURN NUMBER
  IS
    l_return INTEGER;
  BEGIN
    SELECT MAX(LENGTH(config_value))
      INTO l_return
      FROM otap_config
     WHERE config_name IN ( otap_util.CFG_TEXT_RESULT_HEADER
                          , otap_util.CFG_TEXT_RESULT_LINE
                          )
    ;
    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.get_length_result_headers', 'Get MAX length for config values');
      RAISE;
  END get_length_result_headers;


  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  IS
    l_translation otap_config.config_value%TYPE;
  BEGIN
    l_translation := CASE p_test_passed
                       WHEN otap_constants.OTAP_NUM_TEST_PASSED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_PASSED)
                       WHEN otap_constants.OTAP_NUM_TEST_FAILED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_FAILED)
                       WHEN otap_constants.OTAP_NUM_TEST_UNDEFINED
                       THEN otap_util.get_config_value(otap_util.CFG_TEXT_TEST_UNDEFINED)
                       ELSE otap_constants.OTAP_INTERNAL_ERROR
                     END
    ;
    RETURN l_translation;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.test_result_to_text', 'Translate test state to text');
      RAISE;
  END test_result_to_text;

  FUNCTION build_msg( p_cfg_template  IN VARCHAR2
                    , p_type_label    IN VARCHAR2 DEFAULT NULL
                    , p_param1        IN VARCHAR2 DEFAULT NULL
                    , p_param1_value  IN VARCHAR2 DEFAULT NULL
                    , p_param2        IN VARCHAR2 DEFAULT NULL
                    , p_param2_value  IN VARCHAR2 DEFAULT NULL
                    , p_param3        IN VARCHAR2 DEFAULT NULL
                    , p_param3_value  IN VARCHAR2 DEFAULT NULL
                    , p_param4        IN VARCHAR2 DEFAULT NULL
                    , p_param4_value  IN VARCHAR2 DEFAULT NULL
                    , p_param5        IN VARCHAR2 DEFAULT NULL
                    , p_param5_value  IN VARCHAR2 DEFAULT NULL
                    , p_description   IN VARCHAR2 DEFAULT NULL
                    )
    RETURN VARCHAR2
  IS
    l_script        VARCHAR2(256 CHAR) := 'otap_util.build_msg';
    l_text_result   VARCHAR2(4000 CHAR);
    l_label         VARCHAR2(256 CHAR);
    l_var_count     INTEGER;
  BEGIN
    IF p_description IS NOT NULL
    THEN
      l_text_result := otap_string.reduce(p_description, 4000);
    ELSE
      IF p_cfg_template IS NULL
      THEN
        l_text_result := otap_constants.OTAP_INTERNAL_ERROR || ' ' || l_script || ' missing description and template identifier';
        otap_log.log(l_text_result, l_script);
      ELSE
        l_text_result := otap_util.get_config_value(p_cfg_template);
        IF l_text_result = otap_constants.OTAP_INTERNAL_ERROR
        THEN
          l_text_result := otap_constants.OTAP_INTERNAL_ERROR || ' ' || l_script || ' invalid template identifier ' || p_cfg_template;
          otap_log.log(l_text_result, l_script);
        ELSE
          -- check variables, only modify if present, otherwise text is delivered as is
          l_var_count := REGEXP_COUNT(l_text_result, '@');
          -- check also that @@ comes in pairs like valid variables
          IF l_var_count != 0 AND MOD(l_var_count, 2) = 0
          THEN
            -- check type present
            IF     p_type_label                                      IS NOT NULL
               AND INSTR(l_text_result, otap_constants.OTAP_TYPE_VAR) > 0
            THEN
              l_label := otap_util.get_config_value(p_type_label);
              -- do nothing on errors
              IF l_label != otap_constants.OTAP_INTERNAL_ERROR
              THEN
                -- replace if exists in template
                l_text_result := REPLACE(l_text_result, otap_constants.OTAP_TYPE_VAR, l_label);
              ELSE
                otap_log.log('Type ignored, Invalid label used: ' || p_type_label, l_script);
              END IF;
            END IF;
            -- check vars and replace if condition met
            IF p_param1_value IS NOT NULL
            THEN
              IF     p_param1                   IS NOT NULL
                 AND REGEXP_COUNT(p_param1, '@') = 2
              THEN
                -- replace, may work, may not
                l_text_result := REPLACE(l_text_result, p_param1, p_param1_value);
              ELSE
                -- ignore, log error
                otap_log.log('Value without variable name: ' || p_param1_value || ' or invalid parameter: ' || p_param1, l_script);
              END IF;
            END IF;
            IF p_param2_value IS NOT NULL
            THEN
              IF     p_param2                   IS NOT NULL
                 AND REGEXP_COUNT(p_param2, '@') = 2
              THEN
                -- replace, may work, may not
                l_text_result := REPLACE(l_text_result, p_param2, p_param2_value);
              ELSE
                -- ignore, log error
                otap_log.log('Value without variable name: ' || p_param2_value || ' or invalid parameter: ' || p_param2, l_script);
              END IF;
            END IF;
            IF p_param3_value IS NOT NULL
            THEN
              IF     p_param3                   IS NOT NULL
                 AND REGEXP_COUNT(p_param3, '@') = 2
              THEN
                -- replace, may work, may not
                l_text_result := REPLACE(l_text_result, p_param3, p_param3_value);
              ELSE
                -- ignore, log error
                otap_log.log('Value without variable name: ' || p_param3_value || ' or invalid parameter: ' || p_param3, l_script);
              END IF;
            END IF;
            IF p_param4_value IS NOT NULL
            THEN
              IF     p_param4                   IS NOT NULL
                 AND REGEXP_COUNT(p_param4, '@') = 2
              THEN
                -- replace, may work, may not
                l_text_result := REPLACE(l_text_result, p_param4, p_param4_value);
              ELSE
                -- ignore, log error
                otap_log.log('Value without variable name: ' || p_param4_value || ' or invalid parameter: ' || p_param4, l_script);
              END IF;
            END IF;
            IF p_param5_value IS NOT NULL
            THEN
              IF     p_param5                   IS NOT NULL
                 AND REGEXP_COUNT(p_param5, '@') = 2
              THEN
                -- replace, may work, may not
                l_text_result := REPLACE(l_text_result, p_param5, p_param5_value);
              ELSE
                -- ignore, log error
                otap_log.log('Value without variable name: ' || p_param5_value || ' or invalid parameter: ' || p_param5, l_script);
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN l_text_result;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Prepare message from template');
      RAISE;
    RETURN l_text_result;
  END build_msg;

  PROCEDURE write_test_result( p_to_delete         IN NUMBER
                             , p_test_passed       IN NUMBER
                             , p_test_session_id   IN NUMBER
                             , p_test_executor     IN VARCHAR2
                             , p_test_set          IN VARCHAR2
                             , p_db_user           IN VARCHAR2
                             , p_db_schema         IN VARCHAR2
                             , p_test_group        IN VARCHAR2
                             , p_test_start        IN TIMESTAMP
                             , p_test_end          IN TIMESTAMP
                             , p_test_name         IN VARCHAR2
                             , p_test_desc         IN VARCHAR2
                             , p_test_errors       IN VARCHAR2 DEFAULT NULL
                             )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script      VARCHAR2(256 CHAR) := 'otap_util.write_test_result';
    l_to_delete   NUMBER;
    l_test_passed NUMBER;
    l_errors      otap_results.test_errors%TYPE;
  BEGIN
    l_to_delete   := CASE
                       WHEN p_to_delete IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
                       THEN p_to_delete
                       ELSE otap_constants.OTAP_NUM_TRUE
                     END
    ;
    -- this is an error and must be handled
    IF p_test_passed NOT IN (otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED)
    THEN
      l_errors := otap_string.reduce('Invalid test result: ' || p_test_passed || ' ' || p_test_errors, 4000);
      l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    ELSE
      l_test_passed := p_test_passed;
      l_errors := p_test_errors;
    END IF;
    INSERT INTO otap_results
      ( to_delete
      , test_passed
      , test_session_id
      , test_executor
      , test_set
      , db_user
      , db_schema
      , test_group
      , test_start
      , test_end
      , test_name
      , test_desc
      , test_errors
      ) VALUES ( l_to_delete
               , l_test_passed
               , p_test_session_id
               , p_test_executor
               , p_test_set
               , p_db_user
               , p_db_schema
               , p_test_group
               , p_test_start
               , p_test_end
               , p_test_name
               , p_test_desc
               , l_errors
               )
    ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'INSERT into otap_results');
      ROLLBACK;
      RAISE;
  END write_test_result;

  PROCEDURE result_cleanup
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script            VARCHAR2(256 CHAR) := 'otap_util.result_cleanup';
    l_delete_before     DATE;
    l_delete_start      DATE;
    l_delete_batch_size NUMBER;
    l_delete_delay      NUMBER;
    l_row_counter       NUMBER;
    l_processed         NUMBER;
    l_delete_msg        VARCHAR2(32767 CHAR);
    CURSOR cur_delete_tests(cp_delete_before IN DATE)
    IS
      SELECT *
        FROM otap_results
       WHERE test_run_date < cp_delete_before
         AND to_delete     = otap_constants.OTAP_NUM_TRUE
    ;
  BEGIN
    -- read config values before starting, values will not change until finished
    l_delete_start      := SYSDATE;
    l_delete_before     := TRUNC(SYSDATE - otap_util.get_config_number(otap_util.CFG_PRESERVE_DAYS));
    l_delete_batch_size := otap_util.get_config_number(otap_util.CFG_DELETE_BATCH_SIZE);
    l_delete_delay      := otap_util.get_config_number(otap_util.CFG_DELETE_DELAY);
    l_row_counter       := 0;
    l_processed         := 0;
    l_delete_msg        := 'Start delete with batch size ' || l_delete_batch_size || ', delay ' || l_delete_delay || ' seconds. Delete all marked records older than ' || TO_CHAR(l_delete_before, 'YYYY-MM-DD HH24:MI:SS') || '.';
    otap_log.log(l_delete_msg, l_script, 'Procedure start', 'OTAP_DEBUG');
    FOR rec IN cur_delete_tests(l_delete_before)
    LOOP
      IF l_row_counter >= l_delete_batch_size
      THEN
        l_delete_msg := 'Batch size reached, commit and wait. Processed records ' || l_processed || '.';
        otap_log.log(l_delete_msg, l_script, 'Batch size reached and wait', 'OTAP_DEBUG');
        -- commit the batch
        COMMIT;
        -- reset counter
        l_row_counter := 0;
        -- wait defined time
        DBMS_SESSION.SLEEP(l_delete_delay);
      END IF;
      DELETE FROM otap_results WHERE test_run_id = rec.test_run_id AND test_run_date = rec.test_run_date;
      l_row_counter := l_row_counter + 1;
      l_processed   := l_processed + 1;
    END LOOP;
    l_delete_msg := 'Processed ' || l_processed || ' records for delete. Started at ' || TO_CHAR(l_delete_start, 'YYYY-MM-DD HH24:MI:SS') || ' finished at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS');
    otap_log.log(l_delete_msg, l_script, 'Procedure end', 'OTAP_DEBUG');
    DBMS_OUTPUT.PUT_LINE(l_delete_msg);
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'DELETE FROM otap_results');
  END result_cleanup;

  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  IS
    l_result NUMBER;
  BEGIN
    -- use UNION not GREATEST to get a result in any case
    SELECT MAX(str_length) AS max_length
      INTO l_result
      FROM (SELECT otap_constants.get_otap_num_min_fill_length AS str_length FROM dual
             UNION ALL
            SELECT MAX(LENGTH(test_set)) FROM otap_results WHERE test_session_id = p_session_id
             UNION ALL
            SELECT MAX(LENGTH(test_group)) FROM otap_results WHERE test_session_id = p_session_id
             UNION ALL
            SELECT MAX(LENGTH(test_name)) FROM otap_results WHERE test_session_id = p_session_id
             UNION ALL
            SELECT MAX(LENGTH(test_desc)) FROM otap_results WHERE test_session_id = p_session_id
           )
    ;
    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, 'otap_util.max_text_size', 'Get max text size for a given session id');
      RAISE;
  END max_text_size;

END;
/