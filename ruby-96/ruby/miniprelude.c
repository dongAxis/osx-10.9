/* -*-c-*-
 THIS FILE WAS AUTOGENERATED BY tool/compile_prelude.rb. DO NOT EDIT.

 sources: prelude
*/
#include "ruby/ruby.h"
#include "internal.h"
#include "vm_core.h"


static const char prelude_name0[] = "<internal:prelude>";
static const char prelude_code0[] =
"class Thread\n"
"  MUTEX_FOR_THREAD_EXCLUSIVE = Mutex.new # :nodoc:\n"
"\n"
"  # call-seq:\n"
"  #    Thread.exclusive { block }   => obj\n"
"  #\n"
"  # Wraps a block in Thread.critical, restoring the original value\n"
"  # upon exit from the critical section, and returns the value of the\n"
"  # block.\n"
"  def self.exclusive\n"
"    MUTEX_FOR_THREAD_EXCLUSIVE.synchronize{\n"
"      yield\n"
"    }\n"
"  end\n"
"end\n"
;

#define PRELUDE_COUNT 0


static void
prelude_eval(VALUE code, VALUE name, VALUE line)
{
    rb_iseq_eval(rb_iseq_compile_with_option(code, name, Qnil, line, 0, Qtrue));
}

void
Init_prelude(void)
{
    prelude_eval(
      rb_usascii_str_new(prelude_code0, sizeof(prelude_code0) - 1),
      rb_usascii_str_new(prelude_name0, sizeof(prelude_name0) - 1),
      INT2FIX(1));

#if 0
    puts(prelude_code0);
#endif
}
