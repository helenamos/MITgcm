C $Header: /u/gcmpack/MITgcm/pkg/ptracers/ptracers_forcing.F,v 1.16 2010/04/06 20:27:45 jmc Exp $
C $Name: checkpoint64g $

#include "PTRACERS_OPTIONS.h"

CBOP
C !ROUTINE: PTRACERS_FORCING

C !INTERFACE: ==========================================================
      SUBROUTINE PTRACERS_FORCING(
     I                            bi,bj,iMin,iMax,jMin,jMax,k,iTracer,
     U                            gPtracer,surfPtracer,
     I                            myIter,myTime,myThid )

C !DESCRIPTION:
C     Adds sources and sinks of passive tracers to the tendency arrays

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"

C !INPUT PARAMETERS: ===================================================
C  bi,bj                :: tile indices
C  iMin iMax jMin jMax  :: working range of tile for applying forcing
C  k                    :: vertical level number
C  iTracer              :: tracer number
C  gPtracer             :: the tendency array
C  surfPtracer          :: surface forcing term
C  myIter               :: time-step number
C  myTime               :: model time
C  myThid               :: thread number
      INTEGER bi,bj,iMin,iMax,jMin,jMax,k,iTracer
      _RL gPtracer(1-Olx:sNx+Olx,1-Oly:sNy+Oly,Nr,nSx,nSy)
      _RL surfPtracer(1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      INTEGER myIter
      _RL myTime
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  gPtracer       :: updates tendency array

#ifdef ALLOW_PTRACERS

C !LOCAL VARIABLES: ====================================================
C  i,j            :: loop indices
      INTEGER i,j
C     number of surface interface layer
      INTEGER kSurface
CEOP

      IF ( usingPCoords ) THEN
       kSurface = Nr
      ELSE
       kSurface = 1
      ENDIF

C--   Surface forcing term surfPtracer is previously computed by
C     PTRACERS_FORCING_SURF (and stored as surfaceForcingPTr)
C     because it is needed by KPP_TRANSPORT_PTR.

C--   move to forward_step by yanxu zhang
C--   to with GCHEM_CALC_TENDENCY
C--   to apply nsubtime for gchem package
C#ifdef ALLOW_GCHEM
C      IF ( useGCHEM )
C     &     CALL GCHEM_ADD_TENDENCY(
C     I                        bi,bj,iMin,iMax,jMin,jMax,k,
C     I                        iTracer,
C     I                        myTime,myIter, myThid)
C#endif /* ALLOW_GCHEM */
C--   end yanxu zhang, 7/19/2013

      IF ( k .EQ. kSurface ) THEN
        DO j=jMin,jMax
         DO i=iMin,iMax
          gPtracer(i,j,k,bi,bj) = gPtracer(i,j,k,bi,bj)
     &          + surfPtracer(i,j,bi,bj)
     &           *recip_drF(k)*recip_hFacC(i,j,k,bi,bj)
         ENDDO
        ENDDO
      ENDIF

#ifdef ALLOW_RBCS
      IF ( useRBCS ) THEN
        CALL RBCS_ADD_TENDENCY(
     I                          bi,bj,k,iTracer+2,
     I                          myTime, myThid )
      ENDIF
#endif /* ALLOW_RBCS */

#endif /* ALLOW_PTRACERS */

      RETURN
      END
