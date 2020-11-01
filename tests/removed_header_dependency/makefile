include $(d)../../src/prorab.mk


include $(d)../common.mk

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)

$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp_app
$(.RECIPEPREFIX)$(a)cp -r $(d)app $(d)tmp_app

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)tmp_app || $(this_err) "'make' failed"

$(.RECIPEPREFIX)$(a)rm $(d)tmp_app/test.h
$(.RECIPEPREFIX)$(a)rm $(d)tmp_app/test.hpp
$(.RECIPEPREFIX)$(a)cp $(d)tmp_app/test_new.cpp $(d)tmp_app/test.cpp
$(.RECIPEPREFIX)$(a)cp $(d)tmp_app/test_new.c $(d)tmp_app/test.c
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)tmp_app || $(this_err) "'make' after removing header failed"

$(.RECIPEPREFIX)$(a)rm -rf $(d)tmp_app

$(.RECIPEPREFIX)@$(this_pass)

clean::
$(.RECIPEPREFIX)$(a)rm -rf tmp_app
endef
$(eval $(this_rules))
