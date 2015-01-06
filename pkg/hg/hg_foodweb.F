C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_foodweb.F,v 1.10 2010/03/16 00:14:47 jmc Exp $
C $Name: checkpoint64g $

C To calculate the chemistry of Hg species in the ocean, yxzhang, 5/30/13

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE HG_FOODWEB(   Ptr,
     &                         Gchem,
     &                         bi,bj,imin,imax,jmin,jmax,
     &                         myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE HG_FOODWEB                                    |
C     | o Calculate the changes to Hg species because            |
C     |   of foodweb dynamics                                    |
C     |   based on Asif Quesi 2013 paper                         |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "HG_SIZE.h"
#include "HG.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  Gchem(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      INTEGER bi, bj, imin, imax, jmin, jmax
#ifdef FOODW_MODE
C     == Local variables ==            
      INTEGER i,j,k
      INTEGER np,nz
      _RL total_mmhg
      _RL VCF, VCFPP(npmax)  !volume concentration factor, m3/m3 
      _RL fphy(npmax) !fraction of MMhg on phytoplankton
      _RL total_fphy, phytopo(npmax), zoopo(nzmax), no3o
      _RL gr, cpp    !temporary variable
      _RL tiny
      PARAMETER(tiny=1d-32)
      
C     == Phytoplankton variables
      _RL SVR(npmax)  !surface area to volume ratios, um-1
      _RL mgr(npmax)  !max growth rate, d-1
      _RL hsc(npmax)  !half saturation constant (uM-N)
      _RL fcarbon     !carbon content of wet phytoplankton      
      DATA SVR /7.5d-2  ,3d-1, 3d0/   ! um-1, 3/r, three species with radius of 40 um, 10 um and 1 um, Queshi 2013
      DATA mgr / 8d-1  ,8d-1, 1.2d0/  ! Figure 3, Ward et al 2012
      DATA hsc /4.97d0,  1.62d-0, 2.5d-1/   ! 0.17v^0.27, Ward et al 2012
      DATA fcarbon /1d-1/
      

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG
#ifdef FOODW_MODE

C     == Parameters
C     VCF
      VCF = 1.26d4 * dexp(-5d-3*max(doc(i,j,k,bi,bj),0d0))  !mmol C/m3 -> umol C/L
      DO np=1,npmax
          VCFPP(np)=VCF*SVR(np)/0.94
      ENDDO

C     == Partition MMHg onto phytoplankton
      DO j=jMin,jMax
       DO i=iMin,iMax
        DO k=1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
           ! Localize variables
           DO np=1,npmax
               phytopo(np) = max(phytoP(i,j,k,bi,bj,np),0d0)
           ENDDO
           DO nz=1,nzmax
               zoopo(nz) = max(zooP(i,j,k,bi,bj,nz),0d0)
           ENDDO
           no3o = max(NO3(i,j,k,bi,bj),0d0)
             
           ! total mmhg concentration
           total_mmhg = max(Ptr(i,j,k,bi,bj,immhg),0d0)
           DO np=1,npmax
               total_mmhg = total_mmhg 
     &                    + max(Ptr(i,j,k,bi,bj,iPhy+np-1),0d0)          
           ENDDO
           
           ! calculate partitioning
           total_fphy=1d0
           DO np=1,npmax
               gr = mgr(np) * no3o / (hsc(np) + no3o)
               cpp = 2.01d-1  
     &              * VCFPP(np) / 1d3 
     &              * 7.3d-1 / ( gr + tiny )   !ng g ww-1
               fphy(np) = cpp / 2.006d2   ! mol g ww-1
     &              * phytopo(np) * 1d-3 * 1.2d1 / fcarbon  ! g ww /m3            
                                                                      ! transfer to mol/m3  
               total_fphy = total_fphy + fphy(np)                 
           ENDDO
           Ptr(i,j,k,bi,bj,immhg)=total_mmhg/(total_fphy+tiny)
           DO np=1,npmax
               Ptr(i,j,k,bi,bj,iPhy+np-1)=total_mmhg*fphy(np)
     &                  / (total_fphy+tiny)        
           ENDDO
         ENDIF
        ENDDO
       ENDDO
      ENDDO
      
C     == Start biomagnification

#endif
#endif
#endif

#endif
       RETURN
       END
