#!/bin/csh -fxv
#
set OPATH = (  )
set OINC  = (  )

source ${BUILDROOT}/mytools/comp_profile.BASE
source ${BUILDROOT}/mytools/comp_profile.${COMP_PROF}

foreach PE ( $pesizelist )

set includes = ( -I${APPINC_PATH}/${PE}pe -I${APPF90MOD_PATH}/${PE}pe ${compinc}      )
set libs     = ( -L${APPLIB_PATH}/${PE}pe -lmitgcm_org_ocn -lmitgcmrtl ${complibs} -lesmf )

$comp $compopts -c ../utils/mitgcm_org_esmf_utils.F     $includes $libs
$comp $compopts -c mitgcm_org_ocn_esmf_exports.F        $includes $libs
$comp $compopts -c mitgcm_org_ocn_esmf_imports.F        $includes $libs
$comp $compopts -c mitgcm_org_ocn_esmf_driver.F         $includes $libs
\rm main.o

${arcommand} ${aropts} libmitgcm_org_ocn_esmf_driver.a *.o

cp *.a   ${APPLIB_PATH}/${PE}pe
cp *.mod ${APPF90MOD_PATH}/${PE}pe
\rm *.a *.mod
end

