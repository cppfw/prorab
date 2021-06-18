include $(d)../../../src/prorab.mk

include $(d)../../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) outdir/$(this_test)
$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src || $(this_err) "'make' failed"
ifeq ($(os), macosx)
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.dylib ]; then $(this_err) "src/out1/libtests.dylib file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.dylib ]; then $(this_err) "src/out2/libtests_no_install.dylib file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.0.dylib ]; then $(this_err) "src/out1/libtests.0.dylib file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.0.dylib ]; then $(this_err) "src/out2/libtests_no_install.0.dylib file not found"; fi
else ifeq ($(prorab_msys),true)
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.dll ]; then $(this_err) "src/out1/libtests.dll file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.dll ]; then $(this_err) "src/out2/libtests_no_install.dll file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.dll.a ]; then $(this_err) "src/out1/libtests.dll.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.dll.a ]; then $(this_err) "src/out2/libtests_no_install.dll.a file not found"; fi
else
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.so ]; then $(this_err) "src/out1/libtests.so file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.so ]; then $(this_err) "src/out2/libtests_no_install.so file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.so.0 ]; then $(this_err) "src/out1/libtests.so.0 file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.so.0 ]; then $(this_err) "src/out2/libtests_no_install.so.0 file not found"; fi
endif
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out1/libtests.a ]; then $(this_err) "src/out1/libtests.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out2/libtests_no_install.a ]; then $(this_err) "src/out2/libtests_no_install.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/out1/obj_tests ]; then $(this_err) "src/out1/obj_tests directory not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)src/out2/obj_tests_no_install ]; then $(this_err) "src/out2/obj_tests_no_install directory not found"; fi

$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src install DESTDIR=../tmp PREFIX=/usr || $(this_err) "'make install' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/include/test.h ]; then $(this_err) "tmp/usr/include/test.h file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/include/test.hpp ]; then $(this_err) "tmp/usr/include/test.hpp file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/include/test/test.h ]; then $(this_err) "tmp/usr/include/test/test.h file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/include/test/test.hpp ]; then $(this_err) "tmp/usr/include/test/test.hpp file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.a ]; then $(this_err) "tmp/usr/lib/libtests.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test_no_install.h ]; then $(this_err) "tmp/usr/include/test_no_install.h file found, must not be there"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test_no_install.hpp ]; then $(this_err) "tmp/usr/include/test_no_install.hpp file found, must not be there"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.a ]; then $(this_err) "tmp/usr/lib/libtests_no_install.a file found, must not be there"; fi
ifeq ($(os), macosx)
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.dylib ]; then $(this_err) "tmp/usr/lib/libtests.dylib file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests.0.dylib file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.dylib ]; then $(this_err) "tmp/usr/lib/libtests_no_install.dylib file found, must not be there"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests_no_install.0.dylib file found, must not be there"; fi
else ifeq ($(prorab_msys),true)
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/bin/libtests.dll ]; then $(this_err) "tmp/usr/bin/libtests.dll file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.dll.a ]; then $(this_err) "tmp/usr/lib/libtests.dll.a file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/bin/libtests_no_install.dll ]; then $(this_err) "tmp/usr/bin/libtests_no_install.dll file found, must not be there"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.dll.a ]; then $(this_err) "tmp/usr/lib/libtests_no_install.dll.a file found, must not be there"; fi
else
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.so ]; then $(this_err) "tmp/usr/lib/libtests.so file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)tmp/usr/lib/libtests.so.0 ]; then $(this_err) "tmp/usr/lib/libtests.so.0 file not found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.so ]; then $(this_err) "tmp/usr/lib/libtests_no_install.so file found, must not be there"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests_no_install.so.0 ]; then $(this_err) "tmp/usr/lib/libtests_no_install.so.0 file found, must not be there"; fi
endif

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src uninstall DESTDIR=../tmp PREFIX=/usr || $(this_err) "'make uninstall' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test.h ]; then $(this_err) "tmp/usr/include/test.h file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test.hpp ]; then $(this_err) "tmp/usr/include/test.hpp file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test/test.h ]; then $(this_err) "tmp/usr/include/test/test.h file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/include/test/test.hpp ]; then $(this_err) "tmp/usr/include/test/test.hpp file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.a ]; then $(this_err) "tmp/usr/lib/libtests.a file found"; fi
ifeq ($(os), macosx)
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.dylib ]; then $(this_err) "tmp/usr/lib/libtests.dylib file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.0.dylib ]; then $(this_err) "tmp/usr/lib/libtests.0.dylib file found"; fi
else ifeq ($(prorab_msys),true)
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/bin/libtests.dll ]; then $(this_err) "tmp/usr/bin/libtests.dll file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.dll.a ]; then $(this_err) "tmp/usr/lib/libtests.dll.a file found"; fi
else
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.so ]; then $(this_err) "tmp/usr/lib/libtests.so file found"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)tmp/usr/lib/libtests.so.0 ]; then $(this_err) "tmp/usr/lib/libtests.so.0 file found"; fi
endif
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)tmp/usr/lib/ ]; then $(this_err) "tmp/usr/lib/ dir not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -d $(d)tmp/usr/include/ ]; then $(this_err) "tmp/usr/include/ dir not found"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)tmp/usr/include/test/ ]; then $(this_err) "tmp/usr/include/test dir found"; fi

$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out1/libtests.a ]; then $(this_err) "src/out1/libtests.a file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out1/libtests.so ]; then $(this_err) "src/out1/libtests.so file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out1/libtests.so.0 ]; then $(this_err) "src/out1/libtests.so.0 file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out1/libtests.dll ]; then $(this_err) "src/out1/libtests.dll file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out1/libtests.dll.a ]; then $(this_err) "src/out1/libtests.dll.a file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/out1/obj_tests ]; then $(this_err) "src/out1/obj_tests directory remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out2/libtests_no_install.a ]; then $(this_err) "src/out2/libtests_no_install.a file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out2/libtests_no_install.so ]; then $(this_err) "src/out2/libtests_no_install.so file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out2/libtests_no_install.so.0 ]; then $(this_err) "src/out2/libtests_no_install.so.0 file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out2/libtests_no_install.dll ]; then $(this_err) "src/out2/libtests_no_install.dll file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out2/libtests_no_install.dll.a ]; then $(this_err) "src/out2/libtests_no_install.dll.a file remained after clean"; fi
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/out2/obj_tests_no_install ]; then $(this_err) "src/out2/obj_tests_no_install directory remained after clean"; fi
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
