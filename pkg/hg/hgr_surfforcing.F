C $Header: /u/gcmpack/MITgcm/pkg/hg/hgr_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE hgr_SURFFORCING( Ptr, surfhgr,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE HG2_SURFFORCING                               |
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
      INTEGER myIter, myThid
      _RL myTime
      INTEGER iMin,iMax,jMin,jMax, bi, bj
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  surfhgr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nrmax)
      
#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG
#ifdef HGPRIVER

      _RL  Fluxhgr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nrmax)
      _RL  hgrrivero(nrmax)
#ifdef ALLOW_DIAGNOSTICS      
      _RL  hgrriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      CHARACTER*8 diagname
#endif      

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J,nriver

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            hgrriver_diag(i,j)=0d0
        ENDDO
      ENDDO
#endif
      
      DO j=jMin,jMax
        DO i=iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Localize variabls
C            kg/s -> mol/m2/s
            DO nriver=1,nrmax
             hgrrivero(nriver) = hgrriver(i,j,bi,bj,nriver)
     &           *recip_rA(i,j,bi,bj)*4.985
                           
             Fluxhgr(i,j,nriver)=hgrrivero(nriver)
#ifdef ALLOW_DIAGNOSTICS             
             hgrriver_diag(i,j)=hgrriver_diag(i,j)+Fluxhgr(i,j,nriver)
#endif             
            ENDDO
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j=jMin,jMax
          DO i=iMin,iMax
           DO nriver=1,nrmax
            SURFhgr(i,j,nriver)=
     &         HFacC(i,j,1,bi,bj)*Fluxhgr(i,j,nriver)*recip_drF(1)
           ENDDO
          ENDDO
         ENDDO
         
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'HGRRIVER'
        CALL DIAGNOSTICS_FILL( hgrriver_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )         
#endif
         
#endif
#endif
#endif
        RETURN
        END
