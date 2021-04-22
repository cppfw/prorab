include $(d)../../../../src/prorab.mk

this_name := lib2

this_soname := 0

this_srcs := $(call prorab-src-dir, .)

this_out_dir := build

this_cxxflags += -fPIC

this_no_install := true

$(eval $(prorab-build-lib))

$(eval $(call prorab-depend, $(prorab_this_name), ../lib1/build/liblib1$(dot_so)))

$(eval $(call prorab-include, ../lib1/makefile))
