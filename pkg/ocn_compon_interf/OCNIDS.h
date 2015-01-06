C $Header: /u/gcmpack/MITgcm/pkg/atm_ocn_coupler/OCNIDS.h,v 1.2 2007/05/14 21:00:44 jmc Exp $
C $Name: checkpoint64g $

C  These lines are here to deliberately cause a compile-time error.
C  If you see these lines in your .F files or the compiler shows them
C    as an error then it means you have not placed your coupler 
C    configuration files in the appropriate place.
C  You need: a) to place you own copy of OCNIDS.h in a directory
C    (e.g.: shared_code) which is both in the include path of the
C    coupler and in include path of the ocean component ; 
C  and b) to comment out these lines.

C     *==========================================================*
C     | OCNIDS.h Declare symbolic constants holding strings that
C     |          are used to identify this component and the
C     |          fields it exchanges with other components.
C     *==========================================================*
      CHARACTER*(8)  ocnCompName 
      PARAMETER( ocnCompName         = 'UV-Ocean'       )
      CHARACTER*(*) ocnBathyName
      PARAMETER( ocnBathyName        = 'OCN Bathymetry' )
      CHARACTER*(10) ocnMxlDName
      PARAMETER( ocnMxlDName         = 'OCN ocMxlD'     )
      CHARACTER*(7)  ocnSSTName
      PARAMETER( ocnSSTName          = 'OCN SST'        )
      CHARACTER*(7)  ocnSSSName
      PARAMETER( ocnSSSName          = 'OCN SSS'        )
      CHARACTER*(9)  ocnSSVsqName
      PARAMETER( ocnSSVsqName        = 'OCN SSVsq'      )
      CHARACTER*(8)  ocnFCO2Name
      PARAMETER( ocnFCO2Name         = 'OCN FCO2'       )

      CHARACTER*(8)  ocnSLPrName
      PARAMETER( ocnSLPrName         = 'OCN SLPr'       )
      CHARACTER*(12) ocnHeatFluxName
      PARAMETER( ocnHeatFluxName     = 'OCN HeatFlux'   )
      CHARACTER*(14) ocnQshortWaveName
      PARAMETER( ocnQshortWaveName   = 'OCN Qshortwave' )
      CHARACTER*(13) ocnQlongWaveName
      PARAMETER( ocnQlongWaveName    = 'OCN Qlongwave'  )
      CHARACTER*(11) ocnQlatentName
      PARAMETER( ocnQlatentName      = 'OCN Qlatent'    )
      CHARACTER*(13) ocnQsensibleName
      PARAMETER( ocnQsensibleName    = 'OCN Qsensible'  )
      CHARACTER*(14) ocnUvelgroundName
      PARAMETER( ocnUvelgroundName   = 'OCN Uvelground' )
      CHARACTER*(14) ocnVvelgroundName
      PARAMETER( ocnVvelgroundName   = 'OCN Vvelground' )
      CHARACTER*(8)  ocnTauXName
      PARAMETER( ocnTauXName         = 'OCN tauX'       )
      CHARACTER*(8)  ocnTauYName
      PARAMETER( ocnTauYName         = 'OCN tauY'       )
      CHARACTER*(10) ocnFWFluxName
      PARAMETER( ocnFWFluxName       = 'OCN FWFlux'     )
      CHARACTER*(12) ocnSaltFxName
      PARAMETER( ocnSaltFxName       = 'OCN SaltFlux'   )
      CHARACTER*(10) ocnSeaIceName
      PARAMETER( ocnSeaIceName       = 'OCN SeaIce'     )
      CHARACTER*(10) ocnAirCO2Name
      PARAMETER( ocnAirCO2Name       = 'OCN AirCO2'     )
      CHARACTER*(8) ocnWSpdName
      PARAMETER( ocnWSpdName         = 'OCN WSpd'       )
      CHARACTER*(8) ocnFIceName
      PARAMETER( ocnFIceName         = 'OCN FIce'       )
C
C     Pass carbon/DIC variables only if flag set below
      LOGICAL ocnCpl_exchange_DIC
      PARAMETER( ocnCpl_exchange_DIC = .FALSE.)
