include $(d)../../../../src/prorab2.mk

test_var_b := test_value_b

$(eval $(call prorab-include, ../a/makefile))

$(info test_var_a = $(test_var_a))

ifneq ($(test_var_a),test_value_a)
    $(error test_var_a = '$(test_var_a)', while expected value is 'test_value_a')
endif
