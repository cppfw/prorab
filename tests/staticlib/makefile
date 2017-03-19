include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)/src clean
	$(prorab_echo)$(MAKE) -C $(d)/src
	$(prorab_echo)if [ ! -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file not found"; fi
	$(prorab_echo)if [ ! -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory not found"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so ]; then $(this_err) "src/libtests.so file unexpectedly present"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so. ]; then $(this_err) "src/libtests.so. file unexpectedly present"; fi
	$(prorab_echo)$(MAKE) -C $(d)/src clean
	$(prorab_echo)if [ -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
	$(this_pass)
endef
$(eval $(this_rules))
