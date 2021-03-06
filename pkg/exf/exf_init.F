C $Header: /u/gcmpack/MITgcm/pkg/exf/exf_init.F,v 1.31 2013/04/23 19:04:33 dimitri Exp $
C $Name: checkpoint64g $

#include "EXF_OPTIONS.h"


      subroutine exf_init( mythid )

c     ==================================================================
c     SUBROUTINE exf_init
c     ==================================================================
c
c     o This routine initialises the forcing
c
c     started: Ralf.Giering@FastOpt.de 25-Mai-20000
c     mods for pkg/seaice: menemenlis@jpl.nasa.gov 20-Dec-2002
c
c     ==================================================================
c     SUBROUTINE exf_init
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "EXF_PARAM.h"
#include "EXF_FIELDS.h"
#ifdef ALLOW_BULK_OFFLINE
# include "PARAMS.h"
# include "DYNVARS.h"
#endif

c     == routine arguments ==

      integer mythid

c     == local variables ==

      INTEGER i,j,bi,bj

c     == end of interface ==

C--   Initialise to zero intermediate fields (in common block)
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1-Oly,sNy+Oly
         DO i=1-Olx,sNx+Olx
          wStress(i,j,bi,bj) = 0.
          cw(i,j,bi,bj) = 0.
          sw(i,j,bi,bj) = 0.
          sh(i,j,bi,bj) = 0.
#ifdef ALLOW_ATM_TEMP
          hs(i,j,bi,bj) = 0.
          hl(i,j,bi,bj) = 0.
#endif
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      IF ( .NOT.useAtmWind ) THEN

      if ( useCubedSphereExchange
     &     .and. ustressperiod .eq. 0
     &     .and. ustressfile .NE. ' ' ) then
         stop 'CubedSphereExchange and ustressperiod=0 not supported'
      endif
      call exf_init_gen (
     &     ustressfile, ustressperiod, exf_inscal_ustress, ustressmask,
     &     ustressconst, ustress, ustress0, ustress1,
#ifdef USE_EXF_INTERPOLATION
     &     ustress_lon0, ustress_lon_inc,
     &     ustress_lat0, ustress_lat_inc,
     &     ustress_nlon, ustress_nlat, xC, yC, ustress_interpMethod,
#endif
     &     mythid )

      if ( useCubedSphereExchange
     &     .and. vstressperiod .eq. 0
     &     .and. vstressfile .NE. ' ' ) then
         stop 'CubedSphereExchange and vstressperiod=0 not supported'
      endif
      call exf_init_gen (
     &     vstressfile, vstressperiod, exf_inscal_vstress, vstressmask,
     &     vstressconst, vstress, vstress0, vstress1,
#ifdef USE_EXF_INTERPOLATION
     &     vstress_lon0, vstress_lon_inc,
     &     vstress_lat0, vstress_lat_inc,
     &     vstress_nlon, vstress_nlat, xC, yC, vstress_interpMethod,
#endif
     &     mythid )

      ELSE
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1-Oly,sNy+Oly
         DO i=1-Olx,sNx+Olx
          uwind(i,j,bi,bj) = 0.
          vwind(i,j,bi,bj) = 0.
         ENDDO
        ENDDO
       ENDDO
      ENDDO
      ENDIF

      IF ( useAtmWind ) THEN

      if ( useCubedSphereExchange
     &     .and. uwindperiod .eq. 0
     &     .and. uwindfile .NE. ' ' ) then
         stop 'CubedSphereExchange and uwindperiod=0 not supported'
      endif
      call exf_init_gen (
     &     uwindfile, uwindperiod, exf_inscal_uwind, uwindmask,
     &     uwindconst, uwind, uwind0, uwind1,
#ifdef USE_EXF_INTERPOLATION
     &     uwind_lon0, uwind_lon_inc,
     &     uwind_lat0, uwind_lat_inc,
     &     uwind_nlon, uwind_nlat, xC, yC, uwind_interpMethod,
#endif
     &     mythid )

      if ( useCubedSphereExchange
     &     .and. vwindperiod .eq. 0
     &     .and. vwindfile .NE. ' ' ) then
         stop 'CubedSphereExchange and vwindperiod=0 not supported'
      endif
      call exf_init_gen (
     &     vwindfile, vwindperiod, exf_inscal_vwind, vwindmask,
     &     vwindconst, vwind, vwind0, vwind1,
#ifdef USE_EXF_INTERPOLATION
     &     vwind_lon0, vwind_lon_inc,
     &     vwind_lat0, vwind_lat_inc,
     &     vwind_nlon, vwind_nlat, xC, yC, vwind_interpMethod,
#endif
     &     mythid )

      ELSE
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1-Oly,sNy+Oly
         DO i=1-Olx,sNx+Olx
          uwind(i,j,bi,bj) = 0.
          vwind(i,j,bi,bj) = 0.
         ENDDO
        ENDDO
       ENDDO
      ENDDO
      ENDIF

      call exf_init_gen (
     &     wspeedfile, wspeedperiod, exf_inscal_wspeed, wspeedmask,
     &     wspeedconst, wspeed, wspeed0, wspeed1,
#ifdef USE_EXF_INTERPOLATION
     &     wspeed_lon0, wspeed_lon_inc,
     &     wspeed_lat0, wspeed_lat_inc,
     &     wspeed_nlon, wspeed_nlat, xC, yC, wspeed_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     hfluxfile, hfluxperiod, exf_inscal_hflux, hfluxmask,
     &     hfluxconst, hflux, hflux0, hflux1,
#ifdef USE_EXF_INTERPOLATION
     &     hflux_lon0, hflux_lon_inc,
     &     hflux_lat0, hflux_lat_inc,
     &     hflux_nlon, hflux_nlat, xC, yC, hflux_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     sfluxfile, sfluxperiod, exf_inscal_sflux, sfluxmask,
     &     sfluxconst, sflux, sflux0, sflux1,
#ifdef USE_EXF_INTERPOLATION
     &     sflux_lon0, sflux_lon_inc,
     &     sflux_lat0, sflux_lat_inc,
     &     sflux_nlon, sflux_nlat, xC, yC, sflux_interpMethod,
#endif
     &     mythid )

#ifdef ALLOW_ATM_TEMP

      call exf_init_gen (
     &     atempfile, atempperiod, exf_inscal_atemp, atempmask,
     &     atempconst, atemp, atemp0, atemp1,
#ifdef USE_EXF_INTERPOLATION
     &     atemp_lon0, atemp_lon_inc,
     &     atemp_lat0, atemp_lat_inc,
     &     atemp_nlon, atemp_nlat, xC, yC, atemp_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     aqhfile, aqhperiod, exf_inscal_aqh, aqhmask,
     &     aqhconst, aqh, aqh0, aqh1,
#ifdef USE_EXF_INTERPOLATION
     &     aqh_lon0, aqh_lon_inc,
     &     aqh_lat0, aqh_lat_inc,
     &     aqh_nlon, aqh_nlat, xC, yC, aqh_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     lwfluxfile, lwfluxperiod, exf_inscal_lwflux, lwfluxmask,
     &     lwfluxconst, lwflux, lwflux0, lwflux1,
#ifdef USE_EXF_INTERPOLATION
     &     lwflux_lon0, lwflux_lon_inc,
     &     lwflux_lat0, lwflux_lat_inc,
     &     lwflux_nlon, lwflux_nlat, xC, yC, lwflux_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     precipfile, precipperiod, exf_inscal_precip, precipmask,
     &     precipconst, precip, precip0, precip1,
#ifdef USE_EXF_INTERPOLATION
     &     precip_lon0, precip_lon_inc,
     &     precip_lat0, precip_lat_inc,
     &     precip_nlon, precip_nlat, xC, yC, precip_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     snowprecipfile, snowprecipperiod,
     &     exf_inscal_snowprecip, snowprecipmask,
     &     snowprecipconst, snowprecip, snowprecip0, snowprecip1,
#ifdef USE_EXF_INTERPOLATION
     &     snowprecip_lon0, snowprecip_lon_inc,
     &     snowprecip_lat0, snowprecip_lat_inc,
     &     snowprecip_nlon, snowprecip_nlat, xC, yC,
     &     snowprecip_interpMethod,
#endif
     &     mythid )

#endif /* ALLOW_ATM_TEMP */

#if defined(ALLOW_ATM_TEMP) || defined(SHORTWAVE_HEATING)
      call exf_init_gen (
     &     swfluxfile, swfluxperiod,  exf_inscal_swflux, swfluxmask,
     &     swfluxconst, swflux, swflux0, swflux1,
#ifdef USE_EXF_INTERPOLATION
     &     swflux_lon0, swflux_lon_inc,
     &     swflux_lat0, swflux_lat_inc,
     &     swflux_nlon, swflux_nlat, xC, yC, swflux_interpMethod,
#endif
     &     mythid )
#endif /* defined(ALLOW_ATM_TEMP) || defined(SHORTWAVE_HEATING) */

#if defined(ALLOW_ATM_TEMP) || defined(EXF_READ_EVAP)
      call exf_init_gen (
     &     evapfile, evapperiod, exf_inscal_evap, evapmask,
     &     evapconst, evap, evap0, evap1,
#ifdef USE_EXF_INTERPOLATION
     &     evap_lon0, evap_lon_inc,
     &     evap_lat0, evap_lat_inc,
     &     evap_nlon, evap_nlat, xC, yC, evap_interpMethod,
#endif
     &     mythid )
#endif /* defined(ALLOW_ATM_TEMP) || defined(EXF_READ_EVAP) */

#ifdef ALLOW_DOWNWARD_RADIATION

      call exf_init_gen (
     &     swdownfile, swdownperiod, exf_inscal_swdown, swdownmask,
     &     swdownconst, swdown, swdown0, swdown1,
#ifdef USE_EXF_INTERPOLATION
     &     swdown_lon0, swdown_lon_inc,
     &     swdown_lat0, swdown_lat_inc,
     &     swdown_nlon, swdown_nlat, xC, yC, swdown_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     lwdownfile, lwdownperiod, exf_inscal_lwdown, lwdownmask,
     &     lwdownconst, lwdown, lwdown0, lwdown1,
#ifdef USE_EXF_INTERPOLATION
     &     lwdown_lon0, lwdown_lon_inc,
     &     lwdown_lat0, lwdown_lat_inc,
     &     lwdown_nlon, lwdown_nlat, xC, yC, lwdown_interpMethod,
#endif
     &     mythid )

#endif /* ALLOW_DOWNWARD_RADIATION */

#ifdef ATMOSPHERIC_LOADING
      call exf_init_gen (
     &     apressurefile, apressureperiod,
     &     exf_inscal_apressure, apressuremask,
     &     apressureconst, apressure, apressure0, apressure1,
#ifdef USE_EXF_INTERPOLATION
     &     apressure_lon0, apressure_lon_inc,
     &     apressure_lat0, apressure_lat_inc,
     &     apressure_nlon, apressure_nlat, xC, yC,
     &     apressure_interpMethod,
#endif
     &     mythid )
#endif /* ATMOSPHERIC_LOADING */

#ifdef EXF_ALLOW_SEAICE_RELAX
      call exf_init_gen (
     &     areamaskfile, areamaskperiod,
     &     exf_inscal_areamask, areamaskmask,
     &     areamaskconst, areamask, areamask0, areamask1,
#ifdef USE_EXF_INTERPOLATION
     &     areamask_lon0, areamask_lon_inc,
     &     areamask_lat0, areamask_lat_inc,
     &     areamask_nlon, areamask_nlat, xC, yC, areamask_interpMethod,
#endif
     &     mythid )
#endif /* EXF_ALLOW_SEAICE_RELAX */

#ifdef ALLOW_RUNOFF
      call exf_init_gen (
     &     runofffile, runoffperiod, exf_inscal_runoff, runoffmask,
     &     runoffconst, runoff, runoff0, runoff1,
# ifdef USE_EXF_INTERPOLATION
     &     runoff_lon0, runoff_lon_inc,
     &     runoff_lat0, runoff_lat_inc,
     &     runoff_nlon, runoff_nlat, xC, yC, runoff_interpMethod,
# endif
     &     mythid )
# ifdef ALLOW_RUNOFTEMP
      call exf_init_gen (
     &     runoftempfile, runoffperiod, exf_inscal_runoftemp,runoffmask,
     &     runoftempconst, runoftemp, runoftemp0, runoftemp1,
#  ifdef USE_EXF_INTERPOLATION
     &     runoff_lon0, runoff_lon_inc,
     &     runoff_lat0, runoff_lat_inc,
     &     runoff_nlon, runoff_nlat, xC, yC, runoff_interpMethod,
#  endif
     &     mythid )
# endif /* ALLOW_RUNOFTEMP */
#endif /* ALLOW_RUNOFF */

#ifdef ALLOW_CLIMSST_RELAXATION
      call exf_init_gen (
     &     climsstfile, climsstperiod, exf_inscal_climsst, climsstmask,
     &     climsstconst, climsst, climsst0, climsst1,
#ifdef USE_EXF_INTERPOLATION
     &     climsst_lon0, climsst_lon_inc,
     &     climsst_lat0, climsst_lat_inc,
     &     climsst_nlon, climsst_nlat, xC, yC, climsst_interpMethod,
#endif
     &     mythid )
#endif

#ifdef ALLOW_CLIMSSS_RELAXATION
      call exf_init_gen (
     &     climsssfile, climsssperiod, exf_inscal_climsss, climsssmask,
     &     climsssconst, climsss, climsss0, climsss1,
#ifdef USE_EXF_INTERPOLATION
     &     climsss_lon0, climsss_lon_inc,
     &     climsss_lat0, climsss_lat_inc,
     &     climsss_nlon, climsss_nlat, xC, yC, climsss_interpMethod,
#endif
     &     mythid )
#endif

#ifdef ALLOW_CLIMSTRESS_RELAXATION
      call exf_init_gen (
     &     climustrfile, climustrperiod, exf_inscal_climustr,
     &     climustrmask, climustrconst, climustr, climustr0, climustr1,
#ifdef USE_EXF_INTERPOLATION
     &     climustr_lon0, climustr_lon_inc,
     &     climustr_lat0, climustr_lat_inc,
     &     climustr_nlon, climustr_nlat, xC, yC, climustr_interpMethod,
#endif
     &     mythid )

      call exf_init_gen (
     &     climvstrfile, climvstrperiod, exf_inscal_climvstr,
     &     climvstrmask, climvstrconst, climvstr, climvstr0, climvstr1,
#ifdef USE_EXF_INTERPOLATION
     &     climvstr_lon0, climvstr_lon_inc,
     &     climvstr_lat0, climvstr_lat_inc,
     &     climvstr_nlon, climvstr_nlat, xC, yC, climvstr_interpMethod,
#endif
     &     mythid )
#endif /* CLIMSTRESS_RELAXATION */

#ifdef ALLOW_BULK_OFFLINE

# ifdef ALLOW_CLIMSST_RELAXATION
      _EXCH_XY_RL(climsst, mythid)
# endif
# ifdef ALLOW_CLIMSSS_RELAXATION
      _EXCH_XY_RL(climsss, mythid)
# endif
# ifdef ALLOW_CLIMSTRESS_RELAXATION
      CALL EXCH_UV_XY_RL( climustr, climvstr, .TRUE., myThid )
# endif

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-oLy,sNy+oLy
          DO i=1-oLx,sNx+oLx
# ifdef ALLOW_CLIMSST_RELAXATION
           if ( climsstfile .NE. ' ' .AND.
     &          climsstperiod .EQ. 0. )
     &          theta(i,j,1,bi,bj) = climsst(i,j,bi,bj)
# endif
# ifdef ALLOW_CLIMSSS_RELAXATION
           if ( climsssfile .NE. ' ' .AND.
     &          climsssperiod .EQ. 0. )
     &          salt(i,j,1,bi,bj) = climsss(i,j,bi,bj)
# endif
# ifdef ALLOW_CLIMSTRESS_RELAXATION
           if ( climustrfile .NE. ' ' .AND.
     &          climustrperiod .EQ. 0. )
     &          uvel(i,j,1,bi,bj) = climustr(i,j,bi,bj)
           if ( climvstrfile .NE. ' ' .AND.
     &          climvstrperiod .EQ. 0. )
     &          vvel(i,j,1,bi,bj) = climvstr(i,j,bi,bj)
# endif
           if ( maskC(i,j,1,bi,bj) .NE. 0. .AND.
     &             theta(i,j,1,bi,bj) .EQ. 0. ) then
                print *, 'ph-warn-exf-init ', i, j, theta(i,j,1,bi,bj)
cph                STOP 'in exf_init'
           endif
          ENDDO
         ENDDO
       ENDDO
      ENDDO

#endif /* ALLOW_BULK_OFFLINE */

      RETURN
      END
