C $Header: /u/gcmpack/MITgcm/pkg/hg/hg2_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE pcbp_SURFFORCING( PTR, surfpcbp,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE PCBp_SURFFORCING                              |
C     | particle bound PCB discharged by river                   |
C     |                                                          |
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
#include "PCB_SIZE.h"
#include "PCB.h"

C     == Routine arguments ==
      INTEGER myIter, myThid
      _RL  myTime
      _RL  Ptr     (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  surfpcbp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  Fluxpcbp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL  pcbprivero   ! Not considering rivers for PCBs (hma, 11 Jul 2014)
#ifdef ALLOW_DIAGNOSTICS      
c Not considering rivers for PCBs (hma, 11 Jul 2014) 
c      _RL  pcbpriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      CHARACTER*8 diagname
#endif      
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J

C Initialize diagnostics

c Not considering rivers for PCBs (hma, 11 Jul 2014)
c #ifdef ALLOW_DIAGNOSTICS
c      DO j = jMin,jMax
c        DO i = iMin,iMax
c            pcbpriver_diag(i,j) = 0d0
c        ENDDO
c      ENDDO
c #endif
      
      DO j = jMin,jMax
        DO i = iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN

C Localize variabls

c Not considering rivers for PCBs (hma, 11 Jul 2014)
C            kg/s -> mol/m2/s
c             pcbprivero = PCBpriver(i,j,bi,bj)
c     &             *recip_rA(i,j,bi,bj)*1000.d0/Mb
c                           
c             Fluxpcbp(i,j) = pcbprivero
c#ifdef ALLOW_DIAGNOSTICS             
c             pcbpriver_diag(i,j) = FluxPCBp(i,j)
c#endif             
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j = jMin,jMax
          DO i = iMin,iMax
           SURFPCBP(i,j)=
     &         HFacC(i,j,1,bi,bj)*Fluxpcbp(i,j)*recip_drF(1)
          ENDDO
         ENDDO
         
c write diagnostics

c Not considering rivers for PCBs (hma, 11 Jul 2014)
c#ifdef ALLOW_DIAGNOSTICS
c        WRITE(diagname,'(A8)') 'PCBpRIVR'
c        CALL DIAGNOSTICS_FILL( pcbpriver_diag(1-Olx,1-Oly), diagname,
c     &                         0,1,2,bi,bj,myThid )         
c#endif
         
#endif
#endif

        RETURN
        END
