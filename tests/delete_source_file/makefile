include $(d)../../src/prorab.mk

include $(d)../common.mk

ifeq ($(prorab_msys),true)
    this_a := .a
else
    this_a :=
endif

define this_rules
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp_src
$(.RECIPEPREFIX)$(a)cp -r $(d)src $(d)tmp_src
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)tmp_src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)tmp_src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(a)rm $(d)tmp_src/test.cpp
$(.RECIPEPREFIX)$(a)sleep 2 # timestamp resolution can be as low as 1 second, so wait some time before modifying the file.
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)tmp_src || $(this_err) "'make' failed"

# unpack static lib archive
$(.RECIPEPREFIX)$(a)(cd $(d)tmp_src/build_static && ar x libtests.a)
$(.RECIPEPREFIX)$(a)(cd $(d)tmp_src/build_dynamic && ar x libtests.a)
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp_src/build_static/test.c.o ]; then $(this_err) "build_static/test.c.o file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp_src/build_static/test.cpp.o ]; then $(this_err) "build_static/test.cpp.o file unexpectedly present"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp_src/build_dynamic/test.c.o ]; then $(this_err) "build_dynamic/test.c.o file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp_src/build_dynamic/test.cpp.o ]; then $(this_err) "build_dynamic/test.cpp.o file unexpectedly present"; fi

# check that dynamic lib and app binary do not contain 'increment' function
$(.RECIPEPREFIX)$(a)nm $(d)tmp_src/build_dynamic/libtests$(dot_so)$(this_a) > $(d)tmp_src/symbols.txt
$(.RECIPEPREFIX)$(a)[ ! -z "$$$$(cat $(d)tmp_src/symbols.txt | grep decrement)" ] || $(this_err) "build_dynamic/libtests.so does not contain 'decrement' function"
$(.RECIPEPREFIX)$(a)[ -z "$$$$(cat $(d)tmp_src/symbols.txt | grep increment)" ] || $(this_err) "build_dynamic/libtests.so contains 'increment' function"
$(.RECIPEPREFIX)$(a)nm $(d)tmp_src/build_app/tests$(dot_exe) > $(d)tmp_src/symbols.txt
$(.RECIPEPREFIX)$(a)[ ! -z "$$$$(cat $(d)tmp_src/symbols.txt | grep decrement)" ] || $(this_err) "build_app/tests does not contain 'decrement' function"
$(.RECIPEPREFIX)$(a)[ -z "$$$$(cat $(d)tmp_src/symbols.txt | grep increment)" ] || $(this_err) "build_app/tests contains 'increment' function"

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
