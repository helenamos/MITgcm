#!/bin/csh -f
#
#
set OPATH = ( ../../run/mmout )
set OINC  = ( ../../run       )
set OINC_ESMF  = ( ocn                                                     )
set UINC_ESMF  = ( utils                                                   )

source ${BUILDROOT}/mytools/comp_profile.BASE
source ${BUILDROOT}/mytools/comp_profile.${COMP_PROF}

foreach PE ( $pesizelist )
set includes = ( -I${APPF90MOD_PATH} -I${APPF90MOD_PATH}/${PE}pe ${compinc}      )
set libs     = ( -L${APPLIB_PATH} -L${APPLIB_PATH}/${PE}pe     \
                                  -lmitgcm_org_ocn_esmf_driver \
                                  -lcam_stub_driver            \
                                  -lmitgcm_org_ocn2cam         \
                                  -lmitgcm_org_ocn             \
                                  -lmitgcmrtl                  \
                                  ${complibs} -lesmf           \
                                  -lmitgcm_org_ocn_esmf_driver \
                                  -lmitgcm_org_ocn             \
                                  -lmitgcmrtl  )

$comp $compopts main.F $includes $libs
echo $comp $compopts main.F $includes $libs

if ( ! -d ${APPEXE_PATH}/${PE}pe ) then
 mkdir -p ${APPEXE_PATH}/${PE}pe
endif
set thedir = `pwd`
cp a.out ${APPEXE_PATH}/${PE}pe/${thedir:t}.exe
\rm *.o
end
