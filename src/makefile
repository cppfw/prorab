include $(d)prorab.mk

#NOTE: verbatim define := does not work in make 3.81
define this_rules
install::
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install $(d)*.mk $(DESTDIR)$(PREFIX)/include
endef
$(eval $(this_rules))
