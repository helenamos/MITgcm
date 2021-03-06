C $Header: /u/gcmpack/MITgcm/model/src/packages_boot.F,v 1.63 2012/09/04 14:24:36 gforget Exp $
C $Name: checkpoint64g $

#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: PACKAGES_BOOT
C     !INTERFACE:
      SUBROUTINE PACKAGES_BOOT( myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE PACKAGES_BOOT
C     | o Routine to parse runtime package selection file
C     *==========================================================*
C     | Routine reads a flat file which contains a single flag
C     | for each known "package". Flag can enables runtime
C     | activation or deactivation of a package. The data is read
C     | from a file called data.pkg.
C     | Note - If a runtime activation flag is set on but the
C     |        package code was not included in the build then
C     |        the default behavior is to stop with an error.
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid   :: my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf   :: Informational/error message buffer
C     iUnit    :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
CEOP

C     data.pkg namelists
      NAMELIST /PACKAGES/
     &          useOBCS,
     &          useSHAP_FILT,
     &          useZONAL_FILT,
     &          useOPPS,
     &          usePP81,
     &          useMY82,
     &          useGGL90,
     &          useKPP,
     &          useGMRedi,
     &          useDOWN_SLOPE,
     &          useBBL,
     &          useCAL,
     &          useEXF,
     &          useBulkForce,
     &          useEBM,
     &          useCheapAML,
     &          useGrdchk,
     &          useSMOOTH,
     &          usePROFILES,
     &          useECCO,
     &          useSBO,
     &          useFLT,
     &          usePTRACERS,
     &          useGCHEM,
     &          useRBCS,
     &          useOffLine,
     &          useMATRIX,
     &          useFRAZIL,
     &          useSEAICE,
     &          useSALT_PLUME,
     &          useShelfIce,
     &          useStreamIce,
     &          useICEFRONT,
     &          useThSIce,
     &          useATM2D,
     &          useAIM,
     &          useLand,
     &          useFizhi,
     &          useGridAlt,
     &          useDiagnostics,
     &          useREGRID,
     &          useLayers,
     &          useMNC,
     &          useRunClock,
     &          useEMBED_FILES,
     &          useMYPACKAGE

      _BEGIN_MASTER(myThid)

      WRITE(msgBuf,'(A)') ' PACKAGES_BOOT: opening data.pkg'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )


      CALL OPEN_COPY_DATA_FILE(
     I                          'data.pkg', 'PACKAGES_BOOT',
     O                          iUnit,
     I                          myThid )

C--   Default package configuration
c     useGAD          =.FALSE.
      useOBCS         =.FALSE.
      useSHAP_FILT    =.FALSE.
      useZONAL_FILT   =.FALSE.
      useOPPS         =.FALSE.
      usePP81         =.FALSE.
      useMY82         =.FALSE.
      useGGL90        =.FALSE.
      useKPP          =.FALSE.
      useGMRedi       =.FALSE.
      useDOWN_SLOPE   =.FALSE.
      useBBL          =.FALSE.
      useCAL          =.FALSE.
      useEXF          =.FALSE.
      useBulkForce    =.FALSE.
      useEBM          =.FALSE.
      useCheapAML     =.FALSE.
      useGrdchk       =.FALSE.
      useSMOOTH       =.FALSE.
      usePROFILES     =.FALSE.
      useECCO         =.FALSE.
      useSBO          =.FALSE.
      useFLT          =.FALSE.
      usePTRACERS     =.FALSE.
      useGCHEM        =.FALSE.
      useRBCS         =.FALSE.
      useOffLine      =.FALSE.
      useMATRIX       =.FALSE.
      useFRAZIL       =.FALSE.
      useSEAICE       =.FALSE.
      useSALT_PLUME   =.FALSE.
      useShelfIce     =.FALSE.
      useStreamIce    =.FALSE.
      useICEFRONT     =.FALSE.
      useThSIce       =.FALSE.
      useATM2D        =.FALSE.
      useAIM          =.FALSE.
      useLand         =.FALSE.
      useFizhi        =.FALSE.
      useGridAlt      =.FALSE.
      useDiagnostics  =.FALSE.
      useREGRID       =.FALSE.
      useLayers       =.FALSE.
      useMNC          =.FALSE.
      useRunClock     =.FALSE.
      useEMBED_FILES  =.FALSE.
      useMYPACKAGE    =.FALSE.

C--   Read parameters from open data file
      READ(UNIT=iUnit,NML=PACKAGES)

      WRITE(msgBuf,'(A)') ' PACKAGES_BOOT: finished reading data.pkg'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

C--   Close the open data file
      CLOSE(iUnit)

C--   packages with hard-coded switch
#ifdef ALLOW_CAL
C      IF (useEXF) useCAL = .TRUE.   !yanxu
C      is it okay to use cal without EXF? yanxu
       useCAL = .TRUE.   
#endif

#ifndef HAVE_NETCDF
      IF (usePROFILES) THEN
        WRITE(msgBuf,'(2A)') '** WARNING ** pkg/profiles uses NetCDF',
     &   ' which is unavailable (genmake2 test failed)'
        CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(2A)') '** WARNING ** PACKAGES_BOOT:',
     &                       ' ==> Reset usePROFILES to FALSE'
        CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(2A)') ' PACKAGES_BOOT: undef HAVE_NETCDF',
     &                       ' ==> Reset usePROFILES to FALSE'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        usePROFILES=.FALSE.
      ENDIF
#endif

#ifdef ALLOW_PROFILES
      IF (usePROFILES) useCAL = .TRUE.
#endif

#ifdef ALLOW_ECCO
      useCAL = .TRUE.
#endif

C--   packages with an implied switch
      useGAD = tempStepping .OR. saltStepping .OR. usePTRACERS

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

      RETURN
      END
