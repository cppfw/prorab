# The MIT License (MIT)
#
# Copyright (c) 2021 Ivan Gagis <igagis@gmail.com>
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

# include guard
ifneq ($(prorab_is_included),true)
    prorab_is_included := true

    # other popular make utilities like 'nmake' or 'BSD make' have even different syntax for preprocessor
    # commands like ifeq/ifneq, so it is unlikely we reach here if wrong 'make' us used.
    # but nevertheless, check that we are running exactly 'GNU make'
    ifneq ($(shell $(MAKE) --version | sed -E -n 's/.*(GNU Make).*/\1/p'),GNU Make)
        $(error "error: non-GNU make detected, prorab requires GNU make")
    endif

    # check if running minimal supported 'GNU make' version
    prorab_min_gnumake_version := 3.81
    ifeq ($(filter $(prorab_min_gnumake_version),$(firstword $(sort $(MAKE_VERSION) $(prorab_min_gnumake_version)))),)
        $(error GNU make version $(prorab_min_gnumake_version) or higher is needed, but found only $(MAKE_VERSION))
    endif

    # check that prorab.mk is the first file included
    ifneq ($(words $(MAKEFILE_LIST)),2)
        $(error prorab.mk is not a first include in the makefile, include prorab.mk should be the very first thing done in the makefile.)
    endif

    ###############################
    # define arithmetic functions #

    # add two variables
    prorab-add = $1 $2

    # increment variable
    prorab-inc = x $1

    # decrement variable
    prorab-dec = $(wordlist 2,$(words $1),$1)

    # get maximum of two variables
    prorab-max = $(subst xx,x,$(join $1,$2))

    # greater predicate
    prorab-gt = $(filter-out $(words $2),$(words $(call prorab-max,$1,$2)))

    # equals predicate
    prorab-eq = $(filter $(words $1),$(words $2))

    # greater or equals predicate
    prorab-gte = $(call prorab-gt,$1,$2)$(call prorab-eq,$1,$2)

    # subtract one variable from another, negative result is clamped to zero
    prorab-sub = $(if $(call prorab-gte,$1,$2),$(filter-out xx,$(join $1,$2)),$(error subtraction goes negative))

    ####################
    # useful functions #

    # function for calculating number of ../ in a file path
    prorab-count-stepups = $(foreach var,$(filter ..,$(subst /, ,$(dir $1))),x)

    # TODO: test $(call prorab-private-rwildcard somedir. , *.cpp *.hpp)
    prorab-private-rwildcard = $(foreach dd,$(wildcard $(patsubst %.,%,$1)*),$(call prorab-private-rwildcard,$(dd)/,$2) $(filter $(subst *,%,$2),$(dd)))

    # function for recursive wildcard
    prorab-rwildcard = $(patsubst $(d)%,%,$(call prorab-private-rwildcard, $(d)$(strip $1),$2))

    # function to find all source files from specified directory recursively
    prorab-src-dir = $(call prorab-rwildcard,$1,*$(this_dot_cxx) *.c *.S)

    # function to find all header files from specified directory recursively
    prorab-hdr-dir = $(call prorab-rwildcard,$1,*$(this_dot_hxx) *.h)

    # function which clears all 'this_'-prefixed variables and sets default values
    define prorab-clear-this-vars
        # clear all vars
        $(foreach var,$(filter this_%,$(.VARIABLES)),$(eval $(var) := ))

        $(eval this_dot_so := $(dot_so))
        $(eval this_lib_prefix := lib)

        $(eval this_dot_cxx := .cpp)
        $(eval this_dot_hxx := .hpp)

        # set default values for compilers
        $(eval this_cc := $(CC))
        $(eval this_cxx := $(CXX))
        $(eval this_ar := $(AR))
        $(eval this_as := $(AS))
        $(eval this_as_supports_deps_gen := true)
        # NOTE: the deferred assignment to allow changing just C compiler, and linker will change automatically if not explicitly set
        $(eval this_ld = $$(this_cc))

        # set default values for flags
        $(eval this_cppflags := $(CPPFLAGS))
        $(eval this_cflags := $(CFLAGS))
        # NOTE: deferred assignment
        $(eval this_cflags_test = $$(filter -std=%,$$(this_cflags)) $(CPPFLAGS) $(CFLAGS))
        $(eval this_cxxflags := $(CXXFLAGS))
        # NOTE: deferred assignment
        $(eval this_cxxflags_test = $$(filter -std=%,$$(this_cxxflags)) $(CPPFLAGS) $(CXXFLAGS))
        $(eval this_asflags := $(ASFLAGS))
        $(eval this_ldflags := $(LDFLAGS))
        $(eval this_ldlibs := $(LDLIBS))
    endef

    #############
    # variables #

    # make standard variables immediate assignment, as those are deferred assignment by default which is not needed
    CC := $(CC)
    CXX := $(CXX)
    AS := $(AS)
    AR := $(AR)
    CFLAGS := $(CFLAGS)
    CXXFLAGS := $(CXXFLAGS)
    ASFLAGS := $(ASFLAGS)
    CPPFLAGS := $(CPPFLAGS)
    LDFLAGS := $(LDFLAGS)
    LDLIBS := $(LDLIBS)

    # this variable holds filesystem root directory
    # (on Linux and MSYS it is /, on Windows with mingw32-make it is X:/, where X is the drive letter)
    prorab_fs_root := $(abspath /)

    prorab_root_makefile := $(abspath $(word $(words $(call prorab-dec,$(MAKEFILE_LIST))),$(MAKEFILE_LIST)))
    prorab_root_dir := $(dir $(prorab_root_makefile))

    prorab_this_makefile := $(prorab_root_makefile)

    d := $(dir $(prorab_this_makefile))

    # define a blank variable
    prorab_blank :=

    # define tab character
    prorab_tab := $(prorab_blank)	$(prorab_blank)

    # define space character
    prorab_space := $(prorab_blank) $(prorab_blank)

    # define new line character
    define prorab_newline

    endef

    # set recepie prefix to tab if it is not set (tab is default recepie prefix)
    ifeq ($(.RECIPEPREFIX),)
        .RECIPEPREFIX := $(prorab_tab)
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
        # do nothing
    else
        override v := true
    endif

    ifeq ($(v),false)
        a := @
        GNUMAKEFLAGS += --no-print-directory
    else
        a :=
    endif

    # directory of prorab.mk
    prorab_dir := $(dir $(lastword $(MAKEFILE_LIST)))

    # initialize standard vars for "install" and "uninstall" targets
    ifeq ($(PREFIX),) # PREFIX is environment variable, but if it is not set, then set default value
        PREFIX := /usr/local
    endif

    # actual install prefix
    prorab_prefix := $(DESTDIR)$(PREFIX)
    ifeq ($(filter %/,$(prorab_prefix)),) # make sure the prefix ends with /
        prorab_prefix := $(prorab_prefix)/
    endif

    # Detect operating system
    prorab_private_os := $(shell uname)
    prorab_private_os := $(patsubst MINGW%,Windows,$(prorab_private_os))

    prorab_private_os := $(patsubst MSYS%,Msys,$(prorab_private_os))
    prorab_private_os := $(patsubst CYGWIN%,Msys,$(prorab_private_os))

    ifeq ($(prorab_private_os), Windows)
        prorab_os := windows
        prorab_msys := true
    else ifeq ($(prorab_private_os), Msys)
        prorab_os := linux # MSYS and CYGWIN emulate Linux
        prorab_msys := true
    else ifeq ($(prorab_private_os), Darwin)
        prorab_os := macosx
    else ifeq ($(prorab_private_os), Linux)
        prorab_os := linux
    else
        $(info Warning: unknown OS, assuming linux)
        prorab_os := linux
    endif

    os := $(prorab_os)

    # set library suffix
    ifeq ($(prorab_msys),true)
        dot_so := .dll
    else ifeq ($(os),macosx)
        dot_so := .dylib
    else
        dot_so := .so
    endif

    ifeq ($(os),windows)
        dot_exe := .exe
    else
        dot_exe :=
    endif

    ifeq ($(os),macosx)
        prorab_nproc := $(shell sysctl -n hw.ncpu)
    else
        prorab_nproc := $(shell nproc)
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
        MAKEFLAGS += -j$(prorab_nproc)
    endif

    #########################################
    # macro for setting build configuration #

    ifeq ($(config),)
        override config := $(c)
    endif
    ifeq ($(config),)
        override config := default
    endif

    # shorthand alias for config variable
    override c := $(config)

    define prorab-private-config
        this_out_dir := out/$(c)/

        clean-all:: echo-clean-all
$(.RECIPEPREFIX)$(a)rm -rf $(d)out

        $(eval prorab_private_config_file := $(config_dir)$(c).mk)
        $(if $(wildcard $(prorab_private_config_file)),,$(error no $(c).mk config file found in $(config_dir) directory))
        include $(prorab_private_config_file)
    endef

    define prorab-config
        $(if $1,,$(error no 'config dir' argument is given to prorab-config macro))
        $(eval config_dir := $(abspath $(d)$(strip $1))/)
        $(call prorab-private-config,$(config))
    endef

    define prorab-config-default
        $(if $1,,$(error no default config name argument is given to prorab-config-default macro))

        $(if $(filter-out default,$(config)), \
                $(error 'config=$(config)' variable is not set to 'default', unable to apply default config using prorab-config-default macro) \
            )

        $(eval override config := $(strip $1))
        $(eval override c := $(config))
        $(call prorab-private-config, $(config))
    endef

    # helper function for making include path
    ifeq ($(os),windows)
        prorab-private-make-include-path = $(shell cygpath -m $1)
    else
        prorab-private-make-include-path = $1
    endif

    # d variable properly escaped to be used in sed pattern
    prorab_private_d_for_sed = $(subst .,\.,$(subst /,\/,$(d)))

    # sed command which prepends $(d) to local paths in .d files
    prorab_private_d_file_sed_command_intermediate = sed -E -i -e "s/(^| )([^ /\][^ ]*)/\1\$$$$\(d\)\2/g;s/(^| )$(prorab_private_d_for_sed)([^ ]*)/\1\$$$$\(d\)\2/g" $$(patsubst %.o,%.d,$$@)

    # for windows we have to convert windows paths to unix paths using cygpath
    ifeq ($(os),windows)
        # remove spaces in the line beginnings
        # make .d file to have only a single path per line
        # convert to unix paths using cygpath
        # cygpath spoils new line escapes, so restore those (backslash at the line ends)
        prorab_private_d_file_sed_command = sed -E -i -e "s/^ //g;s/([^ ]) ([^ \])/\1 \\\\\n\2/g" $$(patsubst %.o,%.d,$$@) \
                && cygpath -f $$(patsubst %.o,%.d,$$@) > $$(patsubst %.o,%.d,$$@).tmp \
                && mv $$(patsubst %.o,%.d,$$@).tmp $$(patsubst %.o,%.d,$$@) \
                && sed -E -i -e "s/ \/$$$$/ \\\\/g" $$(patsubst %.o,%.d,$$@) \
                && $(prorab_private_d_file_sed_command_intermediate)
    else
        prorab_private_d_file_sed_command = $(prorab_private_d_file_sed_command_intermediate)
    endif

    ###############################
    # add target dependency macro #

    define prorab-depend

        $(if $(strip $1),,$(error prorab-depend: first argument is empty))
        $(if $(strip $2),,$(error prorab-depend: second argument is empty))

        $(if $(filter /%,$(strip $1)),$(strip $1),$(abspath $(d)$(strip $1))): $(foreach p,$(strip $2),$(abspath $(if $(filter /%,$(p)),$(p),$(d)$(p))))

    endef

    ################################
    # makefile inclusion functions #

    # check if makefile was already included with prorab-try-simple-include, prorab-include or prorab-try-include
    # - returns 'true' in case file was included
    # - returns nothing otherwise
    define prorab-is-included

        $(eval prorab_private_include_file := $(abspath $(if $(filter /%,$(strip $1)),$(strip $1),$(d)$(strip $1))))
        $(if $(filter $(prorab_private_include_file),$(MAKEFILE_LIST)),true)

    endef

    # include makefile if it is not included already, does not fail if file does not exist
    define prorab-try-simple-include

        $(eval prorab_private_include_file := $(abspath $(if $(filter /%,$(strip $1)),$(strip $1),$(d)$(strip $1))))
        $(if $(filter $(prorab_private_include_file),$(MAKEFILE_LIST)), \
                , \
                -include $(prorab_private_include_file) \
            )

    endef

    # for storing list of included makefiles
    prorab_included_makefiles :=

    define prorab-include
        $(eval prorab_private_path_to_makefile := $(abspath $(d)$(strip $1)))

        # if makefile is already included do nothing
        $(if $(filter $(prorab_private_path_to_makefile),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(prorab_private_path_to_makefile)) \
                $(call prorab-private-include,$(prorab_private_path_to_makefile),,$(strip $2)) \
            )
    endef

    define prorab-try-include
        $(eval prorab_private_path_to_makefile := $(abspath $(d)$(strip $1)))

        # if makefile is already included do nothing
        $(if $(filter $(prorab_private_path_to_makefile),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(prorab_private_path_to_makefile)) \
                $(call prorab-private-include,$(prorab_private_path_to_makefile),-,$(strip $2)) \
            )
    endef

    # for storing previous prorab_this_makefile when including other makefiles
    prorab_private_this_makefiles :=

    # configs stack
    prorab_private_configs :=

    # include file with correct current directory
    define prorab-private-include
        # push config name
        prorab_private_configs += $$(config)
        override config := $$(if $3,$3,$$(config))
        override c := $$(config)

        prorab_private_this_makefiles += $$(prorab_this_makefile)
        prorab_this_makefile := $1
        d := $$(dir $$(prorab_this_makefile))
        $2include $1
        prorab_this_makefile := $$(lastword $$(prorab_private_this_makefiles))
        d := $$(dir $$(prorab_this_makefile))
        prorab_private_this_makefiles := $$(wordlist 1,$$(words $$(call prorab-dec,$$(prorab_private_this_makefiles))),$$(prorab_private_this_makefiles))

        # pop config name
        override config := $$(lastword $$(prorab_private_configs))
        override c := $$(config)
        prorab_private_configs := $$(wordlist 1,$$(words $$(call prorab-dec,$$(prorab_private_configs))),$$(prorab_private_configs))
    endef

    # include all makefiles in subdirectories
    define prorab-include-subdirs
        $(eval prorab_private_makefilename := $(if $(strip $1),$1,makefile))

        $(foreach path,$(wildcard $(d)*/$(prorab_private_makefilename)), \
                $$(eval $$(call prorab-include,$(patsubst $(d)%,%,$(path)))$(prorab_newline)) \
            )
    endef

    # TODO: deprecated, remove
    define prorab-build-subdirs

        $(info DEPRECATED: prorab-build-subdirs, use prorab-include-subdirs instead. )
        $(prorab-include-subdirs)
        
    endef

    ################
    # common rules #

    # Delete target file in case its recepie has failed
    .DELETE_ON_ERROR:

    .PHONY: all clean distclean clean-all test install uninstall phony re echo-cleaning

    # the very first default target
    all:

    # dummy phony target
    phony:

    # distclean target which does same as clean to make some older versions of debhelper happy
    distclean:: clean

    define prorab-private-rules

        echo-clean:
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;32mclean\e[0m\n" || printf "clean\n"

        echo-clean-all:
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;32mclean all configurations\e[0m\n" || printf "clean\n"

        clean:: echo-clean

        # target for rebuilding all
        re:
$(.RECIPEPREFIX)+$(a)$(MAKE) clean
$(.RECIPEPREFIX)+$(a)$(MAKE)

    endef
    $(eval $(prorab-private-rules))

    ####################################
    # prorab rule generation functions #

    # this is to make sure out dir ends with /
    prorab_private_out_dir = $(if $(this_out_dir),$(if $(patsubst %/,,$(this_out_dir)),$(this_out_dir)/,$(this_out_dir)))

    define prorab-private-app-specific-rules
        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_private_ldflags := )

        $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)$(this_name)$(dot_exe)))

        $(eval prorab_this_symbolic_name := $(prorab_this_name))

        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_this_name)
$(.RECIPEPREFIX)$(a) \
                    install -d $(prorab_prefix)bin/ && \
                    install $(prorab_this_name) $(prorab_prefix)bin/ \
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_prefix)bin/$(notdir $(prorab_this_name)) \
            )
    endef

    define prorab-private-lib-install-headers-rule
        # NOTE: Use 'abspath' to avoid second trailing slash in case 'this_headers_dir' already contains one.
        #       It is ok to use 'abspath' here because 'd' is absolute path anyway.
        $(eval prorab_private_headers_dir := $(abspath $(d)$(this_headers_dir))/)

        $(eval prorab_private_headers := $(patsubst $(prorab_private_headers_dir)%,%, \
                $(if $(this_install_hdrs)$(this_install_c_hdrs)$(this_install_cxx_hdrs), \
                        $(abspath $(addprefix $(d),$(this_install_hdrs))), \
                        $(call prorab-private-rwildcard,$(prorab_private_headers_dir),*.h *$(this_dot_hxx)) \
                    ) \
            ))

        $(eval prorab_private_c_hdrs := $(patsubst $(prorab_private_headers_dir)%,%,$(abspath $(addprefix $(d),$(this_install_c_hdrs)))))
        $(eval prorab_private_cxx_hdrs := $(patsubst $(prorab_private_headers_dir)%,%,$(abspath $(addprefix $(d),$(this_install_cxx_hdrs)))))

        ######################################################
        # Test that headers being installed can be compiled. #
        # This checks that header does not miss any includes #
        # and has proper include guard.                      #
        # The headers are compiled without any specific      #
        # compile flags.                                     #
        ######################################################

        # calculate max number of steps up in source paths and prepare obj directory spacer
        $(eval prorab_private_numobjspacers := )
        $(foreach var,$(prorab_private_headers)$(prorab_private_c_hdrs)$(prorab_private_cxx_hdrs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(eval prorab_private_objspacer := )
        $(foreach var,$(prorab_private_numobjspacers), $(eval prorab_private_objspacer := $(prorab_private_objspacer)_spacer/))

        $(eval prorab_this_obj_dir := $(d)$(prorab_private_out_dir)obj_$(this_name)/)

        # prepare list of header object files (for testing headers compilation)
        $(eval prorab_this_hxx_test_srcs := $(addsuffix .test_cpp,$(filter %$(this_dot_hxx),$(prorab_private_headers))$(prorab_private_cxx_hdrs)))
        $(eval prorab_this_h_test_srcs := $(addsuffix .test_c,$(filter %.h,$(prorab_private_headers))$(prorab_private_c_hdrs)))

        $(eval prorab_this_hxx_test_srcs := $(addprefix $(prorab_this_obj_dir)$(prorab_private_objspacer),$(prorab_this_hxx_test_srcs)))
        $(eval prorab_this_h_test_srcs := $(addprefix $(prorab_this_obj_dir)$(prorab_private_objspacer),$(prorab_this_h_test_srcs)))

        $(eval prorab_this_hxx_test_objs := $(addsuffix .o,$(prorab_this_hxx_test_srcs)))
        $(eval prorab_this_h_test_objs := $(addsuffix .o,$(prorab_this_h_test_srcs)))

        # gerenarte dummy source files for each C++ header (for testing headers compilation)
        $(prorab_this_hxx_test_srcs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.test_cpp : $(prorab_private_headers_dir)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # gerenarte dummy source files for each C header (for testing headers compilation)
        $(prorab_this_h_test_srcs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.test_c : $(prorab_private_headers_dir)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # compile .hpp.test_cpp static pattern rule
        $(prorab_this_hxx_test_objs): $(d)%.o: $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP $(this_cxxflags_test) -o "$$@" $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # compile .h.test_c static pattern rule
        $(prorab_this_h_test_objs): $(d)%.o: $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP $(this_cflags_test) -o "$$@" $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_hxx_test_objs) $(prorab_this_h_test_objs))))

        $(if $(filter $(this_no_install),true), \
                , \
                test:: $(prorab_this_hxx_test_objs) $(prorab_this_h_test_objs) \
            )

        # make sure install dir ends with /
        $(eval prorab_private_install_dir := $(if $(this_headers_install_dir),$(patsubst %/,%,$(this_headers_install_dir))/))

        ##############################
        # Generate 'install' targets #
        ##############################

        $(if $(filter $(this_no_install),true),
                ,
                install::
$(.RECIPEPREFIX)$(a)for i in $(prorab_private_headers) $(prorab_private_c_hdrs) $(prorab_private_cxx_hdrs); do \
                    install -d $(prorab_prefix)include/$(prorab_private_install_dir)$$$$(dirname $$$$i) && \
                    install -m 644 $(prorab_private_headers_dir)$$$$i $(prorab_prefix)include/$(prorab_private_install_dir)$$$$i; \
                done
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)for i in $(prorab_private_headers) $(this_install_c_hdrs) $(prorab_private_cxx_hdrs); do \
                    path=$$$$(echo $(prorab_private_install_dir)$$$$i | cut -d "/" -f1) && \
                    [ ! -z "$$$$path" ] && rm -rf $(prorab_prefix)include/$$$$path; \
                done
            )
    endef

    define prorab-private-dynamic-lib-specific-rules-nix-systems
        $(if $(this_soname),,$(error this_soname is not defined))

        $(eval prorab_this_symbolic_name := $(abspath $(d)$(prorab_private_out_dir)$(this_lib_prefix)$(this_name)$(this_dot_so)))

        $(if $(filter macosx,$(os)), \
                $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)$(this_lib_prefix)$(this_name).$(this_soname)$(this_dot_so))) \
                $(eval prorab_private_ldflags := -dynamiclib -Wl,-install_name,@rpath/$(notdir $(prorab_this_name)),-headerpad_max_install_names,-undefined,dynamic_lookup,-compatibility_version,1.0,-current_version,1.0) \
            ,\
                $(eval prorab_this_name := $(prorab_this_symbolic_name).$(this_soname)) \
                $(eval prorab_private_ldflags := -shared -Wl,-soname,$(notdir $(prorab_this_name))) \
            )

        # symbolic link to shared library rule
        $(prorab_this_symbolic_name): $(prorab_this_name)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;36mcreate symbolic link\e[0m $$(notdir $$@) -> $$(notdir $$<)\n" || printf "create symbolic link $$(notdir $$@) -> $$(notdir $$<)\n"
$(.RECIPEPREFIX)$(a)(cd $$(dir $$<) && ln -f -s $$(notdir $$<) $$(notdir $$@))

        all: $(prorab_this_symbolic_name)

        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_prefix)lib/$(notdir $(prorab_this_name))
$(.RECIPEPREFIX)$(a)install -d $(prorab_prefix)lib/ && \
                        (cd $(prorab_prefix)lib/ && ln -f -s $(notdir $(prorab_this_name)) $(notdir $(prorab_this_symbolic_name)))
$(if $(filter macosx,$(os)),$(.RECIPEPREFIX)$(a) \
                        install_name_tool -id "$(PREFIX)/lib/$(notdir $(prorab_this_name))" $(prorab_prefix)lib/$(notdir $(prorab_this_name)) )
            )

        $(if $(filter $(this_no_install),true),
                ,
                $(prorab_prefix)lib/$(notdir $(prorab_this_name)): $(prorab_this_name)
$(.RECIPEPREFIX)$(a) \
                        install -d $(prorab_prefix)lib/ && \
                        install $(prorab_this_name) $(prorab_prefix)lib/
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_prefix)lib/$(notdir $(prorab_this_symbolic_name))
            )

        clean::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_symbolic_name)
    endef

    define prorab-private-dynamic-lib-specific-rules
        $(if $(this_name),,$(error this_name is not defined))

        $(if $(filter true,$(prorab_msys)), \
                $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)$(this_lib_prefix)$(this_name)$(this_dot_so))) \
                $(eval prorab_private_ldflags := -shared -s -Wl,--out-implib=$(abspath $(d)$(prorab_private_out_dir)$(this_lib_prefix)$(this_name)$(this_dot_so).a)) \
                $(eval prorab_this_symbolic_name := $(prorab_this_name)) \
            , \
                $(prorab-private-dynamic-lib-specific-rules-nix-systems) \
            )

        # in Cygwin and Msys2 the .dll files go to /usr/bin and .a and .dll.a files go to /usr/lib
$(if $(filter true,$(prorab_msys)),
        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_this_name)
$(.RECIPEPREFIX)$(a) \
                    install -d $(prorab_prefix)bin/ && \
                    install $(prorab_this_name) $(prorab_prefix)bin/ && \
                    install -d $(prorab_prefix)lib/ && \
                    install $(prorab_this_name).a $(prorab_prefix)lib/ \
            )
    )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(if $(filter true,$(prorab_msys)),
$(.RECIPEPREFIX)$(a) \
                    rm -f $(prorab_prefix)lib/$(notdir $(prorab_this_name).a) && \
                    rm -f $(prorab_prefix)bin/$(notdir $(prorab_this_name)) \
                    ,
$(.RECIPEPREFIX)$(a)rm -f $(prorab_prefix)lib/$(notdir $(prorab_this_name)) \
                )
            )
    endef

    define prorab-private-lib-static-library-rule
        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_this_static_lib := $(abspath $(d)$(prorab_private_out_dir)$(this_lib_prefix)$(this_name).a))

        all: $(prorab_this_static_lib)

        clean::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_static_lib)

        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_this_static_lib)
$(.RECIPEPREFIX)$(a) \
                    install -d $(prorab_prefix)lib/ && \
                    install -m 644 $(prorab_this_static_lib) $(prorab_prefix)lib/ \
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_prefix)lib/$(notdir $(prorab_this_static_lib)) \
            )

        # static library rule
        # NOTE: need to remove the lib before creating, otherwise files will just be appended to the existing .a archive.
        $(prorab_this_static_lib): $(prorab_this_objs) $(prorab_objs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;33mcreate static library\e[0m $$(notdir $$@)\n" || printf "create static library $$(notdir $$@)\n"
$(.RECIPEPREFIX)$(a)rm -f $$@
$(.RECIPEPREFIX)$(a)$(this_ar) cr $$@ $$(filter %.o,$$^)
    endef

    define prorab-private-args-file-rules
        $1: $(if $(shell echo '$2' | cmp $1 2>/dev/null), phony,)
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)touch $$@
$(.RECIPEPREFIX)$(a)echo '$2' > $$@
    endef

    define prorab-private-compile-rules
        ############################################################################################
        # NOTE: here we also compile header files listed in this_hdrs variable to check that those #
        #       are compileable with the same compiler flags as source files                       #
        ############################################################################################

        # calculate max number of steps up in source paths and prepare obj directory spacer
        $(eval prorab_private_numobjspacers := )
        $(foreach var,$(this_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_c_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_cxx_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_as_srcs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_hdrs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_c_hdrs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(foreach var,$(this_cxx_hdrs),\
                $(eval prorab_private_numobjspacers := $(call prorab-max,$(call prorab-count-stepups,$(var)),$(prorab_private_numobjspacers))) \
            )
        $(eval prorab_this_obj_spacer := )
        $(foreach var,$(prorab_private_numobjspacers), $(eval prorab_this_obj_spacer := $(prorab_this_obj_spacer)_spacer/))

        $(eval prorab_this_obj_dir := $(d)$(prorab_private_out_dir)obj_$(this_name)/)

        # prepare list of object files
        $(eval prorab_this_cxx_objs := $(addsuffix .o,$(filter %$(this_dot_cxx),$(this_srcs))$(this_cxx_srcs)))
        $(eval prorab_this_c_objs := $(addsuffix .o,$(filter %.c,$(this_srcs))$(this_c_srcs)))
        $(eval prorab_this_as_objs := $(addsuffix .o,$(filter %.S,$(this_srcs))$(this_as_srcs)))

        $(eval prorab_objs_file := $(prorab_this_obj_dir)objs.txt)

        # save list of objects to text file and only after that add $(d) prefix to those object files
        $(call prorab-private-args-file-rules, $(prorab_objs_file),$(prorab_this_cxx_objs) $(prorab_this_c_objs) $(prorab_this_as_objs))

        $(eval prorab_this_cxx_objs := $(addprefix $(prorab_this_obj_dir)$(prorab_this_obj_spacer),$(prorab_this_cxx_objs)))
        $(eval prorab_this_c_objs := $(addprefix $(prorab_this_obj_dir)$(prorab_this_obj_spacer),$(prorab_this_c_objs)))
        $(eval prorab_this_as_objs := $(addprefix $(prorab_this_obj_dir)$(prorab_this_obj_spacer),$(prorab_this_as_objs)))
        $(eval prorab_this_objs := $(prorab_this_cxx_objs) $(prorab_this_c_objs) $(prorab_this_as_objs))

        # prepare list of header object files (for testing headers compilation)
        $(eval prorab_this_hxx_srcs := $(addsuffix .hdr_cpp,$(filter %$(this_dot_hxx),$(this_hdrs)) $(this_cxx_hdrs) ))
        $(eval prorab_this_h_srcs := $(addsuffix .hdr_c,$(filter %.h,$(this_hdrs)) $(this_c_hdrs) ))
        $(eval prorab_this_hxx_srcs := $(addprefix $(prorab_this_obj_dir)$(prorab_this_obj_spacer),$(prorab_this_hxx_srcs)))
        $(eval prorab_this_h_srcs := $(addprefix $(prorab_this_obj_dir)$(prorab_this_obj_spacer),$(prorab_this_h_srcs)))

        $(eval prorab_this_hxx_objs := $(addsuffix .o,$(prorab_this_hxx_srcs)))
        $(eval prorab_this_h_objs := $(addsuffix .o,$(prorab_this_h_srcs)))

        # header objects are always compiled
        all: $(prorab_this_hxx_objs) $(prorab_this_h_objs)

        # combine all compilation flags
        $(eval prorab_cxxflags := $(this_cppflags) $(this_cxxflags))
        $(eval prorab_cflags := $(this_cppflags) $(this_cflags))
        $(eval prorab_asflags := $(this_asflags))

        $(eval prorab_cxxflags_file := $(prorab_this_obj_dir)cxx_args.txt)
        $(eval prorab_cflags_file := $(prorab_this_obj_dir)c_args.txt)
        $(eval prorab_asflags_file := $(prorab_this_obj_dir)as_args.txt)

        # compile command line flags dependency
        $(call prorab-private-args-file-rules, $(prorab_cxxflags_file),$(this_cxx) $(prorab_cxxflags))
        $(call prorab-private-args-file-rules, $(prorab_cflags_file),$(this_cc) $(prorab_cflags))
        $(call prorab-private-args-file-rules, $(prorab_asflags_file),$(this_as) $(prorab_asflags))

        # gerenarte dummy source files for each C++ header (for testing headers compilation)
        $(prorab_this_hxx_srcs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.hdr_cpp : $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # gerenarte dummy source files for each C header (for testing headers compilation)
        $(prorab_this_h_srcs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.hdr_c : $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$(call prorab-private-make-include-path,$$<)"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # compile .cpp static pattern rule
        $(prorab_this_cxx_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_cxxflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cxxflags) $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # compile .hpp.hdr_cpp static pattern rule
        $(prorab_this_hxx_objs): $(d)%.o: $(d)% $(prorab_cxxflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cxxflags) $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # compile .c static pattern rule
        $(prorab_this_c_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_cflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cflags) $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # compile .h.hdr_c static pattern rule
        $(prorab_this_h_objs): $(d)%.o: $(d)% $(prorab_cflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cflags) $$<)
$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command)

        # compile .S static pattern rule
        $(prorab_this_as_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_asflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_as) $(if $(filter true,$(this_as_supports_deps_gen)),-MD "$$(patsubst %.o,%.d,$$@)") -o "$$@" $(prorab_asflags) $$<)
$(if $(filter true,$(this_as_supports_deps_gen)),$(.RECIPEPREFIX)$(a)$(prorab_private_d_file_sed_command))

        # include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_objs))))

        clean::
$(.RECIPEPREFIX)$(a)rm -rf $(prorab_this_obj_dir)
    endef

    define prorab-private-link-rules
        $(if $(prorab_this_obj_dir),,$(error prorab_this_obj_dir is not defined))

        $(eval prorab_ldflags := $(this_ldflags) $(prorab_private_ldflags))
        $(eval prorab_ldlibs := $(this_ldlibs))

        $(eval prorab_ldargs_file := $(prorab_this_obj_dir)ldargs.txt)

        $(call prorab-private-args-file-rules, $(prorab_ldargs_file),$(this_cc) $(prorab_ldflags) $(prorab_ldlibs))

        all: $(prorab_this_name)

        # link rule
        $(prorab_this_name): $(prorab_this_objs) $(prorab_ldargs_file) $(prorab_objs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;31mlink\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "link $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $(d)$(prorab_private_out_dir)
$(.RECIPEPREFIX)$(a)(cd $(d) && $(this_ld) $(prorab_ldflags) $$(filter %.o,$$^) $(prorab_ldlibs) -o "$(prorab_this_name)")

        clean::
$(.RECIPEPREFIX)$(if $(filter true,$(prorab_msys)), \
                    $(a)rm -f $(prorab_this_name).a \
                )
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_name)
    endef

    # if there are no any sources in this_srcs then just install headers, no need to build binaries
    define prorab-build-lib
        $(prorab-private-lib-install-headers-rule)
        $(if $(this_srcs)$(this_c_srcs)$(this_cxx_srcs), \
                $(prorab-private-compile-rules) \
                $(prorab-private-lib-static-library-rule) \
                $(if $(filter $(this_static_lib_only),true), \
                    , \
                        $(prorab-private-dynamic-lib-specific-rules) \
                        $(prorab-private-link-rules) \
                    ) \
                , \
            )
    endef

    define prorab-build-app
        $(prorab-private-app-specific-rules)
        $(prorab-private-compile-rules)
        $(prorab-private-link-rules)
    endef

endif # ~include guard

$(if $(filter $(prorab_this_makefile),$(prorab_included_makefiles)), \
        \
    , \
        $(eval prorab_included_makefiles += $(abspath $(prorab_this_makefile))) \
    )

$(eval $(prorab-clear-this-vars))
