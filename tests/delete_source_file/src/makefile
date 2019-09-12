include $(d)../../../src/prorab.mk

this_name := tests

this_soname := 0

this_srcs += $(patsubst $(d)%, %, $(call prorab-rwildcard, $(d), *test.cpp *test.c))

this_cflags += -g
this_cxxflags += -g

this_static_lib_only := false

this_out_dir := build_dynamic

$(eval $(prorab-build-lib))


$(eval $(prorab-clear-this-vars))


this_name := tests

this_soname := 0

this_srcs += $(patsubst $(d)%, %, $(call prorab-rwildcard, $(d), *test.cpp *test.c))

this_cflags += -g
this_cxxflags += -g

this_static_lib_only := true

this_out_dir := build_static

$(eval $(prorab-build-lib))


$(eval $(prorab-clear-this-vars))


this_name := tests

this_srcs += $(patsubst $(d)%, %, $(call prorab-rwildcard, $(d), *test.cpp *test.c)) main.cpp

this_cflags += -g
this_cxxflags += -g
this_ldlibs += -lstdc++

this_out_dir := build_app

$(eval $(prorab-build-app))
