# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# ADIVK -- Divide a vector by a constant (generic).  No divide by zero checking
# is performed.

procedure adivkr (a, b, c, npix)

real	a[ARB]
real	b
real	c[ARB]
int	npix, i

begin
	do i = 1, npix
	    c[i] = a[i] / b
end
