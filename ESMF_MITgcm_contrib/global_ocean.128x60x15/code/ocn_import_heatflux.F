C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/ocn_import_heatflux.F,v 1.1 2004/03/30 03:58:58 cnh Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

CStartOfInterface
      SUBROUTINE OCN_IMPORT_HEATFLUX( myThid )
C     /==========================================================\
C     | SUBROUTINE OCN_IMPORT_HEATFLUX                           |
C     | o Routine for importing surface heat flux from coupling  |
C     |   layer.                                                 |
C     |==========================================================|
C     | This version talks to the MIT Coupler. It uses the       |
C     | MIT Coupler "checkpoint 1" library calls.                |
C     \==========================================================/
      IMPLICIT NONE

C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OCNIDS.h"
#include "OCNCPL.h"

C     == Routine arguments ==
C     myThid - Thread number for this instance of the routine
      INTEGER myThid
CEndOfInterface

C     Receive surface heatflux from coupling layer.
C     Heatflux will have been gridded onto ocean grid.
C     CALL COMPRECV_R8TILES( ocnHeatFluxName,
C    I     sNx, OLx, sNy, OLy, 1, nSx, nSy,
C    O     HeatFlux )

      RETURN
      END
