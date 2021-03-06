C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_usercost_all.F,v 1.3 2012/08/10 19:45:27 jmc Exp $
C $Name: checkpoint64g $

#include "ECCO_OPTIONS.h"


      subroutine cost_usercost_all( myiter, mytime, mythid )

c     ==================================================================
c     SUBROUTINE cost_usercost_all
c     ==================================================================
c
c     o Evaluate user defined penalty terms
c
c     ==================================================================
c     SUBROUTINE cost_usercost_all
c     ==================================================================

      implicit none

c     == global variables ==

#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"

#include "cal.h"
#include "ctrl.h"
#include "ecco_cost.h"

c     == routine arguments ==

      integer mythid
      integer myiter
      _RL     mytime

c     == local variables ==

      integer startrec
      integer endrec

c     == end of interface ==

c--   Evaluate user defined cost function contributions.
c--   [to be added here by user]

      end

