" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=make:
sil! set lz
exe 'r ' . expand("<sfile>")
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g;\<ccc\>;s;;\=expand("%:t:r");g
set makeprg=make
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
sil! 1d
sil! set nolz
sil! update | edit
finish
" <AUTO_VIM_SCRIPT_TAG 2>
# vi: set ts=4 sts=4 sw=4 noet:

.DEFAULT_GOAL := all
AR  := ar
CC  := gcc
CXX := g++
RM  := rm -rf
RANLIB    := ranlib
CCFLAGS   := -W -Werror -Wall -g
INCLUDE   :=
PREREQS   :=
OBJECTS   :=
LIBRARIES :=
TARGETS   :=
LOADLIBS  :=

#-------------------------------------------------------------------------------
# util
#-------------------------------------------------------------------------------

util := libutil.a
util_HELP := Helper utilities
$(util)_SOURCES :=
$(util)_SOURCES += util1.c
$(util)_SOURCES += util2.cpp
$(util)_OBJECTS := $(addsuffix .o, $(basename $($(util)_SOURCES)))
# $(util)_PREREQS := $(addsuffix .d, $(basename $($(util)_SOURCES)))
$(util)_LOADLIBS :=

# $($(util)_OBJECTS) : INCLUDE += -I.
$(util) : $($(util)_OBJECTS)

# PREREQS += $($(util)_PREREQS)
# OBJECTS += $($(util)_OBJECTS)
# LIBRARIES += $(util)
# LOADLIBS += -L. -lutil

libutil.a: $($(util)_PREREQS) $($(util)_SOURCES)
	$(AR) r $@ $($(util)_OBJECTS)
	$(RANLIB) $@

-include $($(util)_PREREQS)

#-------------------------------------------------------------------------------
# modules for all
#-------------------------------------------------------------------------------

HELPER_SOURCES :=
HELPER_SOURCES += helper1.c
HELPER_SOURCES += helper2.cpp

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

main := main
main_HELP := Entry point
$(main)_SOURCES := main.c
# $(main)_SOURCES += $(HELPER_SOURCES)
$(main)_OBJECTS := $(addsuffix .o, $(basename $($(main)_SOURCES)))
$(main)_PREREQS := $(addsuffix .d, $(basename $($(main)_SOURCES)))
$(main)_LOADLIBS :=

# $($(main)_OBJECTS) : INCLUDE += -I.
$(main) : $($(main)_OBJECTS)

PREREQS += $($(main)_PREREQS)
OBJECTS += $($(main)_OBJECTS)
TARGETS += $(main)

main: $($(main)_PREREQS) $($(main)_SOURCES) $($(main)_OBJECTS) $(LIBRARIES)
	$(CXX) -o $@ $($(main)_OBJECTS) $($(main)_LOADLIBS) $(LOADLIBS)

-include $($(main)_PREREQS)

#-------------------------------------------------------------------------------
# make stuff
#-------------------------------------------------------------------------------

%.d: %.c
	$(CC) $(CCFLAGS) $(INCLUDE) -M $< > $@

%.d: %.cpp
	$(CXX) $(CCFLAGS) $(INCLUDE) -M $< > $@

%.o: %.c
	$(CC) $(CCFLAGS) $(INCLUDE) -c  $(addsuffix .c, $(basename $@))

%.o: %.cpp
	$(CXX) $(CCFLAGS) $(INCLUDE) -c $(addsuffix .cpp, $(basename $@))

.PHONY: all
all: $(TARGETS)

.PHONY: rmobjects
rmobjects:
	$(RM) $(OBJECTS)

.PHONY: clean
clean: rmobjects
	$(RM) $(TARGETS) $(LIBRARIES)

.PHONY: reallyclean
reallyclean: clean
	$(RM) $(PREREQS)

echo-%:
	@echo $($*)

" <AUTO_VIM_SCRIPT_TAG 3>
