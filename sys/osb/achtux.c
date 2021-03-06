/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define	import_spp
#define import_knames
#include <iraf.h>

/* ACHTU_ -- Unpack an unsigned short integer array into an SPP datatype.
 * [MACHDEP]: The underscore appended to the procedure name is OS dependent.
 */
void
ACHTUX (
  XUSHORT  	*a,
  XCOMPLEX   	*b,
  XINT	   	*npix
)
{
	register XUSHORT *ip;
	register XCOMPLEX	 *op;
	register int	 n = *npix;

	if (sizeof(*op) >= sizeof(*ip)) {
	    for (ip = &a[n], op = &b[n];  ip > a;  )
		    (--op)->r = (float) *--ip;
	} else {
	    for (ip=a, op=b;  --n >= 0;  )
		    (op++)->r = (float) *ip++;
	}
}
