#///////////////////////////////////////////////////////////////////////////////
#//
#//  Makefile for the VOTable Interface
#//
#///////////////////////////////////////////////////////////////////////////////

# primary dependencies

NAME       	 = VOClient
VERSION    	 = 1.0
PLATFORM  	:= $(shell uname -s)
PLMACH  	:= $(shell uname -m)
HERE      	:= $(shell /bin/pwd)
#BINDIR    	:= ./bin/
#LIBDIR    	:= ./lib/
#INCDIR    	:= ./include/
BINDIR    	:= ../../bin/
LIBDIR    	:= ../../lib/
INCDIR    	:= ../../lib/


# includes, flags and libraries
CC 	  	= gcc
CINCS  	  	= -I$(INCDIR) -I./
ifeq  ($(PLATFORM), "Darwin")
    ifeq  ($(PLATFORM), "x86_64")
        CARCH	= -m64 -mmacosx-version-min=10.5
    else
        CARCH	= -arch i386 -arch ppc -m32 -mmacosx-version-min=10.4
    endif
else
    CARCH	= 
endif

CFLAGS 		= -g -Wall $(CARCH) -D$(PLATFORM) $(CINCS) -L./
LIBS		= -lm -lc -lpthread


all:
	(cd common      ; ${MAKE} all  ; ${MAKE} install)
	(cd libvotable  ; ${MAKE} all  ; ${MAKE} install)
	(cd libsamp     ; ${MAKE} all  ; ${MAKE} install)
	(cd libvoclient ; ${MAKE} all  ; ${MAKE} install)
	(cd voapps      ; ${MAKE} all  ; ${MAKE} install)
	(cd libvo       ; ${MAKE} all  ; ${MAKE} install)

libs:

mylib:
#	(cd common      ; ${MAKE} )
	mkdir -p include lib
	(cd libsamp     ; ${MAKE} .BASE lib ; cp *.h ../include ; cp *.a ../lib )
	(cd libvoclient ; ${MAKE} install )
	cp libsamp/cfitsio/*.h include
	(cd libvotable  ; ${MAKE} install)
	(cd voapps      ; ${MAKE} lib ; cp *.a ../lib )
	(rm -f *.o ; cd libvo       ; ${MAKE} HOST_CURL=1 lib)

apps:
	(cd common      ; ${MAKE} apps)
	(cd libvotable  ; ${MAKE} apps)
	(cd libsamp     ; ${MAKE} apps)
	(cd libvoclient ; ${MAKE} apps)
	(cd voapps      ; ${MAKE} apps)

examples:
	(cd common      ; ${MAKE} examples)
	(cd libvotable  ; ${MAKE} examples)
	(cd libsamp     ; ${MAKE} examples)
	(cd libvoclient ; ${MAKE} examples)
	(cd voapps      ; ${MAKE} examples)

install:
	(cd common      ; ${MAKE} install)
	(cd libvotable  ; ${MAKE} install)
	(cd libsamp     ; ${MAKE} install)
	(cd libvoclient ; ${MAKE} install)
	(cd voapps      ; ${MAKE} install)
	(cd libvo       ; ${MAKE} install)

clean:
ifndef HOST_CURL
	(cd common      ; ${MAKE} clean)
endif
	(cd libvotable  ; ${MAKE} clean)
	(cd libsamp     ; ${MAKE} clean)
	(cd libvoclient ; ${MAKE} clean)
	(cd voapps      ; ${MAKE} clean)
	(cd libvo       ; ${MAKE} clean)
	/bin/rm -rf voclient/lib/libvoclient.*
	/bin/rm -rf bin/* lib/* include/* spool



###############################################################################
# Leave this stuff alone.
###############################################################################

$(STATICLIB): $(SRCS:%.c=Static/%.o)
	/usr/bin/ar rv $@ $?
Static/%.o: %.c $(INCS)
	/usr/bin/gcc $(CINCS) $(CFLAGS) -c $< -o $@
Static:
	/bin/mkdir $@
	chmod 777 $@

$(SHAREDLIB): $(SRCS:%.c=Shared/%.o)
	/usr/bin/ld -shared -o $@ $? -lc -ldl
Shared/%.o: %.c $(INCS)
	/usr/bin/gcc $(CINCS) $(CFLAGS) -fpic -shared -c $< -o $@
Shared:
	/bin/mkdir $@
	chmod 777 $@
