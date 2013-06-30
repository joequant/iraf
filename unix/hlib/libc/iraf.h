/*
 * IRAF.H -- Index to the IRAF/C include files and to the major IRAF
 * directories.  All directory references in the IRAF system are relative
 * to the root directories defined in this file.  The UNIX version of IRAF
 * scans this file at run time to get the logical directory definitions.
 */

#undef abs

#ifndef D_iraf
/* ### Start of run time definitions */
#define	HOST		"/iraf/iraf/unix/"
#define	IRAF		"/iraf/iraf/"
#define	TMP		"/tmp/"
/* ### End of run time definitions */

/* Compile time definitions 
 */
/* #define BSDUNIX */
/* #define SUNOS4 */

#define D_iraf
#endif

/* Include any header files specified in #define import_XXX statements
 * before we were called.
 */
#ifdef import_libc
#ifndef D_libc
#include "libc.h"
#endif
#undef import_libc
#endif

#ifdef import_spp
#ifndef D_spp
#include "spp.h"
#endif
#undef import_spp
#endif

#ifdef import_main
#ifndef D_main
#include "main.h"
#endif
#undef import_main
#endif

#ifdef import_stdio
#ifndef D_stdio

#include "iraf/stdio.h"
#endif
#undef import_stdio
#endif

#ifdef import_error
#ifndef D_error
#include "error.h"
#endif
#undef import_error
#endif

#ifdef import_ctype
#ifndef D_ctype
#include "iraf/ctype.h"
#endif
#undef import_ctype
#endif

#ifdef import_finfo
#ifndef D_finfo
#include "finfo.h"
#endif
#undef import_finfo
#endif

#ifdef import_fset
#ifndef D_fset
#include "fset.h"
#endif
#undef import_fset
#endif

#ifdef import_fpoll
#ifndef D_fpoll
#include "fpoll.h"
#endif
#undef import_fpoll
#endif

#ifdef import_kernel
#ifndef D_kernel
#include "kernel.h"
#endif
#undef import_kernel
#endif

#ifdef import_xnames
#ifndef D_xnames
#include "xnames.h"
#endif
#undef import_xnames
#endif

#ifdef import_knames
#ifndef D_knames
#include "knames.h"
/*
#include "/iraf/iraf/unix/hlib/libc/kproto.h"
*/
#endif
#undef import_knames
#endif

#ifdef import_setjmp
#ifndef D_setjmp
#include <setjmp.h>
#endif
#undef import_setjmp
#endif

#ifdef import_xwhen
#ifndef D_xwhen
#include "xwhen.h"
#endif
#undef import_xwhen
#endif

#ifdef import_protect
#ifndef D_protect
#include "protect.h"
#endif
#undef import_protect
#endif

#ifdef import_prtype
#ifndef D_prtype
#include "prtype.h"
#endif
#undef import_prtype
#endif

#ifdef import_zfstat
#ifndef D_zfstat
#include "zfstat.h"
#endif
#undef import_zfstat
#endif

#ifdef import_alloc
#ifndef D_alloc
#include "alloc.h"
#endif
#undef import_alloc
#endif

#ifdef import_math
#ifndef D_math
#include <math.h>
#endif
#undef import_math
#endif

#ifdef import_prstat
#ifndef D_prstat
#include "prstat.h"
#endif
#undef import_prstat
#endif

#ifdef import_lexnum
#ifndef D_lexnum
#include "lexnum.h"
#endif
#undef import_lexnum
#endif

#ifdef import_ttset
#ifndef D_ttset
#include "ttset.h"
#endif
#undef import_ttset
#endif

#ifdef import_stdarg
#ifndef D_stdarg
#include <stdarg.h>
#endif
#undef import_stdarg
#endif
