include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	$(this_executing_test)
	$(prorab_echo)rm -f $(d)debian/libtest*.install
	$(prorab_echo)rm -f $(d)debian/control
	$(prorab_echo)(cd $(d); ../../src/prorab-deb-prepare.sh)
	$(prorab_echo)if [ ! -f $(d)debian/control ]; then $(this_err) "debian/control file not found"; fi
	$(prorab_echo)if [ ! -f $(d)debian/libtesta4.install ]; then $(this_err) "debian/libtesta4.install file not found"; fi
	$(prorab_echo)if [ ! -f $(d)debian/libtestb4.install ]; then $(this_err) "debian/libtestb4.install file not found"; fi
	$(prorab_echo)cmp $(d)debian/control $(d)samples/control || $(this_err) "debian/control contents are not as expected";
	$(this_passed_message)
endef
$(eval $(this_rules))
