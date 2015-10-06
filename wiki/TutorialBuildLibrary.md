#Building C++ library

To build a C++ library with prorab we can use a *prorab-build-lib* definition.

But before we have to define some input variables if needed:
- *this_name* - name of the application. It will be used to generate the output binary filename.
- *this_soname* - 'so' name for shared library, for example 0.
- *this_cflags* - flags passed to compiler, ok to use += right a way.
- *this_ldflags* - flags passed to linker, ok to use += right a way.
- *this_ldlibs* - libs passed to linker, ok to use += right a way.
- *this_srcs* - list of sources, ok to use += right a way.

After invokation of *prorab-build-lib* there are following variables defined:
- *prorab_this_name* - resulting name of the binary file.
- *prorab_this_symbolic_name* - name of the symbolic link to a shared library.
- *prorab_this_staticlib* - name of the static library file.
- *prorab_this_objs* - list of generated object files.

Example:

```
include prorab.mk

this_name := mylib

this_soname := 0

this_cflags += -Wall
this_cflags += -DDEBUG
this_ldlibs += -lpthread

this_srcs += main.cpp myapp.cpp

$(eval $(prorab-build-lib))
```

##Install target

**prorab** will define a *install* target for the library.
Note, that it only installs *.hpp* header files from _subdirectories_ to PREFIX/include directory.
Shared and static library files are installed to PREFIX/lib directory.
