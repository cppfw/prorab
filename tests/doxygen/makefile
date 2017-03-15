include $(d)../../src/prorab.mk

#TODO: check that correct version is applied to the doxygen.cfg
define this_rules :=
.PHONY: test
test::
	@echo "\\033[1;34mexecuting test\\033[0m doc..."
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)$(MAKE) -C $(d)/doc
	$(prorab_echo)if [ ! -f $(d)doc/doxygen.cfg ]; then echo "\t\\033[1;31mERROR\\033[0m: doc/doxygen.cfg file not found" && exit 1; fi
	$(prorab_echo)if [ ! -d $(d)doc/doxygen ]; then echo "\t\\033[1;31mERROR\\033[0m: doc/doxygen directory not found" && exit 1; fi
	$(prorab_echo)$(MAKE) -C $(d)/doc clean
	$(prorab_echo)if [ -f $(d)doc/doxygen.cfg ]; then echo "\t\\033[1;31mERROR\\033[0m: doc/doxygen.cfg file remained after clean" && exit 1; fi
	$(prorab_echo)if [ -d $(d)doc/doxygen ]; then echo "\t\\033[1;31mERROR\\033[0m: doc/doxygen directory remained after clean" && exit 1; fi
	@echo "\t\\033[1;32mPASSED\\033[0m"
endef
$(eval $(this_rules))
