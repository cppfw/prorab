include $(d)../../src/prorab.mk

this_err := $(d)../../src/prorab-error.sh

define this_rules
.PHONY: test
test::
	@echo "\\033[1;34mexecuting test\\033[0m doc..."
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)$(MAKE) -C $(d)/doc
	$(prorab_echo)if [ ! -f $(d)doc/doxygen.cfg ]; then $(this_err) "doc/doxygen.cfg file not found"; fi
	$(prorab_echo)if [ ! -d $(d)doc/doxygen ]; then $(this_err) "doc/doxygen directory not found"; fi
	$(prorab_echo)cmp $(d)doc/doxygen.cfg $(d)samples/doxygen.cfg || $(this_err) "doc/doxygen.cfg contents are not as expected";
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)if [ -f $(d)doc/doxygen.cfg ]; then $(this_err) "doc/doxygen.cfg file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)doc/doxygen ]; then $(this_err) "doc/doxygen directory remained after clean"; fi
	@echo "\t\\033[1;32mPASSED\\033[0m"
endef
$(eval $(this_rules))
