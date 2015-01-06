C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/driver_run.F,v 1.3 2005/05/12 03:00:39 cnh Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: DRIVER_RUN
C     !INTERFACE:
      SUBROUTINE DRIVER_RUN(      
     I              atm_HeatFlux, atm_TauX, atm_TauY,
     I              atm_Qlatent, atm_Qsensible, atm_Qlongwave,
     I              atm_Qshortwave,
     I              atm_uVelGround, atm_vVelGround,
     I              atm_FWFlux,
     I              atm_Hatm,
     O              ocn_SSTocn, ocn_Hocn,
     O              ocn_uVelocn, ocn_Vvelocn,
     O              ocn_rVolTop,
     U              myCurrentTime, myCurrentIter, 
     U              iLoop,
     I              nTimeS, myThid)

C     !DESCRIPTION: \bv
C     *==================================================================
C     | SUBROUTINE driver_run
C     | o External driver control routine for MITgcm forward step
C     |   execution phase. 
C     *==================================================================
C     |
C     | DRIVER routines are used to control the MITgcm code from an external
C     | driver. This routine invokes the forward phase of code execution.
C     | The driver here is written for an ocean configuration and is designed
C     | for use with either an argument based call/return interface or with a
C     | messaging based "event loop" interface.
C     |
C     *==================================================================
C     \ev

C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "OCNCPL.h"
#include "DYNVARS.h"

C     == Routine arguments ==
      _RL atm_HeatFlux(   1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_TauX(       1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_TauY(       1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_Qlatent(    1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_Qsensible(  1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_Qlongwave(  1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_Qshortwave( 1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_uVelGround( 1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_vVelGround( 1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_FWFlux(     1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atm_Hatm(       1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ocn_SSTocn(     1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ocn_Hocn(       1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ocn_uVelocn(    1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ocn_vVelocn(    1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ocn_rVolTop(    1-OLx:sNx+OLx,1-OLy:sNy+OLy)
C      myThid :: Thread number for this instance of the routine
      INTEGER myThid
      INTEGER myCurrentIter
      _RL     myCurrentTime
      INTEGER nTimeS
      INTEGER iLoop
C     == Local variables ==
      INTEGER i,j,bi,bj
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*13 fNam
      INTEGER iStep
CEOP

      CALL COMP_OCN_PUSH_CONTEXT(1)

      myThid = 1
!cnhdbg      CLOSE(errorMessageUnit)
!cnhdbg      CLOSE(standardMessageUnit)
!     myProcessStr  = '0000'
!cnhdbg      WRITE(fNam,'(A,A)') 'STDOUT.', myProcessStr(1:4)
!cnhdbg      OPEN(standardMessageUnit,FILE=fNam,STATUS='old',POSITION='append')
!cnhdbg      WRITE(fNam,'(A,A)') 'STDERR.', myProcessStr(1:4)
!cnhdbg      OPEN(errorMessageUnit,FILE=fNam,STATUS='old',POSITION='append')
!cnhdbg      WRITE(msgBuf,*) 'Entering OCN driver_run'
!cnhdbg      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
!cnhdbg     &                    SQUEEZE_RIGHT , 1)

C     Extract the import fields
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          HeatFlux(   i,j,bi,bj)=atm_HeatFlux(  i,j)
          TauX(       i,j,bi,bj)=atm_tauX(      i,j)
          TauY(       i,j,bi,bj)=atm_tauY(      i,j)
          Qlatent(    i,j,bi,bj)=atm_qLatent(   i,j)
          Qsensible(  i,j,bi,bj)=atm_qSensible( i,j)
          Qlongwave(  i,j,bi,bj)=atm_qLongwave( i,j)
          Qshortwave( i,j,bi,bj)=atm_qShortwave(i,j)
          uVelGround( i,j,bi,bj)=atm_uVelGround(i,j)
          vVelGround( i,j,bi,bj)=atm_vVelGround(i,j)
          FWFlux(     i,j,bi,bj)=atm_FWFlux(    i,j)
          Hatm(       i,j,bi,bj)=atm_Hatm(      i,j)
         ENDDO
        ENDDO
       ENDDO
      ENDDO


C     myThid = 1
      myCurrentTime = startTime
      myCurrentIter = nIter0
C     myThid        = 1
C     nTimesteps    = 1

      CALL MONITOR( myCurrentIter, myCurrentTime, myThid )

      DO iStep = 1, nTimeS
       CALL FORWARD_STEP_EXECUTE( iLoop, myCurrentTime, 
     &                            myCurrentIter, myThid )
       iLoop = iLoop+1
       CALL FORWARD_STEP_SETUP(   iLoop, myCurrentTime, 
     &                            myCurrentIter, myThid )
      ENDDO

      CALL FORWARD_STEP_EXECUTE( iLoop, myCurrentTime, 
     &                            myCurrentIter, myThid  )
      iLoop = iLoop+1
      CALL FORWARD_STEP_SETUP(    iLoop, myCurrentTime, 
     &                            myCurrentIter, myThid )

      WRITE(41,*) 'MAXVAL SSTocn2cpl = ', MAXVAL(SSTocn2cpl(1:snx,1:sny,:,:))
      WRITE(41,*) 'MINVAL SSTocn2cpl = ', MINVAL(SSTocn2cpl(1:snx,1:sny,:,:))

C     Fill the export fields
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
          ocn_SSTocn(i,j) = SSTocn2cpl(i,j,bi,bj)
          ocn_Hocn(  i,j) = R_low(     i,j,bi,bj)
          ocn_uVelocn(  i,j) = uVel(     i,j,bi,bj,1)
          ocn_vVelocn(  i,j) = vVel(     i,j,bi,bj,1)
          ocn_rVolTop(  i,j) =
     &     _recip_hFacC(i,j,1,bi,bj)*recip_drF(1)*recip_rA(i,j,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      WRITE(41,*) 'D_RUN MAXVAL ocn_SSTocn = ', MAXVAL(ocn_SSTocn(1:snx,1:sny))
      WRITE(41,*) 'D_RUN MINVAL ocn_SSTocn = ', MINVAL(ocn_SSTocn(1:snx,1:sny))

!cnhdbg      CLOSE(errorMessageUnit)
!cnhdbg      CLOSE(standardMessageUnit)
      CALL COMP_OCN_POP_CONTEXT(1)

      RETURN
      END
