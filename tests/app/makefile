include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)/src clean
	$(prorab_echo)$(MAKE) -C $(d)/src
	$(prorab_echo)if [ ! -f $(d)src/tests ]; then $(this_err) "src/tests file not found"; fi
	$(prorab_echo)$(MAKE) -C $(d)/src install DESTDIR=tmp
	$(prorab_echo)if [ ! -f $(d)src/tmp/usr/local/bin/tests ]; then $(this_err) "src/tmp/usr/local/bin/tests file not found"; fi
	$(prorab_echo)rm -rf src/tmp
	$(prorab_echo)$(MAKE) -C $(d)/src clean
	$(prorab_echo)if [ -f $(d)src/tests.a ]; then $(this_err) "src/tests file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
	@$(this_pass)
endef
$(eval $(this_rules))