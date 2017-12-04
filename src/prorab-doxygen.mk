include $(dir $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST)))prorab.mk

#once
ifneq ($(prorab_doxygen_included),true)
    prorab_doxygen_included := true

    .PHONY: doc

    #doxygen docs are only possible for libraries, so install path is lib*-doc
    define prorab-build-doxygen
        #need empty line here to avoid merging with adjacent macro instantiations

        all: doc

        doc:: $(prorab_this_dir)doxygen

        $(prorab_this_dir)doxygen.cfg: $(prorab_this_dir)doxygen.cfg.in $(prorab_this_dir)../debian/changelog
		$(prorab_echo)myci-apply-version.sh -v $$(shell myci-deb-version.sh $(prorab_this_dir)../debian/changelog) $$(firstword $$^)

        $(prorab_this_dir)doxygen: $(prorab_this_dir)doxygen.cfg
		@echo "Building docs..."
		$(prorab_echo)(cd $(prorab_this_dir); doxygen doxygen.cfg || true)

        clean::
		$(prorab_echo)rm -rf $(prorab_this_dir)doxygen
		$(prorab_echo)rm -rf $(prorab_this_dir)doxygen.cfg
		$(prorab_echo)rm -rf $(prorab_this_dir)doxygen_sqlite3.db

        install:: $(prorab_this_dir)doxygen
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/share/doc/lib$(this_name)-doc
		$(prorab_echo)install -m 644 $(prorab_this_dir)doxygen/* $(DESTDIR)$(PREFIX)/share/doc/lib$(this_name)-doc || true #ignore error, not all systems have doxygen

        uninstall::
		$(prorab_echo)rm -rf $(DESTDIR)$(PREFIX)/share/doc/lib$(this_name)-doc

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    
endif
