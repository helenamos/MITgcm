C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_readparms.F,Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CBOP
C     !ROUTINE: PCB_READPARMS
C     !INTERFACE:
      SUBROUTINE PCB_READPARMS( myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | S/R PCB_READPARMS
C     | o Initialise and read pcb package parameters
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PCB_SIZE.h"
#include "PCB.h"

#ifdef ALLOW_PTRACERS
# include "PTRACERS_SIZE.h"
# include "PTRACERS_PARAMS.h"
#endif

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid    :: My Thread Id. number
      INTEGER myThid
CEOP

#ifdef ALLOW_PCB

C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     iUnit     :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      NAMELIST /PCB_FORCING/
c from cfc     &          atmPCB_inpFile, atmPCB_recSepTime, atmPCB_timeOffset,
c from cfc      &          atmPCB_yNorthBnd, atmPCB_ySouthBnd,
c from cfc     &          PCB_windFile, PCB_atmospFile, PCB_iceFile,
     &          PCB_windFile, PCB_iceFile,
     &          PCB_forcingPeriod, PCB_forcingCycle,
c xz:the following lines are modified from hg code  
c PCBa-neutral PCB; PCBi-ionized PCB; PCBp-particle bounded PCB      
     &          PCB_chemPeriod, PCB_chemCycle,
     &          PCB_emisPeriod, PCB_emisCycle,
c Remove PCBi tracer. (hma, 15 Jul 2014)
c     &          PCBa_concFile, PCBi_depoFile,
c     &          PCBi_riverFile, PCBp_riverFile,
     &          PCBp_depoFile, PCBa_depoFile,
     &          PCBa_concFile,
     &          PCBp_riverFile,
     &          chl_file, npp_file,
     &          doc_file, poc_file,
     &          Fdoc_file, Fpoc_file, Fremin_file
#ifdef FOODW_MODE     
     &          , NO3_file,phytoP_file, zooP_file
#endif     
     
     

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      _BEGIN_MASTER(myThid)

c=========== cfc
c       atmPCB_inpFile    = 'pcb010203.atm'
c       atmPCB_recSepTime = 360. _d 0 * 86400. _d 0
c       atmPCB_timeOffset = UNSET_RL
c       atmPCB_yNorthBnd  =  10. _d 0
c       atmPCB_ySouthBnd  = -10. _d 0
c       PCB_windFile  = ' '
c       PCB_atmospFile= ' '
c       PCB_iceFile   = ' '
c==================       
       PCB_windFile  = ' '
       PCB_iceFile   = ' '
       radsw_File   = ' '
       PCBa_concFile = ' '
c Remove PCBi tracer. (hma, 15 Jul 2014)       
c       PCBi_depoFile = ' '
c       PCBi_riverFile= ' '
       PCBp_riverFile= ' '      
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
       
      
c default periodic forcing to same as for physics
       PCB_forcingPeriod = externForcingPeriod
       PCB_forcingCycle  = externForcingCycle
c====== added based on hg code default periodic forcing to same as for physics
       PCB_chemPeriod = externForcingPeriod
       PCB_chemCycle  = externForcingCycle       
c=======
       PCB_emisPeriod = externForcingPeriod
       PCB_emisCycle  = externForcingCycle       



      WRITE(msgBuf,'(A)') ' PCB_READPARMS: opening data.pcb'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

      CALL OPEN_COPY_DATA_FILE( 'data.pcb', 'PCB_READPARMS',
     O                          iUnit, myThid )

C--   Read parameters from open data file:

C-    forcing filenames and parameters
      READ(UNIT=iUnit,NML=PCB_FORCING)

      WRITE(msgBuf,'(A)')
     &   ' PCB_READPARMS: finished reading data.pcb'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

C--   Close the open data file
      CLOSE(iUnit)

c==============the following used in cfc but not in hg
c      IF ( atmPCB_timeOffset .EQ. UNSET_RL ) THEN
C-    Assume that pcbTime=0 corresponds to the beginning of the 1rst record
C     time-period. This is consistent with 1rst record value = time-averaged
C     atmos-PCB over time period: pcbTime= 0 to pcbTime= 1 x atmPCB_recSepTime
C-    To reproduce previous time interpolation (formerly in pcb02_forcing.F),
C     set default timeOffset according to PTRACERS_Iter0 :
c        atmPCB_timeOffset = atmPCB_recSepTime
c     &                     - deltaTClock*PTRACERS_Iter0
c      ENDIF

c      PCB_monFreq = 0. _d 0
c      IF ( debugLevel.GE.debLevB ) PCB_monFreq = PTRACERS_monitorFreq
c==============


      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

#endif /* ALLOW_PCB */

      RETURN
      END
