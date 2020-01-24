include $(d)../../../../src/prorab.mk

this_name := nopapp

this_srcs := $(call prorab-src-dir,src)

this_ldlibs += -lstdc++

this_ldflags += -L$(d)../app

this_include_path := -I$(d)some_path

this_cxxflags += -Werror -O2 -g
this_cxxflags += -I$(d)../app $(this_include_path)

this_cflags += -I$(d)../app


$(eval $(prorab-build-app))

$(prorab_this_name): $(abspath $(d)../lib/libtests$(soext))

$(eval $(call prorab-try-include, ../lib/Makefile))
