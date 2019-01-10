include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)

	$(prorab_echo)rm -rf $(d)tmp_app
	$(prorab_echo)cp -r $(d)app $(d)tmp_app

	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)tmp_app || $(this_err) "'make' failed"

	$(prorab_echo)rm $(d)tmp_app/test.h
	$(prorab_echo)rm $(d)tmp_app/test.hpp
	$(prorab_echo)cp $(d)tmp_app/test_new.cpp $(d)tmp_app/test.cpp
	$(prorab_echo)cp $(d)tmp_app/test_new.c $(d)tmp_app/test.c
	$(prorab_echo)$(MAKE) --no-print-directory -C $(d)tmp_app || $(this_err) "'make' after removing header failed"

	@$(this_pass)

clean::
	$(prorab_echo)rm -rf tmp_app
endef
$(eval $(this_rules))
