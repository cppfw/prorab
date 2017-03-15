include $(d)prorab.mk


define this_rules :=
install::
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install $(d)*.mk $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin
	$(prorab_echo)install $(d)*.sh $(DESTDIR)$(PREFIX)/bin
endef
$(eval $(this_rules))
