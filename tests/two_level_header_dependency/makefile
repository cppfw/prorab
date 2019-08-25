include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)

	$(Q)rm -rf $(d)tmp_src
	$(Q)cp -r $(d)src $(d)tmp_src
	+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src clean

	+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src || $(this_err) "'make' failed"

	$(Q)cp $(d)tmp_src/app/new_test1.h $(d)tmp_src/app/test1.h
	+$(Q)$(MAKE) --no-print-directory -C $(d)tmp_src/app > $(d)log.txt || $(this_err) "'make' after modifying header failed"

	$(Q)cmp $(d)log.txt $(d)log.txt.cmp || (echo "log.txt = "; cat $(d)log.txt; $(this_err) "make log is not as expected");
	$(Q)rm $(d)log.txt

	$(Q)rm -rf $(d)tmp_src

	@$(this_pass)

clean::
	$(Q)rm -rf tmp_src
endef
$(eval $(this_rules))
