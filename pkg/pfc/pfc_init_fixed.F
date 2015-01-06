C $Header: /u/gcmpack/pkg/pfc/pfc_init_fixed.F

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "PFC_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC

c===============================================================================
C===============================================================================
CStartofinterface
      SUBROUTINE PFC_INIT_FIXED(myThid)
C     =============== Global data ==========================================
C     === Global variables ===
         implicit none
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "GCHEM.h"
#include "PFC_SIZE.h"
#include "PFC.h"

        INTEGER myThid

C set up diagnostics
#ifdef ALLOW_DIAGNOSTICS
      IF ( useDIAGNOSTICS ) THEN
        CALL PFC_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */
C

        RETURN
        END
C============================================================================
#endif
#endif

