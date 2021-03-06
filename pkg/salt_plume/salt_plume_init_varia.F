C $Header: /u/gcmpack/MITgcm/pkg/salt_plume/salt_plume_init_varia.F,v 1.2 2007/11/28 17:55:36 dimitri Exp $
C $Name: checkpoint64g $

#include "SALT_PLUME_OPTIONS.h"

CBOP 0
C     !ROUTINE: SALT_PLUME_INIT_VARIA
C     !INTERFACE:
      SUBROUTINE SALT_PLUME_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize SALT_PLUME variables

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "SALT_PLUME.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_SALT_PLUME

C     !LOCAL VARIABLES:
      INTEGER i,j,bi,bj

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)

C     Initialize arrays in common blocks :
C     2-dim.
        DO j=1-Oly,sNy+OLy
         DO i=1-Olx,sNx+Olx
          SaltPlumeDepth (i,j,bi,bj) = 0. _d 0
          saltPlumeFlux  (i,j,bi,bj) = 0. _d 0
         ENDDO
        ENDDO

C- end bi,bj loops
       ENDDO
      ENDDO

#endif /* ALLOW_SALT_PLUME */

      RETURN
      END
