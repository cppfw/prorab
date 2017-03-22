this_err := $(d)../../src/prorab-error.sh
this_pass := $(d)../../src/prorab-passed.sh
this_running := $(d)../../src/prorab-running-test.sh

this_dirs := $(subst /, ,$(d))
this_test := $(word $(words $(this_dirs)),$(this_dirs))


