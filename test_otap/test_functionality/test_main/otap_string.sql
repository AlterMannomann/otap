-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name

-- basic schema and otap_constants tests already done, test log entries will remain, logging is always committed on success
SELECT otap_test.set_test_name('Verify otap_string functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return VARCHAR2(4000);
  l_stamp  TIMESTAMP;
BEGIN
  l_return := otap_test.ok(otap_string.reduce IS NULL, 'otap_string.reduce no parameters');
  l_return := otap_test.is_eq(otap_string.reduce('1234', 2), '12', 'otap_string.reduce cut string');
  l_return := otap_test.is_eq(otap_string.reduce('1234       ', 4000), '1234', 'otap_string.reduce trim string trailing blanks');
  l_return := otap_test.is_eq(otap_string.reduce('           1234', 4000), '1234', 'otap_string.reduce trim string leading blanks');
  l_return := otap_test.is_eq(otap_string.reduce('           1234           ', 4000), '1234', 'otap_string.reduce trim string leading and trailing blanks');
  l_return := otap_test.is_eq(otap_string.reduce('   123   345   ', 6), '123', 'otap_string.reduce trim and cut');
  l_return := otap_test.is_eq(otap_string.reduce('   123   345   ', 9), '123   345', 'otap_string.reduce trim and cut extended');
  l_return := otap_test.throws_ok('l_reduce := otap_string.reduce(RPAD(''a'', 35000, ''b''), 32767);', -6502, 'l_reduce VARCHAR2(32767);', 'otap_string.reduce PLSQL overflow behavior buffer too small exception');
  SELECT otap_test.is_eq(LENGTH(otap_string.reduce(RPAD('a', 35000, 'b'), 32767)), 4000, 'otap_string.reduce SQL overflow behavior cut to 4000 chars')
    INTO l_return
    FROM dual;
  l_return := otap_test.ok(otap_string.cut IS NULL, 'otap_string.cut no parameters');
  l_return := otap_test.is_eq(otap_string.cut('1234', 2), '12', 'otap_string.cut cut string');
  l_return := otap_test.is_eq(otap_string.cut('1234  ', 6), '1234  ', 'otap_string.cut no trim on cut');
  l_return := otap_test.is_eq(otap_string.cut('1234  ', 9), '1234  ', 'otap_string.cut no string filling');
  l_return := otap_test.throws_ok('l_cut := otap_string.cut(RPAD(''a'', 35000, ''b''), 32767);', -6502, 'l_cut VARCHAR2(32767);', 'otap_string.cut PLSQL overflow behavior buffer too small exception');
  SELECT otap_test.is_eq(LENGTH(otap_string.cut(RPAD('a', 35000, 'b'), 32767)), 4000, 'otap_string.cut SQL overflow behavior cut to 4000 chars')
    INTO l_return
    FROM dual;
  l_return := otap_test.ok(otap_string.flatten IS NULL, 'otap_string.flatten no parameter');
  l_return := otap_test.is_eq(otap_string.flatten('1234', 2), '12', 'otap_string.flatten cut string');
  l_return := otap_test.is_eq(otap_string.flatten('           1234           ', 4000), ' 1234 ', 'otap_string.flatten string leading and trailing blanks');
  l_return := otap_test.is_eq(otap_string.flatten('   123   345   ', 6), ' 123 3', 'otap_string.flatten spaces');
  l_return := otap_test.is_eq(otap_string.flatten('   123   345   ', 9), ' 123 345 ', 'otap_string.flatten spaces other size');
  l_return := otap_test.is_eq(otap_string.flatten('123' || CHR(13) || CHR(10) || '   345   ', 9), '123 345 ', 'otap_string.flatten CR, LF and spaces');
  l_return := otap_test.is_eq(otap_string.check_border, otap_constants.OTAP_FALLBACK_BORDER, 'otap_string.check_border no parameter');
  l_return := otap_test.is_eq(otap_string.check_border(NULL), otap_constants.OTAP_FALLBACK_BORDER, 'otap_string.check_border NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_border(5), 5, 'otap_string.check_border valid parameter');
  l_return := otap_test.is_eq(otap_string.check_border(2), 2, 'otap_string.check_border min value');
  l_return := otap_test.is_eq(otap_string.check_border(10), 10, 'otap_string.check_border max value');
  l_return := otap_test.is_eq(otap_string.check_border(20), otap_constants.OTAP_FALLBACK_BORDER, 'otap_string.check_border invalid parameter');
  l_return := otap_test.is_eq(otap_string.check_line_size, otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_line_size no parameter');
  l_return := otap_test.is_eq(otap_string.check_line_size(NULL), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_line_size NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_line_size(-10), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_line_size negative parameter');
  l_return := otap_test.is_eq(otap_string.check_line_size(20), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_line_size under minimum');
  l_return := otap_test.is_eq(otap_string.check_line_size(5000), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.check_line_size over maximum');
  l_return := otap_test.is_eq(otap_string.check_line_size(120), 120, 'otap_string.check_line_size valid size');
  l_return := otap_test.is_eq(otap_string.check_line_size(120.35), 120, 'otap_string.check_line_size truncate decimal to integer');
  l_return := otap_test.is_eq(otap_string.check_title_size, 0, 'otap_string.check_title_size no parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(NULL), 0, 'otap_string.check_title_size NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(-10), 0, 'otap_string.check_title_size negative parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(20), 20, 'otap_string.check_title_size valid parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(4000, 5), (otap_constants.OTAP_NUM_MAX_FILL_LENGTH - 10), 'otap_string.check_title_size overflow max size');
  l_return := otap_test.is_eq(otap_string.check_title_size(4000, 2), (otap_constants.OTAP_NUM_MAX_FILL_LENGTH - 4), 'otap_string.check_title_size overflow max size different border');
  l_return := otap_test.is_eq(otap_string.check_string_size, otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_string_size no parameter');
  l_return := otap_test.is_eq(otap_string.check_string_size(NULL), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_string_size NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_string_size(-10), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_string_size negative parameter');
  l_return := otap_test.is_eq(otap_string.check_string_size(120), 120, 'otap_string.check_string_size valid parameter');
  l_return := otap_test.is_eq(otap_string.check_string_size(5000), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.check_string_size overflow parameter');
  l_return := otap_test.is_eq(otap_string.check_layout, otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'otap_string.check_layout no parameter');
  l_return := otap_test.is_eq(otap_string.check_layout(NULL), otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'otap_string.check_layout NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_layout(otap_constants.OTAP_LAYOUT_RIGHT), otap_constants.OTAP_LAYOUT_RIGHT, 'otap_string.check_layout layout right');
  l_return := otap_test.is_eq(otap_string.check_layout(otap_constants.OTAP_LAYOUT_MIDDLE), otap_constants.OTAP_LAYOUT_MIDDLE, 'otap_string.check_layout layout middle');
  l_return := otap_test.is_eq(otap_string.check_layout(otap_constants.OTAP_LAYOUT_LEFT), otap_constants.OTAP_LAYOUT_LEFT, 'otap_string.check_layout layout left');
  l_return := otap_test.is_eq(otap_string.check_layout('0'), otap_constants.OTAP_FALLBACK_LAYOUT_DEFAULT, 'otap_string.check_layout invalid layout');
  l_return := otap_test.is_eq(otap_string.check_decoration, otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, 'otap_string.check_decoration no parameter');
  l_return := otap_test.is_eq(otap_string.check_decoration(NULL), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, 'otap_string.check_decoration NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_decoration(CHR(9)), CHR(9), 'otap_string.check_decoration define non printable CHR(9)');
  l_return := otap_test.is_eq(otap_string.check_decoration('!'), '!', 'otap_string.check_decoration define printable !');
  l_return := otap_test.is_eq(otap_string.check_decoration('*--'), '*', 'otap_string.check_decoration truncate parameter with invalid size');
  l_return := otap_test.is_eq(otap_string.line_size(NULL), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.line_size NULL parameter');
  l_return := otap_test.is_eq(otap_string.line_size(NULL, 5), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.line_size NULL parameter with border');
  l_return := otap_test.is_eq(otap_string.line_size(60, 5), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.line_size title length below min length');
  l_return := otap_test.is_eq(otap_string.line_size(120, 5), 130, 'otap_string.line_size valid parameter');
  l_return := otap_test.is_eq(otap_string.line_size(otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 5), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.line_size valid max size');
  l_return := otap_test.is_eq(otap_string.line_size(5000, 5), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.line_size invalid max size');
  l_return := otap_test.is_eq(otap_string.line_size(120, 1), 120 + (otap_constants.OTAP_FALLBACK_BORDER * 2), 'otap_string.line_size invalid border parameter');
  l_return := otap_test.is_eq(otap_string.line_size(20, 5, 30), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.line_size invalid min fill size');
  l_return := otap_test.is_eq(otap_string.max_size(NULL), 0, 'otap_string.max_size NULL title size');
  l_return := otap_test.is_eq(otap_string.max_size(0), 0, 'otap_string.max_size 0 title size');
  l_return := otap_test.is_eq(otap_string.max_size(-10), 0, 'otap_string.max_size negative title size');
  l_return := otap_test.is_eq(otap_string.max_size(2), 2, 'otap_string.max_size small title size');
  l_return := otap_test.is_eq(otap_string.max_size(120), 120, 'otap_string.max_size typical title size');
  l_return := otap_test.is_eq(otap_string.max_size(5000, 80, 5), 3990, 'otap_string.max_size overflow title size');
  l_return := otap_test.is_eq(otap_string.max_size(120, 20), 120, 'otap_string.max_size invalid line size ignored');
  l_return := otap_test.is_eq(otap_string.max_size(120, 80, 50), 120, 'otap_string.max_size invalid border size ignored');
  l_return := otap_test.is_eq(otap_string.max_size(120, 10, 50), 120, 'otap_string.max_size invalid line and border size ignored');
  l_return := otap_test.is_eq(otap_string.left_deco(NULL), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.left_deco NULL title size');
  l_return := otap_test.is_eq(otap_string.left_deco(0), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.left_deco 0 title size');
  l_return := otap_test.is_eq(otap_string.left_deco(-10), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.left_deco negative title size');
  l_return := otap_test.is_eq(otap_string.left_deco(60, 80, '-', 'M', 5), LPAD(' ', 10, '-'), 'otap_string.left_deco typical parameter layout M');
  l_return := otap_test.is_eq(otap_string.left_deco(5000, 80, '-', 'M', 5), LPAD(' ', 5, '-'), 'otap_string.left_deco title overflow title size layout M');
  l_return := otap_test.is_eq(otap_string.left_deco(63, 80, '-', 'M', 5), LPAD(' ', 8, '-'), 'otap_string.left_deco uneven title size layout M');
  l_return := otap_test.is_eq(otap_string.left_deco(60, 80, '-', 'R', 5), LPAD(' ', 15, '-'), 'otap_string.left_deco typical parameter layout R');
  l_return := otap_test.is_eq(otap_string.left_deco(5000, 80, '-', 'R', 5), LPAD(' ', 5, '-'), 'otap_string.left_deco title overflow title size layout R');
  l_return := otap_test.is_eq(otap_string.left_deco(63, 80, '-', 'R', 5), LPAD(' ', 12, '-'), 'otap_string.left_deco uneven title size layout R');
  l_return := otap_test.is_eq(otap_string.left_deco(60, 80, '-', 'L', 5), LPAD(' ', 5, '-'), 'otap_string.left_deco typical parameter layout L');
  l_return := otap_test.is_eq(otap_string.left_deco(5000, 80, '-', 'L', 5), LPAD(' ', 5, '-'), 'otap_string.left_deco title overflow title size layout L');
  l_return := otap_test.is_eq(otap_string.left_deco(63, 80, '-', 'L', 5), LPAD(' ', 5, '-'), 'otap_string.left_deco uneven title size layout L');
  l_return := otap_test.is_eq(otap_string.left_deco(60, 80, '-', 'L', 2), LPAD(' ', 2, '-'), 'otap_string.left_deco minimum border layout L');
  l_return := otap_test.is_eq(otap_string.left_deco(60, 80, '-', 'R', 2), LPAD(' ', 18, '-'), 'otap_string.left_deco minimum border layout R');
  l_return := otap_test.is_eq(otap_string.left_deco(60, NULL, NULL, NULL, NULL), LPAD(' ', 10, '-'), 'otap_string.left_deco default optional parameter NULL');
  l_return := otap_test.is_eq(otap_string.right_deco(NULL), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.right_deco NULL title size');
  l_return := otap_test.is_eq(otap_string.right_deco(0), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.right_deco 0 title size');
  l_return := otap_test.is_eq(otap_string.right_deco(-10), RPAD(otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR, (otap_constants.OTAP_NUM_MIN_FILL_LENGTH / 2), otap_constants.OTAP_FALLBACK_FORMAT_NAME_CHAR), 'otap_string.right_deco negative title size');
  l_return := otap_test.is_eq(otap_string.right_deco(60, 80, '-', 'M', 5), RPAD(' ', 10, '-'), 'otap_string.right_deco typical parameter layout M');
  l_return := otap_test.is_eq(otap_string.right_deco(5000, 80, '-', 'M', 5), RPAD(' ', 5, '-'), 'otap_string.right_deco title overflow title size layout M');
  l_return := otap_test.is_eq(otap_string.right_deco(63, 80, '-', 'M', 5), RPAD(' ', 9, '-'), 'otap_string.right_deco uneven title size layout M');
  l_return := otap_test.is_eq(otap_string.right_deco(60, 80, '-', 'R', 5), RPAD(' ', 5, '-'), 'otap_string.right_deco typical parameter layout R');
  l_return := otap_test.is_eq(otap_string.right_deco(5000, 80, '-', 'R', 5), RPAD(' ', 5, '-'), 'otap_string.right_deco title overflow title size layout R');
  l_return := otap_test.is_eq(otap_string.right_deco(63, 80, '-', 'R', 5), RPAD(' ', 5, '-'), 'otap_string.right_deco uneven title size layout R');
  l_return := otap_test.is_eq(otap_string.right_deco(60, 80, '-', 'L', 5), RPAD(' ', 15, '-'), 'otap_string.right_deco typical parameter layout L');
  l_return := otap_test.is_eq(otap_string.right_deco(5000, 80, '-', 'L', 5), RPAD(' ', 5, '-'), 'otap_string.right_deco title overflow title size layout L');
  l_return := otap_test.is_eq(otap_string.right_deco(63, 80, '-', 'L', 5), RPAD(' ', 12, '-'), 'otap_string.right_deco uneven title size layout L');
  l_return := otap_test.is_eq(otap_string.right_deco(60, NULL, NULL, NULL, NULL), RPAD(' ', 10, '-'), 'otap_string.right_deco default optional parameter NULL');
  l_return := otap_test.is_eq(otap_string.right_deco(60, 80, '-', 'L', 2), RPAD(' ', 18, '-'), 'otap_string.right_deco minimum border layout L');
  l_return := otap_test.is_eq(otap_string.right_deco(60, 80, '-', 'R', 2), RPAD(' ', 2, '-'), 'otap_string.right_deco minimum border layout R');
  l_return := otap_test.is_eq(otap_string.decorate('test', '-', 80, 'M', 3), (LPAD(' ', 38, '-') || 'test' || RPAD(' ', 38, '-')), 'otap_string.decorate layout M typical');
  l_return := otap_test.is_eq(otap_string.decorate('test', '-', 80, 'L', 3), (LPAD(' ', 3, '-') || 'test' || RPAD(' ', 73, '-')), 'otap_string.decorate layout L typical');
  l_return := otap_test.is_eq(otap_string.decorate('test', '-', 80, 'R', 3), (LPAD(' ', 73, '-') || 'test' || RPAD(' ', 3, '-')), 'otap_string.decorate layout R typical');
  l_return := otap_test.is_eq(otap_string.decorate(RPAD('test', 5000, 'a'), '-', 80, 'M', 3), (LPAD(' ', 3, '-') || RPAD('test', 3994, 'a') || RPAD(' ', 3, '-')), 'otap_string.decorate layout M oversize cutted');
  l_return := otap_test.is_eq(otap_string.decorate(RPAD('test', 5000, 'a'), '-', 80, 'L', 3), (LPAD(' ', 3, '-') || RPAD('test', 3994, 'a') || RPAD(' ', 3, '-')), 'otap_string.decorate layout L oversize cutted');
  l_return := otap_test.is_eq(otap_string.decorate(RPAD('test', 5000, 'a'), '-', 80, 'R', 3), (LPAD(' ', 3, '-') || RPAD('test', 3994, 'a') || RPAD(' ', 3, '-')), 'otap_string.decorate layout R oversize cutted');
  l_return := otap_test.is_eq(otap_string.decorate('teste', '-', 80, 'M', 3), (LPAD(' ', 37, '-') || 'teste' || RPAD(' ', 38, '-')), 'otap_string.decorate layout M uneven title size');
  l_return := otap_test.is_eq(otap_string.decorate('teste', '-', 80, 'L', 3), (LPAD(' ', 3, '-') || 'teste' || RPAD(' ', 72, '-')), 'otap_string.decorate layout L uneven title size');
  l_return := otap_test.is_eq(otap_string.decorate('teste', '-', 80, 'R', 3), (LPAD(' ', 72, '-') || 'teste' || RPAD(' ', 3, '-')), 'otap_string.decorate layout R uneven title size');
  l_return := otap_test.is_eq(otap_string.borderless('test', 80, 'L'), RPAD('test', 80, ' '), 'otap_string.borderless layout L typical');
  l_return := otap_test.is_eq(otap_string.borderless('test', 80, 'M'), RPAD('test', 80, ' '), 'otap_string.borderless layout M fallback');
  l_return := otap_test.is_eq(otap_string.borderless('test', 80, 'R'), LPAD('test', 80, ' '), 'otap_string.borderless layout R typical');
  l_return := otap_test.is_eq(otap_string.borderless(RPAD('test', 5000, 'a'), 80, 'L'), RPAD('test', 4000, 'a'), 'otap_string.borderless layout L oversize cutted');
  l_return := otap_test.is_eq(otap_string.borderless(RPAD('test', 5000, 'a'), 80, 'R'), RPAD('test', 4000, 'a'), 'otap_string.borderless layout R oversize cutted');
  l_return := otap_test.is_eq(otap_string.borderless(RPAD('test', 5000, 'a'), 80, 'M'), RPAD('test', 4000, 'a'), 'otap_string.borderless layout M oversize cutted');
  l_return := otap_test.ok(otap_string.is_sys_object('SYS_'), 'otap_string.is_sys_object simple SYS_ value');
  l_return := otap_test.ok(otap_string.is_sys_object('sys_'), 'otap_string.is_sys_object sys_ value');
  l_return := otap_test.ok(otap_string.is_sys_object('$'), 'otap_string.is_sys_object simple $ value');
  l_return := otap_test.ok(otap_string.is_sys_object('#'), 'otap_string.is_sys_object simple # value');
  l_return := otap_test.ok(otap_string.is_sys_object('Sys_blabla$bla#'), 'otap_string.is_sys_object mixed case Sys_blabla$bla# value');
  l_return := otap_test.ok(otap_string.is_sys_object('SYSAUTH$'), 'otap_string.is_sys_object typical sys object $');
  l_return := otap_test.ok(otap_string.is_sys_object('SYS_LOB0000000157C00003$$'), 'otap_string.is_sys_object typical sys object lobs');
  l_return := otap_test.ok(otap_string.is_sys_object('I_FILE#_BLOCK#'), 'otap_string.is_sys_object typical sys object #');
END;
/
