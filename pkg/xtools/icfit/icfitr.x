# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.


include	<error.h>
include	<math/curfit.h>
include	"icfit.h"
include	"names.h"

# IC_FIT -- Fit a function.  This is the main fitting task.  It uses
# flags to define changes since the last fit.  This allows the most
# efficient use of the curfit and ranges packages.

procedure ic_fitr (ic, cv, x, y, wts, npts, newx, newy, newwts, newfunction)

pointer	ic				# ICFIT pointer
pointer	cv				# Curfit pointer
real	x[npts]				# Ordinates
real	y[npts]				# Data to be fit
real	wts[npts]			# Weights
int	npts				# Number of points
int	newx				# New x points?
int	newy				# New y points?
int	newwts				# New weights?
int	newfunction			# New function?

int	ier, refit

errchk	ic_dosetupr, rcvfit, rcvrefit, rg_wtbinr, ic_rejectr

begin
	IC_FITERROR(ic) = NO

	iferr {
	    # Setup the new parameters.

	    call ic_dosetupr (ic, cv, x, wts, npts, newx, newwts, newfunction,
		refit)

	    # If not sampling use the data array directly.

	    if (npts == IC_NFIT(ic)) {
		if (refit == NO) {
		    call rcvfit (cv, x, y, wts, npts, WTS_USER, ier)
		} else if (newy == YES)
		    call rcvrefit (cv, x, y, wts, ier)

	    # If sampling first form the sample y values.

	    } else {
		if ((newx == YES) || (newy == YES) || (newwts == YES))
		    call rg_wtbinr (IC_RG(ic), IC_NAVERAGE(ic), y, wts, npts,
			Memr[IC_YFIT(ic)], Memr[IC_WTSFIT(ic)], IC_NFIT(ic))
		if (refit == NO) {
		    call rcvfit (cv, Memr[IC_XFIT(ic)], Memr[IC_YFIT(ic)],
			Memr[IC_WTSFIT(ic)], IC_NFIT(ic), WTS_USER, ier)
		} else if (newy == YES)
		    call rcvrefit (cv, Memr[IC_XFIT(ic)], Memr[IC_YFIT(ic)],
			Memr[IC_WTSFIT(ic)], ier)
	    }

	    # Check for an error in the fit.

	    switch (ier) {
	    case SINGULAR:
		call printf ("Singular solution\n")
		call flush (STDOUT)
	    case NO_DEG_FREEDOM:
		call printf ("No degrees of freedom\n")
		call flush (STDOUT)
		IC_FITERROR(ic) = YES
	    }

	    if (IC_FITERROR(ic) == NO) {
		refit = YES

		# Do pixel rejection if desired.

		if ((IC_LOW(ic) > 0.) || (IC_HIGH(ic) > 0.)) {
		    if (npts == IC_NFIT(ic))
			call ic_rejectr (cv, x, y, wts, Memi[IC_REJPTS(ic)],
			    IC_NFIT(ic), IC_LOW(ic), IC_HIGH(ic),
			    IC_NITERATE(ic), IC_GROW(ic), IC_NREJECT(ic))
		    else
			call ic_rejectr (cv, Memr[IC_XFIT(ic)],
			    Memr[IC_YFIT(ic)], Memr[IC_WTSFIT(ic)],
			    Memi[IC_REJPTS(ic)], IC_NFIT(ic), IC_LOW(ic),
			    IC_HIGH(ic), IC_NITERATE(ic), IC_GROW(ic),
			    IC_NREJECT(ic))

		    if (IC_NREJECT(ic) > 0)
			refit = NO
		} else
		    IC_NREJECT(ic) = 0
	    }
	} then {
	    IC_FITERROR(ic) = YES
	    call erract (EA_ERROR)
	}
end
