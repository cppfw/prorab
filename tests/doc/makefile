include $(d)../../src/prorab.mk

$(eval $(prorab-build-subdirs))

#TODO: check that correct version is applied to the doxygen.cfg
define this_rules :=
test:: $(d)doc/doxygen
	@echo "executing test doc..."
	$(prorab_echo)if [ ! -f $(d)doc/doxygen.cfg ]; then echo "\tERROR: doc/doxygen.cfg file not found" && exit 1; fi
	$(prorab_echo)if [ ! -d $(d)doc/doxygen ]; then echo "\tERROR: doc/doxygen directory not found" && exit 1; fi
	@echo "\tPASSED"
endef
$(eval $(this_rules))
