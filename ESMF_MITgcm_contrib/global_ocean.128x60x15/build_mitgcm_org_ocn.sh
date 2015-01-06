#!/bin/csh -f
#
# Script to build ESMF component libraries for MITgcm ocean 15L.
#
source mytools/comp_profile.BASE
source mytools/comp_profile.${COMP_PROF}

#
# Build individual component core code
#
# MITgcm ocn
# ==========
foreach PE ( $pesizelist )
cp code/SIZE.h.${PE}pe code/SIZE.h
cd run
if ( -f Makefile ) then
 make Clean
endif

# ESMF component build. Creates an ESMF component that can be coupled through
# the ESMF superstructure layer.
${gm2command} ${gm2mods} ${gm2optfile} ${gm2adoptfile}
make depend
make small_f

# Copy the scripts from the download directory making platform specific mods
# along the way.
foreach f ( ../mytools/* )
 if ( -f $f ) then
  cp $f .
  cat $f | sed s'|<TCSH_PATH>|'${TCSH_PATH}'|g' > temp.$$
  mv temp.$$ ${f:t}
  chmod +x ${f:t}
 endif
end
./mkmod.sh ocn

# Copy products to application build library and include directories
if ( ! -d ${APPLIB_PATH}${PE}pe ) then
 mkdir -p ${APPLIB_PATH}/${PE}pe
endif
if ( ! -d ${APPF90MOD_PATH}${PE}pe ) then
 mkdir -p ${APPF90MOD_PATH}/${PE}pe
endif
if ( ! -d ${APPOBJ_PATH}${PE}pe ) then
 mkdir -p ${APPOBJ_PATH}/${PE}pe
endif
if ( ! -d ${APPINC_PATH}${PE}pe ) then
 mkdir -p ${APPINC_PATH}/${PE}pe
endif
if ( ! -d ${APPEXE_PATH}${PE}pe ) then
 mkdir -p ${APPEXE_PATH}/${PE}pe
endif
cp mmout/*.a   ${APPLIB_PATH}/${PE}pe
cp mmout/*.mod ${APPF90MOD_PATH}/${PE}pe
cp mmout/*.o   ${APPOBJ_PATH}/${PE}pe
cp mmout/*.h   ${APPINC_PATH}/${PE}pe
cd ..
end
