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
  CFG_DEFAULT_LABEL_COLUMN         CONSTANT CHAR(20)             := 'DEFAULT_LABEL_COLUMN';
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

  -- extra labels for schema object types
  CFG_LABEL_CLUSTER                     CONSTANT CHAR(13)             := 'LABEL_CLUSTER';
  CFG_LABEL_CONSUMER_GROUP              CONSTANT CHAR(20)             := 'LABEL_CONSUMER_GROUP';
  CFG_LABEL_CONTEXT                     CONSTANT CHAR(13)             := 'LABEL_CONTEXT';
  CFG_LABEL_CREDENTIAL                  CONSTANT CHAR(16)             := 'LABEL_CREDENTIAL';
  CFG_LABEL_DESTINATION                 CONSTANT CHAR(17)             := 'LABEL_DESTINATION';
  CFG_LABEL_DIMENSION                   CONSTANT CHAR(15)             := 'LABEL_DIMENSION';
  CFG_LABEL_DIRECTORY                   CONSTANT CHAR(15)             := 'LABEL_DIRECTORY';
  CFG_LABEL_DOMAIN                      CONSTANT CHAR(12)             := 'LABEL_DOMAIN';
  CFG_LABEL_EDITION                     CONSTANT CHAR(13)             := 'LABEL_EDITION';
  CFG_LABEL_EVALUATION_CONTEXT          CONSTANT CHAR(24)             := 'LABEL_EVALUATION_CONTEXT';
  CFG_LABEL_FUNCTION                    CONSTANT CHAR(14)             := 'LABEL_FUNCTION';
  CFG_LABEL_INDEX                       CONSTANT CHAR(11)             := 'LABEL_INDEX';
  CFG_LABEL_INDEX_PARTITION             CONSTANT CHAR(21)             := 'LABEL_INDEX_PARTITION';
  CFG_LABEL_INDEX_SUBPARTITION          CONSTANT CHAR(24)             := 'LABEL_INDEX_SUBPARTITION';
  CFG_LABEL_INDEXTYPE                   CONSTANT CHAR(15)             := 'LABEL_INDEXTYPE';
  CFG_LABEL_JAVA_CLASS                  CONSTANT CHAR(16)             := 'LABEL_JAVA_CLASS';
  CFG_LABEL_JAVA_DATA                   CONSTANT CHAR(15)             := 'LABEL_JAVA_DATA';
  CFG_LABEL_JAVA_RESOURCE               CONSTANT CHAR(19)             := 'LABEL_JAVA_RESOURCE';
  CFG_LABEL_JAVA_SOURCE                 CONSTANT CHAR(17)             := 'LABEL_JAVA_SOURCE';
  CFG_LABEL_JOB                         CONSTANT CHAR(9)              := 'LABEL_JOB';
  CFG_LABEL_JOB_CLASS                   CONSTANT CHAR(15)             := 'LABEL_JOB_CLASS';
  CFG_LABEL_LIBRARY                     CONSTANT CHAR(13)             := 'LABEL_LIBRARY';
  CFG_LABEL_LOB                         CONSTANT CHAR(9)              := 'LABEL_LOB';
  CFG_LABEL_LOB_PARTITION               CONSTANT CHAR(19)             := 'LABEL_LOB_PARTITION';
  CFG_LABEL_MATERIALIZED_VIEW           CONSTANT CHAR(23)             := 'LABEL_MATERIALIZED_VIEW';
  CFG_LABEL_MLE_LANGUAGE                CONSTANT CHAR(18)             := 'LABEL_MLE_LANGUAGE';
  CFG_LABEL_OPERATOR                    CONSTANT CHAR(14)             := 'LABEL_OPERATOR';
  CFG_LABEL_PACKAGE                     CONSTANT CHAR(13)             := 'LABEL_PACKAGE';
  CFG_LABEL_PACKAGE_BODY                CONSTANT CHAR(18)             := 'LABEL_PACKAGE_BODY';
  CFG_LABEL_PROCEDURE                   CONSTANT CHAR(15)             := 'LABEL_PROCEDURE';
  CFG_LABEL_PROGRAM                     CONSTANT CHAR(13)             := 'LABEL_PROGRAM';
  CFG_LABEL_QUEUE                       CONSTANT CHAR(11)             := 'LABEL_QUEUE';
  CFG_LABEL_RESOURCE_PLAN               CONSTANT CHAR(19)             := 'LABEL_RESOURCE_PLAN';
  CFG_LABEL_RULE                        CONSTANT CHAR(10)             := 'LABEL_RULE';
  CFG_LABEL_RULE_SET                    CONSTANT CHAR(14)             := 'LABEL_RULE_SET';
  CFG_LABEL_SCHEDULE                    CONSTANT CHAR(14)             := 'LABEL_SCHEDULE';
  CFG_LABEL_SCHEDULER_GROUP             CONSTANT CHAR(21)             := 'LABEL_SCHEDULER_GROUP';
  CFG_LABEL_SEQUENCE                    CONSTANT CHAR(14)             := 'LABEL_SEQUENCE';
  CFG_LABEL_SYNONYM                     CONSTANT CHAR(13)             := 'LABEL_SYNONYM';
  CFG_LABEL_TABLE                       CONSTANT CHAR(11)             := 'LABEL_TABLE';
  CFG_LABEL_TABLE_PARTITION             CONSTANT CHAR(21)             := 'LABEL_TABLE_PARTITION';
  CFG_LABEL_TABLE_SUBPARTITION          CONSTANT CHAR(24)             := 'LABEL_TABLE_SUBPARTITION';
  CFG_LABEL_TRIGGER                     CONSTANT CHAR(13)             := 'LABEL_TRIGGER';
  CFG_LABEL_TYPE                        CONSTANT CHAR(10)             := 'LABEL_TYPE';
  CFG_LABEL_TYPE_BODY                   CONSTANT CHAR(15)             := 'LABEL_TYPE_BODY';
  CFG_LABEL_UNDEFINED                   CONSTANT CHAR(15)             := 'LABEL_UNDEFINED';
  CFG_LABEL_UNIFIED_AUDIT_POLICY        CONSTANT CHAR(26)             := 'LABEL_UNIFIED_AUDIT_POLICY';
  CFG_LABEL_VIEW                        CONSTANT CHAR(10)             := 'LABEL_VIEW';
  CFG_LABEL_WINDOW                      CONSTANT CHAR(12)             := 'LABEL_WINDOW';
  CFG_LABEL_XML_SCHEMA                  CONSTANT CHAR(16)             := 'LABEL_XML_SCHEMA';
  CFG_LABEL_COLUMN                      CONSTANT CHAR(12)             := 'LABEL_COLUMN';

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

  /** PROCEDURE otap_util.validate_translatable
  * Checks for OTAP_TRANSLATE trigger if the identifier is defined and not translatable.
  * Identifiers for not translatable config names are not allowed and will cause an exception.
  *
  * @param p_otap_identifier The identifier name, usally :NEW.otap_identifier or :OLD.otap_identifier.
  *
  * @throws -20020 The given identifier cannot be translated. Ask your admin to adjust this configuration item.
  */
  PROCEDURE validate_translatable(p_otap_identifier IN VARCHAR2);

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

  /** FUNCTION otap_util.get_label_id
  * Returns the label name for a given object type. If not found the LABEL_UNDEFINED is returned.
  * Exceptions are raised. Will not check OTAP_CONFIG, will operate on OTAP_LABELS_MV.
  *
  * @param p_object_type A valid Oracle object type as defined in DBA_OBJECTS or V$RESERVED_WORDS.
  *
  * @return The label identifier for a given object type or LABEL_UNDEFINED.
  */
  FUNCTION get_label_id(p_object_type IN VARCHAR2)
    RETURN VARCHAR2
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

  /** FUNCTION otap_util.build_msg
  * Builds a message from a template identifier. Fetches the template and fills the given
  * variables in p_param1-5 with the given value, if the parameters are filled. Type has
  * special translation handling for filling the @type@ variable, if it exists in the template and
  * type label is not NULL. Must be a label from otap_identifiers view like LABEL_COLUMN or LABEL_TABLE.
  *
  * Leaving all parameters apart from p_cfg_template empty will return just the current translation of
  * a config or label value, according to OTAP_TRANSLATE or the default.
  *
  * Parameters must contain leading and trailing @ variable indicator. Ignored if not a otap variable
  * in style @varname@.
  *
  * @param p_cfg_template The config name of the template. See otap_util.CFG_ constants.
  * @param p_type_label The label name of the @type@ variable, if needed. See otap_util.CFG_LABEL constants.
  * @param p_param1 The 1st variable name in @variable@ notation. If @type@ ignored. Optional.
  * @param p_param1_value The substitution value for the 1st variable name. Parameter ignored if not given. Optional.
  * @param p_param2 The 2nd variable name in @variable@ notation. If @type@ ignored. Optional.
  * @param p_param2_value The substitution value for the 2nd variable name. Parameter ignored if not given. Optional.
  * @param p_param3 The 3rd variable name in @variable@ notation. If @type@ ignored. Optional.
  * @param p_param3_value The substitution value for the 3rd variable name. Parameter ignored if not given. Optional.
  * @param p_param4 The 4th variable name in @variable@ notation. If @type@ ignored. Optional.
  * @param p_param4_value The substitution value for the 4th variable name. Parameter ignored if not given. Optional.
  * @param p_param5 The 5th variable name in @variable@ notation. If @type@ ignored. Optional.
  * @param p_param5_value The substitution value for the 5th variable name. Parameter ignored if not given. Optional.
  * @param p_description A template overwrite. Will return the given description instead of the template. Optional.
  *
  * @return The message build from template, overwritten by description or an error message.
  */
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