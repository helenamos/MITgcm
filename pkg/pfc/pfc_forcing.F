C $Header: /u/gcmpack/MITgcm/pkg/pfc/pfc_forcing.F,
C $Name: checkpoint64g $

C modified for external_forcing_DIC.F  August 1999
c
c modified swd Oct 01 and Feb 02, for use as package for c40_patch1
c modified to use with c44 and ptracers: swd May 2002
c modified to have carbonate and biological influences: swd June 2002
c modified for hg: swd Sep 2003
C modifed for PFCs  xz

#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PFC_FORCING( Ptr,
     &                       Gchem,
     &                       bi,bj,imin,imax,jmin,jmax,
     &                       myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE HG_FORCING                                   |
C     | o Calculate the changes of PFCi, PFCn, PFCP,|
C     |   through air-sea  fluxes  and through river            |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PFC_SIZE.h"
#include "PFC.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  Gchem(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      INTEGER i,j,bi, bj, imin, imax, jmin, jmax
c      INTEGER nriver     

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC
C     == Local variables ==
      _RL  SURPFCn(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  SURPFCi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  SURPFCP(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c #ifdef HGPRIVER
c      _RL  SURHgR(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nrmax) 
c #endif             
c #ifdef METHY_MODE      
c      _RL  SURDMHg(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c #endif

         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           SURPFCn(i,j)=0.d0
           SURPFCi(i,j)=0.d0
           SURPFCp(i,j)=0.d0
c #ifdef HGPRIVER
c           DO nriver=1,nrmax
c            SURhgr(i,j,nriver)=0.d0
c           ENDDO 
c #endif            
c #ifdef METHY_MODE
c           SURDMHg(i,j)=0.d0
c #endif
          ENDDO
         ENDDO

C pfcn air-sea interaction
       CALL pfcn_SURFFORCING( 
     I                   Ptr(1-OLx,1-OLy,1,1,1,1),
     O                   SURPFCn,
     I                    bi,bj,imin,imax,jmin,jmax,
     I                    myIter,myTime,myThid)

C pfci air-sea interaction and river runoff
       CALL pfci_SURFFORCING(
     I                     Ptr(1-OLx,1-OLy,1,1,1,1),
     O                     SURPFCi,
     I                    bi,bj,imin,imax,jmin,jmax,
     I                    myIter,myTime,myThid)

C pfcp river runoff
       CALL pfcp_SURFFORCING( 
     I                      Ptr(1-OLx,1-OLy,1,1,1,1), 
     O                      SURPFCp,
     I                    bi,bj,imin,imax,jmin,jmax,
     I                    myIter,myTime,myThid)

C hgr river runoff
c #ifdef HGPRIVER     
c       CALL hgr_SURFFORCING( Ptr(1-OLx,1-OLy,1,1,1,1), SURhgr,
c     &                    bi,bj,imin,imax,jmin,jmax,
c     &                    myIter,myTime,myThid) 
c #endif              
C DMHg air-sea exchange
c#ifdef METHY_MODE
c       CALL dmhg_SURFFORCING( Ptr(1-OLx,1-OLy,1,1,1,1), SURdmhg,
c     &                    bi,bj,imin,imax,jmin,jmax,
c      &                    myIter,myTime,myThid)
c #endif
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
          Gchem(i,j,1,bi,bj,ipfcn)=Gchem(i,j,1,bi,bj,ipfcn)+SURPFCn(i,j)
          Gchem(i,j,1,bi,bj,ipfci)=Gchem(i,j,1,bi,bj,ipfci)+SURPFCi(i,j)
          Gchem(i,j,1,bi,bj,ipfcp)=Gchem(i,j,1,bi,bj,ipfcp)+SURPFCp(i,j)
c	#ifdef HGPRIVER
c	           DO nriver=1,nrmax
c	            Gchem(i,j,1,bi,bj,ihgR+nriver-1)=
c	     &      Gchem(i,j,1,bi,bj,ihgR+nriver-1)+SURhgr(i,j,nriver)
c	           ENDDO
c	#endif           
c	#ifdef METHY_MODE
c	           Gchem(i,j,1,bi,bj,idmhg)=Gchem(i,j,1,bi,bj,idmhg)
c	     &          +SURdmhg(i,j)
c	#endif           
          ENDDO
         ENDDO

#endif
#endif

       RETURN
       END
