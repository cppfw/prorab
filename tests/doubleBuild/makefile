include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src clean || $(this_err) "initial 'make clean' failed"
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)src || $(this_err) "'make' failed"
	@$(this_pass)
endef
$(eval $(this_rules))
