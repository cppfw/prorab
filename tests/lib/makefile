include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)rm -rf $(d)tmp
	$(prorab_echo)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
	$(prorab_echo)$(MAKE) -C $(d)src || $(this_err) "'make' failed"
ifeq ($(os), macosx)
	$(prorab_echo)if [ ! -f $(d)src/libtests.dylib ]; then $(this_err) "src/libtests.dylib file not found"; fi
	$(prorab_echo)if [ ! -f $(d)src/libtests.0.dylib ]; then $(this_err) "src/libtests.0.dylib file not found"; fi
else ifeq ($(os), windows)
	$(prorab_echo)if [ ! -f $(d)src/libtests.dll ]; then $(this_err) "src/libtests.dll file not found"; fi
	$(prorab_echo)if [ ! -f $(d)src/libtests.dll.a ]; then $(this_err) "src/libtests.dll.a file not found"; fi
else
	$(prorab_echo)if [ ! -f $(d)src/libtests.so ]; then $(this_err) "src/libtests.so file not found"; fi
	$(prorab_echo)if [ ! -f $(d)src/libtests.so.0 ]; then $(this_err) "src/libtests.so.0 file not found"; fi
endif
	$(prorab_echo)if [ ! -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file not found"; fi

	$(prorab_echo)rm -rf $(d)tmp
	$(prorab_echo)$(MAKE) -C $(d)src install DESTDIR=../tmp PREFIX=/usr || $(this_err) "'make install' failed"
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test.h ]; then $(this_err) "tmp/usr/include/test.h file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test.hpp ]; then $(this_err) "tmp/usr/include/test.hpp file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test/test.h ]; then $(this_err) "tmp/usr/include/test/test.h file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test/test.hpp ]; then $(this_err) "tmp/usr/include/test/test.hpp file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.a ]; then $(this_err) "tmp/usr/lib/libtests.a file not found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test_no_install.h ]; then $(this_err) "tmp/usr/include/test_no_install.h file found, must not be there"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test_no_install.hpp ]; then $(this_err) "tmp/usr/include/test_no_install.hpp file found, must not be there"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.a ]; then $(this_err) "tmp/usr/lib/libtests_no_install.a file found, must not be there"; fi
ifeq ($(os), macosx)
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.dylib ]; then $(this_err) "tmp/usr/lib/libtests.dylib file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests.0.dylib file not found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.dylib ]; then $(this_err) "tmp/usr/lib/libtests_no_install.dylib file found, must not be there"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests_no_install.0.dylib file found, must not be there"; fi
else ifeq ($(os), windows)
	$(prorab_echo)if [ ! -f $(d)tmp/usr/bin/libtests.dll ]; then $(this_err) "tmp/usr/bin/libtests.dll file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.dll.a ]; then $(this_err) "tmp/usr/lib/libtests.dll.a file not found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/bin/libtests_no_install.dll ]; then $(this_err) "tmp/usr/bin/libtests_no_install.dll file found, must not be there"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.dll.a ]; then $(this_err) "tmp/usr/lib/libtests_no_install.dll.a file found, must not be there"; fi
else
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.so ]; then $(this_err) "tmp/usr/lib/libtests.so file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.so.0 ]; then $(this_err) "tmp/usr/lib/libtests.so.0 file not found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.so ]; then $(this_err) "tmp/usr/lib/libtests_no_install.so file found, must not be there"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests_no_install.so.0 ]; then $(this_err) "tmp/usr/lib/libtests_no_install.so.0 file found, must not be there"; fi
endif

	$(prorab_echo)$(MAKE) -C $(d)src uninstall DESTDIR=../tmp PREFIX=/usr || $(this_err) "'make uninstall' failed"
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test.h ]; then $(this_err) "tmp/usr/include/test.h file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test.hpp ]; then $(this_err) "tmp/usr/include/test.hpp file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test/test.h ]; then $(this_err) "tmp/usr/include/test/test.h file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/include/test/test.hpp ]; then $(this_err) "tmp/usr/include/test/test.hpp file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.a ]; then $(this_err) "tmp/usr/lib/libtests.a file found"; fi
ifeq ($(os), macosx)
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.dylib ]; then $(this_err) "tmp/usr/lib/libtests.dylib file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests.0.dylib file found"; fi
else ifeq ($(os), windows)
	$(prorab_echo)if [ -f $(d)tmp/usr/bin/libtests.dll ]; then $(this_err) "tmp/usr/bin/libtests.dll file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.dll.a ]; then $(this_err) "tmp/usr/lib/libtests.dll.a file found"; fi
else
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.so ]; then $(this_err) "tmp/usr/lib/libtests.so file found"; fi
	$(prorab_echo)if [ -f $(d)tmp/usr/lib/libtests.so.0 ]; then $(this_err) "tmp/usr/lib/libtests.so.0 file found"; fi
endif
	$(prorab_echo)if [ ! -d $(d)tmp/usr/lib/ ]; then $(this_err) "tmp/usr/lib/ dir not found"; fi
	$(prorab_echo)if [ ! -d $(d)tmp/usr/include/ ]; then $(this_err) "tmp/usr/include/ dir not found"; fi
	$(prorab_echo)if [ -d $(d)tmp/usr/include/test/ ]; then $(this_err) "tmp/usr/include/test dir found"; fi

	$(prorab_echo)rm -rf $(d)tmp

	$(prorab_echo)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"
	$(prorab_echo)if [ -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so ]; then $(this_err) "src/libtests.so file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so.0 ]; then $(this_err) "src/libtests.so.0 file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.dll ]; then $(this_err) "src/libtests.dll file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.dll.a ]; then $(this_err) "src/libtests.dll.a file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests_no_install.a ]; then $(this_err) "src/libtests_no_install.a file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests_no_install.so ]; then $(this_err) "src/libtests_no_install.so file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests_no_install.so.0 ]; then $(this_err) "src/libtests_no_install.so.0 file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests_no_install.dll ]; then $(this_err) "src/libtests_no_install.dll file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests_no_install.dll.a ]; then $(this_err) "src/libtests_no_install.dll.a file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests_no_install ]; then $(this_err) "src/obj_tests_no_install directory remained after clean"; fi
	@$(this_pass)
endef
$(eval $(this_rules))
