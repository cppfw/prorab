include $(d)../../../../src/prorab.mk

this_out_dir := out

this_name := app

this_srcs := $(call prorab-src-dir,.)
this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -I ../lib
this_cflags += -I ../lib

this_cxxflags += -ffile-prefix-map=$(d)=
this_cflags += -ffile-prefix-map=$(d)=

this_ldlibs += -lstdc++ ../lib/out/libstuff$(dot_so)

$(eval $(prorab-build-app))

$(eval $(call prorab-include, ../lib/makefile))
