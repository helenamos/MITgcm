C $Header: /u/gcmpack/MITgcm/pkg/diagnostics/diagnostics_init_varia.F,v 1.12 2008/02/05 15:31:19 jmc Exp $
C $Name: checkpoint64g $

#include "DIAG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: DIAGNOSTICS_INIT_VARIA

C     !INTERFACE:
      SUBROUTINE DIAGNOSTICS_INIT_VARIA(
     I     myThid )

C     !DESCRIPTION:
C     Initialize the qdiag array which accumulates during integration

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_SIZE.h"
#include "DIAGNOSTICS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
      INTEGER i,j,k,bi,bj

C     Zero out the qdiag array which accumulates during integration
      DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
          DO k = 1,numDiags
            DO j = 1-Oly,sNy+Oly
              DO i = 1-Olx,sNx+Olx
                qdiag(i,j,k,bi,bj) = 0. _d 0
              ENDDO
            ENDDO
C     Zero out the counters for the qdiag array
            ndiag(k,bi,bj) = 0
          ENDDO
          DO k = 1,numlists
C     Zero out the index array for periodic averaging diagnostic
            pdiag(k,bi,bj) = 0
          ENDDO
        ENDDO
      ENDDO

C     Zero out the qSdiag array (statistics) which accumulates during integration
      DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
          DO k = 1,diagSt_size
            DO j = 0,nRegions
              DO i = 0,nStats
                qSdiag(i,j,k,bi,bj) = 0. _d 0
              ENDDO
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      CALL DIAGNOSTICS_READ_PICKUP( myThid )

      CALL DIAGNOSTICS_SUMMARY( startTime, nIter0, myThid )

      RETURN
      END
