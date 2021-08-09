include $(d)../../../../src/prorab.mk

test_var_a := test_value_a

$(eval $(call prorab-include, ../b/makefile))

$(info test_var_b = $(test_var_b))

ifneq ($(test_var_b),test_value_b)
    $(error test_var_b = '$(test_var_b)', while expected value is 'test_value_b')
endif

define this_rules
test::
$(.RECIPEPREFIX)@echo "testing..."
endef
$(eval $(this_rules))
