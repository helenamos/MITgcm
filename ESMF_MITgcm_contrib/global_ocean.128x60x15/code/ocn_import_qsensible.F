C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/ocn_import_qsensible.F,v 1.1 2004/03/30 03:58:58 cnh Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

CStartOfInterface
      SUBROUTINE OCN_IMPORT_QSENSIBLE( myThid )
C     /==========================================================\
C     | SUBROUTINE OCN_IMPORT_QSENSIBLE                          |
C     | o Routine for importing sensible hflux    into ocean     |
C     |   component from coupling layer.                         |
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

C     Receive atmos. sensible heat flux
C     Already interpolated ointo ocean model grid by coupling layer.
C     CALL COMPRECV_R8TILES( ocnqSensibleName,
C    I     sNx, OLx, sNy, OLy, 1, nSx, nSy,
C    O     qSensible )

      RETURN
      END
