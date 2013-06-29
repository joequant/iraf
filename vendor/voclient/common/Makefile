#///////////////////////////////////////////////////////////////////////////////
#//
#//  Makefile for the common libraries
#//
#///////////////////////////////////////////////////////////////////////////////

# primary dependencies

NAME       	 = Common
VERSION    	 = 1.0
PLATFORM  	:= $(shell uname -s)
PLMACH  	:= $(shell uname -m)
HERE      	:= $(shell /bin/pwd)
BINDIR    	:= ../bin/
LIBDIR    	:= ../lib/
INCDIR    	:= ../include/


# includes, flags and libraries
CINCS  	  	= -I$(INCDIR) -I./
ifeq  ($(PLATFORM), "Darwin")
    ifeq  ($(PLATFORM), "x86_64")
        CARCH	= -m64 -mmacosx-version-min=10.5
    else
        CARCH	= -arch i386 -arch ppc -m32 -mmacosx-version-min=10.4
    endif
    LIBS	= -lm -lc
else
    CARCH	= 
    LIBS	= -lm -lc -lpthread
endif


all::	curl expat

libs::
	(/bin/csh -f mklibs)
	(cd expat ; ./configure --prefix=${HERE}/.. ; $(MAKE) ; $(MAKE) installlib)

curl::
	(/bin/csh -f mklibs)

expat::
	(cd expat ; ./configure --prefix=${HERE}/.. ; $(MAKE) ; $(MAKE) installlib)

apps:

install:
	(cd curl  ; $(MAKE) install)
	#(cd expat ; $(MAKE) install)
	(/bin/rm -rf ../man ../share)

clean:
	(cd curl  	; $(MAKE) clean)
	(cd expat     	; $(MAKE) clean)

distclean:
	(cd curl  	; $(MAKE) distclean)
	(cd expat     	; $(MAKE) distclean)



###############################################################################
# Leave this stuff alone.
###############################################################################

$(STATICLIB): $(SRCS:%.c=Static/%.o)
	/usr/bin/ar rv $@ $?
Static/%.o: %.c $(INCS)
	$(CC) $(CINCS) $(CFLAGS) -c $< -o $@
Static:
	/bin/mkdir $@
	chmod 777 $@

$(SHAREDLIB): $(SRCS:%.c=Shared/%.o)
	/usr/bin/ld -shared -o $@ $? -lc -ldl
Shared/%.o: %.c $(INCS)
	$(CC) $(CINCS) $(CFLAGS) -fpic -shared -c $< -o $@
Shared:
	/bin/mkdir $@
	chmod 777 $@
