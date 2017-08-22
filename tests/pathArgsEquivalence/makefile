include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)prj clean
	$(prorab_echo)$(MAKE) -C $(d)prj > $(d)log.txt
	$(prorab_echo)cat log.txt | sed -n -e "s/\(Compiling\).*/\1 /p" > log1.txt
	$(prorab_echo)cat log.txt | sed -n -e "s/\(Linking\).*/\1 /p" >> log1.txt
	$(prorab_echo)cmp $(d)log1.txt $(d)log1.txt.cmp || (echo "log1.txt = "; cat $(d)log1.txt; $(this_err) "initial compilation log is not as expected");
	$(prorab_echo)$(prorab_echo)$(MAKE) -C $(d)prj/app > $(d)log.txt
	$(prorab_echo)cat log.txt | sed -n -e "s/\(Compiling\).*/\1 /p" > log2.txt
	$(prorab_echo)cat log.txt | sed -n -e "s/\(Linking\).*/\1 /p" >> log2.txt
	$(prorab_echo)cmp $(d)log2.txt $(d)log2.txt.cmp || (echo "log2.txt = "; cat $(d)log2.txt; $(this_err) "second compilation log is not as expected");
	@$(this_pass)
endef
$(eval $(this_rules))
