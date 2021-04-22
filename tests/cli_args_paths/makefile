include $(d)../../src/prorab.mk

include $(d)../common.mk

# TEST DESCRIPTION:
# Test that command line arguments of compiler and linker are relative to $(d).

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)prj clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)prj || $(this_err) "initial 'make' failed"

ifeq ($(os),windows)
$(.RECIPEPREFIX)$(a)cp $(d)prj/lib/out/*.dll $(d)prj/app/out
endif
$(.RECIPEPREFIX)$(a)(cd $(d)prj/app && LD_LIBRARY_PATH=../lib/out DYLD_LIBRARY_PATH=$$LD_LIBRARY_PATH out/app) > $(d)out.log
$(.RECIPEPREFIX)$(a)cmp $(d)out.log $(d)out.log.cmp || (echo "out.log = "; cat $(d)out.log; echo "out.log.cmp = "; cat $(d)out.log.cmp; $(this_err) "output log is not as expected");

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)prj clean || $(this_err) "final 'make clean' failed"

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))