C $Header: /u/gcmpack/MITgcm/pkg/gchem/gchem_init_fixed.F,v 1.11 2009/06/30 16:43:00 jahn Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_INIT_FIXED(myThid )

C !DESCRIPTION:
C calls subroutines that initialized fixed variables for any tracer
C experiment
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
CEOP

#ifdef ALLOW_GCHEM

C     !LOCAL VARIABLES:

C jmc: simpler to put MASTER thread directive within individual S/R :
C      that leave the choice, for each S/R, to do either single (master)
C      thread tasks or Multi-threaded tasks.
c        _BEGIN_MASTER( mythid )
ccccccccccccccccccccccccccc
c initialize parameters   c
ccccccccccccccccccccccccccc
#ifdef ALLOW_DIC
      IF ( useDIC ) THEN
          print*,'QQ load dic parameters, initial fixed'
          CALL DIC_INIT_FIXED( myThid )
      ENDIF
#endif /* ALLOW_DIC */
#ifdef ALLOW_CFC
      IF ( useCFC ) THEN
          print*,'QQ start cfc params'
          CALL CFC_PARAM( myThid )
          print*,'QQ read cfc atmos data'
          CALL CFC_ATMOS( myThid )
      ENDIF
#endif /* ALLOW_CFC */
c         _END_MASTER( mythid )

#ifdef ALLOW_DARWIN
      IF ( useDARWIN ) THEN
         call DARWIN_INIT_FIXED(myThid)
      ENDIF
#endif

C yanxu, 7/11/2013
#ifdef ALLOW_HG
      IF ( useHG ) THEN
         call HG_INIT_FIXED(myThid)
      ENDIF
#endif
C end yanxu

C xmzhang
#ifdef ALLOW_PFC

      IF ( usePFC ) THEN
         call PFC_PARAM (myThid)
         write(*,*) 'finish reading PFC params PFC_PARAM (myThid)'
         call PFC_INIT_FIXED(myThid)
      ENDIF

#endif
C end xmzhang

C hma
#ifdef ALLOW_PCB

      IF ( usePCB ) THEN
         call PCB_PARAM (myThid)
         write(*,*) 'finish reading PCB params PCB_PARAM (myThid)'
         call PCB_INIT_FIXED(myThid)
      ENDIF

#endif
C end xmzhang

#ifdef ALLOW_DIAGNOSTICS
C     Define diagnostics Names :
      IF ( useDiagnostics ) THEN
        CALL GCHEM_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

#endif /* ALLOW_GCHEM */

      RETURN
      END
