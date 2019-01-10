include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "initial 'make clean' failed"
	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src || $(this_err) "'make' failed"
	$(prorab_echo)if [ ! -f $(d)src/tests$(exeext) ]; then $(this_err) "src/tests$(exeext) file not found"; fi
	$(prorab_echo)if [ ! -f $(d)src/tests_no_install$(exeext) ]; then $(this_err) "src/tests_no_install$(exeext) file not found"; fi
	$(prorab_echo)if [ ! -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory not found"; fi
	$(prorab_echo)if [ ! -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory not found"; fi

	$(prorab_echo)rm -rf $(d)src/tmp
	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src install DESTDIR=tmp PREFIX=/usr || $(this_err) "'make install' failed"
	$(prorab_echo)if [ ! -f $(d)src/tmp/usr/bin/tests$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests$(exeext) file not found"; fi
	$(prorab_echo)if [ -f $(d)src/tmp/usr/bin/tests_no_install$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests_no_install$(exeext) file found, must not be there"; fi

	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src uninstall DESTDIR=tmp PREFIX=/usr || $(this_err) "'make uninstall' failed"
	$(prorab_echo)if [ -f $(d)src/tmp/usr/bin/tests$(exeext) ]; then $(this_err) "src/tmp/usr/bin/tests$(exeext) file found"; fi

	$(prorab_echo)if [ ! -d $(d)src/tmp/usr/bin ]; then $(this_err) "src/tmp/usr/bin directory not found"; fi
	$(prorab_echo)rm -rf src/tmp

	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "final 'make clean' failed"
	$(prorab_echo)if [ -f $(d)src/tests$(exeext) ]; then $(this_err) "src/tests$(exeext) file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/tests_no_install$(exeext) ]; then $(this_err) "src/tests_no_install$(exeext) file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory remained after clean"; fi
	@$(this_pass)
endef
$(eval $(this_rules))
