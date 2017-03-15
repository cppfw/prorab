this_err := $(d)../../src/prorab-error.sh

this_dirs := $(subst /, ,$(d))
this_test := $(word $(words $(this_dirs)),$(this_dirs))

define this_executing_test :=
@echo "\\033[0;31mexecuting test\\033[0m $(this_test)..."
endef

define this_passed_message :=
@echo "\t\\033[1;32mPASSED\\033[0m"
endef
