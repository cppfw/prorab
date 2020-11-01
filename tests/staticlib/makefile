include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)/src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)/src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/libtests.so ]; then $(this_err) "src/libtests.so file unexpectedly present"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/libtests.so. ]; then $(this_err) "src/libtests.so. file unexpectedly present"; fi
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)/src clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
