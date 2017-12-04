include $(d)../../../../src/prorab.mk


define this_rules
.PHONY: test
test:: $(abspath $(d)../app/nopapp)
	@$(d)../app/nopapp; \
	    if [ $$$$? -eq 0 ]; then myci-passed.sh; else myci-error.sh "application exited with code $$$$?"; fi

endef
$(eval $(this_rules))


$(eval $(call prorab-include,$(d)../app/makefile))
