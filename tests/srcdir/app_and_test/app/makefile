include $(d)../../../../src/prorab.mk

this_name := nopapp

this_srcs := $(call prorab-src-dir,src)

$(info $(this_srcs))

this_ldlibs += -lstdc++

this_cxxflags += -Werror -O2 -g

$(eval $(prorab-build-app))

$(eval $(prorab-clear-this-vars))
