include $(d)../../src/prorab.mk

define this_rules
test::
$(.RECIPEPREFIX)$(a)$(MAKE) --directory=$(d) --makefile=$(d)test_makefile test
endef
$(eval $(this_rules))
