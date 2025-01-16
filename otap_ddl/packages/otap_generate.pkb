-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_generate
AS
  -- internal package constants and variables
  PREFIX_SQL          CONSTANT CHAR(7)  := 'SELECT ';
  PREFIX_PLSQL        CONSTANT CHAR(15) := '  l_message := ';
  POSTFIX_SQL         CONSTANT CHAR(11) := ' FROM daul;';
  POSTFIX_PLSQL       CONSTANT CHAR(1)  := ';';

  generation_type VARCHAR2(1) := 'S';

  -- for description see header file
  PROCEDURE set_gen_type(p_gen_type IN VARCHAR2)
  IS
  BEGIN
    IF TRIM(p_gen_type) IN (GEN_TYPE_SCRIPT, GEN_TYPE_FUNCTION, GEN_TYPE_PROCEDURE)
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

  FUNCTION build_script_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_set           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_group         IN VARCHAR2 DEFAULT NULL
                              , p_name          IN VARCHAR2 DEFAULT NULL
                              , p_script_count  IN NUMBER   DEFAULT 0
                              )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_title       VARCHAR2(4000 CHAR);
  BEGIN
    l_title := NULL;
    IF p_name IS NOT NULL
    THEN
      -- for names we do not care about underscores
      l_title := otap_string.reduce(p_name, 4000);
    ELSE
      IF p_group IS NOT NULL
      THEN
        l_title := otap_string.reduce(p_group, 4000);
      ELSE
          l_title := otap_string.reduce(p_set, 4000);
      END IF;
    END IF;
    l_title := CASE
                 WHEN p_title_prefix IS NOT NULL
                 -- add prefix limited to 10 chars
                 THEN otap_string.reduce(p_title_prefix, 10) || ' ' || NVL(l_title, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
                 ELSE NVL(l_title, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
               END
    ;
    l_statement := '-- otap GENERATE test scripts ' || l_title;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := PREFIX_SQL || 'otap_test.init_test(' || TRIM(TO_CHAR(NVL(p_script_count, 0))) || ')' || POSTFIX_SQL;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_script_header;

  FUNCTION build_function_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_set           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_group         IN VARCHAR2 DEFAULT NULL
                                , p_name          IN VARCHAR2 DEFAULT NULL
                                , p_script_count  IN NUMBER   DEFAULT 0
                                )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_set         VARCHAR2(128 CHAR);
    l_group       VARCHAR2(128 CHAR);
    l_name        VARCHAR2(128 CHAR);
    l_fn_name     VARCHAR2(128 CHAR);
    l_prefix      VARCHAR2(10 CHAR);
  BEGIN
    l_fn_name := 'test_';
    -- set, group and nem should not contain underscore
    l_set     := CASE
                   WHEN p_title_prefix IS NOT NULL
                   -- add prefix limited to 10 chars
                   THEN SUBSTR(TRIM(p_title_prefix), 1, 10) || NVL(TRIM(p_set), SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
                   ELSE NVL(TRIM(p_set), SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
                 END
    ;
    l_set     := otap_string.reduce(REGEXP_REPLACE(l_set, '[^[:alnum:]]'), 40);
    l_fn_name := l_fn_name || l_set;
    -- if group is not defined, name is not considered
    IF p_group IS NOT NULL
    THEN
      l_group := otap_string.reduce(REGEXP_REPLACE(p_group, '[^[:alnum:]]'), 30);
      l_fn_name := l_fn_name || '_' || l_group;
      IF p_name IS NOT NULL
      THEN
        -- for names we do not care about underscores
        l_name := otap_string.reduce(REGEXP_REPLACE(p_name, '[^[:alnum:]_]'), 128);
        l_fn_name := l_fn_name || '_' || l_name;
      END IF;
    END IF;
    -- remove blanks and not allowed/recommended chars if still any and reduce
    l_fn_name  := otap_string.reduce(REGEXP_REPLACE(l_fn_name, '[^[:alnum:]_]'), 128);
    l_statement := '-- otap GENERATE test function ' || UPPER(l_fn_name);
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'CREATE OR REPLACE FUNCTION ' || l_fn_name;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := ' RETURN NUMBER';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'IS';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := '  l_message VARCHAR2(4000);';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := '  l_return  NUMBER;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'BEGIN';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_function_header;

  FUNCTION build_procedure_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_set           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_group         IN VARCHAR2 DEFAULT NULL
                                 , p_name          IN VARCHAR2 DEFAULT NULL
                                 , p_script_count  IN NUMBER   DEFAULT 0
                                 )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_set         VARCHAR2(128 CHAR);
    l_group       VARCHAR2(128 CHAR);
    l_name        VARCHAR2(128 CHAR);
    l_fn_name     VARCHAR2(128 CHAR);
    l_prefix      VARCHAR2(10 CHAR);
  BEGIN
    l_fn_name := 'test_';
    -- set, group and nem should not contain underscore
    l_set     := CASE
                   WHEN p_title_prefix IS NOT NULL
                   -- add prefix limited to 10 chars
                   THEN SUBSTR(TRIM(p_title_prefix), 1, 10) || NVL(TRIM(p_set), SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
                   ELSE NVL(TRIM(p_set), SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))
                 END
    ;
    l_set     := otap_string.reduce(REGEXP_REPLACE(l_set, '[^[:alnum:]]'), 40);
    l_fn_name := l_fn_name || l_set;
    -- if group is not defined, name is not considered
    IF p_group IS NOT NULL
    THEN
      l_group := otap_string.reduce(REGEXP_REPLACE(p_group, '[^[:alnum:]]'), 30);
      l_fn_name := l_fn_name || '_' || l_group;
      IF p_name IS NOT NULL
      THEN
        -- for names we do not care about underscores
        l_name := otap_string.reduce(REGEXP_REPLACE(p_name, '[^[:alnum:]_]'), 128);
        l_fn_name := l_fn_name || '_' || l_name;
      END IF;
    END IF;
    -- remove blanks and not allowed/recommended chars if still any and reduce
    l_fn_name  := otap_string.reduce(REGEXP_REPLACE(l_fn_name, '[^[:alnum:]_]'), 128);
    l_statement := '-- otap GENERATE test procedure ' || UPPER(l_fn_name);
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'CREATE OR REPLACE PROCEDURE ' || l_fn_name;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'IS';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := '  l_message VARCHAR2(4000);';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := '  l_return  NUMBER;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'BEGIN';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END build_procedure_header;

  FUNCTION get_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_set           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_group         IN VARCHAR2 DEFAULT NULL
                     , p_name          IN VARCHAR2 DEFAULT NULL
                     , p_script_count  IN NUMBER   DEFAULT 0
                     )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    CURSOR cur_fn_header( cp_title_prefix IN VARCHAR2
                        , cp_set          IN VARCHAR2
                        , cp_group        IN VARCHAR2
                        , cp_name         IN VARCHAR2
                        , cp_count        IN NUMBER
                        )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_function_header(cp_title_prefix, cp_set, cp_group, cp_name, cp_count))
    ;
    CURSOR cur_prc_header( cp_title_prefix IN VARCHAR2
                         , cp_set          IN VARCHAR2
                         , cp_group        IN VARCHAR2
                         , cp_name         IN VARCHAR2
                         , cp_count        IN NUMBER
                         )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_procedure_header(cp_title_prefix, cp_set, cp_group, cp_name, cp_count))
    ;
    CURSOR cur_scr_header( cp_title_prefix IN VARCHAR2
                         , cp_set          IN VARCHAR2
                         , cp_group        IN VARCHAR2
                         , cp_name         IN VARCHAR2
                         , cp_count        IN NUMBER
                         )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.build_script_header(cp_title_prefix, cp_set, cp_group, cp_name, cp_count))
    ;
  BEGIN
    IF generation_type = otap_generate.GEN_TYPE_FUNCTION
    THEN
      FOR rec IN cur_fn_header(p_title_prefix, p_set, p_group, p_name, p_script_count)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSIF generation_type = otap_generate.GEN_TYPE_PROCEDURE
    THEN
      FOR rec IN cur_prc_header(p_title_prefix, p_set, p_group, p_name, p_script_count)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    ELSE
      -- all other cases script
      FOR rec IN cur_scr_header(p_title_prefix, p_set, p_group, p_name, p_script_count)
      LOOP
        PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
      END LOOP;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END get_header;

  FUNCTION column_tests( p_table         IN VARCHAR2
                       , p_like_column   IN VARCHAR2 DEFAULT '%'
                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT 1
                       , p_excl_sysgen   IN INTEGER  DEFAULT 1
                       )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_table       VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
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
         AND column_name LIKE cp_like
         AND NOT otap_string.is_sys_object(column_name, cp_excl)
       ORDER BY column_id
    ;
  BEGIN
    IF p_table IS NOT NULL
    THEN
      l_table      := otap_string.reduce(p_table, 128);
      l_like       := NVL(p_like_column, '%');
      l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
      l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
      IF NVL(p_show_header, 1) = 1
      THEN
        l_statement := '-- otap GENERATE column test scripts for table ' || l_schema || '.' || l_table || ' scope: ' || l_like;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        -- get test count
        SELECT COUNT(*)
          INTO l_test_count
          FROM dba_tab_columns
         WHERE owner          = l_schema
           AND table_name     = l_table
           AND column_name LIKE l_like
           AND NOT otap_string.is_sys_object(column_name, p_excl_sysgen)
        ;
        -- build init
        l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      l_statement := '-- loop through columns with names like ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR rec IN cur_columns(l_schema, l_table, l_like, p_excl_sysgen)
      LOOP
        l_statement := 'SELECT otap_test.has_column( p_table_name => ''' || rec.table_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                           , p_column_name => ''' || rec.column_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                           , p_schema => ''' || rec.owner || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                           , p_data_type => ''' || rec.data_type || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                           , p_data_length => ' || TRIM(TO_CHAR(rec.data_length));
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        IF rec.data_precision IS NOT NULL
        THEN
          l_statement := '                           , p_data_precision => ' || TRIM(TO_CHAR(rec.data_precision));
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END IF;
        IF rec.data_scale IS NOT NULL
        THEN
          l_statement := '                           , p_data_scale => ' || TRIM(TO_CHAR(rec.data_scale));
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END IF;
        l_statement := '                           , p_nullable => ''' || rec.nullable || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        IF     rec.data_default_vc IS NOT NULL
           AND NOT otap_string.is_sys_object(rec.data_default_vc, p_excl_sysgen)
        THEN
          IF INSTR(rec.data_default_vc, '''') > 0
          THEN
            l_statement := '                           , p_data_default => q''[' || TRIM(rec.data_default_vc) || ']''';
            PIPE ROW (otap_view_result_rec(l_statement, NULL));
          ELSE
            l_statement := '                           , p_data_default => ''' || TRIM(rec.data_default_vc) || '''';
            PIPE ROW (otap_view_result_rec(l_statement, NULL));
          END IF;
        END IF;
        l_statement := '                           ) FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END LOOP;
      IF NVL(p_show_header, 1) = 1
      THEN
        -- build finish
        l_statement := '-- finish column tests for ' || l_table;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- finish test session';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := 'SELECT otap_test.finish_test FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := 'SELECT * FROM otap_latest_test_results_v;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        -- add AI and copyright
        l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      ELSE
        l_statement := '-- finish column tests for ' || l_table;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END column_tests;

  FUNCTION table_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_like_table    IN VARCHAR2 DEFAULT '%'
                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                      , p_show_header   IN INTEGER  DEFAULT 1
                      , p_excl_sysgen   IN INTEGER  DEFAULT 1
                      )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
    CURSOR cur_tables( cp_schema IN VARCHAR2
                     , cp_like   IN VARCHAR2
                     , cp_excl   IN NUMBER
                     )
    IS
      SELECT object_name AS table_name
        FROM dba_objects
       WHERE owner          = cp_schema
         AND object_type    = 'TABLE'
         AND object_name LIKE cp_like
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
  BEGIN
    l_like       := NVL(p_like_table, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
    IF NVL(p_show_header, 1) = 1
    THEN
      l_statement := '-- otap GENERATE table test scripts for schema ' || l_schema || ' scope: ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
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
                 AND object_name LIKE l_like
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
               WHERE dbc.column_name LIKE l_like
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
      -- build init
      l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    -- build group row
    l_statement := '-- set test group for tables';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'SELECT otap_test.set_test_group(''' || l_base_title || ' tables'') FROM dual;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := '-- loop through tables with names like ' || l_like;
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    FOR rec IN cur_tables(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := '-- set test name for table';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.set_test_name(''' || l_base_title || ' table ' || rec.table_name || ''') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.has_table( p_table_name => ''' || rec.table_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                          , p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                          ) FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR colrec IN cur_columns(l_schema, rec.table_name, l_like, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(colrec.result_text, NULL));
      END LOOP;
    END LOOP;
    IF NVL(p_show_header, 1) = 1
    THEN
      -- build finish
      l_statement := '-- finish table tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    ELSE
      l_statement := '-- finish table tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END table_tests;

  FUNCTION trigger_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_like_trigger  IN VARCHAR2 DEFAULT '%'
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT 1
                        , p_excl_sysgen   IN INTEGER  DEFAULT 1
                        )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_count       INTEGER;
    l_test_count  INTEGER;
    CURSOR cur_table_trigger( cp_schema IN VARCHAR2
                            , cp_like   IN VARCHAR2
                            , cp_excl   IN NUMBER
                            )
    IS
      SELECT table_name
        FROM dba_triggers
       WHERE owner           = cp_schema
         AND table_name     IS NOT NULL
         AND trigger_name LIKE cp_like
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
         AND trigger_name LIKE cp_like
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
         AND trigger_name LIKE cp_like
         AND NOT otap_string.is_sys_object(trigger_name, cp_excl)
       ORDER BY trigger_name
    ;
  BEGIN
    l_like       := NVL(p_like_trigger, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
    IF NVL(p_show_header, 1) = 1
    THEN
      l_statement := '-- otap GENERATE trigger test scripts for schema ' || l_schema || ' scope: ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- get test count
      SELECT COUNT(*)
        INTO l_test_count
        FROM dba_triggers
       WHERE owner           = l_schema
         AND trigger_name LIKE l_like
         AND NOT otap_string.is_sys_object(trigger_name, p_excl_sysgen)
      ;
      -- build init
      l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    -- build group row
    l_statement := '-- set test group for trigger';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'SELECT otap_test.set_test_group(''' || l_base_title || ' trigger'') FROM dual;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    -- organize trigger by table or not
    -- trigger with table
    SELECT COUNT(*) INTO l_count FROM dba_triggers WHERE owner = l_schema AND table_name IS NOT NULL;
    IF l_count > 0
    THEN
      FOR rec IN cur_table_trigger(l_schema, l_like, p_excl_sysgen)
      LOOP
        -- build name
        l_statement := 'SELECT otap_test.set_test_name(''' || l_base_title || ' ' || rec.table_name || ' table trigger'') FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- loop through triggers with names like ' || l_like;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        FOR rectrg IN cur_trigger(l_schema, rec.table_name, l_like, p_excl_sysgen)
        LOOP
          l_statement := 'SELECT otap_test.has_trigger( p_trigger_name => ''' || rectrg.trigger_name || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            , p_schema => ''' || rectrg.owner || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            , p_trigger_type => ''' || TRIM(rectrg.trigger_type) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            , p_trigger_event => ''' || TRIM(rectrg.triggering_event) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            , p_table_owner => ''' || TRIM(rectrg.table_owner) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            , p_table_name => ''' || TRIM(rectrg.table_name) || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
          l_statement := '                            ) FROM dual;';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END LOOP;
      END LOOP;
    END IF;
    -- trigger without table
    SELECT COUNT(*) INTO l_count FROM dba_triggers WHERE owner = l_schema AND table_name IS NULL;
    IF l_count > 0
    THEN
      l_statement := 'SELECT otap_test.set_test_name(''' || l_base_title || ' trigger without tables'') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- loop through triggers with names like ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR rec IN cur_other_trigger(l_schema, l_like, p_excl_sysgen)
      LOOP
        l_statement := 'SELECT otap_test.has_trigger( p_trigger_name => ''' || rec.trigger_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            , p_schema => ''' || rec.owner || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            , p_trigger_type => ''' || TRIM(rec.trigger_type) || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            , p_trigger_event => ''' || TRIM(rec.triggering_event) || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            ) FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END LOOP;
    END IF;
    IF NVL(p_show_header, 1) = 1
    THEN
      -- build finish
      l_statement := '-- finish trigger tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    ELSE
      l_statement := '-- finish trigger tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END trigger_tests;

  FUNCTION pkg_procedures( p_package_name   IN VARCHAR
                         , p_like_procedure IN VARCHAR2 DEFAULT '%'
                         , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                         , p_show_header    IN INTEGER  DEFAULT 1
                         , p_excl_sysgen    IN INTEGER  DEFAULT 1
                         )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_package     VARCHAR2(128 CHAR);
    l_test_count  INTEGER;
    CURSOR cur_pkg_proc( cp_schema  IN VARCHAR2
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
       WHERE package_name      = cp_package
         AND procedure_name LIKE cp_like
    ;
  BEGIN
    l_package := otap_string.reduce(p_package_name, 128);
    IF l_package IS NOT NULL
    THEN
      l_like       := NVL(p_like_procedure, '%');
      l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
      l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
      IF NVL(p_show_header, 1) = 1
      THEN
        l_statement := '-- otap GENERATE package function and procedure test scripts for package ' || l_schema || '.' || l_package || ' scope: ' || l_like;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        -- get test count
           WITH base AS
               (SELECT object_name
                     , object_type
                     , owner
                  FROM dba_objects
                 WHERE owner = l_schema
                       -- currently supported objects
                   AND object_type = 'PACKAGE'
                       -- user like condition
                   AND object_name = l_package
                       -- user exclude condition
                   AND NOT otap_string.is_sys_object(object_name, p_excl_sysgen)
               )
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
                       -- user like condition
                 WHERE dbp.procedure_name LIKE l_like
                       -- user exclude condition
                   AND NOT otap_string.is_sys_object(dbp.procedure_name, p_excl_sysgen)
               )
             , cnt_prc AS (SELECT COUNT(*) AS expected_count FROM prc)
        SELECT expected_count INTO l_test_count FROM cnt_prc;
        -- build init
        l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      l_statement := '-- loop through package functions and triggers with names like ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR rec IN cur_pkg_proc(l_schema, l_package, l_like, p_excl_sysgen)
      LOOP
        l_statement := 'SELECT otap_test.has_procedure( p_procedure_name => ''' || rec.procedure_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                              , p_schema => ''' || l_schema || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                              , p_procedure_type => ''' || rec.procedure_type || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                              , p_package_name => ''' || rec.package_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        IF rec.procedure_type = 'FUNCTION'
        THEN
          l_statement := '                              , p_return_type => ''' || rec.return_type || '''';
          PIPE ROW (otap_view_result_rec(l_statement, NULL));
        END IF;
        l_statement := '                              ) FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END LOOP;
      IF NVL(p_show_header, 1) = 1
      THEN
        -- build finish
        l_statement := '-- finish package function and procedure tests for ' || l_package;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- finish test session';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := 'SELECT otap_test.finish_test FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := 'SELECT * FROM otap_latest_test_results_v;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        -- add AI and copyright
        l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      ELSE
        l_statement := '-- finish package function and procedure tests for ' || l_package;
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END pkg_procedures;

  FUNCTION package_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_like_package  IN VARCHAR2 DEFAULT '%'
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT 1
                        , p_excl_sysgen   IN INTEGER  DEFAULT 1
                        )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_count       INTEGER;
    l_test_count  INTEGER;
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
         AND object_name LIKE cp_like
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
        FROM TABLE(otap_generate.pkg_procedures(cp_package, cp_like, cp_schema, cp_prefix, 0, cp_excl))
    ;
  BEGIN
    l_like       := NVL(p_like_package, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
    IF NVL(p_show_header, 1) = 1
    THEN
      l_statement := '-- otap GENERATE package test scripts for schema ' || l_schema || ' scope: ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
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
                 AND object_name LIKE l_like
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
                     -- user like condition
               WHERE dbp.procedure_name LIKE l_like
                     -- user exclude condition
                 AND NOT otap_string.is_sys_object(dbp.procedure_name, p_excl_sysgen)
             )
           , cnt_prc AS (SELECT COUNT(*) AS expected_count FROM prc)
           , cnt AS
             (SELECT expected_count, 'BASE' AS info FROM cnt_base
               UNION ALL
              SELECT expected_count, 'PROCEDURES' AS info FROM cnt_prc
             )
      SELECT SUM(expected_count) INTO l_test_count FROM cnt;
      -- build init
      l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    -- build group row
    l_statement := '-- set test group for package';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'SELECT otap_test.set_test_group(''' || l_base_title || ' packages'') FROM dual;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    -- first loop through packages
    FOR rec IN cur_packages(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := '-- set test name for package';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.set_test_name(''' || l_base_title || ' package ' || rec.package_name || ''') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.has_package( p_package_name => ''' || rec.package_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                            , p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                            ) FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      IF rec.package_objects = 2
      THEN
        l_statement := 'SELECT otap_test.has_package( p_package_name => ''' || rec.package_name || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            , p_schema => ''' || l_schema || '''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            , p_package_type => ''PACKAGE BODY''';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
        l_statement := '                            ) FROM dual;';
        PIPE ROW (otap_view_result_rec(l_statement, NULL));
      END IF;
      -- now loop through the package procedures and functions
      FOR recfn IN cur_procedures(l_schema, rec.package_name, l_like, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(recfn.result_text, NULL));
      END LOOP;
    END LOOP;
    IF NVL(p_show_header, 1) = 1
    THEN
      -- build finish
      l_statement := '-- finish package tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    ELSE
      l_statement := '-- finish package tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END package_tests;

  FUNCTION view_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_like_view     IN VARCHAR2 DEFAULT '%'
                     , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_show_header   IN INTEGER  DEFAULT 1
                     , p_excl_sysgen   IN INTEGER  DEFAULT 1
                     )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(256 CHAR);
    l_test_count  INTEGER;
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
         AND object_name LIKE cp_like
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
  BEGIN
    l_like       := NVL(p_like_view, '%');
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
    IF NVL(p_show_header, 1) = 1
    THEN
      l_statement := '-- otap GENERATE view test scripts for schema ' || l_schema || ' scope: ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
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
                 AND object_name LIKE l_like
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
               WHERE dbc.column_name LIKE l_like
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
      -- build init
      l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    -- build group row
    l_statement := '-- set test group for views';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'SELECT otap_test.set_test_group(''' || l_base_title || ' views'') FROM dual;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    -- first loop through views
    FOR rec IN cur_views(l_schema, l_like, p_excl_sysgen)
    LOOP
      l_statement := '-- set test name for view';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.set_test_name(''' || l_base_title || ' view ' || rec.view_name || ''') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.has_object( p_object_name => ''' || rec.view_name || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                           , p_object_type => ''' || rec.object_type || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                           , p_schema => ''' || l_schema || '''';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '                           ) FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      FOR colrec IN cur_columns(l_schema, rec.view_name, l_like, p_title_prefix, p_excl_sysgen)
      LOOP
        PIPE ROW (otap_view_result_rec(colrec.result_text, NULL));
      END LOOP;
    END LOOP;
    IF NVL(p_show_header, 1) = 1
    THEN
      -- build finish
      l_statement := '-- finish view tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    ELSE
      l_statement := '-- finish view tests for ' || l_like;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END view_tests;

  FUNCTION schema_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT 1
                       , p_excl_sysgen   IN INTEGER  DEFAULT 1
                       )
    RETURN otap_view_result_tbl PIPELINED
  IS
    l_statement   VARCHAR2(4000 CHAR);
    l_schema      VARCHAR2(128 CHAR);
    l_base_title  VARCHAR2(256 CHAR);
    l_like        VARCHAR2(1 CHAR);
    l_test_count  INTEGER;
    CURSOR cur_tables( cp_schema IN VARCHAR2
                     , cp_like   IN VARCHAR2
                     , cp_prefix IN VARCHAR2
                     , cp_excl   IN NUMBER
                     )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.table_tests(cp_schema, cp_like, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_trigger( cp_schema IN VARCHAR2
                      , cp_like   IN VARCHAR2
                      , cp_prefix IN VARCHAR2
                      , cp_excl   IN NUMBER
                      )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.trigger_tests(cp_schema, cp_like, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_packages( cp_schema IN VARCHAR2
                       , cp_like   IN VARCHAR2
                       , cp_prefix IN VARCHAR2
                       , cp_excl   IN NUMBER
                       )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.package_tests(cp_schema, cp_like, p_title_prefix, 0, cp_excl))
    ;
    CURSOR cur_views( cp_schema IN VARCHAR2
                    , cp_like   IN VARCHAR2
                    , cp_prefix IN VARCHAR2
                    , cp_excl   IN NUMBER
                    )
    IS
      SELECT result_text
        FROM TABLE(otap_generate.view_tests(cp_schema, cp_like, p_title_prefix, 0, cp_excl))
    ;
  BEGIN
    l_like       := '%';
    l_schema     := otap_string.reduce(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')), 128);
    l_base_title := CASE WHEN p_title_prefix IS NULL THEN l_schema ELSE otap_string.reduce(p_title_prefix, 10) || ' - ' || l_schema END;
    IF NVL(p_show_header, 1) = 1
    THEN
      l_statement := '-- otap GENERATE test scripts for schema ' || l_schema;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- get test count, simulate conditions of called test generators
         WITH base AS
             (SELECT object_name
                   , object_type
                   , owner
                FROM dba_objects
               WHERE owner = l_schema
                     -- currently supported objects
                 AND (   object_type   IN ('TABLE', 'FUNCTION', 'PROCEDURE')
                      OR object_type LIKE '%VIEW'
                      OR object_type LIKE 'PACKAGE%'
                     )
                     -- user like condition
                 AND object_name LIKE l_like
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
                     -- user like condition
               WHERE dbp.procedure_name LIKE l_like
                     -- user exclude condition
                 AND NOT otap_string.is_sys_object(dbp.procedure_name, p_excl_sysgen)
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
                     -- user like condition
               WHERE dbc.column_name LIKE l_like
                     -- user exclude condition
                 AND NOT otap_string.is_sys_object(dbc.column_name, p_excl_sysgen)
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
                     -- user like condition
                 AND dbt.trigger_name LIKE l_like
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
                     -- user like condition
                 AND dbt.trigger_name LIKE l_like
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
      -- build init
      l_statement := 'SELECT otap_test.init_test(' || TRIM(TO_CHAR(l_test_count)) || ') FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    -- build set row
    l_statement := '-- set test set for schema';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    l_statement := 'SELECT otap_test.set_test_set(''' || l_base_title || ' schema'') FROM dual;';
    PIPE ROW (otap_view_result_rec(l_statement, NULL));
    FOR rec IN cur_tables(l_schema, l_like, p_title_prefix, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    FOR rec IN cur_trigger(l_schema, l_like, p_title_prefix, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    FOR rec IN cur_packages(l_schema, l_like, p_title_prefix, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    FOR rec IN cur_views(l_schema, l_like, p_title_prefix, p_excl_sysgen)
    LOOP
      PIPE ROW (otap_view_result_rec(rec.result_text, NULL));
    END LOOP;
    IF NVL(p_show_header, 1) = 1
    THEN
      -- build finish
      l_statement := '-- finish schema tests for ' || l_schema;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- finish test session';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT otap_test.finish_test FROM dual;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- build example spool
      l_statement := '-- example spool setup for test script generation';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET ECHO OFF';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET VERIFY OFF';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET FEEDBACK OFF';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET HEADING OFF';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET TRIMSPOOL ON';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET LINESIZE 9999';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET NEWPAGE NONE';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SET PAGESIZE 9999';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SPOOL generated_schema_tests.sql';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SELECT * FROM otap_latest_test_results_v;';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := 'SPOOL OFF';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      -- add AI and copyright
      l_statement := '-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
      l_statement := '-- Not allowed to be used as AI training material without explicite permission.';
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    ELSE
      l_statement := '-- finish schema tests for ' || l_schema;
      PIPE ROW (otap_view_result_rec(l_statement, NULL));
    END IF;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN
      RAISE;
  END schema_tests;

END;
/