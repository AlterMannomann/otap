-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides the used constants of otap.
-- Requires a successful DBA setup and correct otap_setup_def.sql.

-- read setup configuration as written by DBA setup, path relative to setup caller
@@../setup/otap_setup_def.sql

CREATE OR REPLACE PACKAGE otap_constants
AS
  /**
  * This package contains all constants needed by otap. Every constant can be accessed via PL/SQL or as a get function.
  * This package is available to the otap user role defined in otap_setup_def.sql.
  */

  /*====================================== start package constants used by otap ======================================*/
  -- we do not know the size of the setup configuration variable, this can be used as a string size attack, package will
  -- fail being created. otap can't handle this, must rely on Oracle (hard to believe). Nevertheless names currently
  -- (until Oracle 23i) are limited to 128 chars, if not using special UTF chars.
  OTAP_USER_ROLE              CONSTANT VARCHAR2(256)  := '&OTAP_ROLE';
  OTAP_SCHEMA                 CONSTANT VARCHAR2(256)  := '&OTAP_USER';
  OTAP_TABLESPACE             CONSTANT VARCHAR2(256)  := '&OTAP_TABLESPACE';
  OTAP_NUM_TRUE               CONSTANT INTEGER        := 1;
  OTAP_NUM_FALSE              CONSTANT INTEGER        := 0;
  OTAP_CHAR_TRUE              CONSTANT CHAR(4)        := 'true';
  OTAP_CHAR_FALSE             CONSTANT CHAR(5)        := 'false';
  OTAP_CHAR_TRUE_YES          CONSTANT CHAR(3)        := 'Yes';
  OTAP_CHAR_FALSE_NO          CONSTANT CHAR(2)        := 'No';
  OTAP_NUM_TEST_PASSED        CONSTANT INTEGER        := 1;
  OTAP_NUM_TEST_FAILED        CONSTANT INTEGER        := -1;
  OTAP_NUM_TEST_UNDEFINED     CONSTANT INTEGER        := 0;
  OTAP_CHAR_TEST_PASSED       CONSTANT CHAR(6)        := 'Passed';
  OTAP_CHAR_TEST_FAILED       CONSTANT CHAR(6)        := 'Failed';
  OTAP_CHAR_TEST_UNDEFINED    CONSTANT CHAR(9)        := 'Undefined';
  OTAP_LF                     CONSTANT CHAR(1)        := CHR(10);
  OTAP_CFG_DEBUG_MODE         CONSTANT CHAR(10)       := 'DEBUG_MODE';
  OTAP_CFG_PRESERVE_DAYS      CONSTANT CHAR(13)       := 'PRESERVE_DAYS';
  OTAP_CFG_DELETE_DELAY       CONSTANT CHAR(12)       := 'DELETE_DELAY';
  OTAP_CFG_DELETE_BATCH_SIZE  CONSTANT CHAR(17)       := 'DELETE_BATCH_SIZE';
  OTAP_DEFAULT_PREFIX         CONSTANT CHAR(4)        := 'TEST';
  -- default name delimiter, $ and # are not recommended by Oracle and therefore not used
  OTAP_DEFAULT_DELIMITER      CONSTANT CHAR(1)        := '_';
  OTAP_DEFAULT_TEST_SET       CONSTANT CHAR(13)       := 'OTAP test set';
  OTAP_DEFAULT_TEST_GROUP     CONSTANT CHAR(15)       := 'OTAP test group';
  OTAP_DEFAULT_TEST_NAME      CONSTANT CHAR(14)       := 'OTAP test name';
  /*====================================== end package constants used by otap ======================================*/

  /*====================================== start package constant get functions ======================================*/
  -- @return otap_constants.OTAP_USER_ROLE
  FUNCTION get_otap_user_role
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_SCHEMA
  FUNCTION get_otap_schema
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_TABLESPACE
  FUNCTION get_otap_tablespace
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TRUE
  FUNCTION get_otap_num_true
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_FALSE
  FUNCTION get_otap_num_false
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_TRUE
  FUNCTION get_otap_char_true
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_FALSE
  FUNCTION get_otap_char_false
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_TRUE_YES
  FUNCTION get_otap_true_yes
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_FALSE_NO
  FUNCTION get_otap_false_no
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_PASSED
  FUNCTION get_otap_id_test_passed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_FAILED
  FUNCTION get_otap_id_test_failed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_UNDEFINED
  FUNCTION get_otap_id_test_undefined
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_TEST_PASSED
  FUNCTION get_otap_char_test_passed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_TEST_FAILED
  FUNCTION get_otap_char_test_failed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CHAR_TEST_UNDEFINED
  FUNCTION get_otap_char_test_undefined
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_LF
  FUNCTION get_otap_lf
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CFG_DEBUG_MODE
  FUNCTION get_otap_cfg_debug_mode
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CFG_PRESERVE_DAYS
  FUNCTION get_otap_cfg_preserve_days
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CFG_DELETE_DELAY
  FUNCTION get_otap_cfg_delete_delay
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_CFG_DELETE_BATCH_SIZE
  FUNCTION get_otap_cfg_delete_batch_size
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_PREFIX
  FUNCTION get_otap_default_prefix
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_DELIMITER
  FUNCTION get_otap_default_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_TEST_SET
  FUNCTION get_otap_default_test_set
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_TEST_GROUP
  FUNCTION get_otap_default_test_group
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_TEST_NAME
  FUNCTION get_otap_default_test_name
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  /*====================================== end package constant get functions ======================================*/

  /*====================================== start package constant utility functions ======================================*/

  /** FUNCTION otap.translate_yes_no
  * Translate the boolean number indicator to a text representation of Yes or No.
  *
  * @param p_bool_num A valid boolean number indicator 0 or 1, see OTAP_NUM_TRUE and OTAP_NUM_FALSE.
  *
  * @return The text representation Yes or No of the boolean number indicator or NULL, if indicator is not valid.
  */
  FUNCTION translate_yes_no(p_bool_num IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  /** FUNCTION otap.translate_bool
  * Translate the boolean number indicator to a text representation of true or false.
  *
  * @param p_bool_num A valid boolean number indicator 0 or 1, see OTAP_NUM_TRUE and OTAP_NUM_FALSE.
  *
  * @return The text representation true or false of the boolean number indicator or NULL, if indicator is not valid.
  */
  FUNCTION translate_bool(p_bool_num IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  /** FUNCTION otap.translate_test_result
  * Translate the test result indicator to a text representation.
  *
  * @param p_test_results A valid test result indicator, see OTAP_NUM_TEST_PASSED, OTAP_NUM_TEST_FAILED and OTAP_NUM_TEST_UNDEFINED.
  *
  * @return The text representation of the test result indicator or NULL, if indicator is not valid.
  */
  FUNCTION translate_test_result(p_test_results IN NUMBER)
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  /*====================================== end package constant utility functions ======================================*/
END;
/
GRANT EXECUTE ON otap_constants TO &OTAP_ROLE;