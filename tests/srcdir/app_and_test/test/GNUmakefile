include $(d)../../../../src/prorab2.mk


define this_rules
.PHONY: test
test:: $(abspath $(d)../app/nopapp)
	@$(d)../app/nopapp; \
	    if [ $$$$? -eq 0 ]; then myci-passed.sh; else myci-error.sh "application exited with code $$$$?"; fi

endef
$(eval $(this_rules))


$(eval $(call prorab-try-include, ../app/makefile))
