# Building C/C++ application

To build a C/C++ application with prorab we can use a `prorab-build-app` macro.

But before we have to define some input variables if needed:
- `this_name` - name of the application. It will be used to generate the output binary filename.
- `this_srcs` - list of sources, ok to use += right a way.
- `this_cc` - C compiler to use. By default equals to the value of `CC` variable.
- `this_cxx` - C++ compiler to use. By default equals to the value of `CXX` variable.
- `this_dot_cxx` - file suffix for C++ files. Defaults to `.cpp`.
- `this_cflags` - flags passed to C compiler, ok to use += right a way. By default equals to value of `CFLAGS` variable.
- `this_cxxflags` - flags passed to C++ compiler, ok to use += right a way. By default equals to value of `CXXFLAGS` variable.
- `this_ldflags` - flags passed to linker, ok to use += right a way. By default equals to value of `LDFLAGS` variable.
- `this_ldlibs` - libs passed to linker, ok to use += right a way. By default equals to value of `LDLIBS` variable.
- `this_cppflags` - C preprocessor flags, ok to use += right a way. By default equals to value of `CPPFLAGS` variable.
- `this_out_dir` - output directory relative to the directory of `makefile`. Can be empty.
- `this_no_install` - tells whether `install` and `uninstall` targets are needed for this build. If `true` then no `install` and `uninstall` targets are generated for this build. Otherwise those targets are generated.

Note: `this_ldlibs` and `this_ldflags` are separated because sometimes order of linker flags, object files and libraries matters. So, linker flags go first, then go object files and then go linker libs.

After invocation of `prorab-build-app` there are following variables defined:
- `prorab_this_name` - resulting name of the binary file (for example on Windows it will have `.exe` suffix appended)
- `prorab_this_objs` - list of generated object files

Example:

```
include prorab.mk

this_name := myapp

this_cxxflags += -Wall
this_cxxflags += -DDEBUG
this_cflags += -Wall

this_ldlibs += -lpthread

this_srcs += main.cpp myapp.cpp legacy.c

$(eval $(prorab-build-app))
```
