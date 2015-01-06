#!/bin/csh -f
#
# Script to build ESMF driven stand alone MITgcm ocean 15L.
#
setenv BUILDROOT `pwd`
#setenv COMP_PROF  GFDL_HPCS
#setenv COMP_PROF  blackforest_withcam
setenv COMP_PROF  faulks
source mytools/comp_profile.BASE
source mytools/comp_profile.${COMP_PROF}
setenv TCSH_PATH  `which tcsh`
setenv APPLIB_PATH    ${BUILDROOT}/app/lib
setenv APPF90MOD_PATH ${BUILDROOT}/app/f90mod
setenv APPOBJ_PATH    ${BUILDROOT}/app/obj
setenv APPINC_PATH    ${BUILDROOT}/app/inc
setenv APPEXE_PATH    ${BUILDROOT}/app/exe

#
# Build MITgcm OCN computational code
setenv pesizelist_top  "1 2 4 8 16 32"
setenv pesizelist_top  "2"
foreach pe ( $pesizelist_top )
setenv pesizelist $pe
./build_mitgcm_org_ocn.sh
cd ${BUILDROOT}

#
# Build combined CAM stub computational and ESMF component interface layer
cd esmf_top/cam_stub
./comp1.sh
cd ${BUILDROOT}

#
# Build internal component interface layer for the MITgcm OCN ESMF component
###cd esmf_top/ocn_internal_comp_interface
###./comp1.sh
###cd ${BUILDROOT}

#
# Build ESMF component interface layer for the MITgcm OCN ESMF component
cd esmf_top/ocn_driver
./comp1.sh
cd ${BUILDROOT}

#
# Build combined CAM stub computational and ESMF component interface layer
cd esmf_top/mitgcm_ocn2cam
./comp1.sh
cd ${BUILDROOT}

#
# Build the composition layer and executable for the ocean only ESMF application 
cd esmf_top/ocn_only_app
./comp2.sh
cd ${BUILDROOT}

#
# Build the composition layer and executable for the ocean+CAM ESMF application 
cd esmf_top/cam_stub-mitgcm_ocn_app
./comp2.sh
cd ${BUILDROOT}
end
