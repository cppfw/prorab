include $(d)../../../../src/prorab2.mk

this_out_dir := out

this_name := app

this_srcs := $(call prorab-src-dir,.)
this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -I ../lib
this_cflags += -I ../lib

this_ldflags += -L ../lib/out

this_ldlibs += -lstdc++ -lstuff

$(eval $(prorab-build-app))

$(prorab_this_name): $(abspath $(d)../lib/out/libstuff$(dot_so))

$(eval $(call prorab-include, ../lib/makefile))
