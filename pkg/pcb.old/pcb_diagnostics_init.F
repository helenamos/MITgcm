C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_diagnostics_init.F,v 1.0 
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "PCB_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

CBOP
C     !ROUTINE HG_DIAGNOSTICS_INIT
C     !INTERFACE:
      SUBROUTINE PCB_DIAGNOSTICS_INIT( myThid )
C     !DESCRIPTION:
C     Routine to initialize PCB diagnostics

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "PTRACERS_SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "PCB_SIZE.h"
#include "PCB.h"

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid -  Number of this instance of HG_DIAGNOSTICS_INIT
      INTEGER myThid
CEOP

#ifdef ALLOW_DIAGNOSTICS
C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf      - Informational/error meesage buffer
c     CHARACTER*(MAX_LEN_MBUF) msgBuf

      INTEGER       diagNum
      CHARACTER*8   diagName
      CHARACTER*16  diagCode
      CHARACTER*16  diagUnits
      CHARACTER*(80) diagTitle

      INTEGER      np

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   Add diagnostics to the (long) list

C--   Add diagnostic PCBdCONC, PCBdEVAS, and PCBPSINK

      diagName = 'PCBdSPRY'
      WRITE(diagTitle, '(A)') 'PCBd seaspray '
      diagUnits = 'mol/m^2/s          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PCBdCONC'
      WRITE(diagTitle, '(A)') 'Atmospheric PCBd concentration'
      diagUnits = 'ng/m^3          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PCBdEVAS'
      WRITE(diagTitle, '(A)') 'PCBd evasion flux from ocean'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
          
C Not considering river inputs for PCBS (hma, 11 Jul 2014)
C      diagName = 'PCBdRIVR'
C      WRITE(diagTitle, '(A)') 'PCBd riverine runoff'
C      diagUnits = 'mol/m^2/s       '
C      diagCode  = 'SM P    M1      '
C      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
C     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

C      diagName = 'PCBpRIVR'
C      WRITE(diagTitle, '(A)') 'PCBp riverine runoff'
C      diagUnits = 'mol/m^2/s       '
C      diagCode  = 'SM P    M1      '
C      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
C     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )          

      diagName = 'PCBdPART'
      WRITE(diagTitle, '(A)') 'PCBd partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PCBpPART'
      WRITE(diagTitle, '(A)') 'PCBp partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'PCBpSINK'
      WRITE(diagTitle, '(A)') 'PCBp sinking flux at level bottom'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )         


#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END     
C============================================================================
#endif
#endif
