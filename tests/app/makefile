include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/tests$(dot_exe) ]; then $(this_err) "src/tests$(dot_exe) file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/tests_no_install$(dot_exe) ]; then $(this_err) "src/tests_no_install$(dot_exe) file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/obj_tests/_spacer ]; then $(this_err) "src/obj_tests/_spacer directory not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/obj_tests/_spacer/_spacer ]; then $(this_err) "src/obj_tests/_spacer/_spacer directory not found"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/obj_tests/_spacer/_spacer/_spacer ]; then $(this_err) "src/obj_tests/_spacer/_spacer/_spacer directory found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory not found"; fi

$(.RECIPEPREFIX)$(a)rm -rf $(d)src/tmp
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src install verbose=true DESTDIR=tmp PREFIX=/usr || $(this_err) "'make install' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/tmp/usr/bin/tests$(dot_exe) ]; then $(this_err) "src/tmp/usr/bin/tests$(dot_exe) file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/tmp/usr/bin/tests_no_install$(dot_exe) ]; then $(this_err) "src/tmp/usr/bin/tests_no_install$(dot_exe) file found, must not be there"; fi

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src uninstall DESTDIR=tmp PREFIX=/usr || $(this_err) "'make uninstall' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/tmp/usr/bin/tests$(dot_exe) ]; then $(this_err) "src/tmp/usr/bin/tests$(dot_exe) file found"; fi

$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/tmp/usr/bin ]; then $(this_err) "src/tmp/usr/bin directory not found"; fi
$(.RECIPEPREFIX)$(a)rm -rf src/tmp

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/tests$(dot_exe) ]; then $(this_err) "src/tests$(dot_exe) file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/tests_no_install$(dot_exe) ]; then $(this_err) "src/tests_no_install$(dot_exe) file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory remained after clean"; fi
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
