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
  * Furthermore it contains some simple basic string handling functions.
  * This package is available to the otap user role defined in otap_setup_def.sql.
  */

  /*====================================== start package constants used by otap ======================================*/
  -- we do not know the size of the setup configuration variable, this can be used as a string size attack, package will
  -- fail being created. otap can't handle this, must rely on Oracle (hard to believe). Nevertheless names currently
  -- (until Oracle 23i) are limited to 128 chars, if not using special UTF chars.

  -- the following constants have get functions that can be used in SQL selects
  OTAP_USER_ROLE                   CONSTANT VARCHAR2(256)  := '&OTAP_ROLE';
  OTAP_SCHEMA                      CONSTANT VARCHAR2(256)  := '&OTAP_USER';
  OTAP_TABLESPACE                  CONSTANT VARCHAR2(256)  := '&OTAP_TABLESPACE';
  OTAP_NUM_TRUE                    CONSTANT INTEGER        := 1;
  OTAP_NUM_FALSE                   CONSTANT INTEGER        := 0;
  OTAP_NUM_TEST_PASSED             CONSTANT INTEGER        := 1;
  OTAP_NUM_TEST_FAILED             CONSTANT INTEGER        := -1;
  OTAP_NUM_TEST_UNDEFINED          CONSTANT INTEGER        := 0;
  OTAP_REPORT_MIN_FILL_LENGTH      CONSTANT INTEGER        := 80;
  OTAP_REPORT_MAX_FILL_LENGTH      CONSTANT INTEGER        := 4000;
  OTAP_DEFAULT_DELIMITER           CONSTANT CHAR(1)        := '_';
  OTAP_ERROR_IDENTIFIER            CONSTANT CHAR(10)       := 'OTAP_ERROR';
  OTAP_CHAR_NA                     CONSTANT CHAR(3)        := 'N/A';
  OTAP_VAR_DELIMITER               CONSTANT CHAR(1)        := '@';

  -- no get functions for the following constants
  -- internal otap constants only usable within PLSQL
  OTAP_LF                          CONSTANT CHAR(1)        := CHR(10);
  -- default fix name delimiter, $ and # are not recommended by Oracle and therefore not configurable
  OTAP_CFG_DEBUG_MODE              CONSTANT CHAR(10)       := 'DEBUG_MODE';
  OTAP_CFG_DEFAULT_PREFIX          CONSTANT CHAR(14)       := 'DEFAULT_PREFIX';
  OTAP_CFG_DEFAULT_TEST_GROUP      CONSTANT CHAR(18)       := 'DEFAULT_TEST_GROUP';
  OTAP_CFG_DEFAULT_TEST_NAME       CONSTANT CHAR(17)       := 'DEFAULT_TEST_NAME';
  OTAP_CFG_DEFAULT_TEST_SET        CONSTANT CHAR(16)       := 'DEFAULT_TEST_SET';
  OTAP_CFG_DEFAULT_LAYOUT          CONSTANT CHAR(14)       := 'DEFAULT_LAYOUT';
  OTAP_CFG_DEFAULT_RESULT_LAYOUT   CONSTANT CHAR(21)       := 'DEFAULT_RESULT_LAYOUT';
  OTAP_CFG_DEFAULT_BORDER          CONSTANT CHAR(14)       := 'DEFAULT_BORDER';
  OTAP_CFG_DELETE_BATCH_SIZE       CONSTANT CHAR(17)       := 'DELETE_BATCH_SIZE';
  OTAP_CFG_DELETE_DELAY            CONSTANT CHAR(12)       := 'DELETE_DELAY';
  OTAP_CFG_ERRORS_TEMPLATE         CONSTANT CHAR(15)       := 'ERRORS_TEMPLATE';
  OTAP_CFG_ERROR_DETAILS_TEMPLATE  CONSTANT CHAR(22)       := 'ERROR_DETAILS_TEMPLATE';
  OTAP_CFG_FORMAT_GROUP_CHAR       CONSTANT CHAR(17)       := 'FORMAT_GROUP_CHAR';
  OTAP_CFG_FORMAT_HEADER_CHAR      CONSTANT CHAR(18)       := 'FORMAT_HEADER_CHAR';
  OTAP_CFG_FORMAT_NAME_CHAR        CONSTANT CHAR(16)       := 'FORMAT_NAME_CHAR';
  OTAP_CFG_FORMAT_RESULT_HEADER    CONSTANT CHAR(20)       := 'FORMAT_RESULT_HEADER';
  OTAP_CFG_FORMAT_SET_CHAR         CONSTANT CHAR(15)       := 'FORMAT_SET_CHAR';
  OTAP_CFG_GROUP_TEMPLATE          CONSTANT CHAR(14)       := 'GROUP_TEMPLATE';
  OTAP_CFG_NO_DATA_TEMPLATE        CONSTANT CHAR(16)       := 'NO_DATA_TEMPLATE';
  OTAP_CFG_PRESERVE_DAYS           CONSTANT CHAR(13)       := 'PRESERVE_DAYS';
  OTAP_CFG_SESSION_ID_TEMPLATE     CONSTANT CHAR(19)       := 'SESSION_ID_TEMPLATE';
  OTAP_CFG_SET_TEMPLATE            CONSTANT CHAR(12)       := 'SET_TEMPLATE';
  OTAP_CFG_SUMMARY_TEMPLATE        CONSTANT CHAR(16)       := 'SUMMARY_TEMPLATE';
  OTAP_CFG_TEST_NAME_TEMPLATE      CONSTANT CHAR(18)       := 'TEST_NAME_TEMPLATE';
  OTAP_CFG_RESULT_LINE_TEMPLATE    CONSTANT CHAR(20)       := 'RESULT_LINE_TEMPLATE';
  OTAP_CFG_COUNT_DESC_TEMPLATE     CONSTANT CHAR(19)       := 'COUNT_DESC_TEMPLATE';
  OTAP_CFG_REPORT_TOTAL_TEMPLATE   CONSTANT CHAR(21)       := 'REPORT_TOTAL_TEMPLATE';
  OTAP_CFG_FN_HAS_TABLE_TEMPLATE   CONSTANT CHAR(21)       := 'FN_HAS_TABLE_TEMPLATE';
  OTAP_CFG_FN_HAS_COLUMN_TEMPLATE  CONSTANT CHAR(22)       := 'FN_HAS_COLUMN_TEMPLATE';
  OTAP_CFG_FN_HAS_PACKAGE_TEMPLATE CONSTANT CHAR(23)       := 'FN_HAS_PACKAGE_TEMPLATE';
  OTAP_CFG_TEXT_FALSE              CONSTANT CHAR(10)       := 'TEXT_FALSE';
  OTAP_CFG_TEXT_FALSE_NO           CONSTANT CHAR(13)       := 'TEXT_FALSE_NO';
  OTAP_CFG_TEXT_REPORT_END         CONSTANT CHAR(15)       := 'TEXT_REPORT_END';
  OTAP_CFG_TEXT_REPORT_TOTAL       CONSTANT CHAR(17)       := 'TEXT_REPORT_TOTAL';
  OTAP_CFG_TEXT_REPORT_START       CONSTANT CHAR(17)       := 'TEXT_REPORT_START';
  OTAP_CFG_TEXT_RESULT_HEADER      CONSTANT CHAR(18)       := 'TEXT_RESULT_HEADER';
  OTAP_CFG_TEXT_TEST_COUNT_HEADER  CONSTANT CHAR(22)       := 'TEXT_TEST_COUNT_HEADER';
  OTAP_CFG_TEXT_TEST_COUNT_NAME    CONSTANT CHAR(20)       := 'TEXT_TEST_COUNT_NAME';
  OTAP_CFG_TEXT_SUMMARY_ERROR      CONSTANT CHAR(18)       := 'TEXT_SUMMARY_ERROR';
  OTAP_CFG_TEXT_SUMMARY_SUCCESS    CONSTANT CHAR(20)       := 'TEXT_SUMMARY_SUCCESS';
  OTAP_CFG_TEXT_TEST_FAILED        CONSTANT CHAR(16)       := 'TEXT_TEST_FAILED';
  OTAP_CFG_TEXT_TEST_PASSED        CONSTANT CHAR(16)       := 'TEXT_TEST_PASSED';
  OTAP_CFG_TEXT_TEST_UNDEFINED     CONSTANT CHAR(19)       := 'TEXT_TEST_UNDEFINED';
  OTAP_CFG_TEXT_TRUE               CONSTANT CHAR(9)        := 'TEXT_TRUE';
  OTAP_CFG_TEXT_TRUE_YES           CONSTANT CHAR(13)       := 'TEXT_TRUE_YES';

  -- fallback constants for access failure situations, defaults and checks
  OTAP_PRESERVE_DAYS               CONSTANT INTEGER        := 1;
  OTAP_PRESERVE_DAYS_MIN           CONSTANT INTEGER        := 1;
  OTAP_PRESERVE_DAYS_MAX           CONSTANT INTEGER        := 7;
  OTAP_DELETE_DELAY                CONSTANT INTEGER        := 10;
  OTAP_DELETE_DELAY_MIN            CONSTANT INTEGER        := 1;
  OTAP_DELETE_DELAY_MAX            CONSTANT INTEGER        := 600;
  OTAP_DELETE_BATCH_SIZE           CONSTANT INTEGER        := 1000;
  OTAP_DELETE_BATCH_SIZE_MIN       CONSTANT INTEGER        := 100;
  OTAP_DELETE_BATCH_SIZE_MAX       CONSTANT INTEGER        := 10000;
  OTAP_PREFIX_MAX_SIZE             CONSTANT INTEGER        := 4;
  OTAP_DEBUG_MODE                  CONSTANT INTEGER        := 0;
  OTAP_FORMAT_HEADER_CHAR          CONSTANT CHAR(1)        := '=';
  OTAP_FORMAT_SET_CHAR             CONSTANT CHAR(1)        := '*';
  OTAP_FORMAT_GROUP_CHAR           CONSTANT CHAR(1)        := '+';
  OTAP_FORMAT_NAME_CHAR            CONSTANT CHAR(1)        := '-';
  OTAP_TEXT_TRUE                   CONSTANT CHAR(4)        := 'true';
  OTAP_TEXT_FALSE                  CONSTANT CHAR(5)        := 'false';
  OTAP_TEXT_TRUE_YES               CONSTANT CHAR(3)        := 'Yes';
  OTAP_TEXT_FALSE_NO               CONSTANT CHAR(2)        := 'No';
  OTAP_TEXT_TEST_PASSED            CONSTANT CHAR(6)        := 'Passed';
  OTAP_TEXT_TEST_FAILED            CONSTANT CHAR(6)        := 'FAILED';
  OTAP_TEXT_TEST_UNDEFINED         CONSTANT CHAR(9)        := 'UNDEFINED';
  OTAP_DEFAULT_PREFIX              CONSTANT CHAR(4)        := 'TEST';
  OTAP_DEFAULT_TEST_SET            CONSTANT CHAR(13)       := 'OTAP test set';
  OTAP_DEFAULT_TEST_GROUP          CONSTANT CHAR(15)       := 'OTAP test group';
  OTAP_DEFAULT_TEST_NAME           CONSTANT CHAR(14)       := 'OTAP test name';
  OTAP_TEXT_REPORT_START           CONSTANT CHAR(24)       := 'OTAP test summary report';
  OTAP_TEXT_REPORT_TOTAL           CONSTANT CHAR(23)       := 'OTAP test report totals';
  OTAP_TEXT_REPORT_END             CONSTANT CHAR(33)       := 'OTAP test summary report finished';
  OTAP_TEXT_RESULT_HEADER          CONSTANT CHAR(44)       := 'Result    Setup     Runtime             Test';
  OTAP_FORMAT_RESULT_HEADER        CONSTANT CHAR(80)       := '--------- --------- ------------------- ----------------------------------------';
  OTAP_TEXT_TEST_COUNT_HEADER      CONSTANT CHAR(18)       := 'Test count summary';
  OTAP_TEXT_TEST_COUNT_NAME        CONSTANT CHAR(18)       := 'Session test count';
  OTAP_TEXT_SUMMARY_SUCCESS        CONSTANT CHAR(7)        := 'SUCCESS';
  OTAP_TEXT_SUMMARY_ERROR          CONSTANT CHAR(5)        := 'ERROR';
  OTAP_SUMMARY_TEMPLATE            CONSTANT CHAR(76)       := '@status@ runtime: @runtime@ (runs: @runs@ errors: @errors@ issues: @issues@)';
  OTAP_ERRORS_TEMPLATE             CONSTANT CHAR(24)       := '@testname@ error details';
  OTAP_ERROR_DETAILS_TEMPLATE      CONSTANT CHAR(24)       := '@testdesc@: @errorinfo@';
  OTAP_NO_DATA_TEMPLATE            CONSTANT CHAR(56)       := 'NO_DATA - no tests found for test session id @sessionid@';
  OTAP_SESSION_ID_TEMPLATE         CONSTANT CHAR(23)       := 'Session id: @sessionid@';
  OTAP_SET_TEMPLATE                CONSTANT CHAR(19)       := 'Test set: @testset@';
  OTAP_GROUP_TEMPLATE              CONSTANT CHAR(23)       := 'Test group: @testgroup@';
  OTAP_TEST_NAME_TEMPLATE          CONSTANT CHAR(21)       := 'Test name: @testname@';
  OTAP_RESULT_LINE_TEMPLATE        CONSTANT CHAR(45)       := '@teststate@ @issuestate@ @runtime@ @testdesc@';
  OTAP_COUNT_DESC_TEMPLATE         CONSTANT CHAR(46)       := '@testsrun@ from @testsexpected@ tests executed';
  OTAP_REPORT_TOTAL_TEMPLATE       CONSTANT CHAR(66)       := 'sets: @sets@ groups: @groups@ names: @names@ descriptions: @descs@';
  OTAP_FN_HAS_TABLE_TEMPLATE       CONSTANT CHAR(41)       := 'Table @schema@.@tablename@ exists';
  OTAP_FN_HAS_COLUMN_TEMPLATE      CONSTANT CHAR(61)       := 'Column @column@ (@schema@.@tablename@) exists';
  OTAP_FN_HAS_PACKAGE_TEMPLATE     CONSTANT CHAR(70)       := 'Package @schema@.@package@ exists (@packagetype@ state @packagestate@)';
  OTAP_LAYOUT_RIGHT                CONSTANT CHAR(1)        := 'R';
  OTAP_LAYOUT_MIDDLE               CONSTANT CHAR(1)        := 'M';
  OTAP_LAYOUT_LEFT                 CONSTANT CHAR(1)        := 'L';
  OTAP_LAYOUT_DEFAULT              CONSTANT CHAR(1)        := 'M';
  OTAP_RESULT_LAYOUT_DEFAULT       CONSTANT CHAR(1)        := 'L';
  OTAP_BORDER_DEFAULT              CONSTANT INTEGER        := 5;
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
  -- @return otap_constants.OTAP_NUM_TEST_PASSED
  FUNCTION get_otap_num_test_passed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_FAILED
  FUNCTION get_otap_num_test_failed
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_NUM_TEST_UNDEFINED
  FUNCTION get_otap_num_test_undefined
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_REPORT_MIN_FILL_LENGTH
  FUNCTION get_otap_report_min_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_REPORT_MAX_FILL_LENGTH
  FUNCTION get_otap_report_max_fill_length
    RETURN NUMBER
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
  -- @return otap_constants.OTAP_DEFAULT_DELIMITER
  FUNCTION get_otap_default_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_ERROR_IDENTIFIER
  FUNCTION get_otap_error_identifier
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_CHAR_NA
  FUNCTION get_otap_char_na
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;
-- @return otap_constants.OTAP_VAR_DELIMITER
  FUNCTION get_otap_var_delimiter
    RETURN VARCHAR2
    DETERMINISTIC
    PARALLEL_ENABLE
  ;

  /*====================================== end package constant utility functions ======================================*/
END;
/
GRANT EXECUTE ON otap_constants TO &OTAP_ROLE;