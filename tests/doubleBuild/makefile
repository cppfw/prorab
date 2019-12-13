include $(d)../../src/prorab.mk

include $(d)../common.mk

# TEST DESCRIPTION:
# Test that it is possible to declare two binaries in a single makefile without clearing this_ variables in between.

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
