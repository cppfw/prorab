include $(d)../../src/prorab.mk


#TODO: check that correct soname is applied to control.in
define this_rules :=
.PHONY: test
test::
	@echo "\\033[1;34mexecuting test\\033[0m deb-prepare..."
	$(prorab_echo)rm -f $(d)debian/libtest*.install
	$(prorab_echo)rm -f $(d)debian/control
	$(prorab_echo)(cd $(d); ../../src/prorab-deb-prepare.sh)
	$(prorab_echo)if [ ! -f $(d)debian/control ]; then echo "\t\\033[1;31mERROR\\033[0m: debian/control file not found" && exit 1; fi
	$(prorab_echo)if [ ! -f $(d)debian/libtesta4.install ]; then echo "\t\\033[1;31mERROR\\033[0m: debian/libtesta4.install file not found" && exit 1; fi
	$(prorab_echo)if [ ! -f $(d)debian/libtestb4.install ]; then echo "\t\\033[1;31mERROR\\033[0m: debian/libtestb4.install file not found" && exit 1; fi
	@echo "\t\\033[1;32mPASSED\\033[0m"
endef
$(eval $(this_rules))
