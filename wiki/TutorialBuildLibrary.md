# Building C/C++ library

To build a C/C++ library with prorab we can use a `prorab-build-lib` macro.

But before we have to set some input variables if needed:
- `this_soname` - 'so' name for shared library, for example 0.
- `this_dot_hxx` - file suffix for C++ header files. Defaults to `.hpp`.
- `this_headers_dir` - header files root directory, all headers from this directory subtree will be installed by `make install`. The directory is relative to the `makefile` directory. Can be empty.
- `this_static_lib_only` - build only static library if equals to `true`. Otherwise, both static and dynamic libraries will be built.
- `this_ar` - archiver program for creating static libraries. By default equals to value of `AR` variable.
- `this_name`, `this_cc`, `this_cxx`, `this_dot_cxx`, `this_srcs`, `this_cflags`, `this_cxxflags`, `this_ldflags`, `this_ldlibs`, `this_cppflags`, `this_out_dir`, `this_no_install` - same as for [application](TutorialBuildApplication.md).

Note: `this_ldlibs` and `this_ldflags` are separated because sometimes order of linker flags, object files and libraries matters. So, linker flags go first, then go object files and then go linker libs.

After invocation of `prorab-build-lib` there are following variables defined:
- `prorab_this_name` - resulting name of the binary file.
- `prorab_this_so_name` - name of the so-named library.
- `prorab_this_static_lib` - name of the static library file.
- `prorab_this_objs` - list of generated object files.

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

**prorab** will define an `install` target for the library.

Note, that it only installs `.h` header files and files with suffix defined by `this_dot_hxx` variable to the `PREFIX/include` directory.

Shared and static library files are installed to `PREFIX/lib` directory.

`PREFIX` equals to `/usr/local` by default.
