# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

define	DUMMY	6

# Test NCAR routines PWRITY

procedure t_pwrity()

char	device[SZ_FNAME]
int	error_code, wkid
int	gp, gopen()

begin
	call clgstr ("device", device, SZ_FNAME)
	
	call gopks (STDERR)
	wkid = 1
	gp = gopen (device, NEW_FILE, STDGRAPH)
	call gopwk (wkid, DUMMY, gp)
	call gacwk (wkid)

	call tpwry (error_code)

	if (error_code == 0)
	    call printf ("Test successful\n")
	else
	    call printf ("Test was not successful\n")
	
	call gdawk (wkid)
	call gclwk (wkid)
	call gclks ()
end
