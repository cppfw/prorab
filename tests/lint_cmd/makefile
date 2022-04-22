include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src -j1 || $(this_err) "'make' failed"

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
