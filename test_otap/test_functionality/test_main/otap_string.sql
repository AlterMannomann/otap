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
  l_return := otap_test.is_eq(otap_string.check_line_size(20), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_line_size under minimum');
  l_return := otap_test.is_eq(otap_string.check_line_size(5000), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.check_line_size over maximum');
  l_return := otap_test.is_eq(otap_string.check_line_size(120), 120, 'otap_string.check_line_size valid size');
  l_return := otap_test.is_eq(otap_string.check_line_size(120.35), 120, 'otap_string.check_line_size truncate decimal to integer');
  l_return := otap_test.is_eq(otap_string.check_title_size, 0, 'otap_string.check_title_size no parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(NULL), 0, 'otap_string.check_title_size NULL parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(20), 20, 'otap_string.check_title_size valid parameter');
  l_return := otap_test.is_eq(otap_string.check_title_size(4000, 5), (otap_constants.OTAP_NUM_MAX_FILL_LENGTH - 10), 'otap_string.check_title_size overflow max size');
  l_return := otap_test.is_eq(otap_string.check_title_size(4000, 2), (otap_constants.OTAP_NUM_MAX_FILL_LENGTH - 4), 'otap_string.check_title_size overflow max size different border');
  l_return := otap_test.is_eq(otap_string.check_string_size, otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_string_size no parameter');
  l_return := otap_test.is_eq(otap_string.check_string_size(NULL), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.check_string_size NULL parameter');
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
  l_return := otap_test.is_eq(otap_string.line_size(120, 5), 130, 'otap_string.line_size valid parameter');
  l_return := otap_test.is_eq(otap_string.line_size(otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 5), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.line_size valid max size');
  l_return := otap_test.is_eq(otap_string.line_size(5000, 5), otap_constants.OTAP_NUM_MAX_FILL_LENGTH, 'otap_string.line_size invalid max size');
  l_return := otap_test.is_eq(otap_string.line_size(120, 1), 120 + (otap_constants.OTAP_FALLBACK_BORDER * 2), 'otap_string.line_size invalid border parameter');
  l_return := otap_test.is_eq(otap_string.line_size(20, 5, 30), otap_constants.OTAP_NUM_MIN_FILL_LENGTH, 'otap_string.line_size invalid min fill size');
END;
/
