C $Header: /u/gcmpack/MITgcm/pkg/cal/cal_time2load.F,v 1.3 2012/06/08 14:59:05 jmc Exp $
C $Name: checkpoint64g $

#include "CAL_OPTIONS.h"
#ifdef ALLOW_GCHEM
#include "GCHEM_OPTIONS.h"
#endif
#ifdef ALLOW_HG
#include "HG_OPTIONS.h"
#endif

      SUBROUTINE cal_get_periodic_interval(
     &                   intimeP, intime0, intime1, bWght, aWght,
     &                   forcingCycle, forcingPeriod, nowRead,
     &                   dt, myIter, myTime, myThid )

c     ==================================================================
C--   Convert approximate months (30-31 days) and years (360-372 days)
C     to exact calendar months and years.
c     ==================================================================

      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "cal.h"

#ifdef ALLOW_HG
#include "HG_SIZE.h"
#include "HG.h"
#endif
      
C     local variables
      _RL rdt, ForcingPeriod, forcingCycle, phiSec
      _RL dt
      INTEGER nForcingPeriods
      INTEGER Imytm, Ifprd, Ifcyc, Iftm
      INTEGER intimeP, intime0, intime1
      _RL tmp1Wght, tmp2Wght, aWght, bWght
      LOGICAL nowRead
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      LOGICAL first, changed
       
C Now calculate whether it is time to update the forcing arrays
      IF ( forcingPeriod .le. 2591999. ) THEN ! less than 1 month, use the actual frequency
       rdt=1. _d 0 / dt
       nForcingPeriods=
     &  int(ForcingCycle/ForcingPeriod+0.5 _d 0)
       Imytm=int(myTime*rdt+0.5 _d 0)
       Ifprd=int(ForcingPeriod*rdt+0.5 _d 0)
       Ifcyc=int(ForcingCycle*rdt+0.5 _d 0)
       Iftm=mod( Imytm+Ifcyc-Ifprd/2,Ifcyc)

       intime0=int(Iftm/Ifprd)
       intime1=mod(intime0+1,nForcingPeriods)
       tmp1Wght = FLOAT( Iftm-Ifprd*intime0 )
       tmp2Wght = FLOAT( Ifprd )
       aWght =  tmp1Wght / tmp2Wght
       bWght = 1. _d 0 - aWght

       intime0=intime0+1
       intime1=intime1+1
       
       nowRead = (Iftm-Ifprd*(intime0-1) .EQ. 0 ) 
      ENDIF
      
      IF ( forcingPeriod .GE. 2592000. .and. 
     &     forcingPeriod .LE. 2678400.      ) THEN ! 1 month, the cyclelength is not used
        phiSec = 0.
        CALL CAL_TIME2LOAD( phiSec, ForcingPeriod, deltaTClock,
     U                          nowRead,
     I                          myTime, myIter, myThid )
         
        CALL cal_GetMonthsRec(
     O     aWght, first, changed,
     O     intime0, intime1,
     I     mytime, myiter, mythid
     &     )     
        bWght =  1. _d 0 - aWght
      ENDIF
            
      IF ( forcingPeriod .GE. 31104000. .and. 
     &     forcingPeriod .LE. 31968000.      ) THEN ! 1 year
        phiSec = 0.
        CALL CAL_TIME2DUMP( phiSec, ForcingPeriod, deltaTClock,
     U                          nowRead,
     I                          myTime, myIter, myThid )
c        need to add more results          
      ENDIF

      RETURN
      END
