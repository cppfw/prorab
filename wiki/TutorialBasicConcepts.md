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


##Prorab definitions and variables naming conventions

All **prorab** definitions are named using kebab-case and start with **prorab-** prefix.


##Building subprojects with prorab

As said before, **prorab** allows 'cascading' of makefiles. Say, you have two subdirectories in your project: "app" and "test". And both those directories contain some subproject which can be built independently. So, in both those directories there are project makefiles.

Now, if we want to have a makefile in project root directory which builds both those subprojects, we can use *prorab-build-subdirs* definition and root makefile would look like this:

```
include prorab.mk

$(eval $(prorab-build-subdirs))
```

And that's it. Note, that parallel build is still supported.


##Prorab definitions and input
