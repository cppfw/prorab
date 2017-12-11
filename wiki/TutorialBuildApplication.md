# Building C++ application

To build a C++ application with prorab we can use a *prorab-build-app* definition.

But before we have to define some input variables if needed:
- *this_name* - name of the application. It will be used to generate the output binary filename.
- *this_cflags* - flags passed to C compiler, ok to use += right a way.
- *this_cxxflags* - flags passed to C++ compiler, ok to use += right a way.
- *this_ldflags* - flags passed to linker, ok to use += right a way.
- *this_ldlibs* - libs passed to linker, ok to use += right a way.
- *this_srcs* - list of sources, ok to use += right a way.

Note: *this_ldlibs* and *this_ldflags* are separated because sometimes order of linker flags, object files and libraries matters. So, linker flags go first, then go object files and then go linker libs.

After invocation of *prorab-build-app* there are following variables defined:
- *prorab_this_name* - resulting name of the binary file (for example on Windows it will have .exe extension appended)
- *prorab_this_objs* - list of generated object files

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
