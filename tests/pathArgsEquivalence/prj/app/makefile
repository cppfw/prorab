#Main prorab include, should go first in every makefile
include $(d)../../../../src/prorab.mk

#Input variable defining the name of the application.
#It will be used to name the final executable.
this_name := nopapp

#Input variable which lists source files to compile.
#In this case we call to 'prorab-src-dir' function which finds all the .cpp and .c
#files under specified directory (which is 'src' in our case).
this_srcs := $(call prorab-src-dir,src)

#Input variable defining all the libraries we chould link against.
this_ldlibs += -lstdc++

#Input variable defining a;; flags to be passed to linker
this_ldflags += -L$(d)../app

#Input variable defining flags passed to the compiler
this_cxxflags += -Werror -O2 -g
this_cxxflags += -I$(d)../app

this_cflags += -I$(d)../app

#Call to 'prorab-build-app' macro defines all needed rules to build the application.
#All the needed input variables defined above are used by this macro.
$(eval $(prorab-build-app))

#Here we don't need the input variables anymore, so we can reset those.
#Call to 'prorab-clear-this-vars' clears all the variables with 'this_' prefix.
$(eval $(prorab-clear-this-vars))


#Here we can start definition of another app to build if needed.
#I.e. define needed input variables and then call to one of 'prorab-build-*' macros.
