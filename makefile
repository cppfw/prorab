include prorab.mk


install::
#install prorab.mk
	@install -d $(DESTDIR)$(PREFIX)/include
	@install prorab.mk $(DESTDIR)$(PREFIX)/include


$(eval $(prorab-build-deb))
