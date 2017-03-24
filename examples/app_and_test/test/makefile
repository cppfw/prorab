#Prorab include. Should go first in every makefile.
include prorab.mk


#here we can write some tests for our application.
#Let's define a PHONY 'test' target which will run the app and check that its exit doce is 0.


#Since we will be using some variables we want those to be evaluated right here,
#so to achieve that we first assign our rule to a variable 'this_rules' using verbatim
#block definition and then 'eval' it.

define this_rules
.PHONY: test
test:: $(abspath $(d)../app/nopapp)
	@$(d)../app/nopapp; \
	    if [ $$$$? -eq 0 ]; then prorab-passed.sh; else prorab-error.sh "application exited with code $$$$?"; fi

endef
$(eval $(this_rules))

#Note that we need to escape the $ twice, first for $(eval), second for when the recipe is parsed.
#This results in $$$$.

#Note also that 'test' target depends on the application executable, it has it as recipe prerequisite.
#So, if this makefile is used as standalone one we need to know also how to build that prerequisite,
#for that we just include the makefile of the app using 'prorab-include' macro:
$(eval $(call prorab-include,$(d)../app/makefile))
