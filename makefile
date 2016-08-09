include src/prorab.mk

$(eval $(prorab-build-subdirs))

$(eval $(prorab-clear-this-vars))


#install prorab.mk and *.sh
install::
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install $(prorab_this_dir)src/prorab.mk $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin
	$(prorab_echo)install $(prorab_this_dir)src/*.sh $(DESTDIR)$(PREFIX)/bin
