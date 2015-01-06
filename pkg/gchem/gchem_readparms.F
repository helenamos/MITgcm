C $Header: /u/gcmpack/MITgcm/pkg/gchem/gchem_readparms.F,v 1.19 2011/12/22 19:05:27 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"

CBOP
C !ROUTINE: GCHEM_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_READPARMS( myThid )

C !DESCRIPTION:
C     Initialize GCHEM parameters, read in data.gchem
C
C !MODIFICATION HISTORY
C 16 May 2013 - Yanxu Zhang    - Add Hg support
C        2014 - Xianming Zhang - Add PFCs
C 08 Jul 2014 - Helen Amos     - Add PCBs

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none

#ifdef ALLOW_GCHEM

C !LOCAL VARIABLES: ====================================================
C  tIter0               :: retired parameter
C  iTracer              :: loop indices
C  iUnit                :: unit number for I/O
C  msgBuf               :: message buffer
      INTEGER tIter0
      INTEGER iUnit
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

C- Sub-package on/off flags: not fully implemented, requires
C  to test the flag before any corresponding pkg S/R call

      NAMELIST /GCHEM_PARM01/
     &           nsubtime           ,
     &           useDIC             ,
     &           useCFC             ,
     &           useHG              ,    !yxzhang 5/16/13
     &           usePFC             ,    !xmzhang 5/16/14
     &           usePCB             ,    !hma, 08 Jul 2014
     &           useDARWIN          ,
     &           Filename1          ,
     &           Filename2          ,
     &           Filename3          ,
     &           Filename4          ,
     &           Filename5          ,
     &           gchem_int1         , gchem_int2        , 
     &           gchem_int3         ,
     &           gchem_int4         , gchem_int5        ,
     &           gchem_rl1          , gchem_rl2         , 
     &           gchem_rl3          ,
     &           gchem_rl4          , gchem_rl5         ,
     &           gchem_ForcingPeriod, gchem_ForcingCycle,
     &           tIter0

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      _BEGIN_MASTER(myThid)

C Set defaults values for parameters in GCHEM.h
       useDIC     = .FALSE.
       useCFC     = .FALSE.
       useHG      = .FALSE.   !yxzhang 5/16/13 !should there be statement for PFCs? (hma, 08 jul 2014)
       usePCB     = .FALSE.   !hma, 08 Jul 2014
       useDARWIN  = .FALSE.
       tIter0     = UNSET_I
       nsubtime   = 1
       Filename1  = ' '
       Filename2  = ' '
       Filename3  = ' '
       Filename4  = ' '
       Filename5  = ' '
       gchem_int1 = 0
       gchem_int2 = 0
       gchem_int3 = 0
       gchem_int4 = 0
       gchem_int5 = 0
       gchem_rl1  = 0. _d 0
       gchem_rl2  = 0. _d 0
       gchem_rl3  = 0. _d 0
       gchem_rl4  = 0. _d 0
       gchem_rl5  = 0. _d 0

c default periodic forcing to same as for physics
       gchem_ForcingPeriod=externForcingPeriod
       gchem_ForcingCycle=externForcingCycle
C Open and read the data.gchem file
      WRITE(msgBuf,'(A)') ' GCHEM_READPARMS: opening data.gchem'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                   'data.gchem', 'GCHEM_PARM01',
     O                   iUnit,
     I                   myThid )
      READ(UNIT=iUnit,NML=GCHEM_PARM01)
      WRITE(msgBuf,'(A)')
     &  ' GCHEM_READPARMS: finished reading data.gchem'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

C Close the open data file
      CLOSE(iUnit)

C- Check for retired parameters:
      IF ( tIter0 .NE. UNSET_I ) THEN
c      nRetired = nRetired+1
       WRITE(msgBuf,'(A,A)')
     &  'S/R GCHEM_READPARMS: Paramater "tIter0" is',
     &  ' no longer allowed in file "data.gchem"'
       CALL PRINT_ERROR( msgBuf , myThid)
       WRITE(msgBuf,'(A,A)')
     &  'S/R GCHEM_READPARMS: "tIter0" has been moved to',
     &  ' PTRACERS_Iter0 in file "data.ptracers".'
       CALL PRINT_ERROR( msgBuf , myThid)
       STOP 'ABNORMAL END: S/R GCHEM_READPARMS'
      ENDIF

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#ifdef ALLOW_DIC
      IF ( useDIC ) THEN
        CALL DIC_READPARMS(myThid)
      ENDIF
#endif

#ifdef ALLOW_CFC
      IF ( useCFC ) THEN
        CALL CFC_READPARMS(myThid)
      ENDIF
#endif

c yxzhang, 5/16/13
#ifdef ALLOW_HG
      IF ( useHG ) THEN
        CALL HG_READPARMS(myThid)
      ENDIF
#endif
c yxzhang

c xmzhang
#ifdef ALLOW_PFC
      IF ( usePFC ) THEN
        CALL PFC_READPARMS(myThid)
      ENDIF
#endif
c xmzhang

c hma
#ifdef ALLOW_PCB
      IF ( usePCB ) THEN
        CALL PCB_READPARMS(myThid)
      ENDIF
#endif

#ifdef ALLOW_DARWIN
      IF ( useDARWIN ) THEN
        CALL DARWIN_READPARMS(myThid)
      ENDIF
#endif

#endif /* ALLOW_GCHEM */

      RETURN
      END
