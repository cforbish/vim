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
TARGETS   :=
LOADLIBS  :=
DEFINES   :=
ifneq ($(ENV_NUMERIC_DEFINE),)
DEFINES += -DENV_NUMERIC_DEFINE='$(ENV_NUMERIC_DEFINE)'
endif
ifneq ($(ENV_STRING_DEFINE),)
DEFINES += -DENV_STRING_DEFINE='"$(ENV_STRING_DEFINE)"'
endif

#-------------------------------------------------------------------------------
# modules for all
#-------------------------------------------------------------------------------

HELPER_SOURCES :=

LOADLIBS += -lrt -lpthread

# #-------------------------------------------------------------------------------
# # static library goes here
# #-------------------------------------------------------------------------------
# 
# libstatic := libstatic
# static_a := $(libstatic).a
# $(libstatic)_OBJECTS :=
# $(static_a) : $($(libstatic)_OBJECTS)
# OBJECTS += $($(libstatic)_OBJECTS)
# TARGETS += $(static_a)
# 
# $(libstatic)_INCLUDE :=
# $($(libstatic)_OBJECTS) : INCLUDE +=$($(libstatic)_INCLUDE)
# 
# LOADLIBS += -L. -lstatic

# #-------------------------------------------------------------------------------
# # shared library goes here
# #-------------------------------------------------------------------------------
# 
# libshared := libshared
# shared_so := $(libshared).so
# $(libshared)_OBJECTS :=
# $(shared_so) : $($(libshared)_OBJECTS)
# OBJECTS += $($(libshared)_OBJECTS)
# TARGETS += $(shared_so)
# 
# $(libshared)_INCLUDE :=
# $($(libshared)_OBJECTS) : INCLUDE +=$($(libshared)_INCLUDE)
# 
# LOADLIBS += -ldl -L. -lshared

#-------------------------------------------------------------------------------
# tags
#-------------------------------------------------------------------------------
tags:
	ctags *.cpp *.c *.h

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

main := main
main_HELP := Entry point.
$(main)_SOURCES :=
$(main)_SOURCES += main.c
$(main)_SOURCES += $(HELPER_SOURCES)
$(main)_OBJECTS := $(addsuffix .o, $(basename $($(main)_SOURCES)))
$(main)_PREREQS := $(addsuffix .d, $(basename $($(main)_OBJECTS)))
$(main)_INCLUDE :=
$(main)_INCLUDE += -I.
$(main)_LOADLIBS :=
$(main)_LOADLIBS += $(LOADLIBS)

$($(main)_OBJECTS) : INCLUDE := $($(main)_INCLUDE)
# $($(main)_OBJECTS) : DEFINES += ...
$(main) : $($(main)_OBJECTS)

SOURCES += $($(main)_SOURCES)
PREREQS += $($(main)_PREREQS)
OBJECTS += $($(main)_OBJECTS)
TARGETS += $(main)

main: $($(main)_PREREQS) $($(main)_SOURCES) $($(main)_OBJECTS)
	$(CXX) -o $@ $($(main)_OBJECTS) $($(main)_LOADLIBS)

$($(main)_PREREQS) : INCLUDE := $($(main)_INCLUDE)

-include $($(main)_PREREQS)

#-------------------------------------------------------------------------------
# make stuff
#-------------------------------------------------------------------------------

%.d: %.c
	$(CC) -M $(INCLUDE) $< > $@

%.d: %.cpp
	$(CXX) -M $(INCLUDE) $< > $@

%.o: %.c
	$(CC) $(CCFLAGS) $(DEFINES) $(INCLUDE) -c  $(addsuffix .c, $(basename $@))

%.o: %.cpp
	$(CXX) $(CCFLAGS) $(DEFINES) $(INCLUDE) -c $(addsuffix .cpp, $(basename $@))

%.a : $($(*)_OBJECTS)
	$(RM) $@ ; \
	$(AR) ru $@ $($(*)_OBJECTS) ; \
	$(RANLIB) $@

%.so : $($(*)_OBJECTS)
	$(CC) -shared -o $@ $($(*)_OBJECTS) $($(*)_LIBS)

.PHONY: all
all: $(TARGETS)

.PHONY: rmobjects
rmobjects:
	$(RM) $(OBJECTS)

.PHONY: clean
clean: rmobjects
	$(RM) $(TARGETS)

.PHONY: reallyclean
reallyclean: clean
	$(RM) $(PREREQS)

echo-%:
	@echo $($*)

" <AUTO_VIM_SCRIPT_TAG 3>
