C $Header: /u/gcmpack/MITgcm/pkg/pfc/pfc_param.F,v 1.2  Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"
CStartOfInterface
      SUBROUTINE PFC_PARAM( myThid )
C     *==========================================================*
C     | SUBROUTINE PFC_PARAM
C     | o Set parameters needed for PFC runs
C     *==========================================================*
C     *==========================================================*
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PFC.h"

C     == Routine arguments ==
C     myThid -  Number of this instance of PFC_PARAM
      INTEGER myThid
CEndOfInterface

#ifdef ALLOW_PFC

C     == Local variables ==

      _BEGIN_MASTER( myThid )
C XZ : define Schmidt no. coefficients for PFC based on Tsilingiris 2008
      sv_0 = 1.71575 _d -5
      sv_1 = 4.7224 _d -8
      sv_2 = -3.6630 _d -10
      sv_3 = 1.87324 _d -12
      sv_4 = -8.0502 _d -14
      sd_0 = 1.2934 _d 0 
      sd_1 = -5.5384 _d -3
      sd_2 = 3.8602 _d -5
      sd_3 = -5.2536 _d -7
      
      Va = 20.1 _d 0  !cm3/mol
      Vb = 8*15.9 _d 0+15*14.7 _d 0+1*2.31 _d 0+2*6.11 _d 0 !PFOA need to change for other PFASs 
c          #C         #F        #H        #O
      Vb = 8*15.9 _d 0+15*14.7 _d 0+1*2.31 _d 0+2*6.11 _d 0+1*25.6d0 !PFOS  
c          #C         #F        #H        #O       #S
      Ma = 28.97 _d 0 !g/mol
c      Mb = 414.1 _d 0 ! for PFOA
      Mb = 499.0 _d 0 ! for PFOS
      Patm = 1.0 _d 0 !atm
      
c      pKa = 0.0d0  ! xz: for PFOA, even smaller for PFOS
      pKa = -3.d0  ! xz: PFOS From Campbell et al  JPC-A 2009 113
      
      Koc_pfc = 372.d0 ! xz: Koc for PFOS 372 L/kg, need to be changed for other PFCs
c       write(*,*)'xz check Koc_pfc  in pfc_param:',Koc_pfc 
      Kiw = 5.1d-6*1.97d0   !xz PFOS interface/water partition coefficient in
c the unit of m from Vecitis et al JPC-C 2008 43 at dilute condition of
C the Langmuir adsorption equation. 
#ifdef ALLOW_SEASPRAY
      enrichfactor = 5.6d0 !for PFOA MCMURDO et al. Environ. Sci. Technol. 2008, 42, 3969–3974
c        write(*,*)'xz check enrichfactor in pfc_param:',enrichfactor 
#endif /* ALLOW_SEASPRAY */

      _END_MASTER( myThid )

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_PFC */

      RETURN
      END
