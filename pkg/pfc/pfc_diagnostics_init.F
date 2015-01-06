C $Header: /u/gcmpack/MITgcm/pkg/pfc/pfc_diagnostics_init.F,v 1.0 
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "PFC_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC

CBOP
C     !ROUTINE HG_DIAGNOSTICS_INIT
C     !INTERFACE:
      SUBROUTINE PFC_DIAGNOSTICS_INIT( myThid )
C     !DESCRIPTION:
C     Routine to initialize PFC diagnostics

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "PTRACERS_SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "PFC_SIZE.h"
#include "PFC.h"

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

C--   Add diagnostic PFCiDEPO, PFCnCONC, PFCnEVAS, PFCiREDN, and PFCPSINK

      diagName = 'PFCnSPRY'
      WRITE(diagTitle, '(A)') 'PFCn seaspray '
      diagUnits = 'mol/m^2/s          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCiSPRY'
      WRITE(diagTitle, '(A)') 'PFCi seaspray '
      diagUnits = 'mol/m^2/s          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCnCONC'
      WRITE(diagTitle, '(A)') 'Atmospheric PFCn concentration'
      diagUnits = 'ng/m^3          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCnEVAS'
      WRITE(diagTitle, '(A)') 'PFCn evasion flux from ocean'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
          
      diagName = 'PFCiDEPO'
      WRITE(diagTitle, '(A)') 'Atmospheric PFCi deposition flux'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCnRIVR'
      WRITE(diagTitle, '(A)') 'PFCn riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCiRIVR'
      WRITE(diagTitle, '(A)') 'PFCi riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCpRIVR'
      WRITE(diagTitle, '(A)') 'PFCp riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )          

      diagName = 'PFCnPART'
      WRITE(diagTitle, '(A)') 'PFCn partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCiPART'
      WRITE(diagTitle, '(A)') 'PFCi partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PFCpPART'
      WRITE(diagTitle, '(A)') 'PFCp partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'PFCpSINK'
      WRITE(diagTitle, '(A)') 'PFCp sinking flux at level bottom'
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
