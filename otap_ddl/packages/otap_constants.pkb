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

  FUNCTION get_otap_report_min_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_REPORT_MIN_FILL_LENGTH;
  END get_otap_report_min_fill_length;

  FUNCTION get_otap_report_max_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_REPORT_MAX_FILL_LENGTH;
  END get_otap_report_max_fill_length;

  FUNCTION get_otap_default_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_DEFAULT_DELIMITER;
  END get_otap_default_delimiter;

  FUNCTION get_otap_error_identifier
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_ERROR_IDENTIFIER;
  END get_otap_error_identifier;

  FUNCTION get_otap_char_na
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_CHAR_NA;
  END get_otap_char_na;

  FUNCTION get_otap_var_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  IS
  BEGIN
    RETURN otap_constants.OTAP_VAR_DELIMITER;
  END get_otap_var_delimiter;

END;
/