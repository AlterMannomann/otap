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
  * This package contains all application wide constants needed by otap. Every constant can be accessed via PL/SQL.
  * Some constants provide a get function for use in SQL statements.
  * This package is available to the otap user role defined in otap_setup_def.sql.
  */

  /*====================================== start package constants used by otap ======================================*/

  -- the following constants have get functions that can be used in SQL selects
  OTAP_INTERNAL_VERSION_NR CONSTANT CHAR(14)            := 'v1.0.0-alpha.1';
  OTAP_INTERNAL_NAME       CONSTANT CHAR(38)            := 'otap - Oracle Test Automation Protocol';
  OTAP_INTERNAL_COPYRIGHT1 CONSTANT CHAR(80)            := '(C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
  OTAP_INTERNAL_COPYRIGHT2 CONSTANT CHAR(54)            := 'and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
  OTAP_INTERNAL_COPYRIGHT3 CONSTANT CHAR(76)            := 'Not allowed to be used as AI training material without explicite permission.';
  -- we do not know the size of the setup configuration variable, this can be used as a string size attack, package will
  -- fail being created. otap can't handle this, must rely on Oracle (hard to believe). Nevertheless names currently
  -- (until Oracle 23i) are limited to 128 chars.
  OTAP_INTERNAL_USER_ROLE  CONSTANT VARCHAR2(128 CHAR)  := '&OTAP_ROLE';
  OTAP_INTERNAL_SCHEMA     CONSTANT VARCHAR2(128 CHAR)  := '&OTAP_USER';
  OTAP_INTERNAL_TABLESPACE CONSTANT VARCHAR2(128 CHAR)  := '&OTAP_TABLESPACE';
  OTAP_NUM_TRUE            CONSTANT INTEGER             := 1;
  OTAP_NUM_FALSE           CONSTANT INTEGER             := 0;
  OTAP_NUM_TEST_PASSED     CONSTANT INTEGER             := 1;
  OTAP_NUM_TEST_FAILED     CONSTANT INTEGER             := -1;
  OTAP_NUM_TEST_UNDEFINED  CONSTANT INTEGER             := 0;
  OTAP_NUM_MIN_FILL_LENGTH CONSTANT INTEGER             := 80;
  OTAP_NUM_MAX_FILL_LENGTH CONSTANT INTEGER             := 4000;
  -- default fix name delimiter, $ and # are not recommended by Oracle and therefore not configurable
  OTAP_INTERNAL_DELIMITER  CONSTANT CHAR(1)             := '_';
  OTAP_INTERNAL_ERROR      CONSTANT CHAR(10)            := 'OTAP_ERROR';
  OTAP_INTERNAL_NA         CONSTANT CHAR(3)             := 'N/A';
  OTAP_INTERNAL_VAR        CONSTANT CHAR(1)             := '@';
  OTAP_CONFIG_TYPE_NUMBER  CONSTANT CHAR(6)             := 'NUMBER';
  OTAP_CONFIG_TYPE_CHAR    CONSTANT CHAR(4)             := 'CHAR';

  -- no get functions for the following constants
  -- internal otap constants only usable within PLSQL
  OTAP_INTERNAL_LF                    CONSTANT CHAR(1)        := CHR(10);
  OTAP_NUM_PREFIX_MAX_SIZE            CONSTANT INTEGER        := 4;
  OTAP_LAYOUT_RIGHT                   CONSTANT CHAR(1)        := 'R';
  OTAP_LAYOUT_MIDDLE                  CONSTANT CHAR(1)        := 'M';
  OTAP_LAYOUT_LEFT                    CONSTANT CHAR(1)        := 'L';
  OTAP_LABEL_UPPER                    CONSTANT CHAR(1)        := 'U';
  OTAP_LABEL_LOWER                    CONSTANT CHAR(1)        := 'L';
  OTAP_LABEL_INIT_CAP                 CONSTANT CHAR(1)        := 'I';
  OTAP_TYPE_VAR                       CONSTANT CHAR(6)        := '@type@';
  -- otap log needs to know the debug mode access name, therefore in otap_constants, other access identifiers are in otap_util
  OTAP_CFG_DEBUG_MODE                 CONSTANT CHAR(10)       := 'DEBUG_MODE';
  -- fallback constants for access failure situations, defaults and checks
  OTAP_FALLBACK_BORDER                CONSTANT INTEGER        := 5;
  OTAP_FALLBACK_BORDER_MIN            CONSTANT INTEGER        := 2;
  OTAP_FALLBACK_BORDER_MAX            CONSTANT INTEGER        := 10;
  OTAP_FALLBACK_PRESERVE_DAYS         CONSTANT INTEGER        := 1;
  OTAP_FALLBACK_PRESERVE_DAYS_MIN     CONSTANT INTEGER        := 1;
  OTAP_FALLBACK_PRESERVE_DAYS_MAX     CONSTANT INTEGER        := 7;
  OTAP_FALLBACK_DELETE_DELAY          CONSTANT INTEGER        := 10;
  OTAP_FALLBACK_DELETE_DELAY_MIN      CONSTANT INTEGER        := 1;
  OTAP_FALLBACK_DELETE_DELAY_MAX      CONSTANT INTEGER        := 600;
  OTAP_FALLBACK_DELETE_BATCH_SIZE     CONSTANT INTEGER        := 1000;
  OTAP_FALLBACK_DELETE_BATCH_SIZE_MIN CONSTANT INTEGER        := 100;
  OTAP_FALLBACK_DELETE_BATCH_SIZE_MAX CONSTANT INTEGER        := 10000;
  OTAP_FALLBACK_FORMAT_HEADER_CHAR    CONSTANT CHAR(1)        := '=';
  OTAP_FALLBACK_FORMAT_SET_CHAR       CONSTANT CHAR(1)        := '*';
  OTAP_FALLBACK_FORMAT_GROUP_CHAR     CONSTANT CHAR(1)        := '+';
  OTAP_FALLBACK_FORMAT_NAME_CHAR      CONSTANT CHAR(1)        := '-';
  OTAP_FALLBACK_TEXT_TRUE             CONSTANT CHAR(4)        := 'true';
  OTAP_FALLBACK_TEXT_FALSE            CONSTANT CHAR(5)        := 'false';
  OTAP_FALLBACK_TEXT_TRUE_YES         CONSTANT CHAR(3)        := 'Yes';
  OTAP_FALLBACK_TEXT_FALSE_NO         CONSTANT CHAR(2)        := 'No';
  OTAP_FALLBACK_TEXT_TEST_PASSED      CONSTANT CHAR(6)        := 'Passed';
  OTAP_FALLBACK_TEXT_TEST_FAILED      CONSTANT CHAR(6)        := 'FAILED';
  OTAP_FALLBACK_TEXT_TEST_UNDEFINED   CONSTANT CHAR(9)        := 'UNDEFINED';
  OTAP_FALLBACK_DEFAULT_PREFIX        CONSTANT CHAR(4)        := 'TEST';
  OTAP_FALLBACK_DEFAULT_TEST_SET      CONSTANT CHAR(13)       := 'OTAP test set';
  OTAP_FALLBACK_DEFAULT_TEST_GROUP    CONSTANT CHAR(15)       := 'OTAP test group';
  OTAP_FALLBACK_DEFAULT_TEST_NAME     CONSTANT CHAR(14)       := 'OTAP test name';
  OTAP_FALLBACK_DEFAULT_LANGUAGE      CONSTANT CHAR(3)        := 'en';
  OTAP_FALLBACK_LAYOUT_DEFAULT        CONSTANT CHAR(1)        := 'M';
  OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT CONSTANT CHAR(1)        := 'L';
  OTAP_FALLBACK_LABEL_DEFAULT         CONSTANT CHAR(1)        := 'L';
  /*====================================== end package constants used by otap ======================================*/

  /*====================================== start package constant get functions ======================================*/
  -- @return otap version information
  FUNCTION get_version
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  -- @return otap_constants.OTAP_INTERNAL_USER_ROLE
  FUNCTION get_otap_user_role
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_INTERNAL_SCHEMA
  FUNCTION get_otap_schema
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_INTERNAL_TABLESPACE
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
  -- @return otap_constants.OTAP_NUM_TEST_PASSED
  FUNCTION get_otap_num_test_passed
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_FAILED
  FUNCTION get_otap_num_test_failed
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_UNDEFINED
  FUNCTION get_otap_num_test_undefined
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_MIN_FILL_LENGTH
  FUNCTION get_otap_num_min_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_MAX_FILL_LENGTH
  FUNCTION get_otap_num_max_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_INTERNAL_DELIMITER
  FUNCTION get_otap_internal_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_INTERNAL_ERROR
  FUNCTION get_otap_internal_error
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_INTERNAL_NA
  FUNCTION get_otap_internal_na
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_INTERNAL_VAR
  FUNCTION get_otap_internal_var
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_CONFIG_TYPE_NUMBER
  FUNCTION get_otap_config_type_number
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_CONFIG_TYPE_CHAR
  FUNCTION get_otap_config_type_char
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  /*====================================== end package constant utility functions ======================================*/
END;
/
GRANT EXECUTE ON otap_constants TO &OTAP_ROLE;