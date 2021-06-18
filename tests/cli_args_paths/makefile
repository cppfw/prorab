include $(d)../../src/prorab.mk

include $(d)../common.mk

# TEST DESCRIPTION:
# Test that command line arguments of compiler and linker are relative to $(d).

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)

$(.RECIPEPREFIX)+$(a)$(MAKE) --directory=$(d)prj clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) --directory=$(d)prj || $(this_err) "initial 'make' failed"

ifeq ($(prorab_msys),true)
$(.RECIPEPREFIX)$(a)cp $(d)prj/lib/out/*.dll $(d)prj/app/out
endif
$(.RECIPEPREFIX)$(a)(cd $(d)prj/app && LD_LIBRARY_PATH=../lib/out DYLD_LIBRARY_PATH=$$LD_LIBRARY_PATH out/app | dos2unix) > $(d)out.log
$(.RECIPEPREFIX)$(a)cmp $(d)out.log $(d)out.log.cmp || (echo "out.log = "; cat $(d)out.log; echo "out.log.cmp = "; cat $(d)out.log.cmp; $(this_err) "first output log is not as expected");

$(.RECIPEPREFIX)+$(a)$(MAKE) --directory=$(d)prj --no-print-directory | sed -E -e "s/^[^:]*://g" > $(d)out.log || $(this_err) "second 'make' failed"
$(.RECIPEPREFIX)$(a)cmp $(d)out.log $(d)out2.log.cmp || \
        (echo "out.log = "; cat $(d)out.log; echo "out2.log.cmp = "; cat $(d)out2.log.cmp; $(this_err) "second output log is not as expected");

$(.RECIPEPREFIX)+$(a)$(MAKE) --directory=$(d)prj clean || $(this_err) "final 'make clean' failed"

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
