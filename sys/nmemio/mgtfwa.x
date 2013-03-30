# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	<config.h>
include	<mach.h>

# MGTFWA -- Given a user buffer pointer, retrieve physical address of buffer.
# If physical address of buffer does not seem reasonable, memory has probably
# been overwritten, a fatal error.

int procedure mgtfwa (ptr, dtype)

pointer	ptr, bufptr
int	dtype
int	locbuf, fwa
int	coerce(), sizeof()
int     factor

begin
	bufptr = coerce (ptr, dtype, TY_INT)
	call zlocv1 (Memi[bufptr-5], locbuf, fwa)
#	call zzmsg("mgtfwa", ptr)
#	call zzval(bufptr)	
#	call zzval(fwa)
#	call zzval(locbuf)
	factor = sizeof(TY_INT)/sizeof(TY_CHAR) / 2
#	call zzval(factor)
	if (abs (locbuf * factor  - fwa) > (6 * SZ_VMEMALIGN))
	    call sys_panic (SYS_MCORRUPTED, "Memory fwa has been corrupted")

	return (fwa/factor)
end
