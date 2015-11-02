include src/prorab.mk


install::
#install prorab.mk
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/include
	$(prorab_echo)install $(prorab_this_dir)src/prorab.mk $(DESTDIR)$(PREFIX)/include
ifeq ($(prorab_os),macosx)
	$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin
	$(prorab_echo)install $(prorab_this_dir)src/*.sh $(DESTDIR)$(PREFIX)/bin
endif

$(eval $(prorab-build-deb))



$(eval $(prorab-clear-this-vars))

this_version_files += homebrew/prorab.rb.in

this_version_files += tests/test_file.txt.in
this_version_files += tests/test_file2.txt.in

$(eval $(prorab-apply-version))

