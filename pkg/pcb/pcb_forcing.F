C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_forcing.F,
C $Name: checkpoint64g $

C modified for external_forcing_DIC.F  August 1999
c
c modified swd Oct 01 and Feb 02, for use as package for c40_patch1
c modified to use with c44 and ptracers: swd May 2002
c modified to have carbonate and biological influences: swd June 2002
c modified for hg: swd Sep 2003
C modifed for PCBs  xz

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PCB_FORCING( Ptr,
     &                       Gchem,
     &                       bi,bj,imin,imax,jmin,jmax,
     &                       myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE HG_FORCING                                   |
C     | o Calculate the changes of PCBi, PCBa, PCBP,|
C     |   through air-sea  fluxes  and through river            |
C     |==========================================================|
      IMPLICIT NONE

      !-------------------------------------------------------------
      ! Global variables
      !-------------------------------------------------------------
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PCB_SIZE.h"
#include "PCB.h"

      !-------------------------------------------------------------
      ! Routine arguments
      !-------------------------------------------------------------
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  Gchem(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      INTEGER i,j,bi, bj, imin, imax, jmin, jmax
c      INTEGER nriver     

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB
      !-------------------------------------------------------------
      ! Local variables
      !-------------------------------------------------------------
      _RL  SURPCBa(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      _RL  SURPCBi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  SURPCBP(1-OLx:sNx+OLx,1-OLy:sNy+OLy)


c #ifdef HGPRIVER
c      _RL  SURHgR(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nrmax) 
c #endif             
c #ifdef METHY_MODE      
c      _RL  SURDMHg(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c #endif

         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           SURPCBa(i,j)=0.d0
c Remove PCBi tracer. (hma, 15 Jul 2014)
c           SURPCBi(i,j)=0.d0
           SURPCBp(i,j)=0.d0
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

C pcba air-sea interaction
       CALL pcba_SURFFORCING( 
     I                   Ptr(1-OLx,1-OLy,1,1,1,1),
     O                   SURPCBa,
     I                    bi,bj,imin,imax,jmin,jmax,
     I                    myIter,myTime,myThid)

C pcbi air-sea interaction and river runoff
c Remove PCBi tracer. (hma, 15 Jul 2014)
c       CALL pcbi_SURFFORCING(
c     I                     Ptr(1-OLx,1-OLy,1,1,1,1),
c     O                     SURPCBi,
c     I                    bi,bj,imin,imax,jmin,jmax,
c     I                    myIter,myTime,myThid)

C pcbp river runoff
       CALL pcbp_SURFFORCING( 
     I                      Ptr(1-OLx,1-OLy,1,1,1,1), 
     O                      SURPCBp,
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
          Gchem(i,j,1,bi,bj,ipcba)=Gchem(i,j,1,bi,bj,ipcba)+SURPCBa(i,j)
c Remove PCBi tracer. (hma, 15 Jul 2014)
c          Gchem(i,j,1,bi,bj,ipcbi)=Gchem(i,j,1,bi,bj,ipcbi)+SURPCBi(i,j)
          Gchem(i,j,1,bi,bj,ipcbp)=Gchem(i,j,1,bi,bj,ipcbp)+SURPCBp(i,j)
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
