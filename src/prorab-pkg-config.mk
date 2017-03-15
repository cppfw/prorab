include ./prorab.mk

#once
ifneq ($(prorab_pkg_config_included),true)
    prorab_pkg_config_included := true


    define prorab-pkg-config
        #need empty line here to avoid merging with adjacent macro instantiations

        install:: $(shell ls $(d)*.pc.in)
		$(prorab_echo)prorab-apply-version.sh -v `prorab-deb-version.sh $(d)../debian/changelog` $(d)*.pc.in
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/pkgconfig
		$(prorab_echo)install -m 644 $(d)*.pc $(DESTDIR)$(PREFIX)/lib/pkgconfig

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

endif
