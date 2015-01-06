C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_diagnostics_init.F,v 1.0 2013/07/11 08:50:17 yanxu Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "HG_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG

CBOP
C     !ROUTINE HG_DIAGNOSTICS_INIT
C     !INTERFACE:
      SUBROUTINE HG_DIAGNOSTICS_INIT( myThid )
C     !DESCRIPTION:
C     Routine to initialize Hg diagnostics

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "PTRACERS_SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "HG_SIZE.h"
#include "HG.h"

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

C--   Add diagnostic HG2DEPO, HG0CONC, HG0EVAS, HG2REDN, and HGPSINK
      diagName = 'HG2DEPO '
      WRITE(diagTitle, '(A)') 'Atmospheric Hg2 deposition flux'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HG0CONC '
      WRITE(diagTitle, '(A)') 'Atmospheric Hg0 concentration'
      diagUnits = 'ng/m^3          '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HG2RIVER'
      WRITE(diagTitle, '(A)') 'Hg2 riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HGPRIVER'
      WRITE(diagTitle, '(A)') 'HgP riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )          

      diagName = 'HG0EVAS '
      WRITE(diagTitle, '(A)') 'Hg0 evasion flux from ocean'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'HG2REDN '
      WRITE(diagTitle, '(A)') 'Net Hg2 reduction rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'HG2RBIO '
      WRITE(diagTitle, '(A)') 'Gross Hg2 bio-reduction rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HG2RPHO '
      WRITE(diagTitle, '(A)') 'Gross Hg2 photo-reduction rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HG0OBIO '
      WRITE(diagTitle, '(A)') 'Gross Hg0 bio-oxidation rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
                    
      diagName = 'HG0OPHO '
      WRITE(diagTitle, '(A)') 'Gross Hg0 photo-oxidation rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'HG0ODAK '
      WRITE(diagTitle, '(A)') 'Gross Hg0 dark-oxidation rate'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'HGPSINK '
      WRITE(diagTitle, '(A)') 'Hgp sinking flux at level bottom'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HG2PART '
      WRITE(diagTitle, '(A)') 'Hg2 partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
#ifdef HGPRIVER
      diagName = 'HGRSINK '
      WRITE(diagTitle, '(A)') 'River Hgp sinking flux at level bottom'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'HGRRIVER'
      WRITE(diagTitle, '(A)') 'Riverine (special) HgP riverine runoff'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )          
          
      diagName = 'HGRDISS '
      WRITE(diagTitle, '(A)') 'HgR dissolution flux'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif  
               
#ifdef METHY_MODE
      diagName = 'DMHGEVAS'
      WRITE(diagTitle, '(A)') 'DMHg evasion flux from ocean'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'MHGPSINK'
      WRITE(diagTitle, '(A)') 'MMHgp sinking flux at level bottom'
      diagUnits = 'mol/m^2/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
     
      diagName = 'MMHGPART'
      WRITE(diagTitle, '(A)') 'MMHg partitioned onto particles'
      diagUnits = 'mol/m^3/s       '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif     
     
#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END     
C============================================================================
#endif
#endif
