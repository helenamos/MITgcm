C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/OCNIDS.h,v 1.1 2004/03/30 03:58:56 cnh Exp $
C $Name:  $

C     /==========================================================\
C     | OCNIDS.h Declare symbolic constants holding strings that |
C     |          are used to identify this component and the     |
C     |          fields it exchanges with other components.      |
C     \==========================================================/
      CHARACTER*(*) ocnCompName 
      PARAMETER( ocnCompName         = 'UV-Ocean'       )
      CHARACTER*(*) ocnBathyName
      PARAMETER( ocnBathyName        = 'OCN Bathymetry' )
      CHARACTER*(*) ocnSSTName
      PARAMETER( ocnSSTName          = 'OCN SST'        )
      CHARACTER*(*) ocnTauXName
      PARAMETER( ocnTauXName         = 'OCN tauX'       )
      CHARACTER*(*) ocnTauYName
      PARAMETER( ocnTauYName         = 'OCN tauY'       )
      CHARACTER*(*) ocnHeatFluxName
      PARAMETER( ocnHeatFluxName     = 'OCN HeatFlux'   )
      CHARACTER*(*) ocnFWFluxName
      PARAMETER( ocnFWFluxName       = 'OCN FWFlux'     )

      CHARACTER*(*) ocnuVelGroundName
      PARAMETER( ocnuVelGroundName   = 'OCN uVelGround'     )
      CHARACTER*(*) ocnvVelGroundName
      PARAMETER( ocnvVelGroundName   = 'OCN vVelGround'     )
      CHARACTER*(*) ocnqLatentName
      PARAMETER( ocnqLatentName      = 'OCN qLatent'     )
      CHARACTER*(*) ocnqShortwaveName
      PARAMETER( ocnqShortwaveName   = 'OCN qShortwave'     )
      CHARACTER*(*) ocnqLongwaveName
      PARAMETER( ocnqLongwaveName    = 'OCN qLongwave'     )
      CHARACTER*(*) ocnqSensibleName
      PARAMETER( ocnqSensibleName    = 'OCN qSensible'     )
