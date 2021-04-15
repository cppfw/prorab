include $(d)prorab2.mk

#NOTE: verbatim define := does not work in make 3.81
define this_rules
install::
$(.RECIPEPREFIX)$(a)install -d $(DESTDIR)$(PREFIX)/include
$(.RECIPEPREFIX)$(a)install $(d)*.mk $(DESTDIR)$(PREFIX)/include
endef
$(eval $(this_rules))
