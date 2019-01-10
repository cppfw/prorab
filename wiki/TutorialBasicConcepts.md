# Basic concepts

**prorab** is a non-recursive *GNU make*-based build system. Essentially it just provides
convenient definitions for writing clean makefiles.

The main feature of **prorab** is that it allows having independent makefiles
in several subdirectories of the project and at the same time there can be
a main makefile in root directory of the project which builds all those subprojects.
And parallel building is still supported in that case.

Also, **prorab** provides some predefined rules for easy building of C/C++ applications
and libraries.


## Including prorab into the makefile

Including **prorab** in the make file is simple and obvious, just add the following directive
in the beginning of the makefile

```
include prorab.mk
```

Basically, all makefiles in the project are supposed to use **prorab** and have this include directive as a first include.

Right after inclusion of *prorab.mk* there will be following variables defined:
- *prorab_this_dir* - directory where this makefile resides.
- *d* - shorthand alias for *prorab_this_dir*
- *prorab_os* - operating system where makefile is run, can be *linux*, *macosx*, *windows*.
- *os* - shorthand alias for *prorab_os*
- *prorab_lib_extension* - typical extension for dynamically linked libraries in the OS (.dll, .so, .dylib).
- *soext* - shorthand alias for *prorab_lib_extension*

## Prorab definitions and variables naming conventions

All **prorab** definitions are named using kebab-case and start with **prorab-** prefix.
Variables defined by **prorab** are named using underscore case and start with **prorab_** prefix.
Input variables are named using underscore case and start with **this_** prefix.


## Building subprojects with prorab

As said before, **prorab** allows 'cascading' of makefiles. Say, you have two subdirectories in your project: "app" and "test". And both those directories contain some subproject which can be built independently. So, in both those directories there are project makefiles.

Now, if we want to have a makefile in project root directory which builds both those subprojects, we can use *prorab-build-subdirs* definition and root makefile would look like this:

```
include prorab.mk

$(eval $(prorab-build-subdirs))
```

And that's it. This will invoke the same target on every subdirectory which has file named `makefile`. Note, that parallel build is still supported since it is a non-recursive technique.


## Prorab definitions and input variables

Before invoking most of the **prorab** definitions one has to set some input variables for the definition.
For example:

```
this_name := AppName
this_cflags += -I$(d)../src -DDEBUG

$(eval $(prorab-build-app))
```

After invoking some **prorab** definition there might be some output variables defined like, for example, *prorab_this_name* which represents the resulting filename of the created binary.

One can use *prorab-clear-this-vars* definition to clear all variables which have *this_* prefix. Thus, several **prorab** build definitions can be used in the same makefile:

```
this_name := AppName
this_ldlibs += -lsomelib1
this_cxxflags += -I$(d)../src -DDEBUG
this_srcs := main1.cpp MyClass1.cpp

$(eval $(prorab-build-app))

$(eval $(prorab-clear-this-vars))

this_name := AnotherAppName
this_ldlibs += -lsomelib1
this_cxxflags += -I$(d)../src -DDEBUG
this_srcs := main2.cpp MyClass2.cpp

$(eval $(prorab-build-app))
```


## Including other makefiles

In order to include some other makefile one can use *prorab-include* function. This function will check if the makefile was already included or not and only include it if necessary.

Example:

```
...

#add dependency on some other artifact, e.g. libstuff which is built by another makefile

$(prorab_this_name): $(abspath $(d)../stuff/libstuff$(soext))


#include makefile for building libstuff

$(eval $(call prorab-include,$(d)../stuff/makefile))

...
```


## Echoing commands from recipes

All commands in **prorab** recipes are prefixed with @ by default, but it is possible to make it to be verbose by setting the _verbose_ variable to _true_, like this:

```
make verbose=true
```


## Defining several builds in one makefile

It is possible to define several builds in a single `makefile`. Right before starting definition of a next build one has to clear all `this_` prefixed varibales, so that those do not go to the next build from previous build. To do that, there is a `prorab-clear-this-vars` definition which can be invoked using `$(eval ...)` as usual. Note, that this definition is automatically invoked inside of `prorab.mk`, so it is not necessary to invoke it for the very first build of the `makefile`.

```
include prorab.mk

this_name := app1
this_srcs += app1.cpp

$(eval $(prorab-build-app))


$(eval $(prorab-clear-this-vars))


this_name := app2
this_srcs += app2.cpp

$(eval $(prorab-build-app))
```


# Adding all source files from all subdirectories to the build

It is often needed in the build to use all source files from a certain directory subtree. There is a `prorab-src-dir` function for that. The directory to search for source files is relative to the `makefile` directory. Only `.c` and `.cpp` files are searched.

```
include prorab.mk

this_name := app

# all our sources are in `src` directory
this_srcs := $(call prorab-src-dir,src)

this_ldlibs += -lstdc++
this_cxxflags += -Werror -O2 -g

$(eval $(prorab-build-app))
```
