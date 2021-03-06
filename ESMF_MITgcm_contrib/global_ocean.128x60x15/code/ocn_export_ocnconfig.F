C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/ocn_export_ocnconfig.F,v 1.1 2004/03/30 03:58:56 cnh Exp $
C $Name:  $  

#include "CPP_OPTIONS.h"

CStartOfInterface
      SUBROUTINE OCN_EXPORT_OCNCONFIG( myThid )
C     /==========================================================\
C     | SUBROUTINE OCN_EXPORT_OCNCONFIG                          |
C     | o Routine for exporting ocean config to coupling level.  |
C     |==========================================================|
C     | This version talks to the MIT Coupler. It uses the MIT   |
C     | Coupler "checkpoint1" library calls.                     |
C     \==========================================================/
      IMPLICIT NONE

C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "GRID.h"
#include "OCNIDS.h"

C     == Routine arguments ==
C     myThid - Thread number for this instance of the routine
      INTEGER myThid
CEndOfInterface

C     == Local variables ==

C     Send my configuration information to the coupler
C     o Send ocean model bathymetry map
C     CALL COMPSEND_R8TILES( ocnBathyName,
C    I     sNx, OLx, sNy, OLy, 1, nSx, nSy, R_low )

      RETURN
      END
