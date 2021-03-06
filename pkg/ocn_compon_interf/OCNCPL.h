C $Header: /u/gcmpack/MITgcm/pkg/ocn_compon_interf/OCNCPL.h,v 1.5 2007/10/01 15:17:55 jmc Exp $
C $Name: checkpoint64g $
C
C     /==========================================================\
C     | OCNCPL.h                                                 |
C     | o Variables shared between coupling layer and ocean      |
C     |   component.                                             |
C     |==========================================================|
C     | These variables are used in the ocean component. Grid    |
C     | variables have already been mapped/interpolated to the   |
C     | ocean grid.                                              |
C     | Which variables are exported will depend on the specific |
C     | model coupling being utilised. The variables carried here|
C     | will need to be customised accordingly.                  |
C     \==========================================================/
C
C     COMMON /OCN_CPL2OCN_R/
C     Hatm  - Atmosphere model orography i.e. height of mountains (in Pa)
C             Used in checking consistency of land/sea regions.
C     atmSLPr    - Atmospheric Sea-Level pressure anomaly (Pa=N/m2)
C     HeatFlux   - Surface heat flux (W/m2). Positive flux is out of ocean
C     qShortWave - net shortwave radiation heat flux (W/m^2) (+=upward).
C     qSensible  - Sensible heatflux (W/m^2).
C     qLatent    - Latent heatflux (W/m^2).
C     qLongWave  - net longwave radiation heat flux  (W/m^2) (+=upward).
C     uVelGround - Zonal wind speed at the ground (m/s).
C     vVelGround - Meridional wind speed at the ground (m/s).
C     tauX       - Zonal      surface wind-stress (N/m^2). Same sign as the
C                  wind : Zonal      wind is positive for westward flow.
C     tauY       - Meridional surface wind-stress (N/m^2). Same sign as the
C                  wind : Meridional wind is positive for northward flow.
C     FWFlux     - Surface flux of fresh water (kg/m2/s). Positive flux
C                  is out of ocean.
C     iceSaltFlx - salt flux from sea-ice compon. (+=upward=leaving the ocean)
C     seaIceMass - sea-ice mass (kg/m2)
C     airCO2     - atmospheric CO2 (parts by volume)
C     surfWSpeed - atmospheric surface wind speed (m/s)
C     fracIce    - seaice fraction (from external model)
C
      COMMON /OCN_CPL2OCN_R/
     &                   Hatm,
     &                   atmSLPr, HeatFlux, qShortWave,
c    &                   qLatent, qSensible, qLongWave,
c    &                   uVelGround, vVelGround,
Cbegin yanxu
     &                   qLatent, qSensible, qLongWave,
     &                   uVelGround, vVelGround,
Cend yanxu     
     &                   tauX, tauY,
     &                   FWFlux,
     &                   iceSaltFlx, seaIceMass,
     &                   airCO2, surfWSpeed, fracIce
      _RL Hatm      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL atmSLPr   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL HeatFlux  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL qShortWave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RL qLatent   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RL qSensible (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RL qLongWave (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RL uVelGround(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RL vVelGround(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
Cbegin yanxu
      _RL qLatent   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL qSensible (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL qLongWave (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL uVelGround(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL vVelGround(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
Cend yanxu
      _RL tauX      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL tauY      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL FWFlux    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL iceSaltFlx(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL seaIceMass(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL airCO2    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL surfWSpeed(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL fracIce   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

C     COMMON /OCN_OCN2CPL_R/
C     ocMxlD2cpl - Ocean mixed-layer depth exported to coupler (m)
C     SSTocn2cpl - Ocean surface temperature map exported to
C                  coupling layer (oC).
C     SSSocn2cpl - Ocean surface salinity exported to coupler (psu)
C     vSqocn2cpl - Ocean surface velocity square exported to
C                  coupler (m2/s2)
C     fluxCO2cpl - ocean flux of CO2 exported to atm (mol/m2/s)
C
      COMMON /OCN_OCN2CPL_R/
     &       ocMxlD2cpl, SSTocn2cpl, SSSocn2cpl, vSqocn2cpl,
     &       fluxCO2cpl
      _RL ocMxlD2cpl(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL SSTocn2cpl(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL SSSocn2cpl(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL vSqocn2cpl(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL fluxCO2cpl(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

Cbegin yanxu            
C     Pass carbon/DIC variables only if flag set below
C      LOGICAL ocnCpl_exchange_DIC
C      PARAMETER( ocnCpl_exchange_DIC = .FALSE.)
Cendyanxu            

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
