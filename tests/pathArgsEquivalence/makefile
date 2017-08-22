include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)prj clean
	$(prorab_echo)$(MAKE) -C $(d)prj | sed -e "s/^make\[[0-9]*\]:.*//" > $(d)log1.txt
	$(prorab_echo)cmp $(d)log1.txt $(d)log1.txt.cmp || $(this_err) "initial compilation log is not as expected";
	$(prorab_echo)$(prorab_echo)$(MAKE) -C $(d)prj/app | sed -e "s/^make\[[0-9]*\]:.*//" > $(d)log2.txt
	$(prorab_echo)cmp $(d)log2.txt $(d)log2.txt.cmp || $(this_err) "second compilation log is not as expected";
	@$(this_pass)
endef
$(eval $(this_rules))
