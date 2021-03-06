C $Header: /u/gcmpack/MITgcm/pkg/salt_plume/salt_plume_frac.F,v 1.7 2012/01/31 17:33:31 mlosch Exp $
C $Name: checkpoint64g $

#include "SALT_PLUME_OPTIONS.h"

CBOP
C     !ROUTINE: SALT_PLUME_FRAC
C     !INTERFACE:
      SUBROUTINE SALT_PLUME_FRAC(
     I                  imax, fact,SPDepth,
     U                  plumek,
     I                  myTime, myIter, myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE SALT_PLUME_FRAC
C     | o Compute saltplume penetration.
C     *==========================================================*
C     | Compute fraction of saltplume (flux) penetrating to
C     | specified depth, plumek, due to rejected salt
C     | during freezing.
C     | For example, if surface value is Saltplume0,
C     | and each level gets equal fraction 1/5 down to SPDepth=5,
C     | SALT_PLUME_FRAC will report plumek = 4/5 on output if the input
C     | plumek = 1. Else, output plumek = 0.                
C     | Reference : Duffy et al, (GRL 1999)
C     |
C     | =====
C     | Written by   : ATN (based on SWFRAC)
C     | Date         : Sep 13, 2007
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "SALT_PLUME.h"

C     !INPUT/OUTPUT PARAMETERS:
C     input arguments
C     imax    :: number of vertical grid points
C     fact    :: scale  factor to apply to depth array
C     SPDpeth :: corresponding SaltPlumeDepth(i,j) at this grid point
C     myTime  :: Current time in simulation
C     myIter  :: Current iteration number in simulation
C     myThid  :: My Thread Id. number
      INTEGER imax
      _RL     fact
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
C     input/output arguments
C     plumek :: on input: vertical depth for desired plume fraction
C               (fact*plumek) is negative distance (m) from surface
C     plumek :: on output: saltplume contribution fraction
      _RL     plumek(imax), SPDepth(imax)
CEOP

#ifdef ALLOW_SALT_PLUME

C     !LOCAL VARIABLES:
      _RL facz, dd, dd20
      INTEGER i
#ifndef TARGET_NEC_SX
      INTEGER kk
#endif
      _RL     one, two, three, tempN, tempN20
      parameter( one = 1. _d 0, two = 2. _d 0, three = 3. _d 0 )
C     This is an abbreviation of 1./(exp(1.)-1.)
      _RL     recip_expOneM1
      parameter( recip_expOneM1 = 0.581976706869326343 )

      DO i = 1,imax
       facz = abs(fact*plumek(i))
       IF (SPDepth(i).GT.facz) THEN

C     Default: uniform distribution, PlumeMethod=1, Npower=0
        IF (PlumeMethod .EQ. 1) THEN
         dd20 = (abs(SPDepth(i)))
#ifdef TARGET_NEC_SX
         IF ( dd20 .GT. 0. _d 0 ) THEN
          tempN   = (facz/dd20)
C     crazy attempt to make the code faster and raise tempN to (Npower+1)
          IF (Npower .GT. 0) tempN = tempN*tempN**Npower          
         ELSE
          tempN = 0. _d 0
         ENDIF
         plumek(i) = one - min(one,tempN)
#else
         tempN   = one          !input depth temp
         tempN20 = one
         DO kk=1,Npower+1
          tempN   = facz*tempN  !raise to the Npower+1
          tempN20 = dd20*tempN20
         ENDDO
         plumek(i) = one - min(one,tempN/tempN20)
#endif /* TARGET_NEC_SX */

        ELSEIF (PlumeMethod .EQ. 2) THEN !exponential distribution
         dd = abs(SPDepth(i))
CML         plumek(i) = one - (exp(facz/dd)-one)/
CML     &                     (exp(one    )-one)
         plumek(i) = one - (exp(facz/dd)-one)*recip_expOneM1

C     PlumeMethod = 3, distribute salt LINEARLY between SPDepth and 
C     SPDepth/SPovershoot
C     (1-SPovershoot) has already been taken into account in SPDepth 
C     calculation, i.e., SPDepth = SPovershoot*SPDepth.
        ELSEIF (PlumeMethod .EQ. 3) THEN !overshoot 20%
         dd20 = (abs(SPDepth(i)))
         dd   = dd20/SPovershoot
         IF( (facz.GE.dd).AND.(facz.LT.dd20) ) THEN
          plumek(i) = one - min(one,(facz-dd)/(dd20-dd))
         ELSE
          plumek(i) = one
         ENDIF
            
C     PlumeMethod = 5, dumping all salt at the top layer
        ELSEIF (PlumeMethod .EQ. 5) THEN
         dd   = 0.
         dd20 = one
         IF( (facz.GE.dd).AND.(facz.LT.dd20) ) THEN
CML          plumek(i) = one - min(one,(facz-dd)/(dd20-dd))
          plumek(i) = one - min(one,facz)
         ELSE
          plumek(i) = 0.
         ENDIF
        ELSEIF (PlumeMethod .EQ. 6) THEN
C     PLumeMethod = 6, currently only works for Npower = 1 and 2.
         dd20 = (abs(SPDepth(i)))
#ifdef TARGET_NEC_SX
         IF ( dd20 .GT. 0. _d 0 ) THEN
          tempN   = (facz/dd20)
C     crazy attempt to make the code faster and raise tempN to (Npower+1)
          IF (Npower .GT. 0) tempN = tempN*tempN**Npower          
          tempN20 = 1. _d 0/dd20
         ELSE
          tempN   = 0. _d 0
          tempN20 = 0. _d 0
         ENDIF
         IF(Npower.EQ.1) THEN   !Npower=1
          plumek(i) = one - min(one,two*tempN20*facz-tempN)
         ELSE                   !Npower=2
          plumek(i) = one - min(one,
     &         three*tempN20*facz - three*tempN20*tempN20*facz*facz
     &         + tempN)
         ENDIF
#else
         tempN   = one          !input depth temp
         tempN20 = one
         DO kk=1,Npower+1
          tempN   = facz*tempN  !raise to the Npower+1
          tempN20 = dd20*tempN20
         ENDDO
         IF(Npower.EQ.1) THEN   !Npower=1
          plumek(i) = one - min(one,two/dd20*facz-tempN/tempN20)
         ELSE                   !Npower=2
          plumek(i) = one - min(one,
     &         three/dd20*facz - three/(dd20*dd20)*facz*facz
     &         + tempN/tempN20)
         ENDIF
#endif /* TARGET_NEC_SX */
               
#ifndef TARGET_NEC_SX
        ELSE
         WRITE(*,*) 'salt_plume_frac: PLumeMethod =', PLumeMethod,
     &        'not implemented'
         STOP 'ABNORMAL in S/R SALT_PLUME_FRAC'
#endif /* not TARGET_NEC_SX */
        ENDIF
       ELSE
        plumek(i) = 0. _d 0
       ENDIF
      ENDDO
      
#endif /* ALLOW_SALT_PLUME */

      RETURN
      END
