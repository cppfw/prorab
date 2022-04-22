include $(d)../../../src/prorab.mk

this_name := tests

this_out_dir := out

this_srcs += $(call prorab-src-dir, .)

this_cxxflags := -D DUMMY_MACRO_CXX
this_cflags := -D DUMMY_MACRO_C

this_ldlibs += -lstdc++

ifeq ($(os),linux)
	# clang-tidy in Debian 9 (stetch) doesn't support --quiet flag, so filter it out from the lint command
	this_lint_cmd = $(subst --quiet,,$(prorab_lint_cmd_clang_tidy))
endif

$(eval $(prorab-build-app))
