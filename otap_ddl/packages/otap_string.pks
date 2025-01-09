-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Basic package that provides utility functions and procedures for string handling in otap.
CREATE OR REPLACE PACKAGE otap_string
AS
  /**
  * Provides functions to limit and verify strings
  */

  /** FUNCTION otap_string.reduce
  * Basic string trimming and cutting to a given size. Trims the result.
  * Limited to PLSQL string size. On using defaults return a NULL string. Can be used in PLSQL to guarantee string
  * length for a used variable size and avoid exceptions on oversized strings.
  *
  * @param p_string The string to trim and cut to the given size.
  * @param p_size The maximum length for the result string.
  *
  * @return The trimmed result string with the given size, probably cutted.
  */
  FUNCTION reduce( p_string VARCHAR2 DEFAULT NULL
                 , p_size   INTEGER  DEFAULT 0
                 )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.cut
  * Basic string cutting to a given size. Does not trim the result.
  * Limited to PLSQL string size. On using defaults return a NULL string. Can be used in PLSQL to guarantee string
  * length for a used variable size and avoid exceptions on oversized strings.
  *
  * @param p_string The string to cut to the given size.
  * @param p_size The maximum length for the result string.
  *
  * @return The result string with the given size, probably cutted.
  */
  FUNCTION cut( p_string VARCHAR2 DEFAULT NULL
              , p_size   INTEGER  DEFAULT 0
              )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.flatten
  * Basic string flattening and cutting to a given size. Does not trim the result.
  * Limited to PLSQL string size. On using defaults return a NULL string. Can be used
  * to remove addition white space chars like space, tab, line feed and others.
  *
  * @param p_string The string to flatten and cut to the given size.
  * @param p_size The maximum length for the result string.
  *
  * @return The result string with the given size, probably cutted.
  */
  FUNCTION flatten( p_string VARCHAR2 DEFAULT NULL
                  , p_size   INTEGER  DEFAULT 0
                  )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.check_border
  * Constraints the border to a value between 2 and 10. Invalid border will be set to otap_constants.OTAP_FALLBACK_BORDER.
  *
  * @param p_border The minimum border length to verify.
  *
  * @return The given border or a valid border length.
  */
  FUNCTION check_border(p_border IN INTEGER DEFAULT otap_constants.OTAP_FALLBACK_BORDER)
    RETURN NUMBER
  ;

  /** FUNCTION otap_string.check_border
  * Constraints the line size to a value between 80 and 4000. Invalid line size will be set
  * to otap_constants.OTAP_NUM_MIN_FILL_LENGTH or otap_constants.OTAP_NUM_MAX_FILL_LENGTH,
  * depending on line size underflow or overflow.
  *
  * @param p_line_size The line size to verify.
  *
  * @return The given line size or the matching min/max line size.
  */
  FUNCTION check_line_size(p_line_size IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN NUMBER
  ;

  /** FUNCTION otap_string.check_title_size
  * Constraints the title size to a value lower than 4000 depending on the border. Invalid title size
  * will be set to otap_constants.OTAP_NUM_MAX_FILL_LENGTH - (border size *2).
  *
  * @param p_title_length The length of the title to verify.
  * @param p_border The minimum border length to consider for decoration.
  *
  * @return The given title size or the calculated maximum size.
  */
  FUNCTION check_title_size( p_title_length IN INTEGER DEFAULT 0
                           , p_border       IN INTEGER DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                           )
    RETURN NUMBER
  ;

  /** FUNCTION otap_string.check_string_size
  * Constraints the string size to a value between 80 and 4000. Invalid string size will be set
  * to otap_constants.OTAP_NUM_MIN_FILL_LENGTH or otap_constants.OTAP_NUM_MAX_FILL_LENGTH,
  * depending on line size underflow or overflow.
  *
  * @param p_string_length The length of the string to verify.
  *
  * @return The given string size or the calculated minimum/maximum size.
  */
  FUNCTION check_string_size(p_string_length IN INTEGER DEFAULT 0)
    RETURN NUMBER
  ;

  /** FUNCTION otap_string.check_layout
  * Constraints the layout to allowed values. Invalid values will return otap_constants.OTAP_LAYOUT_DEFAULT.
  *
  * @param p_layout A valid layout orientation indicator as defined in OTAP_CONSTANTS.
  *
  * @return The given layout or the default value.
  */
  FUNCTION check_layout(p_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_DEFAULT)
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.check_decoration
  * Constraints the decoration char to 1 char. Invalid values will return otap_constants.OTAP_FORMAT_NAME_CHAR.
  *
  * @param p_decoration A single decoration char. Only the first char is considered if string length > 1.
  *
  * @return The given decoration char or the default value.
  */
  FUNCTION check_decoration(p_decoration IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR)
    RETURN VARCHAR2
  ;


  /** FUNCTION otap_string.line_size
  * Calculates the minimum length to use for a formatted string based on title size. Limited to SQL
  * column size. See otap_constants.OTAP_NUM_MAX_FILL_LENGTH.
  *
  * @param p_title_length The length of the title to use for formatted output.
  * @param p_border The minimum border length to consider for decoration.
  * @param p_min_fill The minimum size for a decorated report line.
  *
  * @return The minimum length of a decorated string with given title size and border fill, limited to otap_constants.OTAP_NUM_MAX_FILL_LENGTH size.
  */
  FUNCTION line_size( p_title_length  IN INTEGER
                    , p_border        IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                    , p_min_fill      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                    )
    RETURN INTEGER
  ;

  /** FUNCTION otap_string.max_size
  * Calculates the maximum length for a given title size considering line size and borders. Limited to SQL
  * column size. See otap_constants.OTAP_NUM_MAX_FILL_LENGTH.
  *
  * @param p_title_length The intended title string size.
  * @param p_line_size The intended line size to use in reports.
  * @param p_border The minimum border length to consider for decoration.
  *
  * @return The maximum allowed title length for current line size and borders. May result in 0 if border or line size dimensions are wrong.
  */
  FUNCTION max_size( p_title_length IN INTEGER
                   , p_line_size    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                   )
    RETURN INTEGER
  ;

  /** FUNCTION otap_string.left_deco
  * Builds the left decoration for a given title length and line size. If title length is 0, no space
  * is added to the decoration. Given layout orientation is considered. If R(right) extra chars are padded to the
  * left. For all other layout orientations, extra chars are padded to the right. Extra char occurs if line size
  * is uneven.
  *
  * @param p_title_length The title string size.
  * @param p_min_fill The intended line size to use in reports.
  * @param p_decoration The decoration char that should pad the title to the left including a space if title length > 0.
  * @param p_layout The decoration layout orientation for the title in the decoration.
  * @param p_border The minimum border length to consider for decoration.
  *
  * @return The decoration string for the left side. Includes a space if title length > 0.
  */
  FUNCTION left_deco( p_title_length IN INTEGER  DEFAULT 0
                    , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                    , p_decoration   IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR
                    , p_layout       IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_DEFAULT
                    , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                    )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.right_deco
  * Builds the right decoration for a given title length and line size. If title length is 0, no space
  * is added to the decoration. Given layout orientation is considered. If R(right) extra chars are padded to the
  * left. For all other layout orientations, extra chars are padded to the right. Extra char occurs if line size
  * is uneven.
  *
  * @param p_title_length The title string size.
  * @param p_min_fill The intended line size to use in reports.
  * @param p_decoration The decoration char that should pad the title to the right including a space if title length > 0.
  * @param p_layout The decoration layout orientation for the title in the decoration.
  * @param p_border The minimum border length to consider for decoration.
  *
  * @return The decoration string for the right side. Includes a space if title length > 0.
  */
  FUNCTION right_deco( p_title_length IN INTEGER  DEFAULT 0
                     , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                     , p_decoration   IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR
                     , p_layout       IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_DEFAULT
                     , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                     )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.decorate
  * Decorates a given title string with the decoration char to left and right padded and a space between title and
  * decoration char. Title is placed as defined by layout. Title will be cutted if it is too long, see
  * otap_constants.OTAP_NUM_MAX_FILL_LENGTH.
  *
  * M (middle): Title is placed in the middle, decoration chars padded and extended equally on both sides up to calculated line size.
  * L (left): Minimum border decoration placed at the left followed by the title, right padding border decoration up to calculated line size.
  * R (right): Minimum border decoration placed at the right with leading title, left padding border decoration up to calculated line size.
  *
  * Examples
  * decorate('test', '-', 20, 'M', 3): ------- test -------
  * decorate('test', '-', 20, 'L', 3): -- test ------------
  * decorate('test', '-', 20, 'R', 3): ------------ test --
  *
  * @param p_title The title to use in the decorated line. If NULL a decorated line is created without any text inside.
  * @param p_decoration The decoration char that should pad the title to the left and right including a space between text and decoration.
  * @param p_min_length The minimum size for a decorated report line.
  * @param p_layout The decoration layout orientation for the title in the decoration.
  * @param p_border The decoration border length including the space to separate text from decoration.
  *
  * @return The decorated string. Limited to 4000 chars as it is used in SQL columns.
  */
  FUNCTION decorate( p_title       IN VARCHAR2 DEFAULT NULL
                   , p_decoration  IN VARCHAR2 DEFAULT otap_constants.OTAP_FORMAT_NAME_CHAR
                   , p_min_length  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_layout      IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_DEFAULT
                   , p_border      IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                   )
    RETURN VARCHAR2
  ;

  /** FUNCTION otap_string.borderless
  * Builds not decorated report lines, like results or result headers, with given layout orientation. Only left and right allowed. Middle
  * will translate to the default otap_constants.OTAP_LAYOUT_RESULT_DEFAULT.
  * For languages that read from right to left, the templates and headers have to be adjusted accordingly.
  *
  * @param p_string The string to format with the given orientation.
  * @param p_min_length The minimum string size to use for padding.
  * @param p_layout The layout orientation for the string.
  *
  * @return The string with the given layout orientation.
  */
  FUNCTION borderless( p_string      IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                     , p_min_length  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                     , p_layout      IN VARCHAR2 DEFAULT otap_constants.OTAP_LAYOUT_RESULT_DEFAULT
                     )
    RETURN VARCHAR2
  ;

END;
/