C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/driver_init.F,v 1.3 2005/05/12 03:00:39 cnh Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: DRIVER_INIT
C     !INTERFACE:
      SUBROUTINE DRIVER_INIT(
     I              atm_HeatFlux, atm_TauX, atm_TauY,
     I              atm_Qlatent, atm_Qsensible, atm_Qlongwave,
     I              atm_Qshortwave,
     I              atm_uVelGround, atm_vVelGround,
     I              atm_FWFlux,
     I              atm_Hatm,
     O              ocn_SSTocn, ocn_Hocn,
     O              ocn_uVelocn, ocn_vVelocn,
     O              ocn_rVolTop
     &              )
C     !DESCRIPTION: \bv
C     *==================================================================
C     | SUBROUTINE driver_init
C     | o External driver control routine for MITgcm init phase.
C     *==================================================================
C     |
C     | DRIVER routines are used to control the MITgcm code from an external
C     | driver. This routine invokes the init phase of code execution
C     |
C     *==================================================================
C     \ev
C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
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
C     == Local variables ==
      INTEGER iLoop
      INTEGER myThid
      INTEGER myCurrentIter
      _RL     myCurrentTime
      INTEGER I,J,K,bi,bj
CEOP

      CALL COMP_OCN_PUSH_CONTEXT(1)

      myThid = 1
      CALL EEBOOT()
C     Read the import fields
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

      CALL INITIALISE_FIXED(    myThid )
      CALL INITIALISE_VARIA(    myThid )
      myCurrentTime = startTime
      myCurrentIter = nIter0
      iLoop  = 1
      CALL FORWARD_STEP_SETUP( iLoop, myCurrentTime, 
     &                         myCurrentIter, myThid    )

C     Fill the export fields
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
          ocn_SSTocn(i,j) = SSTocn2cpl(i,j,bi,bj)
          ocn_Hocn(  i,j) = R_low(     i,j,bi,bj)
          ocn_uVelocn(i,j)   = uVel(i,j,bi,bj,1)
          ocn_vVelocn(i,j)   = vVel(i,j,bi,bj,1)
          ocn_rVolTop(  i,j) =
     &     _recip_hFacC(i,j,1,bi,bj)*recip_drF(1)*recip_rA(i,j,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      WRITE( 6,*) 'MAXVAL SSTocn2cpl = ', MAXVAL(SSTocn2cpl(1:snx,1:sny,:,:))
      WRITE( 6,*) 'MINVAL SSTocn2cpl = ', MINVAL(SSTocn2cpl(1:snx,1:sny,:,:))
      WRITE( 6,*) 'MAXVAL ocn_SSTocn = ', MAXVAL(ocn_SSTocn(1:snx,1:sny))
      WRITE( 6,*) 'MINVAL ocn_SSTocn = ', MINVAL(ocn_SSTocn(1:snx,1:sny))

!     CLOSE(errorMessageUnit)
!     CLOSE(standardMessageUnit)
      CALL COMP_OCN_POP_CONTEXT(1)

      RETURN
      END
