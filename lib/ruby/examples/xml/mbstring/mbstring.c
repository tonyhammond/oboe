/*
 *  Multibyte Extension for String class
 *  May 13, 1999 yoshidam version 0.1
 *
 */

#include "ruby.h"
#include "rubyio.h"
#include "regex.h"
#include <stdio.h>

static VALUE
rb_str_mblength(str)
     VALUE str;
{
  char* p = RSTRING(str)->ptr;
  char* pend = p + RSTRING(str)->len;
  int count = 0;
  int len;

  while (p < pend) {
    if ((len = ismbchar(*p)) && p + len < pend)
      p += len;
    p++;
    count++;
  }
  return INT2FIX(count);
}

static VALUE
rb_str_each_mbchar(str)
     struct RString* str;
{
  char* p = RSTRING(str)->ptr;
  char* pend = p + RSTRING(str)->len;
  int len;

  while (p < pend) {
    if ((len = ismbchar(*p)) && p + len < pend) {
      rb_yield(rb_str_new(p, len + 1));
      p += len;
    }
    else {
      rb_yield(rb_str_new(p, 1));
    }
    p++;
  }
  return Qnil;
}

static VALUE
rb_str_mbchop_bang(str)
     VALUE str;
{
  char* p = RSTRING(str)->ptr;
  char* pend = p + RSTRING(str)->len;
  char* prev = p;
  int len;

  if (RSTRING(str)->len > 0) {
    while (p < pend) {
      prev = p;
      if ((len = ismbchar(*p)) && p + len < pend)
	p += len;
      p++;
    }
    RSTRING(str)->len -= pend - prev;
    if (*prev == '\n') {
      if (RSTRING(str)->len > 0 && *(prev - 1) == '\r') {
	RSTRING(str)->len--;
	prev--;
      }
    }
    *prev = '\0';
    return str;
  }
  return Qnil;
}

static VALUE
rb_str_mbchop(str)
     VALUE str;
{
  VALUE val = rb_str_mbchop_bang(str = rb_str_dup(str));

  if (NIL_P(val)) return str;
  return val;
}

static VALUE
rb_mbsubstr(str, beg, len)
    VALUE str;
    int beg, len;
{
  char* p = RSTRING(str)->ptr;
  char* pend = p + RSTRING(str)->len;
  VALUE str2;
  int pos = 0;
  char* startp = NULL;
  char* endp = NULL;
  int mlen;

  if (len < 0)
    return Qnil;
  if (beg < 0) {
    beg += FIX2INT(rb_str_mblength(str));
    if (beg < 0) return Qnil;
  }
  if (len == 0 || (p == pend && beg == 0))
    return rb_str_new(0,0);

  while (p < pend) {
    if (beg == pos)
      startp = p;
    if (beg + len <= pos) {
      endp = p;
      break;
    }
    if ((mlen = ismbchar(*p)) && p + mlen < pend)
      p += mlen;
    p++;
    pos++;
  }
  if (startp == NULL)
    return Qnil;
  if (endp == NULL)
    endp = pend;

  str2 = rb_str_new(startp, endp - startp);
  if (OBJ_TAINTED(str))
    OBJ_TAINT(str2);

  return str2;
}

static VALUE
rb_str_mbsubstr(str, beg, len)
     VALUE str, beg, len;
{
  Check_Type(beg, T_FIXNUM);
  Check_Type(len, T_FIXNUM);
  return rb_mbsubstr(str, FIX2INT(beg), FIX2INT(len));
}

static void
rb_mbreplace(str, beg, len, val)
     VALUE str, val;
     int beg;
     int len;
{
  char* p = RSTRING(str)->ptr;
  char* pend = p + RSTRING(str)->len;
  int pos = 0;
  char* startp = NULL;
  char* endp = NULL;
  int mlen;
  int bytebeg;
  int bytelen;

  if (len < 0)
    rb_raise(rb_eIndexError, "negative length %d", len);
  if (beg < 0) {
    int chars = FIX2INT(rb_str_mblength(str));
    if (beg+chars < 0)
      rb_raise(rb_eIndexError, "index %d out of string", beg);
    beg += chars;
  }
  while (p < pend) {
    if (beg == pos)
      startp = p;
    if (beg + len <= pos) {
      endp = p;
      break;
    }
    if ((mlen = ismbchar(*p)) && p + mlen < pend)
      p += mlen;
    p++;
    pos++;
  }
  if (startp == NULL)
    rb_raise(rb_eIndexError, "index %d out of string", beg);
  if (endp == NULL)
    endp = pend;

  bytebeg = startp - RSTRING(str)->ptr;
  bytelen = endp - startp;

  if (bytelen < RSTRING(val)->len) {
    /* expand string */
    REALLOC_N(RSTRING(str)->ptr, char,
	      RSTRING(str)->len + RSTRING(val)->len - bytelen + 1);
  }

  if (bytelen != RSTRING(val)->len) {
    memmove(RSTRING(str)->ptr + bytebeg + RSTRING(val)->len,
	    RSTRING(str)->ptr + bytebeg + bytelen,
	    RSTRING(str)->len - (bytebeg + bytelen));
  }
  if (RSTRING(str)->len < bytebeg && bytelen < 0) {
    MEMZERO(RSTRING(str)->ptr + RSTRING(str)->len, char, -bytelen);
  }
  memcpy(RSTRING(str)->ptr+bytebeg, RSTRING(val)->ptr, RSTRING(val)->len);
  RSTRING(str)->len += RSTRING(val)->len - bytelen;
  RSTRING(str)->ptr[RSTRING(str)->len] = '\0';
}

static VALUE
rb_str_mbreplace(str, beg, len, val)
     VALUE str, beg, len, val;
{
  Check_Type(beg, T_FIXNUM);
  Check_Type(len, T_FIXNUM);
  Check_Type(val, T_STRING);
  rb_mbreplace(str, FIX2INT(beg), FIX2INT(len), val);
  return val;
}

void
Init_mbstring()
{
  rb_define_method(rb_cString, "mblength", rb_str_mblength, 0);
  rb_define_alias(rb_cString,  "mbsize", "mblength");
  rb_define_method(rb_cString, "each_mbchar", rb_str_each_mbchar, 0);
  rb_define_method(rb_cString, "mbchop!", rb_str_mbchop_bang, 0);
  rb_define_method(rb_cString, "mbchop", rb_str_mbchop, 0);
  rb_define_method(rb_cString, "mbsubstr", rb_str_mbsubstr, 2);
  rb_define_method(rb_cString, "mbreplace", rb_str_mbreplace, 3);
}
