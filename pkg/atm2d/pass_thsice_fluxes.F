C $Header: /u/gcmpack/MITgcm/pkg/atm2d/pass_thsice_fluxes.F,v 1.2 2007/10/08 23:48:28 jmc Exp $
C $Name: checkpoint64g $

#include "ctrparam.h"
#include "ATM2D_OPTIONS.h"

C     !INTERFACE:
      SUBROUTINE PASS_THSICE_FLUXES( myThid )
C     *==========================================================*
C     | Called after each atm time step - put Qneti, dF/dT, solar|
c     | for seaice to use, accumlate precip fluxes for thsice pkg|
C     *==========================================================*
        IMPLICIT NONE

#include "ATMSIZE.h"
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"

C     === Global SeaIce Variables ===
#include "THSICE_PARAMS.h"
#include "THSICE_VARS.h"

C     === Atmos/Ocean/Seaice Interface Variables ===
#include "ATM2D_VARS.h"


C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid - Thread no. that called this routine.
      INTEGER myThid

C     LOCAL VARIABLES:
      INTEGER i,j

      DO j=1, sNy
       DO i=1, sNx

         IF (iceMask(i,j,1,1) .GT. 0. _d 0) THEN
           netSW(i,j) = solarinc_2D(i,j)*(1. _d 0 - siceAlb(i,j,1,1)) ! convert to netSW
           sFlx(i,j,0)= -qneti_2D(i,j) -netSW(i,j) +
     &                  Tsrf(i,j,1,1)*dFdT_ice_2D(i,j)
           sFlx(i,j,1)= -qneti_2D(i,j) -netSW(i,j)
           sFlx(i,j,2)= -dFdT_ice_2D(i,j)

C          Note conversion to ice model sign convention below
           sum_prcIce(i,j) = sum_prcIce(i,j) - precipi_2D(i,j)*rhofw
           sum_evapIce(i,j) = sum_evapIce(i,j) - evapi_2D(i,j)*rhofw
           IF (Tair_2D(i,j) .LE. 0. _d 0)
     &      sum_snowPrc(i,j) = sum_snowPrc(i,j) - precipi_2D(i,j)*rhofw

         ENDIF

       ENDDO
      ENDDO


      RETURN
      END
