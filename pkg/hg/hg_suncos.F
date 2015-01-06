
#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

      SUBROUTINE hg_suncos(i,j,bi,bj,myTime,suncos )
!
!******************************************************************************
!  Subroutine hg_suncos computes the sum of cosine of the solar zenith
!  angle over a 24 hour day, as well as the total length of daylight. 
!  This is needed to scale the radsw.
!******************************************************************************
!
      IMPLICIT NONE
C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "HG_SIZE.h"
#include "HG.h"

      _RL suncos
      _RL myTime
      INTEGER i,j,bi,bj
            
      ! Local variables      
      _RL A0, A1, A2, A3, B1, B2, B3
      _RL lon,lat
      _RL LHR0, R, AHR, DEC, TIMLOC
                  
      !=================================================================
      ! hg_suncos begins here!
      !=================================================================

      !  Solar declination angle (low precision formula, good enough for us):
      A0 = 0.006918
      A1 = 0.399912
      A2 = 0.006758
      A3 = 0.002697
      B1 = 0.070257
      B2 = 0.000907
      B3 = 0.000148
      
      R  = 2.* PI * dble(mod(myTime, 31104000.))
     &          / 31104000. _d 0             !fraction of year

      DEC = A0 - A1*cos(  R) + B1*sin(  R)
     &         - A2*cos(2*R) + B2*sin(2*R)
     &         - A3*cos(3*R) + B3*sin(3*R)

C     latitude (rad)
      lat = yC(i,j,bi,bj) * pi / 180.0
C     longitude (rad)
      lon = xC(i,j,bi,bj) * pi / 180.0

      LHR0 = mod(mod(myTime, 31104000. ), 86400. ) / 3600. _d 0
      
      TIMLOC = LHR0 + xC(i,j,bi,bj)/15.0
         
      DO WHILE (TIMLOC .lt. 0)
         TIMLOC = TIMLOC + 24.0
      ENDDO

      DO WHILE (TIMLOC .gt. 24.0)
         TIMLOC = TIMLOC - 24.0
      ENDDO

      AHR = abs(TIMLOC - 12.) * 15.0 * PI / 180. _d 0

      ! Compute Cos(SZA)
      suncos = sin(lat) * sin(DEC) +
     &                    cos(lat) * cos(DEC) * cos(AHR)

      suncos = max(suncos, 0. _d 0)

      ! Return to calling program
      RETURN
      END
