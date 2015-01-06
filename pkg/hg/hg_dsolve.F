#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE hg_dsolve(hg0_old,hg2_old,
#ifdef METHY_MODE           
     &                 mmhg_old,dmhg_old,                
#endif     
     &                 hg0_new,hg2_new,
#ifdef METHY_MODE           
     &                 mmhg_new,dmhg_new,                
#endif
     &                 k_hg0_hg2,k_hg2_hg0,
#ifdef METHY_MODE           
     &                 k_hg2_mmhg,k_mmhg_hg2,k_mmhg_hg0,
     &                 k_mmhg_dmhg,k_dmhg_mmhg,                
#endif
     &                 hg0_hg2,dt)
           

C     /==========================================================\
C     | SUBROUTINE HG_DSOLVE                                     |
C     | a linear ordinary differential equation solver           |
C     |==========================================================|
      IMPLICIT NONE
C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "HG_SIZE.h"
#include "HG.h"

C     == input variables
C     == concentrations            
      _RL hg0_old, hg2_old, hg0_new, hg2_new
#ifdef METHY_MODE
      _RL mmhg_old,dmhg_old,mmhg_new,dmhg_new
#endif
C     == gross tendencies
      _RL hg0_hg2
C     == rate constants       
      _RL k_hg0_hg2,k_hg2_hg0
#ifdef METHY_MODE           
      _RL k_hg2_mmhg,k_mmhg_hg2,k_mmhg_hg0
      _RL k_mmhg_dmhg,k_dmhg_mmhg               
#endif

      _RL dt      
      
C     == local variables
      _RL k,kt,ekt
      _RL small_number
      data small_number /1. _d -32/
      
#ifndef METHY_MODE
C     == now I can solve hg0, hg2 system
      if ( k_hg0_hg2 .ge. small_number .and. 
     &     k_hg2_hg0 .ge. small_number ) then
        k    = k_hg0_hg2 + k_hg2_hg0
        kt   = k * dt
        ekt  = dexp(-kt)      
        hg0_new = hg0_old * ( k_hg2_hg0 + k_hg0_hg2 * ekt ) / k
     &          +  hg2_old * ( 1. _d 0 - ekt ) * k_hg2_hg0 / k
        hg2_new = hg2_old + hg0_old - hg0_new
        hg0_hg2 = k_hg0_hg2 / (k**2) *
     &      ( hg0_old * ( k_hg0_hg2 * (1. _d 0 - ekt ) + 
     &                    k_hg2_hg0 * kt ) + 
     &        hg2_old * ( k_hg2_hg0 * (-1. _d 0 + ekt ) + 
     &                    k_hg2_hg0 * kt ) )
      elseif ( k_hg0_hg2 .ge. small_number .and. 
     &     k_hg2_hg0 .lt. small_number ) then
        hg2_new = hg2_old * dexp(-dt*k_hg0_hg2)
        hg0_new = hg0_old + hg2_old - hg2_new
        hg0_hg2 = hg0_old - hg0_new
      elseif ( k_hg0_hg2 .lt. small_number .and. 
     &     k_hg2_hg0 .ge. small_number ) then
        hg0_new = hg0_old * dexp(-dt*k_hg2_hg0)
        hg2_new = hg2_old + hg0_old - hg0_new
        hg0_hg2 = hg0_old - hg0_new
      else
        hg0_new = hg0_old
        hg2_new = hg2_old
        hg0_hg2 = 0. _d 0      
      endif
#else
#endif      

       RETURN
       END
