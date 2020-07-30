include $(d)../../../src/prorab.mk

this_name := tests

this_srcs += test.cpp
this_srcs += ../src/../src/test1.c
this_srcs += test.S

this_ldlibs += -lstdc++

$(eval $(prorab-build-app))



$(eval $(prorab-clear-this-vars))



this_name := tests_no_install

this_srcs += test.cpp
this_srcs += ../src/../src/test1.c

this_ldlibs += -lstdc++

this_no_install := true

$(eval $(prorab-build-app))
