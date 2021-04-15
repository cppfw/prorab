include $(d)../../../../src/prorab.mk

this_out_dir := out

this_name := app

this_srcs := $(call prorab-src-dir,.)
this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -I $(d)../lib
this_cflags += -I $(d)../lib

this_cxxflags += -fmacro-prefix-map=$(d)=
this_cflags += -fmacro-prefix-map=$(d)=

this_ldflags += -L $(d)../lib/out

this_ldlibs += -lstdc++ -lstuff

$(eval $(prorab-build-app))

$(prorab_this_name): $(abspath $(d)../lib/out/libstuff$(dot_so))

$(eval $(call prorab-include, ../lib/makefile))
