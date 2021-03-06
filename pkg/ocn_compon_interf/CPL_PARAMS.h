C $Header: /u/gcmpack/MITgcm/pkg/ocn_compon_interf/CPL_PARAMS.h,v 1.5 2007/05/10 21:15:52 jscott Exp $
C $Name: checkpoint64g $

#ifdef COMPONENT_MODULE
C     *==========================================================*
C     | CPL_PARAMS.h
C     | o Header file for Coupling component interface
C     *==========================================================*
C     |   this version is specific to 1 component (ocean)
C     *==========================================================*

C--   COMMON /CPL_OCN_PAR_L/: logical parameters
C     cpl_earlyExpImpCall :: call coupler early in the time stepping call sequence
C     useImportHFlx :: True => use the Imported HeatFlux from couler
C     useImportFW   :: True => use the Imported Fresh Water flux fr cpl
C     useImportTau  :: True => use the Imported Wind-Stress from couler
C     useImportSLP  :: True => use the Imported Sea-level Pressure
C     useImportSIce :: True => use the Imported Sea-Ice mass as ice-loading
C     useImportFice :: True => use the Imported Seaice fraction fr cpl
C     useImportCO2  :: True => use the Imported atmos. CO2 from coupler
C     useImportWSpd :: True => use the Imported surface Wind speed fr cpl

      COMMON /CPL_OCN_PAR_L/
     &  cpl_earlyExpImpCall,
     &  useImportHFlx, useImportFW, useImportTau, 
     &  useImportSLP, useImportSIce, useImportFIce,
     &  useImportCO2, useImportWSpd,
     &  cpl_snapshot_mdsio, cpl_snapshot_mnc,
     &  cpl_timeave_mdsio, cpl_timeave_mnc
      LOGICAL cpl_earlyExpImpCall
      LOGICAL useImportHFlx
      LOGICAL useImportFW
      LOGICAL useImportTau
      LOGICAL useImportSLP
      LOGICAL useImportSIce
      LOGICAL useImportFIce
      LOGICAL useImportCO2
      LOGICAL useImportWSpd
      LOGICAL 
     &     cpl_snapshot_mdsio, cpl_snapshot_mnc,
     &     cpl_timeave_mdsio, cpl_timeave_mnc

C--   COMMON /CPL_OCN_PAR_C/: Character valued parameters
c     CHARACTER*(MAX_LEN_FNAM) cpl_ocnFile

C--   COMMON /CPL_OCN_PAR_R/: real-type parameters
C     cpl_taveFreq   :: Frequency^-1 for time-Aver. output (s)
      COMMON /CPL_OCN_PAR_R/ 
     &    cpl_taveFreq
      _RL cpl_taveFreq

#endif /* COMPONENT_MODULE */ 

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
