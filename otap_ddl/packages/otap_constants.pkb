-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_constants
AS
  -- for description see header file
  FUNCTION get_otap_user_role
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_USER_ROLE;
  END get_otap_user_role;

  FUNCTION get_otap_schema
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_SCHEMA;
  END get_otap_schema;

  FUNCTION get_otap_tablespace
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_TABLESPACE;
  END get_otap_tablespace;

  FUNCTION get_otap_num_true
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TRUE;
  END get_otap_num_true;

  FUNCTION get_otap_num_false
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_FALSE;
  END get_otap_num_false;

  FUNCTION get_otap_char_true
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_TRUE;
  END get_otap_char_true;

  FUNCTION get_otap_char_false
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_FALSE;
  END get_otap_char_false;

  FUNCTION get_otap_true_yes
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_TRUE_YES;
  END get_otap_true_yes;

  FUNCTION get_otap_false_no
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_FALSE_NO;
  END get_otap_false_no;

  FUNCTION get_otap_id_test_passed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_PASSED;
  END get_otap_id_test_passed;

  FUNCTION get_otap_id_test_failed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_FAILED;
  END get_otap_id_test_failed;

  FUNCTION get_otap_id_test_undefined
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_UNDEFINED;
  END get_otap_id_test_undefined;

  FUNCTION get_otap_char_test_passed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_TEST_PASSED;
  END get_otap_char_test_passed;

  FUNCTION get_otap_char_test_failed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_TEST_FAILED;
  END get_otap_char_test_failed;

  FUNCTION get_otap_char_test_undefined
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_TEST_UNDEFINED;
  END get_otap_char_test_undefined;

  FUNCTION get_otap_lf
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_LF;
  END get_otap_lf;

  FUNCTION get_otap_cfg_debug_mode
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CFG_DEBUG_MODE;
  END get_otap_cfg_debug_mode;

  FUNCTION get_otap_cfg_preserve_days
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CFG_PRESERVE_DAYS;
  END get_otap_cfg_preserve_days;

  FUNCTION get_otap_cfg_delete_delay
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CFG_DELETE_DELAY;
  END get_otap_cfg_delete_delay;

  FUNCTION get_otap_cfg_delete_batch_size
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CFG_DELETE_BATCH_SIZE;
  END get_otap_cfg_delete_batch_size;

  FUNCTION get_otap_default_prefix
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_PREFIX;
  END get_otap_default_prefix;

  FUNCTION get_otap_default_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_DELIMITER;
  END get_otap_default_delimiter;

  FUNCTION get_otap_default_test_set
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_TEST_SET;
  END get_otap_default_test_set;

  FUNCTION get_otap_default_test_group
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_TEST_GROUP;
  END get_otap_default_test_group;

  FUNCTION get_otap_default_test_name
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_TEST_NAME;
  END get_otap_default_test_name;

  FUNCTION translate_yes_no(p_bool_num IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
    l_return  VARCHAR2(10);
  BEGIN
    l_return := CASE p_bool_num
                  WHEN otap_constants.OTAP_NUM_TRUE
                  THEN otap_constants.OTAP_CHAR_TRUE_YES
                  WHEN otap_constants.OTAP_NUM_FALSE
                  THEN otap_constants.OTAP_CHAR_FALSE_NO
                  ELSE NULL
                END;
    RETURN l_return;
  END translate_yes_no;

  FUNCTION translate_bool(p_bool_num IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
    l_return  VARCHAR2(10);
  BEGIN
    l_return := CASE p_bool_num
                  WHEN otap_constants.OTAP_NUM_TRUE
                  THEN otap_constants.OTAP_CHAR_TRUE
                  WHEN otap_constants.OTAP_NUM_FALSE
                  THEN otap_constants.OTAP_CHAR_FALSE
                  ELSE NULL
                END;
    RETURN l_return;
  END translate_bool;

  FUNCTION translate_test_result(p_test_results IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
    l_return  VARCHAR2(10);
  BEGIN
    l_return := CASE p_test_results
                  WHEN otap_constants.OTAP_NUM_TEST_PASSED
                  THEN otap_constants.OTAP_CHAR_TEST_PASSED
                  WHEN otap_constants.OTAP_NUM_TEST_FAILED
                  THEN otap_constants.OTAP_CHAR_TEST_FAILED
                  WHEN otap_constants.OTAP_NUM_TEST_UNDEFINED
                  THEN otap_constants.OTAP_CHAR_TEST_UNDEFINED
                  ELSE NULL
                END;
    RETURN l_return;
  END translate_test_result;

END;
/