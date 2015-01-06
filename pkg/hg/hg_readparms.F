C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_readparms.F,v 1.2 2008/04/09 16:07:41 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CBOP
C !ROUTINE: HG_READPARMS
C !INTERFACE: ==========================================================
      SUBROUTINE HG_READPARMS( myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | S/R HG_READPARMS
C     | o Initialise and read hg package parameters
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "HG_SIZE.h"
#include "HG.h"

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid    :: My Thread Id. number
      INTEGER myThid
CEOP

#ifdef ALLOW_HG

C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     iUnit     :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      NAMELIST /HG_FORCING/
     &          HG_windFile, HG_iceFile, radsw_File,
     &          HG_forcingPeriod, HG_forcingCycle,
     &          HG_chemPeriod, HG_chemCycle,
     &          HG0_concFile, HG2_depoFile,
     &          HG2_riverFile, HGP_riverFile,
#ifdef HGPRIVER
     &          HGR_riverFile,
#endif     
     &          chl_file, npp_file,
     &          doc_file, poc_file,
     &          Fdoc_file, Fpoc_file, Fremin_file
#ifdef FOODW_MODE     
     &          , NO3_file,phytoP_file, zooP_file
#endif     

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      _BEGIN_MASTER(myThid)

       HG_windFile  = ' '
       HG_iceFile   = ' '
       radsw_File   = ' '
       HG0_concFile = ' '
       HG2_depoFile = ' '
       HG2_riverFile= ' '
       HGP_riverFile= ' '
#ifdef HGPRIVER
       HGR_riverFile= ' '
#endif       
       chl_file     = ' '
       npp_file     = ' '
       doc_file     = ' '
       poc_file     = ' '
       Fdoc_file    = ' '
       Fpoc_file    = ' '
       Fremin_file  = ' '
#ifdef FOODW_MODE       
       NO3_file     = ' '
       phytoP_file  = ' '
       zooP_file    = ' '
#endif       
c air-sea exchange: default periodic forcing to same as for physics
       HG_forcingPeriod = externForcingPeriod
       HG_forcingCycle  = externForcingCycle
c hg chemistry: default periodic forcing to same as for physics
       HG_chemPeriod = externForcingPeriod
       HG_chemCycle  = externForcingCycle

      WRITE(msgBuf,'(A)') ' HG_READPARMS: opening data.hg'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

      CALL OPEN_COPY_DATA_FILE( 'data.hg', 'HG_READPARMS',
     O                          iUnit, myThid )

C--   Read parameters from open data file:

C-    forcing filenames and parameters
      READ(UNIT=iUnit,NML=HG_FORCING)

      WRITE(msgBuf,'(A)')
     &   ' HG_READPARMS: finished reading data.hg'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

C--   Close the open data file
      CLOSE(iUnit)

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

#endif /* ALLOW_HG */

      RETURN
      END
