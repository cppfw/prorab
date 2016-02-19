include src/prorab.mk


install::
#install prorab.mk
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install $(prorab_this_dir)src/prorab.mk $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin
	$(prorab_echo)install $(prorab_this_dir)src/*.sh $(DESTDIR)$(PREFIX)/bin

$(eval $(prorab-build-deb))

$(eval $(prorab-clear-this-vars))


$(eval $(prorab-build-subdirs))

