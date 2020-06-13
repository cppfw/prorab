include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean > $(d)log.txt 2>&1 || $(this_err) "'make clean' failed"
$(.RECIPEPREFIX)$(a)cmp $(d)log.txt $(d)log.txt.cmp || (echo "log.txt = "; cat $(d)log.txt; $(this_err) "log is not as expected");
$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
