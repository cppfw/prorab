include $(d)prorab.mk

ifeq ($(PREFIX),) # PREFIX is environment variable, but if it is not set, then set default value
    PREFIX := /usr/local
endif

# NOTE: verbatim define := does not work in make 3.81
define this_rules
install::
$(.RECIPEPREFIX)$(a)install -d $(DESTDIR)$(PREFIX)/include
$(.RECIPEPREFIX)$(a)install $(d)*.mk $(DESTDIR)$(PREFIX)/include
endef
$(eval $(this_rules))
