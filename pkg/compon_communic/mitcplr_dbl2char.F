C $Header: /u/gcmpack/MITgcm/pkg/compon_communic/mitcplr_dbl2char.F,v 1.1 2009/09/14 16:19:09 jmc Exp $
C $Name: checkpoint64g $

!=======================================================================
      subroutine mitcplr_dbl2char( rarg, carg )
      implicit none
! Predefined constants/arrays
#include "CPLR_SIG.h"
! Arguments
      character*(MAXLEN_COMP_NAME) carg
      real*8 rarg(MAXLEN_COMP_NAME)
! Local
      integer j
!     ------------------------------------------------------------------

! Convert the integer array to characters
      do j=1,MAXLEN_COMP_NAME
       carg(j:j) = char( nint( rarg(j) ) )
      enddo

!     ------------------------------------------------------------------
      return
      end
!=======================================================================
