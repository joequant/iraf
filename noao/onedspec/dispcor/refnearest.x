include	<mach.h>
include	"refspectra.h"


# REFNEAREST -- Assign nearest reference spectrum based on sort key.

procedure refnearest (input, refs)

pointer	input			# List of input spectra
pointer	refs			# List of reference spectra

bool	ignoreaps		# Ignore apertures?

int	i, i1, nrefs, ap
double	sortval, d, d1
pointer	sp, image, gval, refimages, refaps, refvals, refgvals

bool	clgetb(), streq(), refginput(), refgref()
int	imtgetim(), imtlen()

begin
	call smark (sp)
	call salloc (image, SZ_FNAME, TY_CHAR)

	# Task parameters
	ignoreaps = clgetb ("ignoreaps")

	# Tabulate reference spectra.  This expands the reference list,
	# checks the spectrum is a reference spectrum of the appropriate
	# aperture.

	call salloc (refimages, imtlen (refs), TY_POINTER)
	call salloc (refaps, imtlen (refs), TY_INT)
	call salloc (refvals, imtlen (refs), TY_DOUBLE)
	call salloc (refgvals, imtlen (refs), TY_POINTER)
	nrefs = 0
	while (imtgetim (refs, Memc[image], SZ_FNAME) != EOF) {
	    call refnoextn (Memc[image])
	    if (!refgref (Memc[image], ap, sortval, gval))
		next

	    for (i=0; i<nrefs; i=i+1)
		if (streq (Memc[image], Memc[Memi[refimages+i]]))
		    break
	    if (i == nrefs) {
		call salloc (Memi[refimages+nrefs], SZ_FNAME, TY_CHAR)
		call salloc (Memi[refgvals+nrefs], SZ_FNAME, TY_CHAR)
		call strcpy (Memc[image], Memc[Memi[refimages+i]], SZ_FNAME)
		Memi[refaps+i] = ap
		Memd[refvals+i] = sortval
		call strcpy (Memc[gval], Memc[Memi[refgvals+i]], SZ_FNAME)
		nrefs = i + 1
	    }
	}
	if (nrefs < 1)
	    call error (0, "No reference images specified")


	# Assign nearest reference spectra to each input spectrum.
	# Skip input spectra which are not of the appropriate aperture

	while (imtgetim (input, Memc[image], SZ_FNAME) != EOF) {
	    call refnoextn (Memc[image])
	    if (!refginput (Memc[image], ap, sortval, gval))
		next

	    i1 = 0
	    d1 = MAX_REAL
	    do i = 1, nrefs {
		if (!streq (Memc[gval], Memc[Memi[refgvals+i-1]]))
		    next
	        if (!ignoreaps && ap != Memi[refaps+i-1])
		    next
	        d = abs (sortval - Memd[refvals+i-1])
	        if (d < d1) {
		    i1 = i
		    d1 = d
	        }
	    }

	    if (i1 > 0)		# Assign nearest reference spectrum
		call refspectra (Memc[image], Memc[Memi[refimages+i1-1]], 1.,
		    Memc[Memi[refimages+i1-1]], 0.)
	    else {		# No reference spectrum found
		call refprint (STDERR, NO_REFSPEC, Memc[image], "", "", "",
		    ap, 0, "")
		do i = 1, nrefs {
		    if (!streq (Memc[gval], Memc[Memi[refgvals+i-1]])) {
			call refprint (STDERR, REF_GROUP, Memc[image],
			    Memc[Memi[refimages+i-1]], Memc[gval],
			    Memc[Memi[refgvals+i-1]], ap, Memi[refaps+i-1], "")
			next
		    }
		    if (!ignoreaps  && ap != Memi[refaps+i-1])
			call refprint (STDERR, REF_AP, Memc[image],
			    Memc[Memi[refimages+i-1]], Memc[gval],
			    Memc[Memi[refgvals+i-1]], ap, Memi[refaps+i-1], "")
			next
		}
	    }
	}

	call sfree (sp)
end
