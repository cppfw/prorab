include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)rm -f $(d)*.txt
	$(prorab_echo)(cd $(d); ../../src/prorab-apply-version.sh -v 1.2.3 *.in)
	$(prorab_echo)if [ ! -f $(d)test-1.2.3.txt ]; then $(this_err) "test-1.2.3.txt file not found"; fi
	$(prorab_echo)cmp $(d)test-1.2.3.txt $(d)test.smp || $(this_err) "test-1.2.3.txt contents are not as expected";
	$(prorab_echo)rm -f $(d)*.txt
	$(prorab_echo)(cd $(d); ../../src/prorab-apply-version.sh -v 1.2.3 *.in --filename-only)
	$(prorab_echo)if [ ! -f $(d)test-1.2.3.txt ]; then $(this_err) "test-1.2.3.txt file not found"; fi
	$(prorab_echo)cmp $(d)test-1.2.3.txt $(d)test-\$$$$\(version\).txt.in || $(this_err) "test-1.2.3.txt contents are not as expected (test-\$$$$(version).txt.in)";
	@$(this_pass)
endef
$(eval $(this_rules))
