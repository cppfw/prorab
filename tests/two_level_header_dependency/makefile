include $(d)../../src/prorab.mk

include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)

$(.RECIPEPREFIX)$(Q)rm -rf $(d)tmp_src
$(.RECIPEPREFIX)$(Q)cp -r $(d)src $(d)tmp_src
$(.RECIPEPREFIX)+$(Q)$(MAKE) -C $(d)tmp_src clean

$(.RECIPEPREFIX)+$(Q)$(MAKE) -C $(d)tmp_src || $(this_err) "'make' failed"

$(.RECIPEPREFIX)$(Q)sleep 2 # timestamp resolution can be as low as 1 second, so wait some time before modifying the file.
$(.RECIPEPREFIX)$(Q)cp $(d)tmp_src/app/new_test1.h $(d)tmp_src/app/test1.h

$(.RECIPEPREFIX)+$(Q)$(MAKE) -C $(d)tmp_src/app > $(d)log.txt || $(this_err) "'make' after modifying header failed"
$(.RECIPEPREFIX)+$(Q)$(MAKE) -C $(d)tmp_src/app > /dev/null || $(this_err) "second 'make' after modifying header failed"

$(.RECIPEPREFIX)$(Q)sed -i -e "s/tests\.exe/tests/g" $(d)log.txt

$(.RECIPEPREFIX)$(Q)cmp $(d)log.txt $(d)log.txt.cmp || (echo "log.txt = "; cat $(d)log.txt; $(this_err) "make log is not as expected");
$(.RECIPEPREFIX)$(Q)rm $(d)log.txt

$(.RECIPEPREFIX)$(Q)rm -rf $(d)tmp_src

$(.RECIPEPREFIX)@$(this_pass)

clean::
$(.RECIPEPREFIX)$(Q)rm -rf tmp_src
endef
$(eval $(this_rules))
