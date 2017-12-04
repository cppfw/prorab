this_err := myci-error.sh
this_pass := myci-passed.sh
this_running := myci-running-test.sh

this_dirs := $(subst /, ,$(d))
this_test := $(word $(words $(this_dirs)),$(this_dirs))


