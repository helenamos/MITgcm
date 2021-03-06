C $Header: /u/gcmpack/MITgcm/pkg/aim_compon_interf/cpl_export_my_data.F,v 1.5 2009/12/25 19:42:46 jmc Exp $
C $Name: checkpoint64g $

#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: CPL_EXPORT_MY_DATA
C     !INTERFACE:
      SUBROUTINE CPL_EXPORT_MY_DATA(
     I                      myTime, myIter, myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE CPL_EXPORT_MY_DATA
C     | o Routine for controlling export of coupling data to
C     |   coupler layer.
C     *==========================================================*
C     | This version talks to the MIT Coupler. It uses the MIT
C     | Coupler "checkpoint1" library calls.
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "CPL_PARAMS.h"
#include "ATMCPL.h"
#include "ATMIDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myTime  :: Current time in simulation.
C     myIter  :: Current timestep number.
C     myThid  :: Thread number for this instance of the routine.
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef COMPONENT_MODULE
C     !LOCAL VARIABLES:
C     == Local variables ==

C     Send data to coupling layer. Note MIT Coupler checkpoint1
C     does not allow asynchronous posting of data, so ordering
C     has to be consistent with coupling layer ordering.
      IF ( MOD(myIter,cplSendFrq_iter).EQ.0 ) THEN
       _BEGIN_MASTER( myThid )
       WRITE(0,'(A,I5,A,I10)') '  Exporting (pid=', myProcId,
     &            ' ) atmospheric fluxes at iter.', myIter
       _END_MASTER( myThid )

C-     export Sea-Level pressure:
       CALL ATM_EXPORT_FLD( atmSLPrName,
     U                      atmSLPr, atmSLPrTime, myThid )
C-     export Net surface heat flux:
       CALL ATM_EXPORT_FLD( atmHeatFluxName,
     U                      heatFlux, HeatFluxTime, myThid )
C-     export Net Short-Wave surface heat flux:
       CALL ATM_EXPORT_FLD( atmQshortWaveName,
     U                      qShortWave, qShortWaveTime, myThid )
C-     export surface wind stress, Zonal & Meridional components:
       CALL ATM_EXPORT_FLD( atmTauXName,
     U                      tauX, tauXTime, myThid )
       CALL ATM_EXPORT_FLD( atmTauYName,
     U                      tauY, tauYTime, myThid )
C-     export Net fresh water flux (Evap - Precip):
       CALL ATM_EXPORT_FLD( atmEvMPrName,
     U                      EvMPrFlux, EvMPrTime, myThid )
C-     export Run Off fresh water flux:
       CALL ATM_EXPORT_FLD( atmRunOffName,
     U                      RunOffFlux, RunOffTime, myThid )
C-     export Energy flux associated with Run Off:
       CALL ATM_EXPORT_FLD( atmROEnFxName,
     U                      RunOffEnFx, ROEnFxTime, myThid )
C-     export Salt flux (related to sea-ice melting/freezing):
       CALL ATM_EXPORT_FLD( atmSaltFxName,
     U                      iceSaltFlx, saltFxTime, myThid )
C-     export Sea-Ice Mass:
       CALL ATM_EXPORT_FLD( atmSeaIceName,
     U                      seaIceMass, seaIceTime, myThid )

       IF ( atmCpl_exchange_DIC ) THEN
C-     export atmospheric CO2:
         CALL ATM_EXPORT_FLD( atmAirCO2Name,
     U                        airCO2, airCO2Time, myThid )

C-     export surface wind speed:
         CALL ATM_EXPORT_FLD( atmWSpdName,
     U                        sWSpeed, sWSpeedTime, myThid )

C-     export seaice fraction:
         CALL ATM_EXPORT_FLD( atmFIceName,
     U                        fracIce, fracIceTime, myThid )
       ENDIF

      ENDIF

#endif /* COMPONENT_MODULE */

      RETURN
      END
