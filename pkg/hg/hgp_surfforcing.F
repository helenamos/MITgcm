C $Header: /u/gcmpack/MITgcm/pkg/hg/hg2_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE hgp_SURFFORCING( PTR, surfhgp,
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
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  surfhgp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  Fluxhgp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  hgprivero
#ifdef ALLOW_DIAGNOSTICS      
      _RL  hgpriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      CHARACTER*8 diagname
#endif      
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            hgpriver_diag(i,j)=0d0
        ENDDO
      ENDDO
#endif
      
      DO j=jMin,jMax
        DO i=iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Localize variabls
C            kg/s -> mol/m2/s
             hgprivero = Hgpriver(i,j,bi,bj)*recip_rA(i,j,bi,bj)*4.985
                           
             Fluxhgp(i,j)=hgprivero
#ifdef ALLOW_DIAGNOSTICS             
             hgpriver_diag(i,j)=FluxHGp(i,j)
#endif             
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFHGP(i,j)=
     &         HFacC(i,j,1,bi,bj)*Fluxhgp(i,j)*recip_drF(1)
          ENDDO
         ENDDO
         
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'HGPRIVER'
        CALL DIAGNOSTICS_FILL( hgpriver_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )         
#endif
         
#endif
#endif

        RETURN
        END
