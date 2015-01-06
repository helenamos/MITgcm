C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/get_domain_size.F,v 1.1 2004/03/30 03:58:56 cnh Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

      SUBROUTINE GET_DOMAIN_SIZE( gnx, gny, gnr, gOL )

      IMPLICIT NONE

C     == Global data ==
#include "SIZE.h"

C     == Routine arguments ==
      INTEGER gnx
      INTEGER gny
      INTEGER gnr
      INTEGER gOL

      gnx = Nx
      gny = Ny
      gnr = Nr
      gOL = OLx

      RETURN
      END
