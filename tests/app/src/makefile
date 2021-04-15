include $(d)../../../src/prorab2.mk

# test that changing this_cc will also change this_ld in case this_ld is not explicitply overriden as well
this_cc := asdf
ifneq ($(this_ld),$(this_cc))
    $(error this_ld is not same as this_cc)
endif

$(eval $(prorab-clear-this-vars))

this_name := tests

this_srcs += test.cpp
this_srcs += ../src/../src/test1.c

ifeq ($(os),macosx)
    this_as_supports_deps_gen := false
else
    this_srcs += test.S
endif

# This is just for demonstration that it is possible to generate temporary compilation files
this_cxxflags += -save-temps=obj
this_cflags += -save-temps=obj

this_ldlibs += -lstdc++

$(eval $(prorab-build-app))



$(eval $(prorab-clear-this-vars))



this_name := tests_no_install

this_srcs += test.cpp
this_srcs += ../src/../src/test1.c

this_ldlibs += -lstdc++

this_no_install := true

$(eval $(prorab-build-app))
