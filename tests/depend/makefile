include $(d)../../src/prorab.mk

ifneq ($(strip $(call prorab-depend, hello, /world/number_one)),hello: /world/number_one)
    $(error prorab-depend test 1 failed)
endif

ifneq ($(strip $(call prorab-depend, hello, /world/number_one /world/number_two)),hello: /world/number_one /world/number_two)
    $(error prorab-depend test 2 failed)
endif

ifneq ($(strip $(call prorab-depend, hello, world/number_three ../world/number_four)),hello: $(abspath $(d)world/number_three) $(abspath $(d)../world/number_four))
    $(error prorab-depend test 3 failed)
endif
