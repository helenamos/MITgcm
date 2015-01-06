C $Header: /u/gcmpack/pkg/pcb/pcb_init_fixed.F

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "PCB_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

c===============================================================================
C===============================================================================
CStartofinterface
      SUBROUTINE PCB_INIT_FIXED(myThid)
C     =============== Global data ==========================================
C     === Global variables ===
         implicit none
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "GCHEM.h"
#include "PCB_SIZE.h"
#include "PCB.h"

        INTEGER myThid

C set up diagnostics
#ifdef ALLOW_DIAGNOSTICS
      IF ( useDIAGNOSTICS ) THEN
        CALL PCB_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */
C

        RETURN
        END
C============================================================================
#endif
#endif

