include $(d)../../../src/prorab.mk

this_name := tests

this_soname := 0

this_srcs += $(call prorab-src-dir, .)

this_hdrs += $(call prorab-hdr-dir, .)

this_c_hdrs += ../no_install_headers/test_no_install.h
this_cxx_hdrs += ../no_install_headers/test_no_install.hpp

$(eval $(prorab-build-lib))



$(eval $(prorab-clear-this-vars))



this_name := tests_no_install

this_soname := 0

this_srcs += $(call prorab-src-dir, .)

this_no_install := true

this_headers_dir := ../no_install_headers

$(eval $(prorab-build-lib))
