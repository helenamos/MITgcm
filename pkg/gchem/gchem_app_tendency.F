#include "GCHEM_OPTIONS.h"

C !ROUTINE: GCHEM_APP_TENDENCY

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_APP_TENDENCY(
     I     myTime, myIter, myThid )

C !DESCRIPTION: a wrapper to calculate gchemtendency and apply this 
C               tendency, with the support of shorter time step for
C               gchem package
C               added by yanxu zhang, 7/19/2013

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "GCHEM.h"
#include "GCHEM_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
C  myTime               :: current time
C  myIter               :: current timestep
C  myThid               :: thread number
      _RL myTime,myTimeo
      INTEGER myIter, myThid      
      INTEGER isubtime
      INTEGER bi,bj
      INTEGER iMin, iMax, jMin, jMax
      INTEGER i,j,k
      INTEGER iTracer

C     Loop ranges for daughter routines
      iMin = 1-OLx+2
      iMax = sNx+OLx-1
      jMin = 1-OLy+2
      jMax = sNy+OLy-1
            
C     Loop over subtime steps
      DO isubtime=1,nsubtime                 
C     Local time
      myTimeo = myTime + dble(isubtime-1) / dble(nsubtime) * deltaTclock
                    
C     Calculate Gchem tendency          
      CALL GCHEM_CALC_TENDENCY( myTimeo, myIter, myThid )

C     Loop over tiles 
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO bj=myByLo(myThid),myByHi(myThid)
            
C     Loop over tracers
      DO iTracer=1,PTRACERS_numInUse

C     Loop over levels            
      DO k=1,Nr

C     Apply Gchem tendency to the main tendency array
C     Note: the tendency is lower by a factor of nsubtime
C           because of multiple adding                                                                            
      CALL GCHEM_ADD_TENDENCY(
     I                        bi,bj,iMin,iMax,jMin,jMax,k,
     I                        iTracer,
     I                        myTime,myIter, myThid)

      ENDDO  ! k
      ENDDO  ! iTracer
      ENDDO  ! bj
      ENDDO  ! bi
      ENDDO  ! isubtime
      
      RETURN
      END
