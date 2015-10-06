#Building C++ application

To build a C++ application with prorab we can use a *prorab-build-app* definition.

But before we have to define some input variables if needed:
- *this_name* - name of the application. It will be used to generate the output binary filename.
- *this_cflags* - flags passed to compiler
- *this_ldflags* - flags passed to linker
- *this_ldlibs* - libs passed to linker
- *this_srcs* - list of sources

After invokation of *prorab-build-app* there are following variables defined:
- *prorab_this_name* - resulting name of the binary file (for example on Windows it will have .exe extension appended)
- *prorab_this_objs* - list of generated object files

Example:

```
include prorab.mk

this_name := myapp

this_cflags += -Wall
this_cflags += -DDEBUG

this_srcs += main.cpp myapp.cpp

$(eval $(prorab-build-app))
```
