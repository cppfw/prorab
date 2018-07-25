# Building C++ library

To build a C++ library with prorab we can use a *prorab-build-lib* definition.

But before we have to define some input variables if needed:
- *this_soname* - 'so' name for shared library, for example 0.
- *this_name*, *this_cc*, *this_cxx*, *this_srcs*, *this_cflags*, *this_cxxflags*, *this_ldflags*, *this_ldlibs*, *this_cppflags* - same as for [application](TutorialBuildApplication.md).

Note: *this_ldlibs* and *this_ldflags* are separated because sometimes order of linker flags, object files and libraries matters. So, linker flags go first, then go object files and then go linker libs.

After invocation of *prorab-build-lib* there are following variables defined:
- *prorab_this_name* - resulting name of the binary file.
- *prorab_this_symbolic_name* - name of the symbolic link to a shared library.
- *prorab_this_staticlib* - name of the static library file.
- *prorab_this_objs* - list of generated object files.

Example:

```
include prorab.mk

this_name := mylib

this_soname := 0

this_cxxflags += -Wall
this_cxxflags += -DDEBUG
this_cflags += -Wall
this_ldlibs += -lpthread

this_srcs += main.cpp myapp.cpp

$(eval $(prorab-build-lib))
```

## Install target

**prorab** will define a *install* target for the library.

Note, that it only installs *.hpp* header files from _subdirectories_ to *PREFIX/include* directory.

Shared and static library files are installed to *PREFIX/lib* directory.

*PREFIX* equals to */usr/local* by default.
