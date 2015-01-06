C $Header: /u/gcmpack/MITgcm/pkg/pfc/pfc_calwaterspray.F, Exp $
C $Name:  $

#ifdef ALLOW_SEASPRAY
#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"

CBOP
C     !ROUTINE: PFCn_SURFFORCING
C     !INTERFACE:
      SUBROUTINE PFC_CalcWaterSpray (
C     O                          IntWtrDrpVolFlux, 
     I           i,j, bi, bj)

C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE PFC_CalcWaterSpray
C     | o Calculate the PFC air-sea fluxes by xz
C     *==========================================================*

C     !USES:
      IMPLICIT NONE

C     == GLobal variables ==ß
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PFC_SIZE.h"
#include "PFC.h"
#ifdef ALLOW_EXF
# include "EXF_FIELDS.h"
#endif
#ifdef ALLOW_SEAICE
# include "SEAICE_SIZE.h"
# include "SEAICE.h"
#endif
#ifdef ALLOW_THSICE
# include "THSICE_VARS.h"
#endif /* ALLOW_THSICE */

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid

C      _RL  IntWtrDrpVolFlux(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, nSx, nSy)
C      _RL ef !enhancement factor of PFC in water droplet in pfci_surfforcing
      
      INTEGER i,j, bi, bj
        
C     == Local variables ==
        _RL    a, b, eps
        _RL    fa, fb, h, t1, s, x
        Integer n, k,step   
      
c        IntWtrDrpVolFlux(i, j, bi, bj)=0.d0
        seaspraywtrflux(i,j,bi,bj)=0.0

C        data a, b, eps /2.d0, 500.d0, 1.d-5/ !integrate 2-500 um water droplets
        a=2.d0
        b=500.d0
        eps=1.d0
        
c            fa = WtrDrpVolFlux(wind (i,j,bi,bj),a)
C       write(*,*) 'xz check fa in CalcWaterSpray', fa
c            fb = WtrDrpVolFlux(wind (i,j,bi,bj),b)
c            n = 1
c            h = b - a 
c            t1 = h * (fa+fb)/2.0d0
c  5         s = 0.d0
c            Do 10 k = 0, n-1
c                x = a + (real(k)+0.5d0)*h
c                s = s + WtrDrpVolFlux(wind (i,j,bi,bj),x)
c  10        Continue
c            IntWtrDrpVolFlux (i,j,bi,bj) = (t1+h*s)/2.0d0
c            If (abs(t1-IntWtrDrpVolFlux (i,j,bi,bj)) .GE. eps) then
c                t1 = IntWtrDrpVolFlux (i,j,bi,bj)
c                n = n + n 
c                h = h/2.0d0
c                GOTO 5
c            End If
c            Return


      n=10
c      h = 1.0/REAL(n)     
      s = 0.0   
      enrichfactor=0.0
      DO 2 step = n,1,-1     
        x = REAL(step)*(b-a)/REAL(n)       
        s = s  + WtrDrpVolFlux(wind (i,j,bi,bj),x)
        enrichfactor=enrichfactor+(1+3.d0*Kiw*1.d6/x)*s
c       write(*,*) 'xz check loop i=', i
   2  CONTINUE    
C      IntWtrDrpVolFlux (i,j,bi,bj)=s
      seaspraywtrflux(i,j,bi,bj)=s
        enrichfactor=enrichfactor/s  !weighed to volume flux of
c different size 
c      write(*,*) 'xz check enrichfactor',enrichfactor
c    
c      write(*,*) 'i, j, bi, bj, IntWtrDrpFlux',i, j, bi,bj,
C     &  IntWtrDrpVolFlux (i,j,bi,bj)
c    & seaspraywtrflux(i,j,bi,bj)


        
             
        CONTAINS
      REAL  FUNCTION WtrDrpVolFlux (u10, r0) 
C     !DESCRIPTION:
C     *==========================================================*
C     | xz: function for volume flux in m3/m2/s/um of sea spray droplet
C       M. H. Smith et al. (1993) sea spray generation function
C     *==========================================================*

C     !USES:    
            Implicit None
C            REAL WtrDrpVolFlux
            _RL cdn10, u14, k, a1, a2
            _RL dfsdr80, temp1, temp2, temp11, temp21
            _RL u10, r0
            If (u10 .LE. 11.d0 ) Then
                cdn10 = 1.2d-3
            Else
                cdn10 = 1.d-3*(0.49d0+0.065d0*u10)
            Endif
            k = 0.4d0
            u14 = u10*(1.d0+cdn10**0.5d0/k*LOG(1.4))
            a1 = 10d0**(0.0676d0*u14+2.43d0)
            a2 = 10d0**(0.959d0*u14**0.5d0-1.476d0)
            temp1 = log(0.518d0*r0**0.976d0/2.1d0)
            temp1 = log(0.518d0*r0**0.976d0/9.2d0)
            dfsdr80 = a1*exp(-3.1d0*temp11*temp11) 
     &           + a2*exp(-3.3d0*temp21*temp21)
            WtrDrpVolFlux =(4d0/3d0*3.14d0*r0**3d0*1.d-18)
     &   * 3.5d0*dfsdr80*0.506d0*r0**(-0.024d0)
        Return
        End Function WtrDrpVolFlux    
        
         
       End Subroutine PFC_CalcWaterSpray  
   
#endif /*ALLOW_SEASPRAY*/
