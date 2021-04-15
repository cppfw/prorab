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

    # check if running minimal supported GNU make version
    prorab_min_gnumake_version := 3.81
    ifeq ($(filter $(prorab_min_gnumake_version),$(firstword $(sort $(MAKE_VERSION) $(prorab_min_gnumake_version)))),)
        $(error GNU make $(prorab_min_gnumake_version) or higher is needed, but found only $(MAKE_VERSION))
    endif

    # check that prorab.mk is the first file included
    ifneq ($(words $(MAKEFILE_LIST)),2)
        $(error prorab.mk is not a first include in the makefile, include prorab.mk should be the very first thing done in the makefile.)
    endif

    ###############################
    # define arithmetic functions #

    # get number from variable
    prorab-num = $(words $1)

    # add two variables
    prorab-add = $1 $2

    # increment variable
    prarab-inc = x $1

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
    # NOTE: filter-out of empty strings from input path is needed when path is supplied with preceding or trailing spaces, to prevent searching from root directory also.
    prorab-rwildcard = $(patsubst $(d)%,%,$(call prorab-private-rwildcard, $(d)$(filter-out ,$1),$2))

    # function to find all source files from specified directory recursively
    prorab-src-dir = $(call prorab-rwildcard,$1,*$(this_dot_cxx) *.c *.S)

    # function to find all header files from specified directory recursively
    prorab-hdr-dir = $(call prorab-rwildcard,$1,*$(this_dot_hxx) *.h)

    # function which clears all 'this_'-prefixed variables and sets default values
    define prorab-clear-this-vars

        # need empty line here to avoid merging with adjacent macro instantiations

        # clear all vars
        $(foreach var,$(filter this_%,$(.VARIABLES)),$(eval $(var) := ))

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
        $(eval this_cxxflags := $(CXXFLAGS))
        $(eval this_asflags := $(ASFLAGS))
        $(eval this_ldflags := $(LDFLAGS))
        $(eval this_ldlibs := $(LDLIBS))

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    #############
    # variables #

    prorab_root_makefile := $(abspath $(word $(call prorab-num,$(call prorab-dec,$(MAKEFILE_LIST))),$(MAKEFILE_LIST)))
    prorab_root_dir := $(dir $(prorab_root_makefile))

    prorab_this_makefile := $(prorab_root_makefile)

    d := $(dir $(prorab_this_makefile))

    # define a blank variable
    prorab_blank :=

    # define tab character
    prorab_tab := $(prorab_blank)	$(prorab_blank)

    # defiane space character
    prorab_space := $(prorab_blank) $(prorab_blank)

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

    # set library suffix
    ifeq ($(os), windows)
        dot_so := .dll
    else ifeq ($(os), macosx)
        dot_so := .dylib
    else
        dot_so := .so
    endif

    ifeq ($(os), windows)
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
        $(eval config_dir := $(abspath $(d)$(filter-out ,$1))/) # filter-out is needed to trim possible leading and trailing spaces
        $(call prorab-private-config, $(config))
    endef

    define prorab-config-default
        $(if $1,,$(error no default config name argument is given to prorab-config-default macro))

        $(if $(filter-out default,$(config)), \
                $(error 'config=$(config)' variable is not set to 'default', unable to apply default config using prorab-config-default macro) \
            )

        $(eval override config := $(filter-out ,$1))
        $(eval override c := $(config))
        $(call prorab-private-config, $(config))
    endef

    ################################
    # makefile inclusion functions #

    # for storing list of included makefiles
    prorab_included_makefiles :=

    define prorab-include

        # need empty line here to avoid merging with adjacent macro instantiations

        # NOTE: filter-out is needed to trim spaces from input parameter $1
        $(eval prorab_private_path_to_makefile := $(d)$(filter-out ,$1))

        # if makefile is already included do nothing
        $(if $(filter $(abspath $(prorab_private_path_to_makefile)),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(abspath $(prorab_private_path_to_makefile))) \
                $(call prorab-private-include,$(prorab_private_path_to_makefile)) \
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-try-include

        # need empty line here to avoid merging with adjacent macro instantiations

        # NOTE: filter-out is needed to trim spaces from input parameter $1
        $(eval prorab_private_path_to_makefile := $(d)$(filter-out ,$1))

        # if makefile is already included do nothing
        $(if $(filter $(abspath $(prorab_private_path_to_makefile)),$(prorab_included_makefiles)), \
            , \
                $(eval prorab_included_makefiles += $(abspath $(prorab_private_path_to_makefile))) \
                $(call prorab-private-include,$(prorab_private_path_to_makefile),-) \
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    # for storing previous prorab_this_makefile when including other makefiles
    prorab_private_this_makefiles :=

    # include file with correct current directory
    define prorab-private-include

        # need empty line here to avoid merging with adjacent macro instantiations

        prorab_private_this_makefiles += $$(prorab_this_makefile)
        prorab_this_makefile := $(abspath $1)
        d := $$(dir $$(prorab_this_makefile))
        $2include $1
        prorab_this_makefile := $$(lastword $$(prorab_private_this_makefiles))
        d := $$(dir $$(prorab_this_makefile))
        prorab_private_this_makefiles := $$(wordlist 1,$$(call prorab-num,$$(call prorab-dec,$$(prorab_private_this_makefiles))),$$(prorab_private_this_makefiles))

        # need empty line here to avoid merging with adjacent macro instantiations

    endef
    # !!!NOTE: the trailing empty line in 'prorab-private-include' definition is needed so that include files would be separated from each other

    # include all makefiles in subdirectories
    define prorab-include-subdirs

        # need empty line here to avoid merging with adjacent macro instantiations

        $(eval prorab_private_makefilename := $(if $(filter-out ,$1),$1,makefile))

        $(foreach path,$(wildcard $(d)*/$(prorab_private_makefilename)), \
                $$(eval $$(call prorab-include,$(patsubst $(d)%,%,$(path)))) \
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    # TODO: deprecated, remove
    prorab-build-subdirs = $(prorab-include-subdirs)

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
$(.RECIPEPREFIX)$(a)$(MAKE) clean
$(.RECIPEPREFIX)$(a)$(MAKE)

    endef
    $(eval $(prorab-private-rules))

    ####################################
    # prorab rule generation functions #

    # this is to make sure out dir ends with /
    prorab_private_out_dir = $(if $(this_out_dir),$(if $(patsubst %/,,$(this_out_dir)),$(this_out_dir)/,$(this_out_dir)))

    define prorab-private-app-specific-rules

        # need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_private_ldflags := )

        $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)$(this_name)$(dot_exe)))

        $(eval prorab_this_symbolic_name := $(prorab_this_name))

        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_this_name)
$(.RECIPEPREFIX)$(a) \
                    install -d $(DESTDIR)$(PREFIX)/bin/ && \
                    install $(prorab_this_name) $(DESTDIR)$(PREFIX)/bin/ \
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(DESTDIR)$(PREFIX)/bin/$(notdir $(prorab_this_name)) \
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-dynamic-lib-specific-rules-nix-systems

        # need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_soname),,$(error this_soname is not defined))

        $(eval prorab_this_symbolic_name := $(abspath $(d)$(prorab_private_out_dir)lib$(this_name)$(dot_so)))

        $(if $(filter macosx,$(os)), \
                $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)lib$(this_name).$(this_soname)$(dot_so))) \
                $(eval prorab_private_ldflags := -dynamiclib -Wl,-install_name,$(prorab_this_name),-headerpad_max_install_names,-undefined,dynamic_lookup,-compatibility_version,1.0,-current_version,1.0) \
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
                install:: $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name))
$(.RECIPEPREFIX)$(a)install -d $(DESTDIR)$(PREFIX)/lib/ && \
                        (cd $(DESTDIR)$(PREFIX)/lib/ && ln -f -s $(notdir $(prorab_this_name)) $(notdir $(prorab_this_symbolic_name)))
            )

        $(if $(filter $(this_no_install),true),
                ,
                $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)): $(prorab_this_name)
$(.RECIPEPREFIX)$(a) \
                        install -d $(DESTDIR)$(PREFIX)/lib/ && \
                        install $(prorab_this_name) $(DESTDIR)$(PREFIX)/lib/
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_symbolic_name))
            )

        clean::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_symbolic_name)

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-lib-install-headers-rule

        # need empty line here to avoid merging with adjacent macro instantiations

        # NOTE: Use 'abspath' to avoid second trailing slash in case 'this_headers_dir' already contains one.
        #       It is ok to use 'abspath' here because $(d) is absolute path anyway.
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

        # gerenarte dummy source files for each header (for testing headers compilation)
        $(prorab_this_hxx_test_srcs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.test_cpp : $(prorab_private_headers_dir)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        $(prorab_this_h_test_srcs): $(prorab_this_obj_dir)$(prorab_private_objspacer)%.test_c : $(prorab_private_headers_dir)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # compile .hpp.test_cpp static pattern rule
        $(prorab_this_hxx_test_objs): $(d)%.o: $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP $(filter -std=c++%,$(this_cxxflags)) -o "$$@" $$<

        # compile .h.test_c static pattern rule
        $(prorab_this_h_test_objs): $(d)%.o: $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $$<

        # include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_hxx_test_objs) $(prorab_this_h_test_objs))))

        # NOTE: testing headers is disabled for windows due to problems with absolute paths in windows starting with drive letter, like C:/
        $(if $(filter $(this_no_install),true),
                ,
                $(if $(filter windows,$(os)),
                        ,
                        test:: $(prorab_this_hxx_test_objs) $(prorab_this_h_test_objs)
                    )
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
                    install -d $(DESTDIR)$(PREFIX)/include/$(prorab_private_install_dir)$$$$(dirname $$$$i) && \
                    install -m 644 $(prorab_private_headers_dir)$$$$i $(DESTDIR)$(PREFIX)/include/$(prorab_private_install_dir)$$$$i; \
                done
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)for i in $(prorab_private_headers) $(this_install_c_hdrs) $(prorab_private_cxx_hdrs); do \
                    path=$$$$(echo $(prorab_private_install_dir)$$$$i | cut -d "/" -f1) && \
                    [ ! -z "$$$$path" ] && rm -rf $(DESTDIR)$(PREFIX)/include/$$$$path; \
                done
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-dynamic-lib-specific-rules

        # need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(if $(filter windows,$(os)), \
                $(eval prorab_this_name := $(abspath $(d)$(prorab_private_out_dir)lib$(this_name)$(dot_so))) \
                $(eval prorab_private_ldflags := -shared -s -Wl,--out-implib=$(abspath $(d)$(prorab_private_out_dir)lib$(this_name)$(dot_so).a)) \
                $(eval prorab_this_symbolic_name := $(prorab_this_name)) \
            , \
                $(prorab-private-dynamic-lib-specific-rules-nix-systems) \
            )

        # in Cygwin and Msys2 the .dll files go to /usr/bin and .a and .dll.a files go to /usr/lib
        $(if $(filter $(this_no_install),true),
                ,
                install:: $(if $(filter windows,$(os)), $(prorab_this_name), $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)))
$(if $(filter windows,$(os)),$(.RECIPEPREFIX)$(a) \
                    install -d $(DESTDIR)$(PREFIX)/bin/ && \
                    install $(prorab_this_name) $(DESTDIR)$(PREFIX)/bin/ && \
                    install -d $(DESTDIR)$(PREFIX)/lib/ && \
                    install $(prorab_this_name).a $(DESTDIR)$(PREFIX)/lib/ )
$(if $(filter macosx,$(os)),$(.RECIPEPREFIX)$(a) \
                    install_name_tool -id "$(PREFIX)/lib/$(notdir $(prorab_this_name))" $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) )
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(if $(filter windows,$(os)),
$(.RECIPEPREFIX)$(a) \
                    rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name).a) && \
                    rm -f $(DESTDIR)$(PREFIX)/bin/$(notdir $(prorab_this_name)) \
                    ,
$(.RECIPEPREFIX)$(a)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_name)) \
                )
            )

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-lib-static-library-rule

        # need empty line here to avoid merging with adjacent macro instantiations

        $(if $(this_name),,$(error this_name is not defined))

        $(eval prorab_this_static_lib := $(abspath $(d)$(prorab_private_out_dir)lib$(this_name).a))

        all: $(prorab_this_static_lib)

        clean::
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_static_lib)

        $(if $(filter $(this_no_install),true),
                ,
                install:: $(prorab_this_static_lib)
$(.RECIPEPREFIX)$(a) \
                    install -d $(DESTDIR)$(PREFIX)/lib/ && \
                    install -m 644 $(prorab_this_static_lib) $(DESTDIR)$(PREFIX)/lib/ \
            )

        $(if $(filter $(this_no_install),true),
                ,
                uninstall::
$(.RECIPEPREFIX)$(a)rm -f $(DESTDIR)$(PREFIX)/lib/$(notdir $(prorab_this_static_lib)) \
            )

        # static library rule
        # NOTE: need to remove the lib before creating, otherwise files will just be appended to the existing .a archive.
        $(prorab_this_static_lib): $(prorab_this_objs) $(prorab_objs_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;33mcreate static library\e[0m $$(notdir $$@)\n" || printf "create static library $$(notdir $$@)\n"
$(.RECIPEPREFIX)$(a)rm -f $$@
$(.RECIPEPREFIX)$(a)$(this_ar) cr $$@ $$(filter %.o,$$^)

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-args-file-rules

        # need empty line here to avoid merging with adjacent macro instantiations

        $1: $(if $(shell echo '$2' | cmp $1 2>/dev/null), phony,)
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)touch $$@
$(.RECIPEPREFIX)$(a)echo '$2' > $$@

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-compile-rules

        # need empty line here to avoid merging with adjacent macro instantiations

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

        # gerenarte dummy source files for each header (for testing headers compilation)
        $(prorab_this_hxx_srcs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.hdr_cpp : $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        $(prorab_this_h_srcs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.hdr_c : $(d)%
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;90mgenerate\e[0m $$(patsubst $(prorab_root_dir)%,%,$$@)\n" || printf "generate $$(patsubst $(prorab_root_dir)%,%,$$@)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' > $$@
$(.RECIPEPREFIX)$(a)echo '#include "$$<"' >> $$@
$(.RECIPEPREFIX)$(a)echo 'int main(int c, const char** v){(void)c;(void)v;return 0;}' >> $$@

        # compile .cpp static pattern rule
        $(prorab_this_cxx_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_cxxflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cxxflags) $$<

        # compile .hpp.hdr_cpp static pattern rule
        $(prorab_this_hxx_objs): $(d)%.o: $(d)% $(prorab_cxxflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[1;34mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cxx) --language c++ -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cxxflags) $$<

        # compile .c static pattern rule
        $(prorab_this_c_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_cflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cflags) $$<

        # compile .h.hdr_c static pattern rule
        $(prorab_this_h_objs): $(d)%.o: $(d)% $(prorab_cflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_cc) --language c -c -MF "$$(patsubst %.o,%.d,$$@)" -MD -MP -o "$$@" $(prorab_cflags) $$<

        # compile .S static pattern rule
        $(prorab_this_as_objs): $(prorab_this_obj_dir)$(prorab_this_obj_spacer)%.o: $(d)% $(prorab_asflags_file)
$(.RECIPEPREFIX)@test -t 1 && printf "\e[0;35mcompile\e[0m $$(patsubst $(prorab_root_dir)%,%,$$<)\n" || printf "compile $$(patsubst $(prorab_root_dir)%,%,$$<)\n"
$(.RECIPEPREFIX)$(a)mkdir -p $$(dir $$@)
$(.RECIPEPREFIX)$(a)$(this_as) $(if $(filter true,$(this_as_supports_deps_gen)),-MD "$$(patsubst %.o,%.d,$$@)") -o "$$@" $(prorab_asflags) $$<

        # include rules for header dependencies
        include $(wildcard $(addsuffix *.d,$(dir $(prorab_this_objs))))

        clean::
$(.RECIPEPREFIX)$(a)rm -rf $(prorab_this_obj_dir)

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-private-link-rules

        # need empty line here to avoid merging with adjacent macro instantiations

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
$(.RECIPEPREFIX)$(a)$(this_ld) $(prorab_ldflags) $$(filter %.o,$$^) $(prorab_ldlibs) -o "$$@"

        clean::
$(.RECIPEPREFIX)$(if $(filter windows,$(os)), \
                    $(a)rm -f $(prorab_this_name).a \
                )
$(.RECIPEPREFIX)$(a)rm -f $(prorab_this_name)

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    # if there are no any sources in this_srcs then just install headers, no need to build binaries
    define prorab-build-lib

        # need empty line here to avoid merging with adjacent macro instantiations

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

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

    define prorab-build-app

        # need empty line here to avoid merging with adjacent macro instantiations

        $(prorab-private-app-specific-rules)
        $(prorab-private-compile-rules)
        $(prorab-private-link-rules)

        # need empty line here to avoid merging with adjacent macro instantiations

    endef

endif # ~include guard

$(if $(filter $(prorab_this_makefile),$(prorab_included_makefiles)), \
        \
    , \
        $(eval prorab_included_makefiles += $(abspath $(prorab_this_makefile))) \
    )

$(eval $(prorab-clear-this-vars))
