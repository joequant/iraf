Summary: Programs for Processing and Analysis of Astronomical Data
Name: iraf
Version: 2.16
Release: %mkrel 1
License: Freely redistributable/modifiable if attributed, no warranty
Group: Applications/Scientific
Distribution: Tim's RPM Shack
Source0: ftp://iraf.noao.edu/iraf/v216/PCIX/iraf-src.tar.gz
Source1: http://iraf.noao.edu/x11iraf/x11iraf-v2.0BETA-src.tar.gz
Patch0: iraf-build.patch
Patch1: x11iraf.stdarg.patch
Url: http://iraf.noao.edu/
Provides: iraf
BuildRequires: curl-devel
BuildRequires: expat-devel
BuildRequires: readline-devel
BuildRequires: cfitsio-devel
BuildRequires: f2c
BuildRequires: tcsh
BuildRequires: bison
BuildRequires: flex

%description
IRAF stands for the Image Reduction and Analysis Facility. It
is the de facto standard for the general processing of astronomical images
and spectroscopy from the ultraviolet to the far infrared.  IRAF is a 
product of the National Optical Astronomy Observatories (www.noao.edu). 

%prep
%setup -q -c
%patch0 -p1
chmod a+x util/mksysvos  util/mksysnovos
find -name "ytab.c" | xargs rm -f
# lex has problems run against xppcode
find pkg -name "lexyy.c" | xargs rm -f
#sed -i unix/boot/spp/xpp/xppcode.c -e 's!extern char \*yytext_ptr;!!g' \
#   -e s!yytext_ptr!yytext!g
%setup -q -T -c -a 1 -n x11-iraf
%patch1 -p1

%build
export iraf=%{_builddir}/%{name}-%{version}/
export host=unix
export hostid=unix
export hlib=${iraf}${host}/hlib/
export PATH=$PATH:${iraf}${host}/bin/
export pkglibs=${iraf}noao/lib/,${hlib}libc/,${iraf}${host}/bin/
cd %{_builddir}/%{name}-%{version}
export HOST_CURL=1
export HOST_READLINE=1
export HOST_EXPAT=1
export IRAFARCH=`${hlib}irafarch.csh`

rm -rf vo/votools/.old
rm -rf vo/votools/.url*
rm -f  ${iraf}${host}/bin/*
rm -rf ${iraf}${host}/bin.*/*
rm -f  ${iraf}${host}/bin
rm -f  lib/*.a lib/*.o
rm -f  bin
ln -sf bin.${IRAFARCH} bin

pushd ${hlib}
ln -sf mach`getconf LONG_BIT`.h mach.h
ln -sf iraf`getconf LONG_BIT`.h iraf.h
popd

find -name "*.a" | xargs rm -f
make src
export NOVOS=1
pushd vendor/voclient
make mylib
cp libvo/libVO.a ${iraf}lib
popd

${iraf}util/mksysnovos

unset NOVOS
export PATH=$PATH:${iraf}${host}/bin/
export pkglibs=${iraf}noao/lib/,${iraf}${host}/bin/,${hlib}
pushd vendor/voclient
make clean
make mylib 
cp libvo/libVO.a ${iraf}lib
popd

export pkglibs=${iraf}noao/lib/,${iraf}${host}/bin/,${hlib}libc/
${iraf}util/mksysvos
sed -i ${hlib}mkiraf.csh -e s!/iraf/iraf!%{_datadir}/iraf!g
cp ${iraf}${host}/bin/*.a ${iraf}lib

find pkg -name "*.e"  | xargs rm -f

cd %{_builddir}/x11-iraf
find -name "*.o" | xargs rm -rf
find -name "*.a" | xargs rm -rf
xmkmf
export PATH=$PATH:${iraf}${host}/bin/
make


%install
%{__mkdir_p} %{buildroot}/%{_bindir}
cd %{_builddir}/%{name}-%{version}
%{__mkdir_p} %{buildroot}/%{_datadir}/iraf
cp -pr pkg %{buildroot}/%{_datadir}/iraf
cp -pr bin.* %{buildroot}/%{_datadir}/iraf
cp -pr unix vo util extern noao dev *.GEN %{buildroot}/%{_datadir}/iraf
cp -pr doc %{buildroot}/%{_datadir}/iraf
cp -pr lib %{buildroot}/%{_datadir}/iraf
cp -pr include %{buildroot}/%{_datadir}/iraf
cp -pr unix/hlib/mkiraf.csh %{buildroot}/%{_bindir}/mkiraf 
cp -pr unix/hlib/cl.csh %{buildroot}/%{_bindir}/cl
%{__mkdir_p} %{buildroot}/%{_includedir}
cp unix/hlib/libc/iraf.h %{buildroot}/%{_includedir}
cd %{_builddir}/x11-iraf 
make install
cp -pr bin/* %{buildroot}/%{_bindir}

%files
%{_datadir}/iraf
%{_bindir}
%{_includedir}
