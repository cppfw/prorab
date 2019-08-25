# The MIT License (MIT)
#
# Copyright (c) 2019 Ivan Gagis <igagis@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# prorab - the build system

#once
ifneq ($(prorab_is_included),true)
    prorab_is_included := true

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

    #get number from variable
    prorab-num = $(words $1)

    #add two variables
    prorab-add = $1 $2

    #increment variable
    prarab-inc = x $1

    #decrement variable
    prorab-dec = $(wordlist 2,$(words $1),$1)

    #get maximum of two variables
    prorab-max = $(subst xx,x,$(join $1,$2))

    #greater predicate
    prorab-gt = $(filter-out $(words $2),$(words $(call prorab-max,$1,$2)))

    #equals predicate
    prorab-eq = $(filter $(words $1),$(words $2))

    #greater or equals predicate
    prorab-gte = $(call prorab-gt,$1,$2)$(call prorab-eq,$1,$2)

    #subtract one variable from another, negative result is clamped to zero
    prorab-sub = $(if $(call prorab-gte,$1,$2),$(filter-out xx,$(join $1,$2)),$(error subtraction goes negative))


    # function for recursive wildcard
    prorab-rwildcard = $(foreach dd,$(wildcard $(patsubst %.,%,$1)*),$(call prorab-rwildcard,$(dd)/,$2) $(filter $(subst *,%,$2),$(dd)))


    # function for calculating number of ../ in a file path
    prorab-calculate-stepups = $(foreach var,$(filter ..,$(subst /, ,$(dir $1))),x)


    # directory of makefile which includes 'prorab.mk'
    prorab_this_makefile := $(word $(call prorab-num,$(call prorab-dec,$(MAKEFILE_LIST))),$(MAKEFILE_LIST))
    d := $(dir $(prorab_this_makefile))

    # defining alias for 'd'
    prorab_this_dir = $(d)

    prorab_root_makefile_abs_dir := $(abspath $(d))/

    # define a blank variable
    prorab-blank :=

    # define tab character
    prorab-tab := $(prorab-blank)	$(prorab-blank)

    # set recepie prefix to tab if it is not set (tab is default recepie prefix)
    ifeq ($(.RECIPEPREFIX),)
        .RECIPEPREFIX := $(prorab-tab)
    endif

    # 'verbose' valid values are only 'true' or 'false'
    ifeq ($(verbose),true)
        override v := true
    else ifeq ($(verbose),false)
        override v := false
    else ifeq ($(v),0)
        override v := false
    else ifeq ($(v),)
        override v := false
    else ifeq ($(v),false)
        #do nothing
    else
        override v := true
    endif

    ifeq ($(v),false)
        prorab_echo := @
        Q := @
    else
        prorab_echo :=
        Q := 
    endif

    #######################
    # define common rules #

    # Delete target file in case its recepie has failed
    .DELETE_ON_ERROR:

    .PHONY: clean all install uninstall distclean phony re echo-cleaning

    # define the very first default target
    all:

    # define dummy phony target
    phony:

    # define distclean target which does same as clean. This is to make some older versions of debhelper happy.
    distclean: clean

    define prorab-private-rules

        echo-cleaning:
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;90mCleaning\\033[0m\n" || printf "Cleaning\n"

        clean:: echo-cleaning

        # target for rebuilding all
        re:
$(.RECIPEPREFIX)$(Q)$(MAKE) --no-print-directory clean
$(.RECIPEPREFIX)$(Q)$(MAKE) --no-print-directory

    endef
    $(eval $(prorab-private-rules))




    # directory of prorab.mk
    prorab_dir := $(dir $(lastword $(MAKEFILE_LIST)))

    # initialize standard vars for "install" and "uninstall" targets
    ifeq ($(PREFIX),) #PREFIX is environment variable, but if it is not set, then set default value
        PREFIX := /usr/local
    endif

    # Detect operating system
    prorab_private_os := $(shell uname)
    prorab_private_os := $(patsubst MINGW%,Windows,$(prorab_private_os))
    prorab_private_os := $(patsubst MSYS%,Windows,$(prorab_private_os))
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

    # set library extension
    ifeq ($(os), windows)
        prorab_lib_extension := .dll
    else ifeq ($(os), macosx)
        prorab_lib_extension := .dylib
    else
        prorab_lib_extension := .so
    endif

    soext := $(prorab_lib_extension)

    ifeq ($(os), windows)
        exeext := .exe
    else
        exeext :=
    endif

    # 'autojobs' valid values are only 'true' or 'false'
    ifeq ($(autojobs),true)
        override aj := true
    else ifeq ($(autojobs),false)
        override aj := false
    else ifeq ($(aj),0)
        override aj := false
    else ifeq ($(aj),false)
        # do nothing
    else ifeq ($(aj),)
        override aj := false
    else
        override aj := true
    endif

    ifeq ($(aj),true)
        ifeq ($(os),macosx)
            MAKEFLAGS += -j$(shell sysctl -n hw.ncpu)
        else
            MAKEFLAGS += -j$(shell nproc)
        endif
    endif

    define prorab-private-app-specific-rules

        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        # Make sure this_out_dir ends with /
        $(if $(this_out_dir),
                $(if $(patsubst %/,,$(this_out_dir)),
                        $(eval this_out_dir := $(this_out_dir)/)
                    )
            )

        $(eval prorab_private_ldflags := )

        $(eval prorab_this_name := $(abspath $(d)$(this_out_dir)$(this_name)$(exeext)))

        $(eval prorab_this_symbolic_name := $(prorab_this_name))

        $(if $(filter $(this_no_install),true),, install:: $(prorab_this_name))
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)install -d $(DESTDIR)$(PREFIX)/bin/ && \
                        install $(prorab_this_name) $(DESTDIR)$(PREFIX)/bin/ \
            )

        $(if $(filter $(this_no_install),true),, uninstall::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/bin/$(notdir $(prorab_this_name)) \
            )

        #need empty line here to avoid merging with adjacent macro instantiations

    endef



    define prorab-private-dynamic-lib-specific-rules-nix-systems

        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_soname),,$(error this_soname is not defined))

        # Make sure this_out_dir ends with /
        $(if $(this_out_dir),
                $(if $(patsubst %/,,$(this_out_dir)),
                        $(eval this_out_dir := $(this_out_dir)/)
                    )
            )

        $(eval prorab_this_symbolic_name := $(abspath $(d)$(this_out_dir)lib$(this_name)$(soext)))

        $(if $(filter macosx,$(os)), \
                $(eval prorab_this_name := $(abspath $(d)$(this_out_dir)lib$(this_name).$(this_soname)$(soext))) \
                $(eval prorab_private_ldflags := -dynamiclib -Wl,-install_name,$(prorab_this_name),-headerpad_max_install_names,-undefined,dynamic_lookup,-compatibility_version,1.0,-current_version,1.0) \
            ,\
                $(eval prorab_this_name := $(prorab_this_symbolic_name).$(this_soname)) \
                $(eval prorab_private_ldflags := -shared -Wl,-soname,$(notdir $(prorab_this_name))) \
            )

        #symbolic link to shared library rule
        $(prorab_this_symbolic_name): $(prorab_this_name)
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;36mCreating symbolic link\\033[0m $$(notdir $$@) -> $$(notdir $$<)\n" || printf "Creating symbolic link $$(notdir $$@) -> $$(notdir $$<)\n"
$(.RECIPEPREFIX)$(prorab_echo)(cd $$(dir $$<) && ln -f -s $$(notdir $$<) $$(notdir $$@))

        all: $(prorab_this_symbolic_name)

        $(if $(filter $(this_no_install),true),, install:: $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)))
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/ && \
                        (cd $(DESTDIR)$(PREFIX)/lib/ && ln -f -s $(notdir $(prorab_this_name)) $(notdir $(prorab_this_symbolic_name))) \
            )

        $(if $(filter $(this_no_install),true),, $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)): $(prorab_this_name))
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo) \
                        install -d $(DESTDIR)$(PREFIX)/lib/ && \
                        install $(prorab_this_name) $(DESTDIR)$(PREFIX)/lib/ \
            )

        $(if $(filter $(this_no_install),true),, uninstall::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_symbolic_name))
            )

        clean::
$(.RECIPEPREFIX)$(prorab_echo)rm -f $(prorab_this_symbolic_name)

        #need empty line here to avoid merging with adjacent macro instantiations

    endef


    define prorab-private-lib-install-headers-rule

        #need empty line here to avoid merging with adjacent macro instantiations

        $(eval prorab_private_headers_dir := $(d)$(this_headers_dir)/)

        $(eval prorab_private_headers := $(patsubst $(prorab_private_headers_dir)%,%,$(call prorab-rwildcard, $(prorab_private_headers_dir), *.h *.hpp)))

        $(if $(filter $(this_no_install),true),, install::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)for i in $(prorab_private_headers); do \
                    install -d $(DESTDIR)$(PREFIX)/include/$$$$(dirname $$$$i) && \
                    install -m 644 $(prorab_private_headers_dir)$$$$i $(DESTDIR)$(PREFIX)/include/$$$$i; \
                done \
            )

        $(if $(filter $(this_no_install),true),, uninstall::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)for i in $(prorab_private_headers); do \
                    path=$$$$(echo $$$$i | cut -d "/" -f1) && \
                    rm -rf $(DESTDIR)$(PREFIX)/include/$$$$path; \
                done \
            )

        #need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-dynamic-lib-specific-rules

        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        # Make sure this_out_dir ends with /
        $(if $(this_out_dir),
                $(if $(patsubst %/,,$(this_out_dir)),
                        $(eval this_out_dir := $(this_out_dir)/)
                    )
            )

        $(if $(filter windows,$(os)), \
                $(eval prorab_this_name := $(abspath $(d)$(this_out_dir)lib$(this_name)$(soext))) \
                $(eval prorab_private_ldflags := -shared -s -Wl,--out-implib=$(d)$(this_out_dir)lib$(this_name)$(soext).a) \
                $(eval prorab_this_symbolic_name := $(prorab_this_name)) \
            , \
                $(prorab-private-dynamic-lib-specific-rules-nix-systems) \
            )

        #in Cygwin and Msys2 the .dll files go to /usr/bin and .a and .dll.a files go to /usr/lib
        $(if $(filter $(this_no_install),true),, install:: \
                $(if $(filter windows,$(os)), \
                        $(prorab_this_name), \
                        $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) \
                    ) \
            )
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(if $(filter windows,$(os)), \
                        $(prorab_echo) \
                                install -d $(DESTDIR)$(PREFIX)/bin/ && \
                                install $(prorab_this_name) $(DESTDIR)$(PREFIX)/bin/ && \
                                install -d $(DESTDIR)$(PREFIX)/lib/ && \
                                install $(prorab_this_name).a $(DESTDIR)$(PREFIX)/lib/ \
                    ,) \
            )
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(if $(filter macosx,$(os)), \
                        $(prorab_echo)install_name_tool -id "$(PREFIX)/lib/$(notdir $(prorab_this_name))" $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) \
                    ) \
            )

        $(if $(filter $(this_no_install),true),, uninstall::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(if $(filter windows,$(os)), \
                        $(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name).a) && \
                                rm -f $(DESTDIR)$(PREFIX)/bin/$(notdir $(prorab_this_name)) \
                    , \
                        $(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) \
                    ) \
            )

        #need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-lib-static-library-rule

        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        # Make sure this_out_dir ends with /
        $(if $(this_out_dir),
                $(if $(patsubst %/,,$(this_out_dir)),
                        $(eval this_out_dir := $(this_out_dir)/)
                    )
            )

        $(eval prorab_this_static_lib := $(abspath $(d)$(this_out_dir)lib$(this_name).a))

        all: $(prorab_this_static_lib)

        clean::
$(.RECIPEPREFIX)$(prorab_echo)rm -f $(prorab_this_static_lib)

        $(if $(filter $(this_no_install),true),, install:: $(prorab_this_static_lib))
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)install -d $(DESTDIR)$(PREFIX)/lib/ && \
                        install -m 644 $(prorab_this_static_lib) $(DESTDIR)$(PREFIX)/lib/ \
            )

        $(if $(filter $(this_no_install),true),, uninstall::)
$(.RECIPEPREFIX)$(if $(filter $(this_no_install),true),, \
                $(prorab_echo)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_static_lib)) \
            )

        #static library rule
        $(prorab_this_static_lib): $(prorab_this_objs)
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;33mCreating static library\\033[0m $$(notdir $$@)\n" || printf "Creating static library $$(notdir $$@)\n"
$(.RECIPEPREFIX)$(prorab_echo)$(this_ar) cr $$@ $$(filter %.o,$$^)

        #need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-args-file-rules

        #need empty line here to avoid merging with adjacent macro instantiations

        $1: $(if $(shell echo '$2' | cmp $1 2>/dev/null), phony,)
$(.RECIPEPREFIX)$(prorab_echo)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(prorab_echo)touch $$@
$(.RECIPEPREFIX)$(prorab_echo)echo '$2' > $$@

        #need empty line here to avoid merging with adjacent macro instantiations

    endef


    define prorab-private-assert-deferred

        $(eval prorab_private_tmp := $($1))
        $(eval prorab_private_probe := x)
        $(eval $1 += $$(prorab_private_probe))
        $(eval prorab_private_probe :=)
        $(if $(call prorab-eq, $($1), $(prorab_private_tmp)),,$(error [$(d)makefile]: Variable '$1' must be a deferred expansion variable))

    endef


    define prorab-private-compile-rules

        #need empty line here to avoid merging with adjacent macro instantiations

        #calculate max number of steps up in source paths and prepare obj directory spacer
        $(eval prorab_private_numobjspacers := )
        $(foreach var,$(this_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-calculate-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(eval prorab_private_objspacer := )
        $(foreach var,$(prorab_private_numobjspacers), $(eval prorab_private_objspacer := $(prorab_private_objspacer)_prorab/))

        # Make sure this_out_dir ends with /
        $(if $(this_out_dir),
                $(if $(patsubst %/,,$(this_out_dir)),
                        $(eval this_out_dir := $(this_out_dir)/)
                    )
            )

        $(eval prorab_this_obj_dir := $(d)$(this_out_dir)obj_$(this_name)/)

        #Prepare list of object files
        $(eval prorab_this_cpp_objs := $(addprefix $(prorab_this_obj_dir)$(prorab_private_objspacer),$(patsubst %.cpp,%.cpp.o,$(filter %.cpp,$(this_srcs)))))
        $(eval prorab_this_c_objs := $(addprefix $(prorab_this_obj_dir)$(prorab_private_objspacer),$(patsubst %.c,%.c.o,$(filter %.c,$(this_srcs)))))
        $(eval prorab_this_objs := $(prorab_this_cpp_objs) $(prorab_this_c_objs))

        $(call prorab-private-assert-deferred,this_cxxflags)
        $(call prorab-private-assert-deferred,this_cflags)
        $(call prorab-private-assert-deferred,this_cppflags)

        $(eval prorab_cxxargs = $$(this_cppflags) $$(this_cxxflags))
        $(eval prorab_cargs = $$(this_cppflags) $$(this_cflags))

        $(eval prorab_cxxargs_file := $(prorab_this_obj_dir)cxxargs.txt)
        $(eval prorab_cargs_file := $(prorab_this_obj_dir)cargs.txt)

        #compile command line flags dependency
        #we don't want to store equivalent paths in a different way, so substitute 'd' to empty string
        $(eval prorab_private_temp_d := $(d))
        $(eval d := )
        $(call prorab-private-args-file-rules, $(prorab_cxxargs_file),$(this_cxx) $(prorab_cxxargs))
        $(call prorab-private-args-file-rules, $(prorab_cargs_file),$(this_cc) $(prorab_cargs))
        $(eval d := $(prorab_private_temp_d))

        #compile .cpp static pattern rule
        $(prorab_this_cpp_objs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.cpp.o: $(d)%.cpp $(prorab_cxxargs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;94mCompiling\\033[0m $$<\n" || printf "Compiling $$<\n"
$(.RECIPEPREFIX)$(prorab_echo)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(prorab_echo)$(this_cxx) -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cxxargs) $$<

        #compile .c static pattern rule
        $(prorab_this_c_objs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.c.o: $(d)%.c $(prorab_cargs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;35mCompiling\\033[0m $$<\n" || printf "Compiling $$<\n"
$(.RECIPEPREFIX)$(prorab_echo)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(prorab_echo)$(this_cc) -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cargs) $$<

        #include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_objs))))

        clean::
$(.RECIPEPREFIX)$(prorab_echo)rm -rf $(prorab_this_obj_dir)

        #need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-link-rules

        #need empty line here to avoid merging with adjacent macro instantiations

        $(if $(prorab_this_obj_dir),,$(error prorab_this_obj_dir is not defined))

        $(call prorab-private-assert-deferred,this_ldflags)
        $(call prorab-private-assert-deferred,this_ldlibs)

        $(eval prorab_ldflags = $$(this_ldflags) $$(prorab_private_ldflags))
        $(eval prorab_ldlibs = $$(this_ldlibs))

        $(eval prorab_ldargs_file := $(prorab_this_obj_dir)ldargs.txt)

        #we don't want to store equivalent paths in a different way, so substitute 'd' to empty string
        $(eval prorab_private_temp_d := $(d))
        $(eval d := )
        $(call prorab-private-args-file-rules, $(prorab_ldargs_file),$(this_cc) $(prorab_ldflags) $(prorab_ldlibs))
        $(eval d := $(prorab_private_temp_d))

        all: $(prorab_this_name)

        #link rule
        $(prorab_this_name): $(prorab_this_objs) $(prorab_ldargs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\\033[0;91mLinking\\033[0m $$(patsubst $(prorab_root_makefile_abs_dir)%,%,$$@)\n" || printf "Linking $$(patsubst $(prorab_root_makefile_abs_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(prorab_echo)mkdir -p $(d)$(this_out_dir)
$(.RECIPEPREFIX)$(prorab_echo)$(this_cc) $(prorab_ldflags) $$(filter %.o,$$^) $(prorab_ldlibs) -o "$$@"

        clean::
$(.RECIPEPREFIX)$(if $(filter windows,$(os)), \
                    $(prorab_echo)rm -f $(prorab_this_name).a \
                )
$(.RECIPEPREFIX)$(prorab_echo)rm -f $(prorab_this_name)

        #need empty line here to avoid merging with adjacent macro instantiations

    endef


    #if there are no any sources in this_srcs then just install headers, no need to build binaries
    define prorab-build-lib

        #need empty line here to avoid merging with adjacent macro instantiations

        $(prorab-private-lib-install-headers-rule)
        $(if $(this_srcs), \
                $(prorab-private-compile-rules) \
                $(prorab-private-lib-static-library-rule) \
                $(if $(filter $(this_static_lib_only),true), \
                    , \
                        $(prorab-private-dynamic-lib-specific-rules) \
                        $(prorab-private-link-rules) \
                    ) \
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

        #if makefile is already included do nothing
        $(if $(filter $(abspath $1),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(abspath $1)) \
                $(call prorab-private-include,$1) \
            )

        #need empty line here to avoid merging with adjacent macro instantiations

    endef


    #for storing previous prorab_this_makefile when including other makefiles
    prorab_private_this_makefiles :=

    #include file with correct current directory
    define prorab-private-include

        #need empty line here to avoid merging with adjacent macro instantiations

        prorab_private_this_makefiles += $$(prorab_this_makefile)
        prorab_this_makefile := $1
        d := $$(dir $$(prorab_this_makefile))
        include $1
        prorab_this_makefile := $$(lastword $$(prorab_private_this_makefiles))
        d := $$(dir $$(prorab_this_makefile))
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

    define prorab-clear-this-vars

        #need empty line here to avoid merging with adjacent macro instantiations

        #clear all vars
        $(foreach var,$(filter this_%,$(.VARIABLES)),$(eval $(var) := ))

        #set default values for compilers
        $(eval this_cc := $(CC))
        $(eval this_cxx := $(CXX))
        $(eval this_ar := $(AR))

        #set default values for flags
        #NOTE: we need deferred assignment here because we want that $(d) would be substituted after saving arguments to command line arguments dependency files.
        $(eval this_cppflags = $(CPPFLAGS))
        $(eval this_cflags = $(CFLAGS))
        $(eval this_cxxflags = $(CXXFLAGS))
        $(eval this_ldflags = $(LDFLAGS))
        $(eval this_ldlibs = $(LDLIBS))

        #need empty line here to avoid merging with adjacent macro instantiations

    endef

    #define function to find all source files from specified directory recursively
    #NOTE: filter-out of empty strings from input path is needed when path is supplied with preceding or trailing spaces, to prevent searching sources from root directory also.
    prorab-src-dir = $(patsubst $(d)%, %, $(call prorab-rwildcard, $(d)$(filter-out ,$1), *.cpp *.c))

endif #~once


$(if $(filter $(prorab_this_makefile),$(prorab_included_makefiles)), \
        \
    , \
        $(eval prorab_included_makefiles += $(abspath $(prorab_this_makefile))) \
    )

$(eval $(prorab-clear-this-vars))
