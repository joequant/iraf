export iraf=`pwd`/
export host=unix
export hlib=${iraf}${host}/hlib/
export PATH=$PATH:${iraf}${host}"/bin/"
export pkglibs=${iraf}noao/lib/,${iraf}${host}/hlib/libc/,${iraf}${host}/bin/
export HOST_CURL=1
export HOST_READLINE=1
export HOST_EXPAT=1
export HOST_CFITSIO=1
export IRAFARCH=`${hlib}irafarch.csh`

rm -rf vo/votools/.old
rm -rf vo/votools/.url*
rm -f  ${host}/bin/*
rm -rf ${host}/bin.*/*
rm -f  ${host}/bin
ln -sf bin.${IRAFARCH} bin

pushd ${host}/hlib
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
export pkglibs=${iraf}noao/lib/,${iraf}${host}/bin/,${iraf}${host}/hlib/
pushd vendor/voclient
make clean
make mylib 
cp libvo/libVO.a ${iraf}lib
popd

export pkglibs=${iraf}noao/lib/,${iraf}${host}/bin/,${iraf}${host}/hlib/libc/
${iraf}util/mksysvos
sed -i ${host}/hlib/mkiraf.csh -e s!/iraf/iraf!%{_datadir}/iraf!g
cp ${iraf}${host}/bin/*.a ${iraf}lib
rm pkg/utilities/nttools/xx_nttools.e

cd %{_builddir}/x11-iraf
rm ximtool/clients/x_ism.o
xmkmf
export PATH=$PATH:${iraf}${host}"/bin/"
make
