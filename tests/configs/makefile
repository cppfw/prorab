include $(d)../../src/prorab.mk

include $(d)../common.mk

# TEST DESCRIPTION:
# Test prorab-config macro.

define this_rules
.PHONY: test
test::
$(.RECIPEPREFIX)@$(this_running) $(this_test)

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean config=rel || $(this_err) "initial 'make clean config=rel' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src config=rel || $(this_err) "'make config=rel' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out/rel/out.txt ]; then $(this_err) "$(d)src/out/rel/out.txt file not found"; fi
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean config=rel || $(this_err) "final 'make clean config=rel' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out/rel/out.txt ]; then $(this_err) "$(d)src/out/rel/out.txt file unexpectedly found"; fi

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "initial 'make clean' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src || $(this_err) "'make' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out/dbg/out.txt ]; then $(this_err) "$(d)src/out/dbg/out.txt file not found"; fi
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean || $(this_err) "final 'make clean' failed"
$(.RECIPEPREFIX)$(a)if [ -f $(d)src/out/dbg/out.txt ]; then $(this_err) "$(d)src/out/dbg/out.txt file unexpectedly found"; fi

$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean-all || $(this_err) "initial 'make clean-all' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src config=rel || $(this_err) "'make config=rel' failed"
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src config=dbg || $(this_err) "'make config=dbg' failed"
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out/rel/out.txt ]; then $(this_err) "$(d)src/out/rel/out.txt file not found"; fi
$(.RECIPEPREFIX)$(a)if [ ! -f $(d)src/out/dbg/out.txt ]; then $(this_err) "$(d)src/out/dbg/out.txt file not found"; fi
$(.RECIPEPREFIX)+$(a)$(MAKE) -C $(d)src clean-all || $(this_err) "final 'make clean-all' failed"
$(.RECIPEPREFIX)$(a)if [ -d $(d)src/out ]; then $(this_err) "$(d)src/out directory unexpectedly found"; fi

$(.RECIPEPREFIX)@$(this_pass)
endef
$(eval $(this_rules))
