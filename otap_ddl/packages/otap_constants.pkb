-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_constants
AS
  -- for description see header file
  FUNCTION get_version
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN LPAD(otap_constants.OTAP_INTERNAL_NAME, 59, ' ') || otap_constants.OTAP_INTERNAL_LF ||
           LPAD(otap_constants.OTAP_INTERNAL_VERSION_NR, 47, ' ') || otap_constants.OTAP_INTERNAL_LF ||
           otap_constants.OTAP_INTERNAL_COPYRIGHT1 || otap_constants.OTAP_INTERNAL_LF ||
           otap_constants.OTAP_INTERNAL_COPYRIGHT2
    ;
  END get_version;

  FUNCTION get_otap_user_role
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_USER_ROLE;
  END get_otap_user_role;

  FUNCTION get_otap_schema
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_SCHEMA;
  END get_otap_schema;

  FUNCTION get_otap_tablespace
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_TABLESPACE;
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

  FUNCTION get_otap_num_test_passed
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_PASSED;
  END get_otap_num_test_passed;

  FUNCTION get_otap_num_test_failed
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_FAILED;
  END get_otap_num_test_failed;

  FUNCTION get_otap_num_test_undefined
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_TEST_UNDEFINED;
  END get_otap_num_test_undefined;

  FUNCTION get_otap_num_min_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
  END get_otap_num_min_fill_length;

  FUNCTION get_otap_num_max_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_NUM_MAX_FILL_LENGTH;
  END get_otap_num_max_fill_length;

  FUNCTION get_otap_internal_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_DELIMITER;
  END get_otap_internal_delimiter;

  FUNCTION get_otap_internal_error
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_ERROR;
  END get_otap_internal_error;

  FUNCTION get_otap_internal_na
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_NA;
  END get_otap_internal_na;

  FUNCTION get_otap_internal_var
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_INTERNAL_VAR;
  END get_otap_internal_var;

  FUNCTION get_otap_config_type_number
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CONFIG_TYPE_NUMBER;
  END get_otap_config_type_number;

  FUNCTION get_otap_config_type_char
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CONFIG_TYPE_CHAR;
  END get_otap_config_type_char;

END;
/