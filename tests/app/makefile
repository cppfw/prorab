include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(Q)if [ ! -f $(d)src/tests$(exeext) ]; then $(this_err) "src/tests$(exeext) file not found"; fi
$(.RECIPEPREFIX)$(Q)if [ ! -f $(d)src/tests_no_install$(exeext) ]; then $(this_err) "src/tests_no_install$(exeext) file not found"; fi
$(.RECIPEPREFIX)$(Q)if [ ! -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory not found"; fi
$(.RECIPEPREFIX)$(Q)if [ ! -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory not found"; fi

$(.RECIPEPREFIX)$(Q)rm -rf $(d)src/tmp
$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)src install v=t DESTDIR=tmp PREFIX=/usr || $(this_err) "'make install' failed"
$(.RECIPEPREFIX)$(Q)if [ ! -f $(d)src/tmp/usr/bin/tests$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests$(exeext) file not found"; fi
$(.RECIPEPREFIX)$(Q)if [ -f $(d)src/tmp/usr/bin/tests_no_install$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests_no_install$(exeext) file found, must not be there"; fi

$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)src uninstall DESTDIR=tmp PREFIX=/usr || $(this_err) "'make uninstall' failed"
$(.RECIPEPREFIX)$(Q)if [ -f $(d)src/tmp/usr/bin/tests$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests$(exeext) file found"; fi

$(.RECIPEPREFIX)$(Q)if [ ! -d $(d)src/tmp/usr/bin ]; then $(this_err) "src/tmp/usr/bin directory not found"; fi
$(.RECIPEPREFIX)$(Q)rm -rf src/tmp

$(.RECIPEPREFIX)+$(Q)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(Q)if [ -f $(d)src/tests$(exeext) ]; then $(this_err) "src/tests$(exeext) file remained after clean"; fi
$(.RECIPEPREFIX)$(Q)if [ -f $(d)src/tests_no_install$(exeext) ]; then $(this_err) "src/tests_no_install$(exeext) file remained after clean"; fi
$(.RECIPEPREFIX)$(Q)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
$(.RECIPEPREFIX)$(Q)if [ -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory remained after clean"; fi
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
