C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_partition.F,v 1.10 2010/03/16 00:14:47 jmc Exp $
C $Name: checkpoint64g $

C To calculate the chemistry of Hg species in the ocean, yxzhang, 5/30/13
C

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE HG_PARTITION( Ptr,
     &                         bi,bj,imin,imax,jmin,jmax,
     &                         myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE HG_PARTITION                                  |
C     | o Calculate the changes to Hg species because            |
C     |   of partitioning onto suspended particulate matter      |
C     |   based on Anne Sorerensen 2010 paper                    |
C     |   We assume an instantaneous equilibrium                 |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "HG_SIZE.h"
#include "HG.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
#ifdef ALLOW_DIAGNOSTICS      
      _RL  hg2part_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#ifdef METHY_MODE      
      _RL  mmhgpart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#endif            
      CHARACTER*8 diagname
#endif
      _RL  TOT_HG, FRAC_DISSOLVED, poco, doco
      INTEGER i,j,k,bi, bj, imin, imax, jmin, jmax
      _RL  hg2_old,hgp_old,hg2_new,hgp_new
#ifdef METHY_MODE
      _RL  mmhg_old,mmhgp_old,mmhg_new,mmhgp_new
#endif      

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG

C     == Parameters
C     -- Partition coefficient
      _RL Kd_hg2_poc  ! L/kg
      data  Kd_hg2_poc /1264910./
#ifdef METHY_MODE 
      _RL Kd_mmhg_poc  ! L/kg
      data Kd_mmhg_poc /126491./
#endif
C     == Start calculation

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO k=1,Nr
        DO j=jMin,jMax
          DO i=iMin,iMax
            hg2part_diag(i,j,k)=0d0
#ifdef METHY_MODE            
            mmhgpart_diag(i,j,k)=0d0
#endif            
          ENDDO
        ENDDO
      ENDDO
#endif

      DO j=jMin,jMax
       DO i=iMin,iMax
        DO k=1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
C     instantaneous equilibrium
#ifdef PART_EQ             
C     == Localize variables
           poco = max(poc(i,j,k,bi,bj),0d0)
           doco = max(doc(i,j,k,bi,bj),0d0)
 
C     == Hg2 and HgP
           hg2_old = max(Ptr(i,j,k,bi,bj,ihg2),0d0)
           hgp_old = max(Ptr(i,j,k,bi,bj,ihgp),0d0)
           TOT_HG = hg2_old + hgp_old
           IF (TOT_HG .gt. 0. _d 0) THEN
             IF (doco .gt. 4.99 _d 2) THEN ! coast
               FRAC_DISSOLVED = 1. _d 0 /
     &             (1. _d 0 + Kd_hg2_poc * 0.2  * poco
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
             ELSE
               FRAC_DISSOLVED = 1. _d 0 /
     &             (1. _d 0 + Kd_hg2_poc * poco 
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
             ENDIF
             hg2_new = TOT_HG * FRAC_DISSOLVED
             hgp_new = TOT_HG - hg2_new
             Ptr(i,j,k,bi,bj,ihg2) = hg2_new
             Ptr(i,j,k,bi,bj,ihgp) = hgp_new
#ifdef ALLOW_DIAGNOSTICS
             hg2part_diag(i,j,k) = (hg2_old - hg2_new) / deltaTclock
#endif             
           ENDIF

C     == MMHg and MMHgp
#ifdef METHY_MODE
           mmhg_old = max(Ptr(i,j,k,bi,bj,immhg),0d0)
           mmhgp_old = max(Ptr(i,j,k,bi,bj,immhgp),0d0)
           TOT_HG = mmhg_old + mmhgp_old
           IF (TOT_HG .gt. 0. _d 0) THEN
             FRAC_DISSOLVED = 1. _d 0 /
     &             (1. _d 0 + Kd_mmhg_poc * poco 
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
             mmhg_new = TOT_HG * FRAC_DISSOLVED
             mmhgp_new = TOT_HG - mmhg_new
             Ptr(i,j,k,bi,bj,immhg) = mmhg_new
             Ptr(i,j,k,bi,bj,immhgp) = mmhgp_new
#ifdef ALLOW_DIAGNOSTICS
             mmhgpart_diag(i,j,k) = (mmhg_old - mmhg_new) / deltaTclock
#endif             
           ENDIF
#endif
#endif

C      no partitioning  
#ifdef PART_NO
#endif

C      slow dissolution or sorption
#ifdef PART_DI
#endif
         ENDIF
        ENDDO

       ENDDO
      ENDDO

c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'HG2PART '
        CALL DIAGNOSTICS_FILL( hg2part_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#ifdef METHY_MODE     
        WRITE(diagname,'(A8)') 'MMHGPART'
        CALL DIAGNOSTICS_FILL( mmhgpart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#endif     
#endif

#endif
#endif

       RETURN
       END
