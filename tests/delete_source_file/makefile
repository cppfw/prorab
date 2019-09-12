include $(d)../../src/prorab.mk


include $(d)../common.mk

# In Msys2 the nm does not find symbols in binaries for some reason, but objdump finds.
# On theother hand, objdump does not work in macosx for some reason.
ifeq ($(os),windows)
    this_symcmd := objdump -t
else
	this_symcmd := nm
endif

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)$(Q)rm -rf $(d)tmp_src
$(.RECIPEPREFIX)$(Q)cp -r $(d)src $(d)tmp_src
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(Q)rm $(d)tmp_src/test.cpp
$(.RECIPEPREFIX)$(Q)sleep 2 # timestamp resolution can be as low as 1 second, so wait some time before modifying the file.
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src || $(this_err) "'make' failed"

# unpack static lib archive
$(.RECIPEPREFIX)$(Q)(cd $(d)tmp_src/build_static && ar x libtests.a)
$(.RECIPEPREFIX)$(Q)(cd $(d)tmp_src/build_dynamic && ar x libtests.a)
$(.RECIPEPREFIX)$(Q)if [ ! -f $(d)tmp_src/build_static/test.c.o ]; then $(this_err) "build_static/test.c.o file not found"; fi
$(.RECIPEPREFIX)$(Q)if [ -f $(d)tmp_src/build_static/test.cpp.o ]; then $(this_err) "build_static/test.cpp.o file unexpectedly present"; fi
$(.RECIPEPREFIX)$(Q)if [ ! -f $(d)tmp_src/build_dynamic/test.c.o ]; then $(this_err) "build_dynamic/test.c.o file not found"; fi
$(.RECIPEPREFIX)$(Q)if [ -f $(d)tmp_src/build_dynamic/test.cpp.o ]; then $(this_err) "build_dynamic/test.cpp.o file unexpectedly present"; fi

# check that dynamic lib and app binary do not contain 'increment' function
$(.RECIPEPREFIX)$(Q)$(this_symcmd) $(d)tmp_src/build_dynamic/libtests$(soext) > $(d)tmp_src/symbols.txt
$(.RECIPEPREFIX)$(Q)[ -z "$$$$(cat $(d)tmp_src/symbols.txt | grep increment)" ] || $(this_err) "build_dynamic/libtests.so contains 'increment' function"
$(.RECIPEPREFIX)$(Q)$(this_symcmd) $(d)tmp_src/build_app/tests$(exeext) > $(d)tmp_src/symbols.txt
$(.RECIPEPREFIX)$(Q)[ -z "$$$$(cat $(d)tmp_src/symbols.txt | grep increment)" ] || $(this_err) "build_app/tests contains 'increment' function"

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
