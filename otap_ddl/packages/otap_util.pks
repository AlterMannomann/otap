-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE otap_util
AS
  /**
  * Provides basic table management and utility functions for otap. Used in triggers and packages.
  * Owes the configuration access constants.
  */
  -- configuration access constants apart from DEBUG_MODE which is in otap_constants.
  CFG_DEFAULT_BORDER               CONSTANT CHAR(14)             := 'DEFAULT_BORDER';
  CFG_DEFAULT_LAYOUT               CONSTANT CHAR(14)             := 'DEFAULT_LAYOUT';
  CFG_DEFAULT_PREFIX               CONSTANT CHAR(14)             := 'DEFAULT_PREFIX';
  CFG_DEFAULT_RESULT_LAYOUT        CONSTANT CHAR(21)             := 'DEFAULT_RESULT_LAYOUT';
  CFG_DEFAULT_TEST_GROUP           CONSTANT CHAR(18)             := 'DEFAULT_TEST_GROUP';
  CFG_DEFAULT_TEST_NAME            CONSTANT CHAR(17)             := 'DEFAULT_TEST_NAME';
  CFG_DEFAULT_TEST_SET             CONSTANT CHAR(16)             := 'DEFAULT_TEST_SET';
  CFG_DELETE_BATCH_SIZE            CONSTANT CHAR(17)             := 'DELETE_BATCH_SIZE';
  CFG_DELETE_DELAY                 CONSTANT CHAR(12)             := 'DELETE_DELAY';
  CFG_FORMAT_GROUP_CHAR            CONSTANT CHAR(17)             := 'FORMAT_GROUP_CHAR';
  CFG_FORMAT_HEADER_CHAR           CONSTANT CHAR(18)             := 'FORMAT_HEADER_CHAR';
  CFG_FORMAT_NAME_CHAR             CONSTANT CHAR(16)             := 'FORMAT_NAME_CHAR';
  CFG_FORMAT_SET_CHAR              CONSTANT CHAR(15)             := 'FORMAT_SET_CHAR';
  CFG_PRESERVE_DAYS                CONSTANT CHAR(13)             := 'PRESERVE_DAYS';
  CFG_TEMPLATE_COUNT_DESC          CONSTANT CHAR(19)             := 'TEMPLATE_COUNT_DESC';
  CFG_TEMPLATE_ERRORS              CONSTANT CHAR(15)             := 'TEMPLATE_ERRORS';
  CFG_TEMPLATE_ERROR_DETAILS       CONSTANT CHAR(22)             := 'TEMPLATE_ERROR_DETAILS';
  CFG_TEMPLATE_EXISTS              CONSTANT CHAR(15)             := 'TEMPLATE_EXISTS';
  CFG_TEMPLATE_FN_HAS_COLUMN       CONSTANT CHAR(22)             := 'TEMPLATE_FN_HAS_COLUMN';
  CFG_TEMPLATE_FN_HAS_PACKAGE      CONSTANT CHAR(23)             := 'TEMPLATE_FN_HAS_PACKAGE';
  CFG_TEMPLATE_FN_HAS_PROCEDURE    CONSTANT CHAR(25)             := 'TEMPLATE_FN_HAS_PROCEDURE';
  CFG_TEMPLATE_FN_HAS_TABLE        CONSTANT CHAR(21)             := 'TEMPLATE_FN_HAS_TABLE';
  CFG_TEMPLATE_FN_HAS_TRIGGER      CONSTANT CHAR(23)             := 'TEMPLATE_FN_HAS_TRIGGER';
  CFG_TEMPLATE_GROUP               CONSTANT CHAR(14)             := 'TEMPLATE_GROUP';
  CFG_TEMPLATE_NO_DATA             CONSTANT CHAR(16)             := 'TEMPLATE_NO_DATA';
  CFG_TEMPLATE_REPORT_TOTAL        CONSTANT CHAR(21)             := 'TEMPLATE_REPORT_TOTAL';
  CFG_TEMPLATE_RESULT_LINE         CONSTANT CHAR(20)             := 'TEMPLATE_RESULT_LINE';
  CFG_TEMPLATE_SESSION_ID          CONSTANT CHAR(19)             := 'TEMPLATE_SESSION_ID';
  CFG_TEMPLATE_SET                 CONSTANT CHAR(12)             := 'TEMPLATE_SET';
  CFG_TEMPLATE_SUMMARY             CONSTANT CHAR(16)             := 'TEMPLATE_SUMMARY';
  CFG_TEMPLATE_TEST_NAME           CONSTANT CHAR(18)             := 'TEMPLATE_TEST_NAME';
  CFG_TEMPLATE_XEXISTS             CONSTANT CHAR(16)             := 'TEMPLATE_XEXISTS';
  CFG_TEXT_FALSE                   CONSTANT CHAR(10)             := 'TEXT_FALSE';
  CFG_TEXT_FALSE_NO                CONSTANT CHAR(13)             := 'TEXT_FALSE_NO';
  CFG_TEXT_REPORT_END              CONSTANT CHAR(15)             := 'TEXT_REPORT_END';
  CFG_TEXT_REPORT_START            CONSTANT CHAR(17)             := 'TEXT_REPORT_START';
  CFG_TEXT_REPORT_TOTAL            CONSTANT CHAR(17)             := 'TEXT_REPORT_TOTAL';
  CFG_TEXT_RESULT_HEADER           CONSTANT CHAR(18)             := 'TEXT_RESULT_HEADER';
  CFG_TEXT_RESULT_LINE             CONSTANT CHAR(16)             := 'TEXT_RESULT_LINE';
  CFG_TEXT_SUMMARY_ERROR           CONSTANT CHAR(18)             := 'TEXT_SUMMARY_ERROR';
  CFG_TEXT_SUMMARY_SUCCESS         CONSTANT CHAR(20)             := 'TEXT_SUMMARY_SUCCESS';
  CFG_TEXT_TEST_COUNT_HEADER       CONSTANT CHAR(22)             := 'TEXT_TEST_COUNT_HEADER';
  CFG_TEXT_TEST_COUNT_NAME         CONSTANT CHAR(20)             := 'TEXT_TEST_COUNT_NAME';
  CFG_TEXT_TEST_FAILED             CONSTANT CHAR(16)             := 'TEXT_TEST_FAILED';
  CFG_TEXT_TEST_PASSED             CONSTANT CHAR(16)             := 'TEXT_TEST_PASSED';
  CFG_TEXT_TEST_UNDEFINED          CONSTANT CHAR(19)             := 'TEXT_TEST_UNDEFINED';
  CFG_TEXT_TRUE                    CONSTANT CHAR(9)              := 'TEXT_TRUE';
  CFG_TEXT_TRUE_YES                CONSTANT CHAR(13)             := 'TEXT_TRUE_YES';

  /** FUNCTION otap_util.is_number
  * Checks if a VARCHAR2 can be converted to a number and back. No format options supported.
  * Simple TO_NUMBER without parameters.
  *
  * @param p_varchar_number The string to verify for number transformation.
  *
  * @return TRUE if string can be translated to a number otherwise FALSE.
  */
  FUNCTION is_number(p_varchar_number IN VARCHAR2)
    RETURN BOOLEAN
  ;

  /** FUNCTION otap_util.is_integer
  * Checks if a VARCHAR2 can be converted to a integer and back.
  *
  * @param p_varchar_number The string to verify for number transformation.
  *
  * @return TRUE if string can be translated to a integer otherwise FALSE.
  */
  FUNCTION is_integer(p_varchar_number IN VARCHAR2)
    RETURN BOOLEAN
  ;

  /** PROCEDURE otap_util.validate_config_name
  * Validates the given CONFIG_NAME. If valid does nothing. If invalid will raise an application
  * exception. To be used in OTAP_CONFIG triggers.
  *
  * @param p_config_name The configuration name as given, usally :NEW.config_name or :OLD.config_name.
  * @param p_del_trigger Changes the logic for DELETE triggers.
  *
  * @throws -20001 The configuration name is not supported
  * @throws -20006 The configuration name cannot be deleted.
  */
  PROCEDURE validate_config_name( p_config_name IN VARCHAR2
                                , p_del_trigger IN BOOLEAN  DEFAULT FALSE
                                )
  ;

  /** PROCEDURE otap_util.validate_config_type
  * Validates the given configuration. If valid does nothing. If invalid will raise an application
  * exception. To be used in OTAP_CONFIG triggers. Checks the internal constraints on special configuration values.
  *
  * @param p_config_name The configuration name as given, usally :NEW.config_name or :OLD.config_name.
  * @param p_config_value The configuration value as given, usally :NEW.config_value or :OLD.config_value.
  * @param p_config_type The configuration type as given, usally :NEW.config_type or :OLD.config_type. Only CHAR and NUMBER supported.
  * @param p_translatable The translatable indicator as given, usally :NEW.translatable or :OLD.translatable. Only allowed for CHAR to be set to 1.
  * @param p_max_length The configuration max length for the config value as given, usally :NEW.config_max_length or :OLD.config_max_length.
  * @param p_raise By default raise on validation errors, if FALSE deliver default value if available.
  *
  * @return The config value as is if tests passed or the default value, if p_raise is FALSE and value not valid.
  *
  * @throws -20002 The given config_value is not supported. Empty or only spaces.
  * @throws -20003 The given config_type is not supported. Only CHAR or NUMBER supported.
  * @throws -20004 The given config_value exceeds the maximum length allowed.
  * @throws -20005 The given config_value cannot be converted to a number.
  */
  FUNCTION validate_config_value( p_config_name   IN            VARCHAR2
                                , p_config_value  IN            VARCHAR2
                                , p_config_type   IN            VARCHAR2
                                , p_translatable  IN OUT NOCOPY NUMBER
                                , p_max_length    IN            NUMBER
                                , p_raise         IN            BOOLEAN  DEFAULT TRUE
                                )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_util.get_config_value
  * Returns a config value for a given configuration as is. Return value is always VARCHAR2.
  * On errors return otap error identifier or raise exception.
  *
  * @param p_config_name A valid configuration name.
  *
  * @return The config value for the given config name as string or the otap error identifier.
  */
  FUNCTION get_config_value(p_config_name IN VARCHAR2)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_util.get_config_value
  * Returns a config value for a given configuration as NUMBER. Return value is always NUMBER.
  * On errors return NULL or raise exception.
  *
  * @param p_config_name A valid configuration name that has configured NUMBER as type.
  *
  * @return The config value for the given config name as number or NULL.
  */
  FUNCTION get_config_number(p_config_name IN VARCHAR2)
    RETURN NUMBER
  ;


  /** FUNCTION otap_util.get_length_test_state
  * Checks the defined text representations of passed, failed and undefined to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of test states defined in OTAP_CONFIG.
  */
  FUNCTION get_length_test_state
    RETURN NUMBER
  ;


  /** FUNCTION otap_util.get_length_summary_state
  * Checks the defined text representations of summary state SUCCESS and ERROR to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of summary states defined in OTAP_CONFIG.
  */
  FUNCTION get_length_summary_state
    RETURN NUMBER
  ;

  /** FUNCTION otap_util.get_length_headers
  * Checks the defined text representations of report headers to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of report headers defined in OTAP_CONFIG.
  */
  FUNCTION get_length_headers
    RETURN NUMBER
  ;

  /** FUNCTION otap_util.get_length_result_headers
  * Checks the defined text representations of result headers to
  * determine the maximum length a string needs. Used during formatting reports.
  *
  * @return The maximum length of result headers defined in OTAP_CONFIG.
  */
  FUNCTION get_length_result_headers
    RETURN NUMBER
  ;


  /** FUNCTION otap_util.test_result_to_text
  * Translate the numeric test state to the defined text representation. If test state
  * is not valid, will return the otap error indicator OTAP_ERROR.
  *
  * @param p_test_passed The numeric test state indicator.
  *
  * @return The text representation as defined in OTAP_CONFIG for the given test state or OTAP_ERROR.
  */
  FUNCTION test_result_to_text(p_test_passed IN NUMBER)
    RETURN VARCHAR
  ;

  /** PROCEDURE otap_util.write_test_result
  * Just persist the given values. Minimal handling of input. Invalid TO_DELETE
  * and TEST_PASSED will be set to the default. NULL values neither checked nor allowed
  * for parameters without default. May throw exceptions.
  *
  * @param p_to_delete A valid to delete value, either 0 or 1.
  * @param p_test_passed A valid test passed, either 0, -1 or 1.
  * @param p_test_session_id A valid current test session id.
  * @param p_test_executor A valid executor / session user name.
  * @param p_test_set The test set defined for the current test.
  * @param p_db_user The database user for this test.
  * @param p_db_schema The schema used for this test.
  * @param p_test_group The test group defined for the current test.
  * @param p_test_start The start of the test.
  * @param p_test_end The end of the test.
  * @param p_test_name The test name defined for the current test.
  * @param p_test_desc The test description of the current test.
  * @param p_test_errors Any errors during test execution, if any.
  */
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
  ;

  /** PROCEDURE otap_util.result_cleanup
  * Used for cleanup of the test results. Will run under scheduler job OTAP_MAINTENANCE every
  * day. Will use the current otap configuration in OTAP_CONFIG, where PRESERVE_DAYS defines
  * the days to keep test results, the DELETE_BATCH_SIZE defines the amount of rows to delete
  * before committing them and DELETE_DELAY the seconds to wait after a commit before deleting
  * more rows. Records must be marked for deletion. Provides debug logging if debug mode is
  * activated in OTAP_CONFIG.
  */
  PROCEDURE result_cleanup;

  /** FUNCTION otap_util.max_text_size
  * Determines the maximum size for a session id the text label test_set, test_group, test_name and test_description.
  * Used for report formatting. Error text is not considered as this might get huge.
  *
  * @param p_session_id A valid session id to get the maximum text size for.
  *
  * @return The maximum text size for the given session id or otap_constants.OTAP_NUM_MIN_FILL_LENGTH on errors.
  */
  FUNCTION max_text_size(p_session_id IN NUMBER)
    RETURN NUMBER
  ;

END;
/