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
    IF NVL(p_config_type, otap_constants.OTAP_INTERNAL_NA) NOT IN ('CHAR', 'NUMBER')
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
      IF l_config_value != '1'
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
    RETURN l_config_value;
  END validate_config_value;

END;
/