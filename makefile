include prorab.mk


install::
#install prorab.mk
	@install -d $(DESTDIR)$(PREFIX)/include
	@install prorab.mk $(DESTDIR)$(PREFIX)/include


$(eval $(prorab-build-deb))

$(eval $(prorab-clear-this-vars))



this_version_files += tests/test_file.txt.in
this_version_files += tests/test_file2.txt.in

$(eval $(prorab-apply-version))

