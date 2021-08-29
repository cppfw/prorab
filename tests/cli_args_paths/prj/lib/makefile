include $(d)../../../../src/prorab.mk

this_out_dir := out

this_name := stuff

this_soname := 0

this_srcs := $(call prorab-src-dir,.)

this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -fPIC

this_cxxflags += -ffile-prefix-map=$(d)=
this_cflags += -ffile-prefix-map=$(d)=

this_ldlibs += -lstdc++

$(eval $(prorab-build-lib))
