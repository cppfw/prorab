include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)prj clean || $(this_err) "initial 'make clean' failed"
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)prj verbose=true > $(d)log.txt || $(this_err) "'make verbose=true' failed"
	$(prorab_echo)cat $(d)log.txt | sed -n -e "s/.*\(Compiling\).*/Compile/p" > $(d)log1.txt #check that compiler is invoked
	$(prorab_echo)cat $(d)log.txt | sed -n -e "s/.*\(Linking\).*/Link/p" >> $(d)log1.txt #check that linker is invoked
	$(prorab_echo)cat $(d)log.txt | sed -e "s/^echo .*//" | sed -n -e "s/.* \(-I\.\/app\/\.\.\/app\).*/\1 /p" >> $(d)log1.txt #check that correct paths are passed to compiler
	$(prorab_echo)cat $(d)log.txt | sed -e "s/^echo .*//" | sed -n -e "s/.* \(-L\.\/app\/\.\.\/app\).*/\1 /p" >> $(d)log1.txt #check that correct paths are passed to linker
	$(prorab_echo)cmp $(d)log1.txt $(d)log1.txt.cmp || (echo "log1.txt = "; cat $(d)log1.txt; echo "log.txt = "; cat $(d)log.txt; $(this_err) "initial compilation log is not as expected");
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)prj/app > $(d)log.txt || $(this_err) "'make' failed"
	$(prorab_echo)cat $(d)log.txt | sed -n -e "s/.*\(Compiling\).*/Compile/p" > $(d)log2.txt #check that compiler is NOT invoked
	$(prorab_echo)cat $(d)log.txt | sed -n -e "s/.*\(Linking\).*/Link/p" >> $(d)log2.txt #check that linker is NOT invoked
	$(prorab_echo)cmp $(d)log2.txt $(d)log2.txt.cmp || (echo "log2.txt = "; cat $(d)log2.txt; $(this_err) "second compilation log is not as expected");
	+$(prorab_echo)$(MAKE) --no-print-directory -C $(d)prj clean || $(this_err) "final 'make clean' failed"
	$(prorab_echo)rm $(d)log.txt $(d)log1.txt $(d)log2.txt
	@$(this_pass)
endef
$(eval $(this_rules))
