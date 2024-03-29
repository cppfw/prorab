# Basic concepts

**prorab** is a non-recursive `GNU make`-based build system. Essentially it just provides
convenient definitions for writing clean makefiles.

The main feature of **prorab** is that it allows having independent makefiles
in several subdirectories of the project and at the same time there can be
a main makefile in root directory of the project which builds all those subprojects.
And parallel building is still supported in that case.

Also, **prorab** provides some predefined rules for easy building of C/C++ applications
and libraries.


## Including prorab into the makefile

Including **prorab** in the make file is simple and obvious, just add the following directive
in the beginning of the `makefile`

```makefile
include prorab.mk
```

Basically, all makefiles in the project are supposed to use **prorab** and have this include directive as a first include.

Right after inclusion of `prorab.mk` there will be following variables defined:
- `d` - directory where this `makefile` resides
- `os` - operating system where makefile is run, can be `linux`, `macosx`, `windows`. Note, that `windows` is when building under `Msys2/MinGW`.
- `dot_so` - typical suffix for dynamically linked libraries in the OS (windows: `.dll`, linux: `.so`, macosx: `.dylib`)
- `dot_exe` - typical suffix for executable files (windows: `.exe`, linux: empty, macosx: empty)
- `.RECIPEPREFIX` - this is a built-in variable of `GNU make`, but by default it is empty which means the default recipe prefix will be the tab character. Prorab explicitly sets the value of this variable to `>` character.
- `a` - this variable is either empty or set to `@` depending on value of `verbose` or `v` variables. See about verbosity below.

## Prorab macros and variables naming conventions

 - **Prorab macros** are named using hyphen-case and start with `prorab-` prefix.
 - **Output variables** are named using snake case and start with `prorab_this_` prefix.
 - **Input variables** are named using snake case and start with `this_` prefix.


## Building subprojects with prorab

As said before, **prorab** allows 'cascading' of makefiles. Say, you have two subdirectories in your project: `app` and `test`. And both those directories contain some subproject which can be built independently. So, in both those directories there are project makefiles.

Now, if we want to have a makefile in project root directory which builds both of those subprojects, we can use `prorab-include-subdirs` macro and then the root makefile would look like this:

```makefile
include prorab.mk

$(eval $(prorab-include-subdirs))
```

And that's it. This will invoke the same target on every subdirectory which has file named `makefile`. Note, that parallel build is still supported since it is a non-recursive technique.

In case the makefiles in project have different name than `makefile` then it is possible to supply the name of makefiles to include as argument:

```makefile
include prorab.mk

$(eval $(call prorab-include-subdirs, my_Makefile))
```


## Prorab macros and input variables

Before invoking most of the **prorab** macros one has to set some input variables for the macro.
For example:

```makefile
this_name := AppName
this_cflags += -I../src -DDEBUG

$(eval $(prorab-build-app))
```

After invoking some **prorab** macro there might be some output variables defined like, for example, `prorab_this_name` which represents the resulting filename of the created binary.


## Including other makefiles

In order to include some other makefile one can use `prorab-include` macro. This macro will check if the makefile was already included or not and only include it if necessary, it will also adjust the value of `d` variable for the included `makefile`.

Example:

```makefile
...

# Add dependency on some other artifact, e.g. libstuff which is built by another makefile.
# All targets generated by prorab use absolute paths, so need to use $(abspath)

$(prorab_this_name): $(abspath $(d)../stuff/libstuff$(dot_so))


# include makefile which defines rules for building the libstuff

$(eval $(call prorab-include, ../stuff/makefile))

...
```

There is also `prorab-try-include` macro which is similar to `prorab-include` but also does not fail if the `makefile` does not exist, it does nothing in this case.

Also, there is a `prorab-depend` macro which can be used to define the dependency as follows:
```makefile
$(eval $(call prorab-depend, $(prorab_this_name), ../stuff/libstuff$(dot_so)))
```


## Echoing commands from recipes

All commands in **prorab** recipes are prefixed with @ by default, but it is possible to make it to be verbose by setting the `verbose` variable to `true`, like this:

```console
make verbose=true
```
Valid values for `verbose` are `true` or `false` or not set.

The `v` is a shorthand alias for `verbose`. If `v` is not set or set to `0` or `false` then it is equivalent to `verbose=false`. Otherwise, if `v` is set to any other value it is same as `verbose=true`.
Set `verbose` variable has higher priority than set `v` variable.

Prorab uses value of `a` variable to prefix all recipe lines. The `a` variable is set by prorab to `@` or to empty value depending on verbosity.

## Defining several builds in one makefile

It is possible to define several builds in a single `makefile`. Right before starting definition of the next build one has to clear all `this_` prefixed varibales, so that those do not go to the next build from previous build. To do that, there is a `prorab-clear-this-vars` macro which can be invoked using `$(eval ...)` as usual. Note, that this macro is automatically invoked inside of `prorab.mk`, so it is not necessary to invoke it for the very first build of the `makefile`.

```makefile
include prorab.mk

this_name := app1
this_srcs += app1.cpp
$(eval $(prorab-build-app))

$(eval $(prorab-clear-this-vars))

this_name := app2
this_srcs += app2.cpp
$(eval $(prorab-build-app))
```


## Adding all source files from all subdirectories to the build

It is often needed in the build to use all source files from a certain directory subtree. There is a `prorab-src-dir` function for that. The directory to search for source files is relative to the `makefile` directory. It only searches for `.c` files and files with suffix defined by `this_dot_cxx` variable which defaults to `.cpp`.

```makefile
include prorab.mk

this_name := app

# all our sources are in `src` directory
this_srcs := $(call prorab-src-dir,src)

this_ldlibs += -lstdc++
this_cxxflags += -Werror -O2 -g

$(eval $(prorab-build-app))
```


## Using automatic number of parallel jobs

`prorab` will automatically set number of parallel jobs to the number of physical CPU threads on the system, unless `-j`/`--jobs` command line option
is given to the `make` invocation.

## Adding prorab.mk to project tree

If there is no possibility to install **prorab** to the system then it is possible to just add the `prorab.mk` to the project file tree. Then all includes of the `prorab.mk` have to be done with relative path and using the `$(d)` variable as path prefix.

```makefile
include $(d)../../prorab.mk
```
It is good to take a note in some `readme` file, or as a comment right in `prorab.mk` about which version of **prorab** you copied, so that you know if it needs update or not when new version of **prorab** comes out.


## Defining custom rules

It is often necessary to add custom rules. `GNU make` expands variables in `makefile` in two phases. During first phase it expands all variables in makefiles, except recipes. During second phase it starts executing the recipes and it expands variables in recipes right before executing, see [GNU make: Using Variables in Recipes](https://www.gnu.org/software/make/manual/html_node/Variables-in-Recipes.html). So, in order to use correct values of context dependent variables, like `$(d)`, one has to use the trick to substitue those variable values to the custom rule's recipe right away during the first phase. This is achieved by wrapping the custom rule with recipe into some temporary variable, let's say `this_rules`, and then evaluating the value of that variable.

```makefile
define this_rules

test:: $(d)my_executable_binary
>   @echo "Running my_executable_binary"
>   @$$^
>   @echo "program finished"

endef
$(eval $(this_rules))
```

Note, the use of double dollar sign in `$$^` variable, this is escaping of dollar sign so that `$^` will actually appear in the `this_rules` value at the moment of `$(eval $(this_rules))` invocation.

User can override the value of `.RECIPEPREFIX` variable to any character he/she wants. I personally recommend to explicitly use the `.RECIPEPREFIX` when writing custom rules to avoid possible errors:

```makefile
define this_rules

test:: $(d)my_executable_binary
$(.RECIPEPREFIX)@echo "Running my_executable_binary"
$(.RECIPEPREFIX)$(a)$$^
$(.RECIPEPREFIX)@echo "program finished"

endef
$(eval $(this_rules))
```

Note the use of `$(a)` variable which normally just equals to `@`.
