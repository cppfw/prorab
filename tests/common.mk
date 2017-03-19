this_err := $(d)../../src/prorab-error.sh
this_pass := $(d)../../src/prorab-passed.sh

this_dirs := $(subst /, ,$(d))
this_test := $(word $(words $(this_dirs)),$(this_dirs))

define this_executing_test_
@echo "\\033[0;31mexecuting test\\033[0m $(this_test)..."
endef

#this is a workaround, for some reason verbatim define := does not work in make version 3.81, but works in 4.1 at least
this_executing_test := $(this_executing_test_)
