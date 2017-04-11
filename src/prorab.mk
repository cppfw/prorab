# prorab - the build system


#once
ifneq ($(prorab_included),true)
    prorab_included := true

    #for storing list of included makefiles
    prorab_included_makefiles :=


    #check if running minimal supported GNU make version
    prorab_min_gnumake_version := 3.81
    ifeq ($(filter $(prorab_min_gnumake_version),$(firstword $(sort $(MAKE_VERSION) $(prorab_min_gnumake_version)))),)
        $(error GNU make $(prorab_min_gnumake_version) or higher is needed, but found only $(MAKE_VERSION))
    endif


    #check that prorab.mk is the first file included
    ifneq ($(words $(MAKEFILE_LIST)),2)
        $(error prorab.mk is not a first include in the makefile, include prorab.mk should be the very first thing done in the makefile.)
    endif


    #define arithmetic functions
    prorab-num = $(words $1) #get number from variable
    prorab-add = $1 $2 #add two variables
    prarab-inc = x $1 #increment variable
    prorab-dec = $(wordlist 2,$(words $1),$1) #decrement variable
    prorab-max = $(subst xx,x,$(join $1,$2)) #get maximum of two variables
    prorab-gt = $(filter-out $(words $2),$(words $(call prorab-max,$1,$2))) #greater predicate
    prorab-eq = $(filter $(words $1),$(words $2)) #equals predicate
    prorab-gte = $(call prorab-gt,$1,$2)$(call prorab-eq,$1,$2) #greater or equals predicate
    prorab-sub = $(if $(call prorab-gte,$1,$2),$(filter-out xx,$(join $1,$2)),$(error subtraction goes negative)) #subtract one variable from another, negative result is clamped to zero

    prorab-rwildcard = $(foreach dd,$(wildcard $(patsubst %.,%,$1)*),$(call prorab-rwildcard,$(dd)/,$2) $(filter $(subst *,%,$2),$(dd)))

    #calculate number of ../ in a file path
    prorab-calculate-stepups = $(foreach var,$(filter ..,$(subst /, ,$(dir $1))),x)

    #define this directory for parent makefile
    prorab_this_makefile := $(word $(call prorab-num,$(call prorab-dec,$(MAKEFILE_LIST))),$(MAKEFILE_LIST))
    prorab_this_dir := $(dir $(prorab_this_makefile))

    #defining alias for prorab_this_dir, it should be deferred assignment to make it work with current prorab-include macro correctly.
    d = $(prorab_this_dir)

    #define local variables used by prorab
    this_name :=
    this_soname :=
    this_cflags :=
    this_cxxflags :=
    this_ldflags :=
    this_ldlibs :=
    this_srcs :=


    .PHONY: clean all install uninstall distclean phony

    #define the very first default target
    all:

    #define dummy phony target
    phony:

    #define distclean target which does same as clean. This is to make some older versions of debhelper happy.
    distclean: clean

    #directory of prorab.mk
    prorab_dir := $(dir $(lastword $(MAKEFILE_LIST)))

    #initialize standard vars for "install" and "uninstall" targets
    ifeq ($(PREFIX),) #PREFIX is environment variable, but if it is not set, then set default value
        PREFIX := /usr/local
    endif

    #Detect operating system
    prorab_private_os := $(shell uname)
    prorab_private_os := $(patsubst MINGW%,Windows,$(prorab_private_os))
    prorab_private_os := $(patsubst CYGWIN%,Windows,$(prorab_private_os))
    ifeq ($(prorab_private_os), Windows)
        prorab_os := windows
    else ifeq ($(prorab_private_os), Darwin)
        prorab_os := macosx
    else ifeq ($(prorab_private_os), Linux)
        prorab_os := linux
    else
        $(info Warning: unknown OS, assuming linux)
        prorab_os := linux
    endif

    os := $(prorab_os)

    #set library extension
    ifeq ($(prorab_os), windows)
        prorab_lib_extension := .dll
    else ifeq ($(prorab_os), macosx)
        prorab_lib_extension := .dylib
    else
        prorab_lib_extension := .so
    endif

    soext := $(prorab_lib_extension)

    ifeq ($(verbose),true)
        prorab_echo :=
    else
        prorab_echo := @
    endif



    define prorab-private-app-specific-rules
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_private_ldflags := )

        $(if $(filter windows,$(prorab_os)), \
                $(eval prorab_this_name := $(abspath $(prorab_this_dir)$(this_name).exe)) \
            , \
                $(eval prorab_this_name := $(abspath $(prorab_this_dir)$(this_name))) \
            )

        $(eval prorab_this_symbolic_name := $(prorab_this_name))

        install:: $(prorab_this_name)
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin/
		$(prorab_echo)install $(prorab_this_name) $(DESTDIR)$(PREFIX)/bin/

        uninstall::
		$(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/bin/$(notdir $(prorab_this_name))

        #need empty line here to avoid merging with adjacent macro instantiations
    endef



    define prorab-private-dynamic-lib-specific-rules-nix-systems
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_soname),,$(error this_soname is not defined))

        $(if $(filter macosx,$(prorab_os)), \
                $(eval prorab_this_symbolic_name := $(abspath $(prorab_this_dir)lib$(this_name)$(prorab_lib_extension))) \
                $(eval prorab_this_name := $(abspath $(prorab_this_dir)lib$(this_name).$(this_soname)$(prorab_lib_extension))) \
                $(eval prorab_private_ldflags += -dynamiclib -Wl,-install_name,$(prorab_this_name),-headerpad_max_install_names,-undefined,dynamic_lookup,-compatibility_version,1.0,-current_version,1.0) \
            ,\
                $(eval prorab_this_symbolic_name := $(abspath $(prorab_this_dir)lib$(this_name)$(prorab_lib_extension))) \
                $(eval prorab_this_name := $(prorab_this_symbolic_name).$(this_soname)) \
                $(eval prorab_private_ldflags := -shared -Wl,-soname,$(notdir $(prorab_this_name))) \
            )

        #symbolic link to shared library rule
        $(prorab_this_symbolic_name): $(prorab_this_name)
			@printf "\\033[0;36mCreating symbolic link\\033[0m $$(notdir $$@) -> $$(notdir $$<)...\n"
			$(prorab_echo)(cd $$(dir $$<); ln -f -s $$(notdir $$<) $$(notdir $$@))

        all: $(prorab_this_symbolic_name)

        install:: $(prorab_this_symbolic_name)
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/
		$(prorab_echo)(cd $(DESTDIR)$(PREFIX)/lib/; ln -f -s $(notdir $(prorab_this_name)) $(notdir $(prorab_this_symbolic_name)))

        uninstall::
		$(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_symbolic_name))

        clean::
		$(prorab_echo)rm -f $(prorab_this_symbolic_name)

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    
    define prorab-private-lib-install-headers-rule
        #need empty line here to avoid merging with adjacent macro instantiations

        $(eval prorab_private_headers := $(patsubst $(d)%,%,$(call prorab-rwildcard, $(d), *.h *.hpp)))

        install::
		$(prorab_echo)for i in $(prorab_private_headers); do \
		    install -d $(DESTDIR)$(PREFIX)/include/$$$$(dirname $$$$i); \
		    install -m 644 $(d)$$$$i $(DESTDIR)$(PREFIX)/include/$$$$i; \
		done

        uninstall::
		$(prorab_echo)for i in $(prorab_private_headers); do \
		    path=$$$$(echo $$$$i | cut -d "/" -f1) && \
		    rm -rf $(DESTDIR)$(PREFIX)/include/$$$$path; \
		done

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-private-dynamic-lib-specific-rules
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(if $(filter windows,$(prorab_os)), \
                $(eval prorab_this_name := $(abspath $(prorab_this_dir)lib$(this_name)$(prorab_lib_extension))) \
                $(eval prorab_private_ldflags := -shared -s) \
                $(eval prorab_this_symbolic_name := $(prorab_this_name)) \
            , \
                $(prorab-private-dynamic-lib-specific-rules-nix-systems) \
            )

        install:: $(prorab_this_name)
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/
		$(prorab_echo)install $(prorab_this_name) $(DESTDIR)$(PREFIX)/lib/
		$(if $(filter macosx,$(prorab_os)), \
		        $(prorab_echo)install_name_tool -id "$(PREFIX)/lib/$(notdir $(prorab_this_name))" $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) \
		    )

        uninstall::
		$(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name))
	
        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-private-lib-static-library-rule
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_this_staticlib := $(abspath $(prorab_this_dir)lib$(this_name).a))

        all: $(prorab_this_staticlib)

        clean::
		$(prorab_echo)rm -f $(prorab_this_staticlib)

        install:: $(prorab_this_staticlib)
		$(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/
		$(prorab_echo)install -m 644 $(prorab_this_staticlib) $(DESTDIR)$(PREFIX)/lib/

        uninstall::
		$(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_staticlib))

        #static library rule
        $(prorab_this_staticlib): $(prorab_this_objs)
		@printf "\\033[0;33mCreating static library\\033[0m $$(notdir $$@)...\n"
		$(prorab_echo)ar cr $$@ $$(filter %.o,$$^)

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-private-args-file-rules
        #need empty line here to avoid merging with adjacent macro instantiations

        $1: $(if $(shell echo '$2' | cmp $1 2>/dev/null), phony,)
		$(prorab_echo)mkdir -p $$(dir $$@)
		$(prorab_echo)touch $$@
		$(prorab_echo)echo '$2' > $$@

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-private-compile-rules
        #need empty line here to avoid merging with adjacent macro instantiations

        #calculate max number of steps up in source paths and prepare obj directory spacer
        $(eval prorab_private_numobjspacers := )
        $(foreach var,$(this_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-calculate-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(eval prorab_private_objspacer:= )
        $(foreach var,$(prorab_private_numobjspacers), $(eval prorab_private_objspacer := $(prorab_private_objspacer)_prorab/))

        $(eval prorab_this_obj_dir := obj_$(this_name)/)

        #Prepare list of object files
        $(eval prorab_this_cpp_objs := $(addprefix $(prorab_this_dir)$(prorab_this_obj_dir)cpp/$(prorab_private_objspacer),$(patsubst %.cpp,%.o,$(filter %.cpp,$(this_srcs)))))
        $(eval prorab_this_c_objs := $(addprefix $(prorab_this_dir)$(prorab_this_obj_dir)c/$(prorab_private_objspacer),$(patsubst %.c,%.o,$(filter %.c,$(this_srcs)))))
        $(eval prorab_this_objs := $(prorab_this_cpp_objs) $(prorab_this_c_objs))

        $(eval prorab_cxxargs := $(CXXFLAGS) $(CPPFLAGS) $(this_cxxflags))
        $(eval prorab_cargs := $(CFLAGS) $(CPPFLAGS) $(this_cflags))

        $(eval prorab_cxxargs_file := $(prorab_this_dir)$(prorab_this_obj_dir)cxxargs.txt)
        $(eval prorab_cargs_file := $(prorab_this_dir)$(prorab_this_obj_dir)cargs.txt)

        #compile command line flags dependency
        $(call prorab-private-args-file-rules, $(prorab_cxxargs_file),$(CXX) $(prorab_cxxargs))
        $(call prorab-private-args-file-rules, $(prorab_cargs_file),$(CC) $(prorab_cargs))

        #compile .cpp static pattern rule
        $(prorab_this_cpp_objs): $(prorab_this_dir)$(prorab_this_obj_dir)cpp/$(prorab_private_objspacer)%.o: $(prorab_this_dir)%.cpp $(prorab_cxxargs_file)
		@printf "\\033[1;34mCompiling\\033[0m $$<...\n"
		$(prorab_echo)mkdir -p $$(dir $$@)
		$(prorab_echo)$$(CXX) -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -o "$$@" $(prorab_cxxargs) $$<

        #compile .c static pattern rule
        $(prorab_this_c_objs): $(prorab_this_dir)$(prorab_this_obj_dir)c/$(prorab_private_objspacer)%.o: $(prorab_this_dir)%.c $(prorab_cargs_file)
		@printf "\\033[1;35mCompiling\\033[0m $$<...\n"
		$(prorab_echo)mkdir -p $$(dir $$@)
		$(prorab_echo)$$(CC) -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -o "$$@" $(prorab_cargs) $$<

        #include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_objs))))

        clean::
		$(prorab_echo)rm -rf $(prorab_this_dir)$(prorab_this_obj_dir)

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-private-link-rules
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(prorab_this_obj_dir),,$(error prorab_this_obj_dir is not defined))

        $(eval prorab_ldflags := $(this_ldflags) $(LDFLAGS) $(prorab_private_ldflags))
        $(eval prorab_ldlibs := $(this_ldlibs) $(LDLIBS))
        $(eval prorab_ldargs_file := $(prorab_this_dir)$(prorab_this_obj_dir)ldargs.txt)

        $(call prorab-private-args-file-rules, $(prorab_ldargs_file),$(CC) $(prorab_ldflags) $(prorab_ldlibs))

        all: $(prorab_this_name)

        #link rule
        $(prorab_this_name): $(prorab_this_objs) $(prorab_ldargs_file)
		@printf "\\033[1;32mLinking\\033[0m $$@...\n"
		$(prorab_echo)$$(CC) $(prorab_ldflags) $$(filter %.o,$$^) $(prorab_ldlibs) -o "$$@"

        clean::
		$(prorab_echo)rm -f $(prorab_this_name)

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    #if there are no any sources in this_srcs then just install headers, no need to build binaries
    define prorab-build-lib
        #need empty line here to avoid merging with adjacent macro instantiations

        $(prorab-build-static-lib)
        $(if $(this_srcs), \
                $(prorab-private-dynamic-lib-specific-rules) \
                $(prorab-private-link-rules) \
                , \
            )

        #need empty line here to avoid merging with adjacent macro instantiations
    endef

    define prorab-build-static-lib
        #need empty line here to avoid merging with adjacent macro instantiations

        $(prorab-private-lib-install-headers-rule)
        $(if $(this_srcs), \
                $(prorab-private-compile-rules) \
                $(prorab-private-lib-static-library-rule) \
                , \
            )

        #need empty line here to avoid merging with adjacent macro instantiations
    endef


    define prorab-build-app
        #need empty line here to avoid merging with adjacent macro instantiations

        $(prorab-private-app-specific-rules)
        $(prorab-private-compile-rules)
        $(prorab-private-link-rules)

        #need empty line here to avoid merging with adjacent macro instantiations
    endef




    define prorab-include
        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(filter $(abspath $1),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(abspath $1)) \
                $(call prorab-private-include,$1) \
            )

        #need empty line here to avoid merging with adjacent macro instantiations
    endef


    #for storing previous prorab_this_makefile when including other makefiles
    prorab_private_this_makefiles :=

    #include file with correct prorab_this_dir
    define prorab-private-include
        #need empty line here to avoid merging with adjacent macro instantiations

        prorab_private_this_makefiles += $$(prorab_this_makefile)
        prorab_this_makefile := $1
        prorab_this_dir := $$(dir $$(prorab_this_makefile))
        include $1
        prorab_this_makefile := $$(lastword $$(prorab_private_this_makefiles))
        prorab_this_dir := $$(dir $$(prorab_this_makefile))
        prorab_private_this_makefiles := $$(wordlist 1,$$(call prorab-num,$$(call prorab-dec,$$(prorab_private_this_makefiles))),$$(prorab_private_this_makefiles))

        #need empty line here to avoid merging with adjacent macro instantiations
    endef
    #!!!NOTE: the trailing empty line in 'prorab-private-include' definition is needed so that include files would be separated from each other

    #include all makefiles in subdirectories
    define prorab-build-subdirs
        #need empty line here to avoid merging with adjacent macro instantiations

        $(foreach path,$(wildcard $(d)*/makefile),$(call prorab-include,$(path)))

        #need empty line here to avoid merging with adjacent macro instantiations
    endef


    prorab-clear-this-vars = $(foreach var,$(filter this_%,$(.VARIABLES)),$(eval $(var) := ))


    #define function to find all source files from specified directory recursively
    #NOTE: filter-out of empty strings from input path is needed when path is supplied with preceding or trailing spaces, to prevent searching sources from root directory also.
    prorab-src-dir = $(call prorab-rwildcard, $(d)$(filter-out ,$1), *.cpp *.c)

endif #~once


$(if $(filter $(prorab_this_makefile),$(prorab_included_makefiles)), \
        \
    , \
        $(eval prorab_included_makefiles += $(abspath $(prorab_this_makefile))) \
    )

$(prorab-clear-this-vars)
