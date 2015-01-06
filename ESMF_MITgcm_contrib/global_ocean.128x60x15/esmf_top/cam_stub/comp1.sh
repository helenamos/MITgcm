#!/bin/csh -fxv
#

source ${BUILDROOT}/mytools/comp_profile.BASE
source ${BUILDROOT}/mytools/comp_profile.${COMP_PROF}

foreach PE ( ${pesizelist} )

set includes = ( -I${APPF90MOD_PATH}/${PE}pe ${compinc}      )
set libs     = ( -L${APPLIB_PATH}/${PE}pe ${complibs} -lesmf )

$comp $compopts -c cam_stub_esmf_driver.F  $includes $libs

${arcommand} ${aropts} libcam_stub_driver.a *.o

cp *.a   ${APPLIB_PATH}/${PE}pe
cp *.mod ${APPF90MOD_PATH}/${PE}pe
\rm *.a *.mod

end

