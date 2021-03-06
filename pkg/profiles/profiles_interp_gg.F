C $Header: /u/gcmpack/MITgcm/pkg/profiles/profiles_interp_gg.F,v 1.2 2012/06/22 22:07:34 gforget Exp $
C $Name: checkpoint64g $

#include "PROFILES_OPTIONS.h"

C     o==========================================================o
C     | subroutine profiles_interp                               |
C     | o 3D interpolation of model counterparts                 |
C     |   for netcdf profiles data                               |
C     | started: Gael Forget 15-March-2006                       |
C     o==========================================================o

      SUBROUTINE profiles_interp_gg(
     O traj_cur_out,
     I i_cur,
     I j_cur,
     I weights_cur,
     I type_cur,
     I file_cur,
     I mytime,
     I bi,
     I bj,
     I myThid
     & )

      implicit none

C ==================== Global Variables ===========================
#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PARAMS.h"
#ifdef ALLOW_CAL
#include "cal.h"
#endif
#ifdef ALLOW_PROFILES
# include "profiles.h"
#else
      integer NLEVELMAX
      parameter (NLEVELMAX=1)
#endif
#ifdef ALLOW_PTRACERS
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#endif
C ==================== Routine Variables ==========================
      _RL  mytime
      integer mythid
      integer type_cur,file_cur 
      _RL  traj_cur_out(NLEVELMAX)
      _RL  weights_cur(NUM_INTERP_POINTS)
      integer  i_cur(NUM_INTERP_POINTS)
      integer  j_cur(NUM_INTERP_POINTS)

#ifdef ALLOW_PROFILES

C ==================== Local Variables ==========================
      _RL tab_coeffs1(NUM_INTERP_POINTS)
      _RL tab_coeffs3(NUM_INTERP_POINTS)
      _RL ponderations(NUM_INTERP_POINTS)
      _RL pondsSUM
      integer q,k,kk,kcur,bi,bj
      _RL traj_cur(nR),mask_cur(nR)
      _RL tmp_coeff
c--   == end of interface ==

       do k=1,nr

        pondsSUM=0
       do q=1,NUM_INTERP_POINTS

       if (type_cur.EQ.1) then
               tab_coeffs1(q)=theta(i_cur(q),j_cur(q),k,bi,bj)
               tab_coeffs3(q)=maskC(i_cur(q),j_cur(q),k,bi,bj) 
       elseif (type_cur.EQ.2) then
               tab_coeffs1(q)=salt(i_cur(q),j_cur(q),k,bi,bj) 
               tab_coeffs3(q)=maskC(i_cur(q),j_cur(q),k,bi,bj) 
       elseif (type_cur.EQ.3) then
               tab_coeffs1(q)=uVel(i_cur(q),j_cur(q),k,bi,bj) 
               tab_coeffs3(q)=maskW(i_cur(q),j_cur(q),k,bi,bj)  
       elseif (type_cur.EQ.4) then
               tab_coeffs1(q)=vVel(i_cur(q),j_cur(q),k,bi,bj) 
               tab_coeffs3(q)=maskS(i_cur(q),j_cur(q),k,bi,bj)  
       elseif (type_cur.EQ.5) then
#ifdef ALLOW_PTRACERS
cgf if this gets used, an additional common block could be defined, containing
cgf the pTracer number (now 1, hard-coded), that would be read from the .nc input file
               tab_coeffs1(q)=pTracer(i_cur(q),j_cur(q),k,bi,bj,1) 
#else
               tab_coeffs1(q)=0 
#endif
               tab_coeffs3(q)=maskC(i_cur(q),j_cur(q),k,bi,bj) 
       elseif (type_cur.EQ.6) then
               tab_coeffs1(q)=etan(i_cur(q),j_cur(q),bi,bj) 
               tab_coeffs3(q)=maskC(i_cur(q),j_cur(q),1,bi,bj) 
       else
               tab_coeffs1(q)=0.
               tab_coeffs3(q)=0.
       endif

        ponderations(q)=tab_coeffs3(q)*weights_cur(q)
        pondsSUM=pondsSUM+ponderations(q)
        enddo

        if (pondsSUM.GT.0) then
         mask_cur(k)=1
         traj_cur(k)=0
         do q=1,NUM_INTERP_POINTS
       traj_cur(k)=traj_cur(k)+tab_coeffs1(q)*ponderations(q)/pondsSUM
         enddo
        else
         traj_cur(k)=0
         mask_cur(k)=0
        endif

       enddo

cgf vertical interpolation:
      do kk=1,NLEVELMAX
         traj_cur_out(kk)=0
         prof_mask1D_cur(kk,bi,bj)=0
      enddo
      do kk=1,ProfDepthNo(file_cur,bi,bj)
c case 1: above first grid center=> first grid center value 
        if (prof_depth(file_cur,kk,bi,bj).LT.-rC(1)) then
          traj_cur_out(kk)=traj_cur(1)
          prof_mask1D_cur(kk,bi,bj)=mask_cur(1)
c case 2: just below last grid center=> last cell value
        elseif (prof_depth(file_cur,kk,bi,bj).GE.-rC(nr)) then
          if ( prof_depth(file_cur,kk,bi,bj) .LT. 
     &    (-rC(nr)+drC(nr)/2) ) then  
            traj_cur_out(kk)=traj_cur(nr)
            prof_mask1D_cur(kk,bi,bj)=mask_cur(nr)
          endif
c case 3: between two grid centers
        else
          kcur=0
          do k=1,nr-1
            if ((prof_depth(file_cur,kk,bi,bj).GE.-rC(k)).AND.
     &      (prof_depth(file_cur,kk,bi,bj).LT.-rC(k+1))) then
              kcur=k
            endif
          enddo
          if (kcur.EQ.0) then
            WRITE(errorMessageUnit,'(A)')
     & 'ERROR in PROFILES_INTERP: unexpected case 1'
             STOP 'ABNORMAL END: S/R PROFILES_INTERP'
          endif
          if (mask_cur(kcur+1).EQ.1.) then
c  subcase 1: 2 wet points=>linear interpolation
            tmp_coeff=(prof_depth(file_cur,kk,bi,bj)+rC(kcur))/
     &      (-rC(kcur+1)+rC(kcur))
            traj_cur_out(kk)=(1-tmp_coeff)*traj_cur(kcur)
     &      +tmp_coeff*traj_cur(kcur+1)
            prof_mask1D_cur(kk,bi,bj)=1
            if (mask_cur(kcur).EQ.0.) then
            WRITE(errorMessageUnit,'(A)')
     & 'ERROR in PROFILES_INTERP: unexpected case 2'
             STOP 'ABNORMAL END: S/R PROFILES_INTERP'
            endif
          elseif (prof_depth(file_cur,kk,bi,bj).LT.-rF(kcur+1)) then
c  subcase 2: only 1 wet point just above=>upper cell value
            traj_cur_out(kk)=traj_cur(kcur)
            prof_mask1D_cur(kk,bi,bj)=mask_cur(kcur)
          endif
        endif
      enddo


#endif

      end

