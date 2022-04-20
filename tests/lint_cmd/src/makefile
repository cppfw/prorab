include $(d)../../../src/prorab.mk

this_name := tests

this_out_dir := out

this_srcs += $(call prorab-src-dir, .)

this_ldlibs += -lstdc++

ifeq ($(os),linux)
	this_lint_cmd = clang-tidy $$< -- $(this_cppflags) $(this_cxxflags)
endif

$(eval $(prorab-build-app))
