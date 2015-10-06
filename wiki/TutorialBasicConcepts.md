#Basic concepts

**prorab** is a *GNU make*-based build system. Essentially it just provides
convenient definitions for writing clean makefiles.

The main feature of prorab is that it allows having independent makefiles
in several subdirectories of the project and at the same time there can be
a main makefile in root directory of the project which builds all those subprojects.
And in parallel building is still supported in that case.

Also, **prorab** provides some predefined rules for easy building of C++ applications
and libraries.


##Including prorab into the makefile

Including prorab in the make file is simple and obvious, just add the following directive
in the beginning of the makefile

```
include prorab.mk
```

Basically, all makefiles in the project are supposed to use **prorab** and have this include directive as a first include.

