#!/bin/csh -fxv
#
set OPATH = (  )
set OINC  = (  )

source ${BUILDROOT}/mytools/comp_profile.BASE
source ${BUILDROOT}/mytools/comp_profile.${COMP_PROF}

foreach PE ( $pesizelist )

set includes = ( -I${APPF90MOD_PATH}/${PE}pe ${compinc}      )
set libs     = ( -L${APPLIB_PATH}/${PE}pe -lmitgcm_org_ocn_esmf_driver ${complibs} -lesmf )

$comp $compopts -c mitgcm_ocn2cam_cpl.F  $includes $libs

${arcommand} ${aropts} libmitgcm_org_ocn2cam.a *.o

cp *.a   ${APPLIB_PATH}/${PE}pe
cp *.mod ${APPF90MOD_PATH}/${PE}pe
\rm *.a *.mod

end

