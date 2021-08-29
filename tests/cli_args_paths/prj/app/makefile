include $(d)../../../../src/prorab.mk

this_out_dir := out

this_name := app

this_srcs := $(call prorab-src-dir,.)
this_hdrs := $(call prorab-hdr-dir,.)

this_cxxflags += -I ../lib
this_cflags += -I ../lib

this_cxxflags += -fmacro-prefix-map=$(d)=./
this_cflags += -fmacro-prefix-map=$(d)=./

#$(info this_cxxflags = $(this_cxxflags))

this_ldflags += -L ../lib/out

this_ldlibs += -lstdc++ -lstuff

$(eval $(prorab-build-app))

$(eval $(call prorab-depend, $(prorab_this_name), ../lib/out/libstuff$(dot_so) ))

$(eval $(call prorab-include, ../lib/makefile))
