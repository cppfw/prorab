include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)prj clean
	$(prorab_echo)$(MAKE) -C $(d)prj | sed -e "s/^make[0-9[]*]*:.*//" | sed -e "s/\(.*Linking.* \).*\(pathArgsEquivalence\/prj\/app\/nopapp\.\.\.\)/\1\2/" > $(d)log1.txt
	$(prorab_echo)cmp $(d)log1.txt $(d)log1.txt.cmp || (echo "log1.txt = "; cat $(d)log1.txt; $(this_err) "initial compilation log is not as expected");
	$(prorab_echo)$(prorab_echo)$(MAKE) -C $(d)prj/app | sed -e "s/^make\[[0-9]*\]:.*//" > $(d)log2.txt
	$(prorab_echo)cmp $(d)log2.txt $(d)log2.txt.cmp || (echo "log2.txt = "; cat $(d)log2.txt; $(this_err) "second compilation log is not as expected");
	@$(this_pass)
endef
$(eval $(this_rules))
