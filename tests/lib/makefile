include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
	@$(this_running) $(this_test)
	$(prorab_echo)rm -rf $(d)tmp
	$(prorab_echo)$(MAKE) -C $(d)src clean
	$(prorab_echo)$(MAKE) -C $(d)src
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

	$(prorab_echo)$(MAKE) -C $(d)src install DESTDIR=../tmp PREFIX=/usr
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test.h ]; then $(this_err) "tmp/usr/include/test.h file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test.hpp ]; then $(this_err) "tmp/usr/include/test.hpp file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test/test.h ]; then $(this_err) "tmp/usr/include/test/test.h file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/include/test/test.hpp ]; then $(this_err) "tmp/usr/include/test/test.hpp file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.a ]; then $(this_err) "tmp/usr/lib/libtests.a file not found"; fi
ifeq ($(os), macosx)
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.dylib ]; then $(this_err) "tmp/usr/lib/libtests.dylib file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests.0.dylib file not found"; fi
else ifeq ($(os), windows)
	$(prorab_echo)if [ ! -f $(d)tmp/usr/bin/libtests.dll ]; then $(this_err) "tmp/usr/bin/libtests.dll file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.dll.a ]; then $(this_err) "tmp/usr/lib/libtests.dll.a file not found"; fi
else
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.so ]; then $(this_err) "tmp/usr/lib/libtests.so file not found"; fi
	$(prorab_echo)if [ ! -f $(d)tmp/usr/lib/libtests.so.0 ]; then $(this_err) "tmp/usr/lib/libtests.so.0 file not found"; fi
endif

	$(prorab_echo)$(MAKE) -C $(d)src uninstall DESTDIR=../tmp PREFIX=/usr
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

	$(prorab_echo)$(MAKE) -C $(d)src clean
	$(prorab_echo)if [ -f $(d)src/libtests.a ]; then $(this_err) "src/libtests.a file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so ]; then $(this_err) "src/libtests.so file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.so.0 ]; then $(this_err) "src/libtests.so.0 file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.dll ]; then $(this_err) "src/libtests.dll file remained after clean"; fi
	$(prorab_echo)if [ -f $(d)src/libtests.dll.a ]; then $(this_err) "src/libtests.dll.a file remained after clean"; fi
	$(prorab_echo)if [ -d $(d)src/obj_tests ]; then $(this_err) "src/obj_tests directory remained after clean"; fi
	@$(this_pass)
endef
$(eval $(this_rules))
