-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_generate
AS
  -- internal package constants and variables
  PREFIX_SQL          CONSTANT CHAR(7)  := 'SELECT ';
  PREFIX_PLSQL        CONSTANT CHAR(15) := '  l_message := ';
  POSTFIX_SQL         CONSTANT CHAR(11) := ' FROM dual;';
  POSTFIX_PLSQL       CONSTANT CHAR(1)  := ';';

  generation_type VARCHAR2(1) := otap_constants.OTAP_GEN_TYPE_SCRIPT;

  -- for description see header file
  PROCEDURE set_gen_type(p_gen_type IN VARCHAR2)
  IS
  BEGIN
    IF TRIM(p_gen_type) IN (otap_constants.OTAP_GEN_TYPE_SCRIPT, otap_constants.OTAP_GEN_TYPE_FUNCTION, otap_constants.OTAP_GEN_TYPE_PROCEDURE)
    THEN
      generation_type := TRIM(p_gen_type);
    END IF;
  END set_gen_type;

  FUNCTION get_gen_type
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN generation_type;
  END;

  FUNCTION get_code_prefix
    RETURN VARCHAR2
  IS
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_SCRIPT
    THEN
      RETURN PREFIX_SQL;
    ELSE
      RETURN PREFIX_PLSQL;
    END IF;
  END get_code_prefix;

  FUNCTION get_code_prefix_len
    RETURN NUMBER
  IS
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_SCRIPT
    THEN
      RETURN LENGTH(PREFIX_SQL);
    ELSE
      RETURN LENGTH(PREFIX_PLSQL);
    END IF;
  END get_code_prefix_len;

  FUNCTION get_code_postfix
    RETURN VARCHAR2
  IS
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_SCRIPT
    THEN
      RETURN POSTFIX_SQL;
    ELSE
      RETURN POSTFIX_PLSQL;
    END IF;
  END get_code_postfix;

  FUNCTION get_code_pad
    RETURN VARCHAR
  IS
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_SCRIPT
    THEN
      RETURN '';
    ELSE
      RETURN '  ';
    END IF;
  END get_code_pad;

  FUNCTION prepare( p_title_prefix IN             VARCHAR2
                  , p_schema       IN             VARCHAR2
                  , p_object_type  IN             VARCHAR2
                  , p_object       IN             VARCHAR2
                  , o_set             OUT NOCOPY  VARCHAR2
                  , o_group           OUT NOCOPY  VARCHAR2
                  , o_name            OUT NOCOPY  VARCHAR2
                  )
    RETURN VARCHAR2
  IS
    l_set       VARCHAR2(256 CHAR);
    l_group     VARCHAR2(256 CHAR);
    l_name      VARCHAR2(256 CHAR);
    l_fn_set    VARCHAR2(40 CHAR);
    l_fn_group  VARCHAR2(30 CHAR);
    l_fn_name   VARCHAR2(30 CHAR);
    l_prc_name  VARCHAR2(128 CHAR);
  BEGIN
    -- define display values first
    l_set       := NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'));
    l_fn_set    := otap_string.reduce(REGEXP_REPLACE(l_set, '[^[:alnum:]]'), 30);
    l_prc_name  := 'test_' || l_fn_set;
    l_group     := NULL;
    l_name      := NULL;
    IF p_title_prefix IS NOT NULL
    THEN
      l_fn_set    := otap_string.reduce(REGEXP_REPLACE(p_title_prefix, '[^[:alnum:]]'), 10) || otap_string.reduce(REGEXP_REPLACE(l_set, '[^[:alnum:]]'), 30);
      l_prc_name  := 'test_' || l_fn_set;
      l_set       := otap_string.reduce(TRIM(p_title_prefix) || ' ' || l_set, 256);
    END IF;
    IF p_object_type IS NOT NULL
    THEN
      l_fn_group  := otap_string.reduce(REGEXP_REPLACE(p_object_type, '[^[:alnum:]]'), 30);
      l_group     := otap_string.reduce(p_object_type, 256);
      l_prc_name  := l_prc_name || '_' || l_fn_group;
      IF p_object IS NOT NULL
      THEN
        -- if we arrive here we must not care about extra underscores
        l_fn_name   := otap_string.reduce(REGEXP_REPLACE(p_object, '[^[:alnum:]_]'), 30);
        l_name      := otap_string.reduce(p_object, 256);
        l_prc_name  := l_prc_name || '_' || l_fn_name;
      END IF;
    END IF;
    -- set out vars
    o_set   := l_set;
    o_group := l_group;
    o_name  := l_name;
    RETURN LOWER(l_prc_name);
  END prepare;

  PROCEDURE prepare( p_title_prefix IN             VARCHAR2
                   , p_schema       IN             VARCHAR2
                   , p_object_type  IN             VARCHAR2
                   , p_object       IN             VARCHAR2
                   , o_set             OUT NOCOPY  VARCHAR2
                   , o_group           OUT NOCOPY  VARCHAR2
                   , o_name            OUT NOCOPY  VARCHAR2
                   )
  IS
    l_ignore VARCHAR2(128 CHAR);
  BEGIN
    l_ignore := otap_generate.prepare(p_title_prefix, p_schema, p_object_type, p_object, o_set, o_group, o_name);
  END prepare;

  FUNCTION build_script_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_object_type   IN VARCHAR2 DEFAULT NULL
                              , p_object        IN VARCHAR2 DEFAULT NULL
                              , p_scope         IN VARCHAR2 DEFAULT '%'
                              , p_script_count  IN NUMBER   DEFAULT 0
                              , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_set         VARCHAR2(256 CHAR);
    l_group       VARCHAR2(256 CHAR);
    l_name        VARCHAR2(256 CHAR);
  BEGIN
    -- map objects
    otap_generate.prepare(p_title_prefix, p_schema, p_object_type, p_object, l_set, l_group, l_name);
    l_statement := TRIM('-- otap GENERATE test scripts ' || l_set || ' ' || l_group || ' ' || l_name);
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    IF p_scope IS NOT NULL
    THEN
      l_statement := '-- LIKE scope: ' || TRIM(p_scope);
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := PREFIX_SQL || 'otap_test.init_test(' || TRIM(TO_CHAR(NVL(p_script_count, 0))) || ')' || POSTFIX_SQL;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_script_header;

  FUNCTION build_function_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_object_type   IN VARCHAR2 DEFAULT NULL
                                , p_object        IN VARCHAR2 DEFAULT NULL
                                , p_scope         IN VARCHAR2 DEFAULT '%'
                                , p_script_count  IN NUMBER   DEFAULT 0
                                , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_set         VARCHAR2(256 CHAR);
    l_group       VARCHAR2(256 CHAR);
    l_name        VARCHAR2(256 CHAR);
    l_fn_name     VARCHAR2(128 CHAR);
  BEGIN
    l_fn_name := otap_generate.prepare(p_title_prefix, p_schema, p_object_type, p_object, l_set, l_group, l_name);
    l_statement := otap_generate.get_code_pad || TRIM('-- otap GENERATE test scripts ' || l_set || ' ' || l_group || ' ' || l_name);
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    IF p_scope IS NOT NULL
    THEN
      l_statement := otap_generate.get_code_pad || '-- LIKE scope: ' || TRIM(p_scope);
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := '-- otap GENERATE test function ' || l_fn_name;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'CREATE OR REPLACE FUNCTION ' || l_fn_name;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'RETURN NUMBER';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'IS';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_message VARCHAR2(4000);';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_return  NUMBER;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'BEGIN';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := PREFIX_PLSQL || 'otap_test.init_test(' || TRIM(TO_CHAR(NVL(p_script_count, 0))) || ')' || POSTFIX_PLSQL;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_function_header;

  FUNCTION build_procedure_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_object_type   IN VARCHAR2 DEFAULT NULL
                                 , p_object        IN VARCHAR2 DEFAULT NULL
                                 , p_scope         IN VARCHAR2 DEFAULT '%'
                                 , p_script_count  IN NUMBER   DEFAULT 0
                                 , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_set         VARCHAR2(256 CHAR);
    l_group       VARCHAR2(256 CHAR);
    l_name        VARCHAR2(256 CHAR);
    l_fn_name     VARCHAR2(128 CHAR);
  BEGIN
    l_fn_name := otap_generate.prepare(p_title_prefix, p_schema, p_object_type, p_object, l_set, l_group, l_name);
    l_statement := otap_generate.get_code_pad || TRIM('-- otap GENERATE test scripts ' || l_set || ' ' || l_group || ' ' || l_name);
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    IF p_scope IS NOT NULL
    THEN
      l_statement := otap_generate.get_code_pad || '-- LIKE scope: ' || TRIM(p_scope);
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := '-- otap GENERATE test procedure ' || l_fn_name;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'CREATE OR REPLACE PROCEDURE ' || l_fn_name;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'IS';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_message VARCHAR2(4000);';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_return  NUMBER;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'BEGIN';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := PREFIX_PLSQL || 'otap_test.init_test(' || TRIM(TO_CHAR(NVL(p_script_count, 0))) || ')' || POSTFIX_PLSQL;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_procedure_header;

  FUNCTION get_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_object_type   IN VARCHAR2 DEFAULT NULL
                     , p_object        IN VARCHAR2 DEFAULT NULL
                     , p_scope         IN VARCHAR2 DEFAULT '%'
                     , p_script_count  IN NUMBER   DEFAULT 0
                     , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                     )
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_fn_header( cp_prefix IN VARCHAR2
                        , cp_schema IN VARCHAR2
                        , cp_type   IN VARCHAR2
                        , cp_object IN VARCHAR2
                        , cp_scope  IN VARCHAR2
                        , cp_count  IN NUMBER
                        , cp_show   IN NUMBER
                        )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_function_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_prc_header( cp_prefix IN VARCHAR2
                         , cp_schema IN VARCHAR2
                         , cp_type   IN VARCHAR2
                         , cp_object IN VARCHAR2
                         , cp_scope  IN VARCHAR2
                         , cp_count  IN NUMBER
                         , cp_show   IN NUMBER
                         )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_procedure_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_scr_header( cp_prefix IN VARCHAR2
                         , cp_schema IN VARCHAR2
                         , cp_type   IN VARCHAR2
                         , cp_object IN VARCHAR2
                         , cp_scope  IN VARCHAR2
                         , cp_count  IN NUMBER
                         , cp_show   IN NUMBER
                         )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_script_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_FUNCTION
    THEN
      FOR rec IN cur_fn_header(p_title_prefix, p_schema, p_object_type, p_object, p_scope, p_script_count, p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSIF generation_type = otap_constants.OTAP_GEN_TYPE_PROCEDURE
    THEN
      FOR rec IN cur_prc_header(p_title_prefix, p_schema, p_object_type, p_object, p_scope, p_script_count, p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSE
      -- all other cases script
      FOR rec IN cur_scr_header(p_title_prefix, p_schema, p_object_type, p_object, p_scope, p_script_count, p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END get_header;

  FUNCTION build_script_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
  BEGIN
    -- build finish
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := '-- end OTAP tests';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '/* alternative option get and return finish code';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'COLUMN EXIT_CODE NEW_VAL EXIT_CODE';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test_with_exit_code AS EXIT_CODE FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'RETURN &' || 'EXIT_CODE';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '*/';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- get result';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- ' || LPAD(otap_constants.OTAP_INTERNAL_NAME, 59, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- ' || LPAD(otap_constants.OTAP_INTERNAL_VERSION_NR, 47, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT1;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT2;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT3;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_script_footer;

  FUNCTION build_function_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
  BEGIN
    -- build finish
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := otap_generate.get_code_pad || '-- end OTAP tests';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_return := otap_test.finish_test_with_exit_code;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- you may want to insert functionality to persist the report or id to your system';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- or consume exceptions to guarantee following functions or procedures will run';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := otap_generate.get_code_pad || '-- ' || LPAD(otap_constants.OTAP_INTERNAL_NAME, 59, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || LPAD(otap_constants.OTAP_INTERNAL_VERSION_NR, 47, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT1;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT2;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT3;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'RETURN l_return;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'END;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '/';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_function_footer;

  FUNCTION build_procedure_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
  BEGIN
    -- build finish
    IF p_show_header = otap_constants.OTAP_NUM_TRUE
    THEN
      l_statement := '  -- end OTAP tests';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- finish test session, consume the return code or act upon result before leaving the procedure';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || 'l_return := otap_test.finish_test_with_exit_code;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- you may want to insert functionality to persist the report or id to your system';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- or consume exceptions to guarantee following functions or procedures will run';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := otap_generate.get_code_pad || '-- ' || LPAD(otap_constants.OTAP_INTERNAL_NAME, 59, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || LPAD(otap_constants.OTAP_INTERNAL_VERSION_NR, 47, ' ');
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT1;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT2;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_pad || '-- ' || otap_constants.OTAP_INTERNAL_COPYRIGHT3;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'END;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '/';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_procedure_footer;

  FUNCTION get_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  IS
    CURSOR cur_fn_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_function_footer(cp_show))
    ;
    CURSOR cur_prc_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_procedure_footer(cp_show))
    ;
    CURSOR cur_scr_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_script_footer(cp_show))
    ;
  BEGIN
    IF generation_type = otap_constants.OTAP_GEN_TYPE_FUNCTION
    THEN
      FOR rec IN cur_fn_footer(p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSIF generation_type = otap_constants.OTAP_GEN_TYPE_PROCEDURE
    THEN
      FOR rec IN cur_prc_footer(p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSE
      -- all other cases script
      FOR rec IN cur_scr_footer(p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END get_footer;

  FUNCTION column_tests( p_table         IN VARCHAR2
                       , p_like_column   IN VARCHAR2 DEFAULT '%'
                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_table       VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_columns( cp_schema IN VARCHAR2
                      , cp_table  IN VARCHAR2
                      , cp_like   IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT table_name
           , column_name
           , owner
           , data_type
           , data_precision
           , data_length
           , data_scale
           , nullable
           , data_default_vc
        FROM dba_tab_columns
       WHERE owner          = cp_schema
         AND table_name     = cp_table
         AND column_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(column_name, cp_excl)
       ORDER BY column_id
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    IF p_table IS NOT NULL
    THEN
      l_table      := otap_string.reduce(p_table, 128);
      l_like       := NVL(p_like_column, '%');
      l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
      -- get test count
      SELECT COUNT(*)
        INTO l_test_count
        FROM dba_tab_columns
       WHERE owner          = l_schema
         AND table_name     = l_table
         AND column_name LIKE l_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(column_name, p_excl_sysgen)
      ;
      -- get header
      FOR rec IN cur_header(p_title_prefix, l_schema, 'columns', l_table, l_like, l_test_count, p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
      l_pad_par := otap_generate.get_code_prefix_len + 20;
      FOR rec IN cur_columns(l_schema, l_table, l_like, p_excl_sysgen)
      LOOP
        l_statement := otap_generate.get_code_prefix || 'otap_test.has_column( p_table_name => ''' || rec.table_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_column_name => ''' || rec.column_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || rec.owner || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_type => ''' || rec.data_type || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_length => ' || TRIM(TO_CHAR(rec.data_length));
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        IF rec.data_precision IS NOT NULL
        THEN
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_precision => ' || TRIM(TO_CHAR(rec.data_precision));
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END IF;
        IF rec.data_scale IS NOT NULL
        THEN
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_scale => ' || TRIM(TO_CHAR(rec.data_scale));
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END IF;
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_nullable => ''' || rec.nullable || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        IF     rec.data_default_vc IS NOT NULL
           AND NOT otap_string.is_sys_object(rec.data_default_vc, p_excl_sysgen)
        THEN
          IF INSTR(rec.data_default_vc, '''') > 0
          THEN
            l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_default => q''[' || TRIM(rec.data_default_vc) || ']''';
            PIPE ROW (otap_view_result_rec(l_statement, NULL));
          ELSE
            l_statement := LPAD(' ', l_pad_par, ' ') || ', p_data_default => ''' || TRIM(rec.data_default_vc) || '''';
            PIPE ROW (otap_view_result_rec(l_statement, NULL));
          END IF;
        END IF;
        l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END LOOP;
      FOR rec IN cur_footer(p_show_header)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END column_tests;

  FUNCTION table_tests( p_like_table    IN VARCHAR2 DEFAULT '%'
                      , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                      , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_tables( cp_schema IN VARCHAR2
                     , cp_like   IN VARCHAR2
                     , cp_excl   IN NUMBER
                     )
    IS
      SELECT object_name AS table_name
        FROM dba_objects
       WHERE owner          = cp_schema
         AND object_type    = 'TABLE'
         AND object_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(object_name, cp_excl)
    ;
    CURSOR cur_columns( cp_schema IN VARCHAR2
                      , cp_table  IN VARCHAR2
                      , cp_like   IN VARCHAR2
                      , cp_prefix IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.column_tests(cp_table, cp_like, cp_schema, cp_prefix, 0, cp_excl))
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_table, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    -- get test count, simulate conditions of called test generators
       WITH base AS
           (SELECT object_name
                 , object_type
                 , owner
              FROM dba_objects
             WHERE owner = l_schema
                   -- currently supported objects
               AND object_type    = 'TABLE'
                   -- user like condition
               AND object_name LIKE l_like ESCAPE '\'
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(object_name, p_excl_sysgen)
           )
           -- counter objects
         , cnt_base AS (SELECT COUNT(*) AS expected_count FROM base)
         , cols AS
           (SELECT dbc.owner
                 , dbc.table_name
                 , dbc.column_name
              FROM dba_tab_columns dbc
             INNER JOIN base
                ON dbc.owner      = base.owner
               AND dbc.table_name = base.object_name
                   -- user like condition
             WHERE dbc.column_name LIKE '%' ESCAPE '\'
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(dbc.column_name, p_excl_sysgen)
           )
         , cnt_cols AS (SELECT COUNT(*) AS expected_count FROM cols)
         , cnt AS
           (SELECT expected_count, 'BASE' AS info FROM cnt_base
             UNION ALL
            SELECT expected_count, 'COLUMNS' AS info FROM cnt_cols
           )
    SELECT SUM(expected_count) INTO l_test_count FROM cnt;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'tables', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 19;
    -- build group row
    l_statement := otap_generate.get_code_pad || '-- set test group for tables';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_group(''tables'')' || otap_generate.get_code_postfix;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    FOR rec IN cur_tables(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := otap_generate.get_code_pad || '-- set test name for table';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_name(''table ' || rec.table_name || ''')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.has_table( p_table_name => ''' || rec.table_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR colrec IN cur_columns(l_schema, rec.table_name, '%', p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(colrec.result_text, NULL));
      END LOOP;
    END LOOP;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END table_tests;

  FUNCTION trigger_tests( p_like_trigger  IN VARCHAR2 DEFAULT '%'
                        , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_count       INTEGER;
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_table_trigger( cp_schema IN VARCHAR2
                            , cp_like   IN VARCHAR2
                            , cp_excl   IN NUMBER
                            )
    IS
      SELECT table_name
        FROM dba_triggers
       WHERE owner           = cp_schema
         AND table_name     IS NOT NULL
         AND trigger_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(table_name, cp_excl)
         AND NOT otap_string.is_sys_object(trigger_name, cp_excl)
       GROUP BY table_name
       ORDER BY table_name
    ;
    CURSOR cur_trigger( cp_schema IN VARCHAR2
                      , cp_table  IN VARCHAR2
                      , cp_like   IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT trigger_name
           , table_name
           , table_owner
           , owner
           , trigger_type
           , triggering_event
        FROM dba_triggers
       WHERE owner           = cp_schema
         AND table_name      = cp_table
         AND trigger_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(trigger_name, cp_excl)
       ORDER BY trigger_name
    ;
    CURSOR cur_other_trigger( cp_schema IN VARCHAR2
                            , cp_like   IN VARCHAR2
                            , cp_excl   IN NUMBER
                            )
    IS
      SELECT trigger_name
           , owner
           , trigger_type
           , triggering_event
        FROM dba_triggers
       WHERE owner           = cp_schema
         AND table_name     IS NULL
         AND trigger_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(trigger_name, cp_excl)
       ORDER BY trigger_name
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_trigger, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    -- get test count
    SELECT COUNT(*)
      INTO l_test_count
      FROM dba_triggers
     WHERE owner           = l_schema
       AND trigger_name LIKE l_like ESCAPE '\'
       AND NOT otap_string.is_sys_object(trigger_name, p_excl_sysgen)
    ;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'trigger', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 21;
    l_statement :=  otap_generate.get_code_prefix || 'otap_test.set_group_name(''trigger'')' || otap_generate.get_code_postfix;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    SELECT COUNT(*) INTO l_count FROM dba_triggers WHERE owner = l_schema AND table_name IS NOT NULL;
    IF l_count > 0
    THEN
      FOR rec IN cur_table_trigger(l_schema, l_like, p_excl_sysgen)
      LOOP
        -- build name
        l_statement := otap_generate.get_code_pad || '-- set test name for table trigger';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement :=  otap_generate.get_code_prefix || 'otap_test.set_test_name(''table trigger ' || rec.table_name || ''')' || otap_generate.get_code_postfix;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        FOR rectrg IN cur_trigger(l_schema, rec.table_name, '%', p_excl_sysgen)
        LOOP
          l_statement := otap_generate.get_code_prefix || 'otap_test.has_trigger( p_trigger_name => ''' || rectrg.trigger_name || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || rectrg.owner || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_trigger_type => ''' || TRIM(rectrg.trigger_type) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_trigger_event => ''' || TRIM(rectrg.triggering_event) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_table_owner => ''' || TRIM(rectrg.table_owner) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ', p_table_name => ''' || TRIM(rectrg.table_name) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END LOOP;
      END LOOP;
    END IF;
    -- trigger without table
    SELECT COUNT(*) INTO l_count FROM dba_triggers WHERE owner = l_schema AND table_name IS NULL;
    IF l_count > 0
    THEN
      l_statement := otap_generate.get_code_pad || '-- set test name for non table trigger';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement :=  otap_generate.get_code_prefix || 'otap_test.set_test_name(''trigger without table'')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR rec IN cur_other_trigger(l_schema, l_like, p_excl_sysgen)
      LOOP
        l_statement := otap_generate.get_code_prefix || 'otap_test.has_trigger( p_trigger_name => ''' || rec.trigger_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || rec.owner || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_trigger_type => ''' || TRIM(rec.trigger_type) || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_trigger_event => ''' || TRIM(rec.triggering_event) || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END LOOP;
    END IF;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END trigger_tests;

  FUNCTION procedure_tests( p_like_procedure IN VARCHAR2 DEFAULT '%'
                          , p_package_name   IN VARCHAR  DEFAULT NULL
                          , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                          , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                          , p_show_header    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          , p_excl_sysgen    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_package     VARCHAR2(128 CHAR);
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_procedures( cp_schema  IN VARCHAR2
                         , cp_package IN VARCHAR2
                         , cp_like    IN VARCHAR2
                         , cp_excl    IN NUMBER
                         )
    IS
        WITH prc AS
             (SELECT dbo.owner
                   , dbp.procedure_name
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN 'FUNCTION'
                       ELSE 'PROCEDURE'
                     END AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , dbo.object_name AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.package_name
                 AND dbp.procedure_name = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = cp_schema
                 AND dbo.object_type  = 'PACKAGE'
                     -- exclude package itself
                 AND dbp.procedure_name IS NOT NULL
                 AND NOT otap_string.is_sys_object(dbp.procedure_name, cp_excl)
                 AND NOT otap_string.is_sys_object(dbo.object_name, cp_excl)
               UNION ALL
              SELECT dbo.owner
                   , dbo.object_name AS procedure_name
                   , dbo.object_type AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , NULL AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = cp_schema
                 AND dbo.object_type IN ('FUNCTION', 'PROCEDURE')
                 AND NOT otap_string.is_sys_object(dbo.object_name, cp_excl)
             )
      SELECT DISTINCT
             owner
           , procedure_name
           , procedure_type
           , return_type
           , status
           , package_name
        FROM prc
       WHERE NVL(package_name, 'N/A') = NVL(cp_package, 'N/A')
         AND procedure_name        LIKE cp_like ESCAPE '\'
    ;
    CURSOR cur_count( cp_schema  IN VARCHAR2
                    , cp_package IN VARCHAR2
                    , cp_like    IN VARCHAR2
                    , cp_excl    IN NUMBER
                    )
    IS
        WITH prc AS
             (SELECT dbo.owner
                   , dbp.procedure_name
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN 'FUNCTION'
                       ELSE 'PROCEDURE'
                     END AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , dbo.object_name AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.package_name
                 AND dbp.procedure_name = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = cp_schema
                 AND dbo.object_type  = 'PACKAGE'
                     -- exclude package itself
                 AND dbp.procedure_name IS NOT NULL
                 AND NOT otap_string.is_sys_object(dbp.procedure_name, cp_excl)
                 AND NOT otap_string.is_sys_object(dbo.object_name, cp_excl)
               UNION ALL
              SELECT dbo.owner
                   , dbo.object_name AS procedure_name
                   , dbo.object_type AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , NULL AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = cp_schema
                 AND dbo.object_type IN ('FUNCTION', 'PROCEDURE')
                 AND NOT otap_string.is_sys_object(dbo.object_name, cp_excl)
             )
           , res AS
             (SELECT DISTINCT
                     owner
                   , procedure_name
                   , procedure_type
                   , return_type
                   , status
                   , package_name
                FROM prc
               WHERE NVL(package_name, 'N/A') = NVL(cp_package, 'N/A')
                 AND procedure_name        LIKE cp_like ESCAPE '\'
             )
    SELECT COUNT(*) AS test_count FROM res;

    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_procedure, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    OPEN cur_count(l_schema, p_package_name, l_like, p_excl_sysgen);
    FETCH cur_count INTO l_test_count;
    CLOSE cur_count;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'procedures', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 23;
    FOR rec IN cur_procedures(l_schema, p_package_name, l_like, p_excl_sysgen)
    LOOP
      IF p_package_name IS NULL
      THEN
        -- set name if not package, otherwise name is already set
        l_statement := otap_generate.get_code_pad || '-- set test name for not package procedures and functions';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement :=  otap_generate.get_code_prefix || 'otap_test.set_test_name(''' || rec.procedure_type || ' ' || rec.procedure_name || ''')' || otap_generate.get_code_postfix;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      l_statement := otap_generate.get_code_prefix || 'otap_test.has_procedure( p_procedure_name => ''' || rec.procedure_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_procedure_type => ''' || rec.procedure_type || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_package_name => ''' || rec.package_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      IF rec.procedure_type = 'FUNCTION'
      THEN
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_return_type => ''' || rec.return_type || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END LOOP;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END procedure_tests;

  FUNCTION package_tests( p_like_package  IN VARCHAR2 DEFAULT '%'
                        , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_count       INTEGER;
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_packages( cp_schema IN VARCHAR2
                       , cp_like   IN VARCHAR2
                       , cp_excl   IN NUMBER
                       )
    IS
      SELECT object_name AS package_name
           , COUNT(*)    AS package_objects
        FROM dba_objects
       WHERE owner          = cp_schema
         AND object_type LIKE 'PACKAGE%'
         AND object_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(object_name, cp_excl)
       GROUP BY object_name
    ;
    CURSOR cur_procedures( cp_schema  IN VARCHAR2
                         , cp_package IN VARCHAR2
                         , cp_like    IN VARCHAR2
                         , cp_prefix  IN VARCHAR2
                         , cp_excl    IN NUMBER
                         )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.procedure_tests(cp_like, cp_package, cp_schema, cp_prefix, 0, cp_excl))
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_package, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    -- get test count, simulate conditions of called test generators
       WITH base AS
           (SELECT object_name
                 , object_type
                 , owner
              FROM dba_objects
             WHERE owner = l_schema
                   -- currently supported objects
               AND object_type LIKE 'PACKAGE%'
                   -- user like condition
               AND object_name LIKE l_like ESCAPE '\'
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(object_name, p_excl_sysgen)
           )
           -- counter objects
         , cnt_base AS (SELECT COUNT(*) AS expected_count FROM base)
           -- depending procedures
         , prc AS
           (SELECT dbp.procedure_name
                 , dbp.object_name
                 , dbp.object_type
              FROM dba_procedures dbp
             INNER JOIN base
                ON dbp.object_name = base.object_name
               AND dbp.object_type = base.object_type
               AND dbp.owner       = base.owner
                   -- exclude pure functions and procedures, already counted by base
               AND base.object_type NOT IN ('FUNCTION', 'PROCEDURE')
                   -- user exclude condition
             WHERE NOT otap_string.is_sys_object(dbp.procedure_name, p_excl_sysgen)
           )
         , cnt_prc AS (SELECT COUNT(*) AS expected_count FROM prc)
         , cnt AS
           (SELECT expected_count, 'BASE' AS info FROM cnt_base
             UNION ALL
            SELECT expected_count, 'PROCEDURES' AS info FROM cnt_prc
           )
    SELECT SUM(expected_count) INTO l_test_count FROM cnt;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'packages', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 21;
    -- build group row
    l_statement := otap_generate.get_code_pad || '-- set test group for package';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_group(''packages'')' || otap_generate.get_code_postfix;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    -- first loop through packages
    FOR rec IN cur_packages(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := otap_generate.get_code_pad || '-- set test name for package';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_name(''package ' || rec.package_name || ''')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.has_package( p_package_name => ''' || rec.package_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      IF rec.package_objects = 2
      THEN
        l_statement := otap_generate.get_code_prefix || 'otap_test.has_package( p_package_name => ''' || rec.package_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || l_schema || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ', p_package_type => ''PACKAGE BODY''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      -- now loop through the package procedures and functions
      FOR recfn IN cur_procedures(l_schema, rec.package_name, '%', p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(recfn.result_text, NULL));
      END LOOP;
    END LOOP;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END package_tests;

  FUNCTION view_tests( p_like_view     IN VARCHAR2 DEFAULT '%'
                     , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_views( cp_schema IN VARCHAR2
                    , cp_like   IN VARCHAR2
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT owner
           , object_name AS view_name
           , object_type
        FROM dba_objects
       WHERE owner          = cp_schema
         AND object_type LIKE '%VIEW'
         AND object_name LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(object_name, cp_excl)
       ORDER BY object_type DESC
              , object_name
    ;
    CURSOR cur_columns( cp_schema IN VARCHAR2
                      , cp_table  IN VARCHAR2
                      , cp_like   IN VARCHAR2
                      , cp_prefix IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.column_tests(cp_table, cp_like, cp_schema, cp_prefix, 0, cp_excl))
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_view, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    -- get test count, simulate conditions of called test generators
       WITH base AS
           (SELECT object_name
                 , object_type
                 , owner
              FROM dba_objects
             WHERE owner = l_schema
                   -- currently supported objects
               AND object_type LIKE '%VIEW'
                   -- user like condition
               AND object_name LIKE l_like ESCAPE '\'
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(object_name, p_excl_sysgen)
           )
           -- counter objects
         , cnt_base AS (SELECT COUNT(*) AS expected_count FROM base)
         , cols AS
           (SELECT dbc.owner
                 , dbc.table_name
                 , dbc.column_name
              FROM dba_tab_columns dbc
             INNER JOIN base
                ON dbc.owner      = base.owner
               AND dbc.table_name = base.object_name
                   -- user like condition
             WHERE dbc.column_name LIKE '%' ESCAPE '\'
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(dbc.column_name, p_excl_sysgen)
           )
         , cnt_cols AS (SELECT COUNT(*) AS expected_count FROM cols)
         , cnt AS
           (SELECT expected_count, 'BASE' AS info FROM cnt_base
             UNION ALL
            SELECT expected_count, 'COLUMNS' AS info FROM cnt_cols
           )
    SELECT SUM(expected_count) INTO l_test_count FROM cnt;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'views', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 20;
    -- build group row
    l_statement := otap_generate.get_code_pad || '-- set test group for views';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_group(''views'')' || otap_generate.get_code_postfix;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    -- first loop through views
    FOR rec IN cur_views(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := otap_generate.get_code_pad || '-- set test name for view';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_name(''view ' || rec.view_name || ''')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.has_object( p_object_name => ''' || rec.view_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_object_type => ''' || rec.object_type || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ', p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := LPAD(' ', l_pad_par, ' ') || ')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR colrec IN cur_columns(l_schema, rec.view_name, '%', p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(colrec.result_text, NULL));
      END LOOP;
    END LOOP;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END view_tests;

  FUNCTION schema_tests( p_like_schema   IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
    l_pad_par     INTEGER;
    CURSOR cur_schemas( cp_like IN VARCHAR2
                      , cp_excl IN NUMBER
                      )
    IS
      SELECT username
        FROM dba_users
       WHERE username LIKE cp_like ESCAPE '\'
         AND NOT otap_string.is_sys_object(username, cp_excl)
    ;
    CURSOR cur_tables( cp_like   IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_prefix IN VARCHAR2
                     , cp_excl   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.table_tests(cp_like, cp_schema, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_trigger( cp_like   IN VARCHAR2
                      , cp_schema IN VARCHAR2
                      , cp_prefix IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.trigger_tests(cp_like, cp_schema, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_packages( cp_like   IN VARCHAR2
                       , cp_schema IN VARCHAR2
                       , cp_prefix IN VARCHAR2
                       , cp_excl   IN NUMBER
                       )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.package_tests(cp_like, cp_schema, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_views( cp_like   IN VARCHAR2
                    , cp_schema IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.view_tests(cp_like, cp_schema, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_header( cp_prefix IN VARCHAR2
                     , cp_schema IN VARCHAR2
                     , cp_type   IN VARCHAR2
                     , cp_object IN VARCHAR2
                     , cp_scope  IN VARCHAR2
                     , cp_count  IN NUMBER
                     , cp_show   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_header(cp_prefix, cp_schema, cp_type, cp_object, cp_scope, cp_count, cp_show))
    ;
    CURSOR cur_footer(cp_show IN NUMBER)
    IS
      SELECT result_text
        FROM TABLE(otap_generate.get_footer(cp_show))
    ;
  BEGIN
    l_like       := NVL(p_like_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'));
    l_schema     := otap_string.reduce(SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'), 128);
    -- get test count, simulate conditions of called test generators
       WITH base AS
           (SELECT object_name
                 , object_type
                 , owner
              FROM dba_objects
                   -- user like condition
             WHERE owner LIKE l_like ESCAPE '\'
                   -- currently supported objects
               AND (   object_type   IN ('TABLE', 'FUNCTION', 'PROCEDURE')
                    OR object_type LIKE '%VIEW'
                    OR object_type LIKE 'PACKAGE%'
                   )
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(object_name, p_excl_sysgen)
           )
           -- counter objects
         , cnt_base AS (SELECT COUNT(*) AS expected_count FROM base)
           -- depending procedures
         , prc AS
           (SELECT dbp.procedure_name
                 , dbp.object_name
                 , dbp.object_type
              FROM dba_procedures dbp
             INNER JOIN base
                ON dbp.object_name = base.object_name
               AND dbp.object_type = base.object_type
               AND dbp.owner       = base.owner
                   -- exclude pure functions and procedures, already counted by base
               AND base.object_type NOT IN ('FUNCTION', 'PROCEDURE')
                   -- user exclude condition
             WHERE NOT otap_string.is_sys_object(dbp.procedure_name, p_excl_sysgen)
           )
         , cnt_prc AS (SELECT COUNT(*) AS expected_count FROM prc)
         , cols AS
           (SELECT dbc.owner
                 , dbc.table_name
                 , dbc.column_name
              FROM dba_tab_columns dbc
             INNER JOIN base
                ON dbc.owner      = base.owner
               AND dbc.table_name = base.object_name
                   -- user exclude condition
             WHERE NOT otap_string.is_sys_object(dbc.column_name, p_excl_sysgen)
           )
         , cnt_cols AS (SELECT COUNT(*) AS expected_count FROM cols)
           -- table triggers
         , trgt AS
           (SELECT dbt.owner
                 , dbt.trigger_name
                 , dbt.table_owner
              FROM dba_triggers dbt
             INNER JOIN base
                ON dbt.table_owner      = base.owner
               AND dbt.table_name       = base.object_name
               AND dbt.base_object_type = base.object_type
             WHERE dbt.table_name     IS NOT NULL
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(dbt.trigger_name, p_excl_sysgen)
           )
         , cnt_trgt AS (SELECT COUNT(*) AS expected_count FROM trgt)
         , trgs AS
           (SELECT dbt.owner
                 , dbt.trigger_name
                 , dbt.table_owner
              FROM dba_triggers dbt
             INNER JOIN base
                ON dbt.owner = base.owner
             WHERE dbt.table_name     IS NULL
                   -- user exclude condition
               AND NOT otap_string.is_sys_object(dbt.trigger_name, p_excl_sysgen)
           )
         , cnt_trgs AS (SELECT COUNT(*) AS expected_count FROM trgs)
         , cnt AS
           (SELECT expected_count, 'BASE' AS info FROM cnt_base
             UNION ALL
            SELECT expected_count, 'PROCEDURES' AS info FROM cnt_prc
             UNION ALL
            SELECT expected_count, 'COLUMNS' AS info FROM cnt_cols
             UNION ALL
            SELECT expected_count, 'TABLE TRIGGER' AS info FROM cnt_trgt
             UNION ALL
            SELECT expected_count, 'SCHEMA TRIGGER' AS info FROM cnt_trgs
           )
    SELECT SUM(expected_count) INTO l_test_count FROM cnt;
    -- get header
    FOR rec IN cur_header(p_title_prefix, l_schema, 'schemas', NULL, l_like, l_test_count, p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    l_pad_par := otap_generate.get_code_prefix_len + 20;
    -- get schemas to process
    FOR recset IN cur_schemas(l_like, p_excl_sysgen)
    LOOP
      -- build set row
      l_statement := otap_generate.get_code_pad || '-- set test set for schema';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := otap_generate.get_code_prefix || 'otap_test.set_test_set(''schema ' || recset.username || ''')' || otap_generate.get_code_postfix;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR rec IN cur_tables('%', recset.username, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
      FOR rec IN cur_trigger('%', recset.username, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
      FOR rec IN cur_packages('%', recset.username, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
      FOR rec IN cur_views('%', recset.username, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    END LOOP;
    FOR rec IN cur_footer(p_show_header)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END schema_tests;

  FUNCTION get_dba_col_details( p_table_name  IN VARCHAR2
                              , p_column_name IN VARCHAR2
                              )
    RETURN VARCHAR2
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_count     INTEGER;
    l_data_type sys.dba_tab_columns.data_type%TYPE;
    l_nullable  sys.dba_tab_columns.nullable%TYPE;
    l_char_len  sys.dba_tab_columns.char_length%TYPE;
    l_statement VARCHAR2(32767 CHAR);
    l_return    VARCHAR2(4000 CHAR);
    l_dba_table VARCHAR2(128 CHAR);
    l_dba_col   VARCHAR2(128 CHAR);
  BEGIN
    IF     p_table_name  IS NOT NULL
       AND p_column_name IS NOT NULL
    THEN
      l_dba_table := otap_string.reduce(UPPER(p_table_name), 128);
      l_dba_col   := otap_string.reduce(UPPER(p_column_name), 128);
      SELECT COUNT(*)
        INTO l_count
        FROM dba_tab_columns
       WHERE owner = 'SYS'
         AND table_name   = l_dba_table
         AND column_name  = l_dba_col
         AND data_type   IN ('VARCHAR2', 'DATE', 'NUMBER')
      ;
      IF l_count = 0
      THEN
        l_return := 'Invalid column or table name or datatype not supported';
      ELSE
        -- get column details
        SELECT data_type
             , nullable
             , char_length
          INTO l_data_type
             , l_nullable
             , l_char_len
          FROM dba_tab_columns
         WHERE owner = 'SYS'
           AND table_name   = l_dba_table
           AND column_name  = l_dba_col
           AND data_type   IN ('VARCHAR2', 'DATE', 'NUMBER')
        ;
        IF l_nullable = 'N'
        THEN
          l_return := LOWER(l_dba_col) || ' -- not nullable';
          -- determine valid NULL substition
          IF l_data_type = 'VARCHAR2'
          THEN
            l_return    := l_return || ' (' || TRIM(TO_CHAR(l_char_len)) || ' chars)';
            l_statement := 'SELECT COUNT(*) FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' = ''n/a'' AND ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := l_return || CASE WHEN l_count = 0 THEN ' n/a valid substitute' ELSE ' n/a not working as substitute' END;
          ELSIF l_data_type = 'NUMBER'
          THEN
            -- verify -1 is usable
            l_statement := 'SELECT MIN(' || l_dba_col || ') FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := l_return || CASE WHEN l_count >= 0 THEN ' -1 valid substitute' ELSE ' -1 not working as substitute' END;
          ELSE
            -- verify 01.01.1900 is usable
            l_statement := 'SELECT COUNT(*) FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' = TO_DATE(''01.01.1900'', ''DD.MM.YYYY'') AND ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := l_return || CASE WHEN l_count = 0 THEN ' TO_DATE(''01.01.1900'', ''DD.MM.YYYY'') valid substitute' ELSE ' TO_DATE(''01.01.1900'', ''DD.MM.YYYY'') not working as substitute' END;
          END IF;
        ELSE
          -- determine valid NULL substition
          IF l_data_type = 'VARCHAR2'
          THEN
            -- verify n/a is not used in the given field for the given table and column
            l_statement := 'SELECT COUNT(*) FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' = ''n/a'' AND ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := 'NVL(' || LOWER(l_dba_col) || ', ''n/a'')';
            l_return    := l_return || ' (' || TRIM(TO_CHAR(l_char_len)) || ' chars)';
            IF l_count != 0
            THEN
              l_return := l_return || ' -- n/a not save, substitute the value by a value that is not contained in the column';
            END IF;
          ELSIF l_data_type = 'NUMBER'
          THEN
            -- verify -1 is usable
            l_statement := 'SELECT MIN(' || l_dba_col || ') FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := 'NVL(' || LOWER(l_dba_col) || ', -1)';
            IF l_count < 0
            THEN
              l_return := l_return || ' -- -1 not save, substitute the value by a value that is not contained in the column';
            END IF;
          ELSE
            -- verify 01.01.1900 is usable
            l_statement := 'SELECT COUNT(*) FROM ' || l_dba_table || ' WHERE ' || l_dba_col || ' = TO_DATE(''01.01.1900'', ''DD.MM.YYYY'') AND ' || l_dba_col || ' IS NOT NULL';
            EXECUTE IMMEDIATE l_statement INTO l_count;
            l_return := 'NVL(' || LOWER(l_dba_col) || ', TO_DATE(''01.01.1900'', ''DD.MM.YYYY''))';
            IF l_count != 0
            THEN
              l_return := l_return || ' -- 01.01.1900 not save, substitute the value by a value that is not contained in the column';
            END IF;
          END IF;
        END IF;
      END IF;
    ELSE
      l_return := 'Try using NOT NULL values for both parameters';
    END IF;
    RETURN l_return;
  END get_dba_col_details;

END;
/