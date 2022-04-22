include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src -j1 || $(this_err) "'make' failed"

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"

$(.RECIPEPREFIX)@$(this_pass)
endef

# clang-tidy in Debian 9 and below does not support --quiet flag, which is used in the test,
# so only run the test on Debian 10 or later
this_min_supported_debian := 10
ifeq ($(firstword $(sort $(this_min_supported_debian) $(shell lsb_release --release --short))),$(this_min_supported_debian))
    $(eval $(this_rules))
endif
