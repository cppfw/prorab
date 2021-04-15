include $(d)../../../../src/prorab2.mk

this_name := tests

this_soname := 0

this_srcs += $(call prorab-src-dir, .)

# this_install_hdrs := include/dir1/dir2/test/test.h include/dir1/dir2/test/test.hpp
this_install_c_hdrs := include/dir1/dir2/test/test.h
this_install_cxx_hdrs := include/dir1/dir2/test/test.hpp
# this_install_hdrs := $(call prorab-hdr-dir,include/dir1/dir2/test)

this_headers_install_dir := test_dir/

this_headers_dir := include/dir1/dir2

$(eval $(prorab-build-lib))
