include $(prorab_this_dir)../../src/prorab.mk



define this_rules
test::
	$(prorab_echo)(cd $(prorab_this_dir); ../../src/prorab-deb-prepare.sh)

clean::
	$(prorab_echo)rm -f $(prorab_this_dir)debian/libtest*.install
	$(prorab_echo)rm -f $(prorab_this_dir)debian/control
endef
$(eval $(this_rules))
