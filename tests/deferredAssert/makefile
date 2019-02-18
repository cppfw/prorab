include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)/$1
	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)$1 > $(d)$1/log.txt 2>&1; if [ $$$$? -eq 0 ]; then $(this_err) "$1 'make' completed successfully"; fi
	$(prorab_echo)cmp $(d)$1/log.txt $(d)$1/log.txt.cmp || (echo "log.txt = "; cat $(d)$1/log.txt; $(this_err) "make log is not as expected");
	$(prorab_echo)rm $(d)$1/log.txt
	@$(this_pass)
endef
$(eval $(call this_rules,cflags))
$(eval $(call this_rules,cppflags))
$(eval $(call this_rules,cxxflags))
$(eval $(call this_rules,ldflags))
$(eval $(call this_rules,ldlibs))
