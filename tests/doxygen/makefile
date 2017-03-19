include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	$(this_running) $(this_test)
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)$(MAKE) -C $(d)/doc
	$(prorab_echo)if [ ! -f $(d)doc/doxygen.cfg ]; then $(this_err) "doc/doxygen.cfg file not found"; fi
#	$(prorab_echo)if [ ! -d $(d)doc/doxygen ]; then $(this_err) "doc/doxygen directory not found"; fi
	$(prorab_echo)cmp $(d)doc/doxygen.cfg $(d)samples/doxygen.cfg || $(this_err) "doc/doxygen.cfg contents are not as expected";
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)if [ -f $(d)doc/doxygen.cfg ]; then $(this_err) "doc/doxygen.cfg file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)doc/doxygen ]; then $(this_err) "doc/doxygen directory remained after clean"; fi
	$(this_pass)
endef
$(eval $(this_rules))
