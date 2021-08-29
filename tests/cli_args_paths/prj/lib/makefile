include $(d)../../../../src/prorab.mk

this_out_dir := out

this_name := stuff

this_soname := 0

this_srcs := $(call prorab-src-dir,.)

this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -fPIC

$(info g++ version = $(shell g++ --version))

this_cxxflags += -fmacro-prefix-map=$(d)=
this_cflags += -fmacro-prefix-map=$(d)=

this_ldlibs += -lstdc++

$(eval $(prorab-build-lib))
