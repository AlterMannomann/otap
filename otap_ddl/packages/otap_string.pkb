-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_string
AS
  -- for description see header file
  FUNCTION reduce( p_string VARCHAR2 DEFAULT NULL
                 , p_size   INTEGER  DEFAULT 0
                 )
    RETURN VARCHAR2
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.reduce';
    l_string VARCHAR2(32767 CHAR);
  BEGIN
    l_string := CASE WHEN LENGTH(TRIM(p_string)) > p_size THEN TRIM(SUBSTR(TRIM(p_string), 1, p_size)) ELSE TRIM(p_string) END;
    RETURN l_string;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'CASE WHEN LENGTH(TRIM(p_string)) > p_size THEN TRIM(SUBSTR(TRIM(p_string), 1, p_size)) ELSE TRIM(p_string) END');
      RAISE;
  END reduce;

  FUNCTION cut( p_string VARCHAR2 DEFAULT NULL
              , p_size   INTEGER  DEFAULT 0
              )
    RETURN VARCHAR2
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.cut';
    l_string VARCHAR2(32767 CHAR);
  BEGIN
    l_string := CASE WHEN LENGTH(p_string) > p_size THEN SUBSTR(p_string, 1, p_size) ELSE p_string END;
    RETURN l_string;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'CASE WHEN LENGTH(p_string) > p_size THEN SUBSTR(p_string, 1, p_size) ELSE p_string END');
      RAISE;
  END cut;

  FUNCTION flatten( p_string VARCHAR2 DEFAULT NULL
                  , p_size   INTEGER  DEFAULT 0
                  )
    RETURN VARCHAR2
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.flatten';
    l_string VARCHAR2(32767 CHAR);
  BEGIN
    l_string := REGEXP_REPLACE(p_string, '\s{2,}', ' ');
    l_string := CASE WHEN LENGTH(l_string) > p_size THEN SUBSTR(l_string, 1, p_size) ELSE l_string END;
    RETURN l_string;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Flatten and cut the given string, remove useless white space chars');
      RAISE;
  END flatten;

  FUNCTION check_border(p_border IN INTEGER DEFAULT otap_constants.OTAP_FALLBACK_BORDER)
    RETURN NUMBER
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.check_border';
    l_border INTEGER;
  BEGIN
    IF NVL(p_border, otap_constants.OTAP_FALLBACK_BORDER) NOT BETWEEN 2 AND 10
    THEN
      l_border := otap_constants.OTAP_FALLBACK_BORDER;
    ELSE
      l_border := NVL(p_border, otap_constants.OTAP_FALLBACK_BORDER);
    END IF;
    RETURN l_border;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Check border constraints');
      RAISE;
  END check_border;

  FUNCTION check_line_size(p_line_size IN INTEGER DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH)
    RETURN NUMBER
  IS
    l_script    VARCHAR2(256 CHAR) := 'otap_string.check_line_size';
    l_line_size INTEGER;
  BEGIN
    IF NVL(p_line_size, otap_constants.OTAP_NUM_MIN_FILL_LENGTH) NOT BETWEEN otap_constants.OTAP_NUM_MIN_FILL_LENGTH AND otap_constants.OTAP_NUM_MAX_FILL_LENGTH
    THEN
      IF p_line_size > otap_constants.OTAP_NUM_MAX_FILL_LENGTH
      THEN
        l_line_size := otap_constants.OTAP_NUM_MAX_FILL_LENGTH;
      ELSE
        l_line_size := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
      END IF;
    ELSE
      l_line_size := NVL(p_line_size, otap_constants.OTAP_NUM_MIN_FILL_LENGTH);
    END IF;
    RETURN l_line_size;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Check line size constraints');
      RAISE;
  END check_line_size;

  FUNCTION check_title_size( p_title_length IN INTEGER DEFAULT 0
                           , p_border       IN INTEGER DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                           )
    RETURN NUMBER
  IS
    l_script     VARCHAR2(256 CHAR) := 'otap_string.check_title_size';
    l_title_size INTEGER;
    l_border     INTEGER;
  BEGIN
    l_border := otap_string.check_border(p_border);
    IF (NVL(p_title_length, 0) + (l_border * 2)) > otap_constants.OTAP_NUM_MAX_FILL_LENGTH
    THEN
      l_title_size := otap_constants.OTAP_NUM_MAX_FILL_LENGTH - (l_border * 2);
    ELSE
      l_title_size := NVL(p_title_length, 0);
    END IF;
    RETURN l_title_size;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Check title size constraints');
      RAISE;
  END check_title_size;

  FUNCTION check_string_size(p_string_length IN INTEGER DEFAULT 0)
    RETURN NUMBER
  IS
    l_script      VARCHAR2(256 CHAR) := 'otap_string.check_string_size';
    l_string_size INTEGER;
  BEGIN
    IF NVL(p_string_length, 0) > otap_constants.OTAP_NUM_MAX_FILL_LENGTH
    THEN
      l_string_size := otap_constants.OTAP_NUM_MAX_FILL_LENGTH;
    ELSIF NVL(p_string_length, 0) < otap_constants.OTAP_NUM_MIN_FILL_LENGTH
    THEN
      l_string_size := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
    ELSE
      l_string_size := NVL(p_string_length, 0);
    END IF;
    RETURN l_string_size;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Check string size constraints');
      RAISE;
  END check_string_size;

  FUNCTION check_layout(p_layout IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT)
    RETURN VARCHAR2
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.check_layout';
    l_layout VARCHAR2(1 CHAR);
  BEGIN
    l_layout := CASE
                  WHEN p_layout IN (otap_constants.OTAP_LAYOUT_LEFT, otap_constants.OTAP_LAYOUT_MIDDLE, otap_constants.OTAP_LAYOUT_RIGHT)
                  THEN p_layout
                  ELSE otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT
                END
    ;
    RETURN l_layout;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Check layout constraints');
      RAISE;
  END check_layout;

  FUNCTION check_decoration(p_decoration IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR)
    RETURN VARCHAR2
  IS
    l_script     VARCHAR2(256 CHAR) := 'otap_string.check_decoration';
    l_decoration VARCHAR2(1 CHAR);
  BEGIN
    l_decoration := SUBSTR(NVL(p_decoration, otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 1, 1);
    RETURN l_decoration;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'SUBSTR(NVL(p_decoration, otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 1, 1)');
      RAISE;
  END check_decoration;

  FUNCTION line_size( p_title_length  IN INTEGER
                    , p_border        IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                    , p_min_fill      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                    )
    RETURN INTEGER
  IS
    l_script     VARCHAR2(256 CHAR) := 'otap_string.line_size';
    l_length     INTEGER;
    l_border     INTEGER;
    l_line_size  INTEGER;
    l_title_size INTEGER;
    l_calc_size  INTEGER;
  BEGIN
    l_border     := otap_string.check_border(p_border);
    l_line_size  := otap_string.check_line_size(p_min_fill);
    l_title_size := otap_string.check_title_size(p_title_length, l_border);
    l_calc_size  := l_title_size + (l_border * 2);
    l_length     := GREATEST(NVL(l_calc_size, 0), l_line_size);
    IF l_length < otap_constants.OTAP_NUM_MIN_FILL_LENGTH
    THEN
      l_length := otap_constants.OTAP_NUM_MIN_FILL_LENGTH;
    ELSIF l_length > otap_constants.OTAP_NUM_MAX_FILL_LENGTH
    THEN
      l_length := otap_constants.OTAP_NUM_MAX_FILL_LENGTH;
    END IF;
    RETURN l_length;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Calculate decorated line size');
      RAISE;
  END line_size;

  FUNCTION max_size( p_title_length IN INTEGER
                   , p_line_size    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                   )
    RETURN INTEGER
  IS
    l_script VARCHAR2(256 CHAR) := 'otap_string.max_size';
    l_title_length INTEGER;
    l_line_size    INTEGER;
    l_border       INTEGER;
    l_max_size     INTEGER;
  BEGIN
    l_line_size    := otap_string.check_line_size(p_line_size);
    l_border       := otap_string.check_border(p_border);
    l_title_length := otap_string.check_title_size(p_title_length, l_border);
    IF l_title_length <= 0
    THEN
      l_max_size := 0;
    ELSE
      IF (l_title_length + (l_border * 2)) > otap_constants.OTAP_NUM_MAX_FILL_LENGTH
      THEN
        l_max_size := otap_constants.OTAP_NUM_MAX_FILL_LENGTH - (l_border * 2);
      ELSE
        l_max_size := l_title_length;
      END IF;
    END IF;
    RETURN l_max_size;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Calculate maximum title size');
      RAISE;
  END max_size;

  FUNCTION left_deco( p_title_length IN INTEGER  DEFAULT 0
                    , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                    , p_decoration   IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                    , p_layout       IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT
                    , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                    )
    RETURN VARCHAR2
  IS
    l_script        VARCHAR2(256 CHAR) := 'otap_string.left_deco';
    l_deco          VARCHAR2(1 CHAR);
    l_layout        VARCHAR2(1 CHAR);
    l_border        INTEGER;
    l_pad_size      INTEGER;
    l_min_fill      INTEGER;
    l_line_size     INTEGER;
    l_title_length  INTEGER;
    l_left_pad      VARCHAR2(32767 CHAR);
  BEGIN
    l_min_fill      := otap_string.check_line_size(p_min_fill);
    l_deco          := otap_string.check_decoration(p_decoration);
    l_border        := otap_string.check_border(p_border);
    l_layout        := otap_string.check_layout(p_layout);
    l_title_length  := otap_string.check_title_size(p_title_length, l_border);
    l_line_size     := otap_string.line_size(l_title_length, l_border, l_min_fill);
    -- if defaults we should have now a line size between 80 and 4000, a border between 2 and 10, a valid deco and a valid layout.
    l_pad_size := CASE
                    WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                    THEN l_border
                    WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                    THEN l_line_size - (l_title_length + l_border)
                    ELSE FLOOR((l_line_size - l_title_length) / 2)
                  END
    ;
    IF l_title_length = 0
    THEN
      l_left_pad := LPAD(l_deco, l_pad_size, l_deco);
    ELSE
      l_left_pad := LPAD(' ', l_pad_size, l_deco);
    END IF;
    RETURN l_left_pad;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Build left decoration');
      RAISE;
  END left_deco;

  FUNCTION right_deco( p_title_length IN INTEGER  DEFAULT 0
                     , p_min_fill     IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                     , p_decoration   IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                     , p_layout       IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT
                     , p_border       IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                     )
    RETURN VARCHAR2
  IS
    l_script        VARCHAR2(256 CHAR) := 'otap_string.right_deco';
    l_deco          VARCHAR2(1 CHAR);
    l_layout        VARCHAR2(1 CHAR);
    l_border        INTEGER;
    l_pad_size      INTEGER;
    l_min_fill      INTEGER;
    l_line_size     INTEGER;
    l_title_length  INTEGER;
    l_right_pad     VARCHAR2(32767 CHAR);
  BEGIN
    l_min_fill      := otap_string.check_line_size(p_min_fill);
    l_deco          := otap_string.check_decoration(p_decoration);
    l_border        := otap_string.check_border(p_border);
    l_layout        := otap_string.check_layout(p_layout);
    l_title_length  := otap_string.check_title_size(p_title_length, l_border);
    l_line_size     := otap_string.line_size(l_title_length, l_border, l_min_fill);
    l_pad_size := CASE
                    WHEN l_layout = otap_constants.OTAP_LAYOUT_LEFT
                    THEN l_line_size - (l_title_length + l_border)
                    WHEN l_layout = otap_constants.OTAP_LAYOUT_RIGHT
                    THEN l_border
                    ELSE FLOOR((l_line_size - l_title_length) / 2) + MOD((l_line_size - l_title_length), 2)
                  END
    ;
    IF l_title_length = 0
    THEN
      l_right_pad := RPAD(l_deco, l_pad_size, l_deco);
    ELSE
      l_right_pad := RPAD(' ', l_pad_size, l_deco);
    END IF;
    RETURN l_right_pad;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Build right decoration');
      RAISE;
  END right_deco;

  FUNCTION decorate( p_title       IN VARCHAR2 DEFAULT NULL
                   , p_decoration  IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR
                   , p_min_length  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                   , p_layout      IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT
                   , p_border      IN INTEGER  DEFAULT otap_constants.OTAP_FALLBACK_BORDER
                   )
    RETURN VARCHAR2
  IS
    l_script        VARCHAR2(256 CHAR) := 'otap_string.decorate';
    l_deco_length   INTEGER;
    l_pad_length    INTEGER;
    l_title_length  INTEGER;
    l_min_length    INTEGER;
    l_line_size     INTEGER;
    l_add           INTEGER;
    l_padding       INTEGER;
    l_border        INTEGER;
    l_deco          VARCHAR2(1 CHAR);
    l_layout        VARCHAR2(1 CHAR);
    l_deco_string   VARCHAR2(32767 CHAR);
    l_title         VARCHAR2(32767 CHAR);
  BEGIN
    otap_log.log('Parameter p_title: ' || p_title || ' p_decoration: ' || p_decoration || ' p_min_length: ' || p_min_length || ' p_layout: ' || p_layout || ' p_border: ' || p_border, l_script, 'Call', 'OTAP_DEBUG');
    -- check params, assign defaults
    l_min_length := otap_string.check_line_size(p_min_length);
    l_border     := otap_string.check_border(p_border);
    l_layout     := otap_string.check_layout(p_layout);
    l_deco       := otap_string.check_decoration(p_decoration);
    otap_log.log('After param check l_min_length: ' || l_min_length || ' l_border: ' || l_border || ' l_layout: ' || l_layout || ' l_deco: ' || l_deco, l_script, 'param check section', 'OTAP_DEBUG');
    l_title_length := otap_string.check_title_size(LENGTH(p_title), l_border);
    l_line_size    := otap_string.line_size(l_title_length, l_border, l_min_length);
    l_title_length := otap_string.max_size(l_title_length, l_line_size, l_border);
    l_title        := otap_string.reduce(p_title, l_title_length);
    otap_log.log('Current title: ' || l_title || ' calculated title length: ' || l_title_length || ' line size: ' || l_line_size, l_script, 'Calculate title and line size to use', 'OTAP_DEBUG');
    -- build the string
    l_deco_string := otap_string.left_deco(l_title_length, l_line_size, l_deco, l_layout) ||
                     l_title ||
                     otap_string.right_deco(l_title_length, l_line_size, l_deco, l_layout)
    ;
    RETURN l_deco_string;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Decorate string');
      RAISE;
  END decorate;

  FUNCTION borderless( p_string      IN VARCHAR2 DEFAULT otap_constants.OTAP_INTERNAL_NA
                     , p_min_length  IN INTEGER  DEFAULT otap_constants.OTAP_NUM_MIN_FILL_LENGTH
                     , p_layout      IN VARCHAR2 DEFAULT otap_constants.OTAP_FALLBACK_LAYOUT_RESULT_DEFAULT
                     )
    RETURN VARCHAR2
  IS
    l_script      VARCHAR2(256 CHAR) := 'otap_string.borderless';
    l_layout      VARCHAR2(1 CHAR);
    l_min_length  INTEGER;
    l_line_size   INTEGER;
    l_string      VARCHAR2(32767 CHAR);
  BEGIN
    l_min_length := otap_string.check_line_size(p_min_length);
    l_layout     := otap_string.check_layout(p_layout);
    IF l_layout = otap_constants.OTAP_LAYOUT_MIDDLE
    THEN
      l_layout := otap_constants.OTAP_LAYOUT_LEFT;
    END IF;
    l_line_size   := GREATEST(l_min_length, otap_string.check_string_size(NVL(LENGTH(p_string), 0)));
    l_string      := otap_string.reduce(p_string, l_line_size);
    -- now pad the string for the right or left side
    IF l_layout = otap_constants.OTAP_LAYOUT_RIGHT
    THEN
      l_string := LPAD(l_string, l_line_size, ' ');
    ELSE
      -- middle and left are treated equally
      l_string := RPAD(l_string, l_line_size, ' ');
    END IF;
    RETURN l_string;
  EXCEPTION
    WHEN OTHERS THEN
      otap_log.log(SQLERRM, l_script, 'Borderless layout');
      RAISE;
  END borderless;

END;
/