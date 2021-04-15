include $(d)../../src/prorab2.mk

include $(d)../common.mk

# TEST DESCRIPTION:
# Test that prorab-build-subdirs mixed with prorab-try-include prodice the correct order of makefiles inclusion.

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)test test || $(this_err) "'make test' failed"
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
