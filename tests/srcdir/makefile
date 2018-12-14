include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)app_and_test clean || $(this_err) "initial 'make clean' failed"
	$(prorab_echo)$(MAKE) -C $(d)app_and_test || $(this_err) "'make' failed"
	$(prorab_echo)if [ ! -f $(d)app_and_test/app/nopapp ]; then $(this_err) "app_and_test/app/nopapp file not found"; fi

	$(prorab_echo)$(MAKE) -C $(d)app_and_test clean || $(this_err) "final 'make clean' failed"
	$(prorab_echo)if [ -f $(d)app_and_test/app/nopapp ]; then $(this_err) "app_and_test/app/nopapp file remained after clean"; fi
	@$(this_pass)
endef
$(eval $(this_rules))
