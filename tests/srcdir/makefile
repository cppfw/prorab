include $(d)../../src/prorab2.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)app_and_test clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)app_and_test || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)app_and_test/app/nopapp ]; then $(this_err) "app_and_test/app/nopapp file not found"; fi

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)app_and_test clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)app_and_test/app/nopapp ]; then $(this_err) "app_and_test/app/nopapp file remained after clean"; fi
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
