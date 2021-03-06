# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<pkg/gtools.h>
include	"names.h"
include	"icfit.h"

# ICG_FIT -- Interactive curve fitting with graphics.  This is the main
# entry point for the interactive graphics part of the icfit package.

procedure icg_fitd (ic, gp, cursor, gt, cv, x, y, wts, npts)

pointer	ic			# ICFIT pointer
pointer	gp			# GIO pointer
char	cursor[ARB]		# GIO cursor input
pointer	gt			# GTOOLS pointer
pointer	cv			# CURFIT pointer
double	x[npts]			# Ordinates
double	y[npts]			# Abscissas
double	wts[npts]		# Weights
int	npts			# Number of points

real	wx, wy
int	wcs, key

int	i, j, newgraph, axes[2], xtype
double	px1
real	rx1, rx2, ry1, ry2
pointer	sp, cmd, userwts, x1, y1, w1, n

int	gt_gcur1(), stridxs(), scan(), nscan()
int	icg_nearestd()
double	dcveval()
errchk	ic_fitd()

begin
	call smark (sp)
	call salloc (cmd, IC_SZSAMPLE, TY_CHAR)

	# Allocate memory for the fit and a copy of the weights.
	# The weights are copied because they are changed when points are
	# deleted.

	n = npts
	x1 = NULL
	y1 = NULL
	w1 = NULL
	call malloc (userwts, n, TY_DOUBLE)
	call amovd (wts, Memd[userwts], n)

	# Initialize
	IC_GP(ic) = gp
	IC_GT(ic) = gt
	IC_OVERPLOT(ic) = NO
	IC_NEWX(ic) = YES
	IC_NEWY(ic) = YES
	IC_NEWWTS(ic) = YES
	IC_NEWFUNCTION(ic) = YES

	# Send the GUI the current task values.
	call ic_gui (ic, "open")
	call ic_gui (ic, "graph")

	# Read cursor commands.

	key = 'f'
	newgraph = YES
	axes[1] = IC_AXES(ic, IC_GKEY(ic), 1)
	axes[2] = IC_AXES(ic, IC_GKEY(ic), 2)
	xtype = 0

	repeat {
	    switch (key) {
	    case '?': # Print help text.
		call ic_gui (ic, "help")

	    case ':': # List or set parameters
		if (Memc[cmd] == '/')
	            call gt_colon (Memc[cmd], gp, gt, newgraph)
		else
		    call icg_colond (ic, Memc[cmd], newgraph, gp, gt, cv,
			x, y, wts, n)

	    case 'a': # Add points
		if ((IC_AXES(ic,IC_GKEY(ic),1) == 'x') &&
		    (IC_AXES(ic,IC_GKEY(ic),2) == 'y'))
		    ;
		else if ((IC_AXES(ic,IC_GKEY(ic),1) == 'y') &&
		    (IC_AXES(ic,IC_GKEY(ic),2) == 'x')) {
		    rx1 = wx
		    wx = wy
		    wy = rx1
		} else {
		    call printf ("Graph must be x vs. y or y vs. x\07\n")
		    next
		}

		rx1 = 1.
		call printf ("weight = (%g) ")
		    call pargr (rx1)
		call flush (STDOUT)
		if (scan() != EOF) {
		    call gargr (rx2)
		    if (nscan() == 1)
			if (!IS_INDEFR (rx2))
			    rx1 = rx2
		}

		if (x1 == NULL) {
		    call malloc (x1, n+1, TY_DOUBLE)
		    call malloc (y1, n+1, TY_DOUBLE)
		    call malloc (w1, n+1, TY_DOUBLE)
		    call amovd (x, Memd[x1], n)
		    call amovd (y, Memd[y1], n)
		    call amovd (wts, Memd[w1], n)
		} else {
		    call realloc (x1, n+1, TY_DOUBLE)
		    call realloc (y1, n+1, TY_DOUBLE)
		    call realloc (w1, n+1, TY_DOUBLE)
		}
		call realloc (userwts, n+1, TY_DOUBLE)

		call icg_addd (gp, wx, wy, rx1, Memd[x1], Memd[y1],
		    Memd[w1], Memd[userwts], n)

		IC_NEWX(ic) = YES
		IC_NEWY(ic) = YES
		IC_NEWWTS(ic) = YES

	    case 'c': # Print the positions of data points.
		if (x1 == NULL) {
		    i = icg_nearestd (ic, gp, gt, cv, x, y, n, wx, wy)

		    if (i != 0) {
			call printf ("x = %g  y = %g  fit = %g\n")
			    call pargd (x[i])
			    call pargd (y[i])
			    call pargd (dcveval (cv, x[i]))
		    }
		} else {
		    i = icg_nearestd (ic, gp, gt, cv, Memd[x1], Memd[y1],
			n, wx, wy)

		    if (i != 0) {
			call printf ("x = %g  y = %g  fit = %g\n")
			    call pargd (Memd[x1+i-1])
			    call pargd (Memd[y1+i-1])
			    call pargd (dcveval (cv, Memd[x1+i-1]))
		    }
		}

	    case 'd': # Delete data points.
		if (x1 == NULL)
		    call icg_deleted (ic, gp, gt, cv, x, y, wts,
			Memd[userwts], n, wx, wy)
		else
		    call icg_deleted (ic, gp, gt, cv, Memd[x1], Memd[y1],
			Memd[w1], Memd[userwts], n, wx, wy)
		call ic_gui (ic, "refit YES")

	    case 'f': # Fit the function and reset the flags.
		iferr {
		    if (x1 == NULL)
			call ic_fitd (ic, cv, x, y, wts, n, IC_NEWX(ic),
			    IC_NEWY(ic), IC_NEWWTS(ic), IC_NEWFUNCTION(ic))
		    else
			call ic_fitd (ic, cv, Memd[x1], Memd[y1], Memd[w1],
			    n, IC_NEWX(ic), IC_NEWY(ic), IC_NEWWTS(ic),
			    IC_NEWFUNCTION(ic))

		    IC_NEWX(ic) = NO
		    IC_NEWY(ic) = NO
		    IC_NEWWTS(ic) = NO
		    IC_NEWFUNCTION(ic) = NO
		    IC_FITERROR(ic) = NO
		    newgraph = YES

		    call  ic_gui (ic, "refit NO")
		} then {
		    IC_FITERROR(ic) = YES
		    call erract (EA_WARN)
		}

	    case 'g':	# Set graph axes types.
		call printf ("Graph key to be defined: ")
		call flush (STDOUT)
		if (scan() == EOF)
		    goto 10
		call gargc (Memc[cmd])

		switch (Memc[cmd]) {
		case '\n':
		case 'h', 'i', 'j', 'k', 'l':
		    switch (Memc[cmd]) {
		    case 'h':
		        key = 1
		    case 'i':
		        key = 2
		    case 'j':
		        key = 3
		    case 'k':
		        key = 4
		    case 'l':
		        key = 5
		    }

		    call printf ("Set graph axes types (%c, %c): ")
		        call pargi (IC_AXES(ic, key, 1))
		        call pargi (IC_AXES(ic, key, 2))
		    call flush (STDOUT)
		    if (scan() == EOF)
		        goto 10
		    call gargc (Memc[cmd])

		    switch (Memc[cmd]) {
		    case '\n':
		    default:
		        call gargc (Memc[cmd+1])
		        call gargc (Memc[cmd+1])
		        if (Memc[cmd+1] != '\n') {
			    IC_AXES(ic, key, 1) = Memc[cmd]
			    IC_AXES(ic, key, 2) = Memc[cmd+1]
			    if (IC_GKEY(ic) == key)
				newgraph = YES
		        }
		    }
		default:
		    call printf ("Not a graph key\n")
		}

	    case 'h':
		if (IC_GKEY(ic) != 1) {
		    IC_GKEY(ic) = 1
		    newgraph = YES
		    call ic_gui (ic, "graph")
		}

	    case 'i':
		if (IC_GKEY(ic) != 2) {
		    IC_GKEY(ic) = 2
		    newgraph = YES
		    call ic_gui (ic, "graph")
		}

	    case 'j':
		if (IC_GKEY(ic) != 3) {
		    IC_GKEY(ic) = 3
		    newgraph = YES
		    call ic_gui (ic, "graph")
		}

	    case 'k':
		if (IC_GKEY(ic) != 4) {
		    IC_GKEY(ic) = 4
		    newgraph = YES
		    call ic_gui (ic, "graph")
		}

	    case 'l':
		if (IC_GKEY(ic) != 5) {
		    IC_GKEY(ic) = 5
		    newgraph = YES
		    call ic_gui (ic, "graph")
		}

	    case 't': # Initialize the sample string and erase from the graph.
		if (x1 == NULL)
		    call icg_sampled (ic, gp, gt, x, n, 0)
		else
		    call icg_sampled (ic, gp, gt, Memd[x1], n, 0)
		call ic_pstr (ic, "sample", "*")
		IC_NEWX(ic) = YES

	    case 'o': # Set overplot flag
		IC_OVERPLOT(ic) = YES

	    case 'r': # Redraw the graph
		newgraph = YES

	    case 's': # Set sample regions with the cursor.
		if ((IC_AXES(ic,IC_GKEY(ic),1) == 'x') ||
		    (IC_AXES(ic,IC_GKEY(ic),2) == 'x')) {
		    if (stridxs ("*", Memc[IC_SAMPLE(ic)]) > 0)
		        Memc[IC_SAMPLE(ic)] = EOS

		    rx1 = wx
		    ry1 = wy
		    call printf ("again:\n")
		    if (gt_gcur1(gt, cursor, wx, wy, wcs, key, Memc[cmd],
			IC_SZSAMPLE) == EOF)
		        break
		    call printf ("\n")
		    rx2 = wx
		    ry2 = wy

		    # Determine if the x vector is integer.
		    if (xtype == 0) {
			xtype = TY_INT
			if (x1 == NULL) {
			    do i = 1, n
				if (x[i] != int (x[i])) {
				    xtype = TY_REAL
				    break
				}
			} else {
			    do i = 1, n
				if (Memd[x1+i-1] != int (Memd[x1+i-1])) {
				    xtype = TY_REAL
				    break
				}
			}
		    }

		    if (IC_AXES(ic,IC_GKEY(ic),1) == 'x') {
		        if (xtype == TY_INT) {
		            call sprintf (Memc[cmd], IC_SZSAMPLE, " %d:%d")
		                call pargi (nint (rx1))
		                call pargi (nint (rx2))
			} else {
		            call sprintf (Memc[cmd], IC_SZSAMPLE, " %g:%g")
		                call pargr (rx1)
		                call pargr (rx2)
			}
		    } else {
		        if (xtype == TY_INT) {
		            call sprintf (Memc[cmd], IC_SZSAMPLE, " %d:%d")
		                call pargi (nint (ry1))
		                call pargi (nint (ry2))
			} else {
		            call sprintf (Memc[cmd], IC_SZSAMPLE, " %g:%g")
		                call pargr (ry1)
		                call pargr (ry2)
			}
		    }
		    call strcat (Memc[cmd], Memc[IC_SAMPLE(ic)], IC_SZSAMPLE)
		    if (x1 == NULL)
			call icg_sampled (ic, gp, gt, x, n, 1)
		    else
			call icg_sampled (ic, gp, gt, Memd[x1], n, 1)
		    call ic_pstr (ic, "sample",  Memc[IC_SAMPLE(ic)])
		    IC_NEWX(ic) = YES
		}

	    case 'u': # Undelete data points.
		if (x1 == NULL)
		    call icg_undeleted (ic, gp, gt, cv, x, y, wts,
			Memd[userwts], n, wx, wy)
		else
		    call icg_undeleted (ic, gp, gt, cv, Memd[x1], Memd[y1],
			Memd[w1], Memd[userwts], n, wx, wy)
		call ic_gui (ic, "refit YES")

	    case 'w':  # Window graph
		call gt_window (gt, gp, cursor, newgraph)

	    case 'v': # Reset the value of the weight.
		if (x1 == NULL) {
		    i = icg_nearestd (ic, gp, gt, cv, x, y, n, wx, wy)

		    if (i != 0) {
			call printf ("weight = (%g) ")
			    call pargd (wts[i])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    wts[i] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWWTS(ic) = YES
				}
			    }
			}
		    }
		} else {
		    i = icg_nearestd (ic, gp, gt, cv, Memd[x1], Memd[y1], n,
			wx, wy)

		    if (i != 0) {
			call printf ("weight = (%g) ")
			    call pargd (Memd[w1+i-1])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    j = icg_nearestd (ic, gp, gt, cv, x, y, n,
					wx, wy)
				    if (j != 0)
					if (x[j] == Memd[x1+i-1] &&
					    y[j] == Memd[y1+i-1])
					    wts[j] = px1
				    Memd[w1+i-1] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWWTS(ic) = YES
				}
			    }
			}
		    }
		}

	    case 'x': # Reset the value of the x point.
		if (x1 == NULL) {
		    i = icg_nearestd (ic, gp, gt, cv, x, y, n, wx, wy)

		    if (i != 0) {
			call printf ("x = (%g) ")
			    call pargd (x[i])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    x[i] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWX(ic) = YES
				}
			    }
			}
		    }
		} else {
		    i = icg_nearestd (ic, gp, gt, cv, Memd[x1], Memd[y1], n,
			wx, wy)

		    if (i != 0) {
			call printf ("x = (%g) ")
			    call pargd (Memd[x1+i-1])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    j = icg_nearestd (ic, gp, gt, cv, x, y, n,
					wx, wy)
				    if (j != 0)
					if (x[j] == Memd[x1+i-1] &&
					    y[j] == Memd[y1+i-1])
					    x[j] = px1
				    Memd[x1+i-1] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWX(ic) = YES
				}
			    }
			}
		    }
		}

	    case 'y': # Reset the value of the y point.
		if (x1 == NULL) {
		    i = icg_nearestd (ic, gp, gt, cv, x, y, n, wx, wy)

		    if (i != 0) {
			call printf ("y = (%g) ")
			    call pargd (y[i])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    y[i] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWY(ic) = YES
				}
			    }
			}
		    }
		} else {
		    i = icg_nearestd (ic, gp, gt, cv, Memd[x1], Memd[y1], n,
			wx, wy)

		    if (i != 0) {
			call printf ("y = (%g) ")
			    call pargd (Memd[y1+i-1])
			call flush (STDOUT)
			if (scan() != EOF) {
			    call gargd (px1)
			    if (nscan() == 1) {
				if (!IS_INDEF (px1)) {
				    j = icg_nearestd (ic, gp, gt, cv, x, y, n,
					wx, wy)
				    if (j != 0)
					if (x[j] == Memd[x1+i-1] &&
					    y[j] == Memd[y1+i-1])
					    y[j] = px1
				    Memd[y1+i-1] = px1
				    call ic_gui (ic, "refit YES")
				    IC_NEWY(ic) = YES
				}
			    }
			}
		    }
		}

	    case 'z': # Delete sample region
		if (x1 == NULL)
		    call icg_dsampled (wx, wy, ic, gp, gt, x, n)
		else
		    call icg_dsampled (wx, wy, ic, gp, gt, Memd[x1], n)
		call ic_pstr (ic, "sample", Memc[IC_SAMPLE(ic)])

	    case 'I': # Interrupt
		call fatal (0, "Interrupt")

	    default: # Let the user decide on any other keys.
		call icg_user (ic, gp, gt, cv, wx, wy, wcs, key, Memc[cmd])
	    }

	    # Redraw the graph if necessary.
10	    if (newgraph == YES) {
		if (IC_AXES(ic, IC_GKEY(ic), 1) != axes[1]) {
		    axes[1] = IC_AXES(ic, IC_GKEY(ic), 1)
		    call gt_setr (gt, GTXMIN, INDEFR)
		    call gt_setr (gt, GTXMAX, INDEFR)
		}
		if (IC_AXES(ic, IC_GKEY(ic), 2) != axes[2]) {
		    axes[2] = IC_AXES(ic, IC_GKEY(ic), 2)
		    call gt_setr (gt, GTYMIN, INDEFR)
		    call gt_setr (gt, GTYMAX, INDEFR)
		}
		if (x1 == NULL)
		    call icg_graphd (ic, gp, gt, cv, x, y, wts, n)
		else
		    call icg_graphd (ic, gp, gt, cv, Memd[x1], Memd[y1],
			Memd[w1], n)
		newgraph = NO
	    }
	    if (cursor[1] == EOS)
		break
	} until (gt_gcur1 (gt, cursor, wx, wy, wcs, key, Memc[cmd],
	    IC_SZSAMPLE) == EOF)

	call ic_gui (ic, "close")
	IC_GP(ic) = NULL

	if (x1 != NULL) {
	    call mfree (x1, TY_DOUBLE)
	    call mfree (y1, TY_DOUBLE)
	    call mfree (w1, TY_DOUBLE)
	    if (IC_WTSFIT(ic) == NULL)
		IC_NFIT(ic) = npts
	}
	call mfree (userwts, TY_DOUBLE)
	call sfree (sp)
end
