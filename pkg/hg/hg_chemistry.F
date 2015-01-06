C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_chemistry.F,v 1.10 2010/03/16 00:14:47 jmc Exp $
C $Name: checkpoint64g $

C To calculate the chemistry of Hg species in the ocean, yxzhang, 5/30/13
C

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE HG_CHEMISTRY( Ptr,
     &                         Gchem,    
     &                         bi,bj,imin,imax,jmin,jmax,
     &                         myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE HG_CHEMISTRY                                  |
C     | o Calculate the changes to Hg species because            |
C     |   photo- and bio-chemical reactions, and food web        |
C     |   based on Anne Sorerensen 2013 paper                    |
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
#include "GCHEM.h"
#include "HG_SIZE.h"
#include "HG.h"


C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  Gchem(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)    
#ifdef ALLOW_DIAGNOSTICS      
      _RL  hg2redn_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  hg2redb_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  hg2redp_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  hg0oxdb_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  hg0oxdp_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  hg0oxdd_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#ifdef HGPRIVER       
      _RL  hgrdiss_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#endif                  
      CHARACTER*8 diagname
#endif
      _RL,save :: meansuncos(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      LOGICAL,SAVE :: FIRST
      data FIRST /.TRUE./
      INTEGER nl
      INTEGER i,j,k,l,bi, bj, imin, imax, jmin, jmax
      
#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG
C     == Local variables ==
      _RL radz, radz0, ecz1, ecz2
      _RL depth, suncos
      _RL hg0_old, hg2_old, hg0_new, hg2_new
#ifdef METHY_MODE
      _RL mmhg_old,dmhg_old,mmhg_new,dmhg_new
#endif      

C     -- Gross tendencies
      _RL invdt
      _RL hg2_hg0, hg0_hg2
#ifdef HGPRIVER
      _RL hgr_hg2
#endif      
#ifdef METHY_MODE      
      _RL hg2_mmhg, mmhg_hg2
      _RL mmhg_hg0, mmhg_dmhg, dmhg_mmhg
#endif
C     == Parameters
C     -- Radiation extinction
      _RL EC_w    ! m-1
      _RL EC_doc  ! m-1
      _RL EC_chla ! m-1
      data EC_w /0.0145 _d 0/
      data EC_doc /0.654 _d 0/
      data EC_chla /3.1 _d 1/

C     -- Reaction base, scale factors
C     -- Inorganic species, from Soerensen 2010
      _RL k_hg2_hg0_rad  ! s-1
      _RL k_hg2_hg0_bio
      _RL k_hg0_hg2_rad
      _RL k_hg0_hg2_dak
      _RL k_hg0_hg2_bio

      _RL k_hg2_hg0_rad_base
      _RL k_hg2_hg0_bio_base
      _RL k_hg0_hg2_rad_base
      _RL k_hg0_hg2_dak_base
      _RL k_hg0_hg2_bio_base
      _RL k_hg2_red_fraction      
      data k_hg2_hg0_rad_base / 1.56d-6/
C     Sorensen 2010, based on production 
C     data k_hg2_hg0_bio_base / 4.51d-10/  s-1 (mgCm-2d-1 npp)-1
C     based on remin, through entire water column, s-1(mgCm-3d-1 fremin)-1
      data k_hg2_hg0_bio_base / 6.2d-7 /
C     assume Hg0:Hg2 in deep ocean = 1:4      
      data k_hg0_hg2_bio_base / 9.9d-7/
      data k_hg0_hg2_rad_base / 5.6d-6/
C     Sorensen 2010, constant
C     now scaled based on monthly mean rad
C     data k_hg0_hg2_dak_base / 1d-7/
      data k_hg0_hg2_dak_base / 1.3d-9/
      data k_hg2_red_fraction /4.0 _d -1/

C     -- Methylation and demethylation
#ifdef METHY_MODE
      _RL k_hg2_mmhg_bio_base
      _RL k_mmhg_hg2_rad_base
      _RL k_mmhg_hg0_bio_base
      
      _RL k_mmhg_dmhg_bio_base
      _RL k_dmhg_mmhg_bio_base

      _RL k_dmhg_mmhg_rad_base

      _RL k_mmhg_dmhg_dak_base
      _RL k_dmhg_mmhg_dak_base 
#endif
      
C     -- Overall reduction in subsurface waters, from Zhang 2013
C      _RL k_hg2_hg0_remin_base 
C      data k_hg2_hg0_remin_base / 1d-10 /

#ifdef METHY_MODE
      !anls data k_hg2_mmhg_bio_base / 8.0d-8 /
      !anls data k_mmhg_hg2_rad_base /5.7d-7 * 0.432/
      !anls data k_mmhg_hg0_bio_base /2.3d-8/
      !anls data k_mmhg_dmhg_bio_base /3.0d-9/
      !anls data k_dmhg_mmhg_bio_base /1.0d-6/
      
      ! Lehnherr et al 2011
      data k_hg2_mmhg_bio_base / 1.6d-8 /      
      data k_mmhg_hg2_rad_base /2.3d-8/      
      data k_mmhg_hg0_bio_base /8d-7/                  
      data k_mmhg_dmhg_bio_base /3.0d-9/
      data k_dmhg_mmhg_bio_base /1.0d-6/      
      data k_dmhg_mmhg_rad_base / 2.3d-8/  ! no data yet, assume the same as mmhg photodecomposition      
      data k_mmhg_dmhg_dak_base / 7.5d-9 /  ! Lehnherr et al 2011, use the oxcline rate
      data k_dmhg_mmhg_dak_base / 1.5d-8 /  ! Assume MMHg:DMHg=2:1 at deep ocean    
#endif

C     == Gross rate constant
      _RL k_hg2_hg0, k_hg0_hg2
#ifdef HGPRIVER       
      _RL k_hgr_hg2
      data k_hgr_hg2 / 3.85d-8 /  !10%/ (30 day)
      INTEGER nriver 
#endif            
#ifdef METHY_MODE      
      _RL k_hg2_mmhg, k_mmhg_hg2, k_mmhg_hg0
      _RL k_mmhg_dmhg, k_dmhg_mmhg
#endif
C     ==local variables      
      _RL nppo,chlo,fremino,doco,radswo,radswo0,meank     
      _RL myTimeo
      
C     == Start calculation

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO k=1,Nr
        DO j=jMin,jMax
          DO i=iMin,iMax
            hg2redn_diag(i,j,k)=0d0
            hg2redb_diag(i,j,k)=0d0
            hg2redp_diag(i,j,k)=0d0
            hg0oxdb_diag(i,j,k)=0d0
            hg0oxdp_diag(i,j,k)=0d0
            hg0oxdd_diag(i,j,k)=0d0
#ifdef HGPRIVER       
            hgrdiss_diag(i,j,k)=0d0
#endif                          
          ENDDO
        ENDDO
      ENDDO
#endif
      
C     == calculate monthly mean suncos
      IF ( mod( myTime, 2592000.0 ) .lt. 0.1 .or. FIRST) THEN
       FIRST = .FALSE.   
       nl = 2592000 / deltaTclock * nsubtime
       DO j=jMin,jMax
        DO i=iMin,iMax
         IF (HFacC(i,j,1,bi,bj).gt.0. _d 0) THEN
           meansuncos(i,j)=0. _d 0  
           DO l=1,nl
            myTimeo=myTime+dble(l-1)*deltaTclock/dble(nsubtime)   
            CALL hg_suncos(i,j,bi,bj,myTimeo,suncos)  
            meansuncos(i,j)=meansuncos(i,j)+suncos
           ENDDO
           meansuncos(i,j)=meansuncos(i,j)/dble(nl)   
         ENDIF                                   
        ENDDO
       ENDDO
      ENDIF
      
      DO j=jMin,jMax
       DO i=iMin,iMax
       IF (HFacC(i,j,1,bi,bj).gt.0. _d 0) THEN    
C     == Radiation attenuation calculation
        ecz1 = 0d0
        ecz2 = 0d0
        depth = 0d0
C     == localize variables
        radswo0 =  max(radsw(i,j,bi,bj),0d0)*(1d0-Fice(i,j,bi,bj))  ! wm-2
C       impose a diurnal cycle
        CALL hg_suncos(i,j,bi,bj,myTime,suncos)
        radswo = radswo0 * suncos / (meansuncos(i,j) + 1. _d -32)        
                          
        DO k=1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
C     == localize variables
           nppo =    max(npp(i,j,k,bi,bj),0d0)
           fremino = max(Fremin(i,j,k,bi,bj),0d0)
           chlo =    max(chl(i,j,k,bi,bj),0d0)
           doco =    max(doc(i,j,k,bi,bj),0d0)

           depth = depth + drF(k)
           IF (k .le. 10) THEN
            ecz2 = ecz1 + drF(k) * ( EC_w
     &           + EC_doc * doco * 1.2d-2   ! mmolC/m3 -> mg/L
     &           + EC_chla * chlo * 1.0d-3 ) ! mg chl/m3 -> mg/L
            meank = 1. _d 0 / (ecz2 - ecz1)
     &          * ( exp( -ecz1 ) - exp( -ecz2 ) )
            radz = radswo * meank
            radz0 = radswo0 * meank ! for dark oxidation
            ecz1 = ecz2                  
           ELSE
            radz = 0. _d 0
            radz0 = 0. _d 0
           ENDIF

C     == Rate coefficent calculation
c     -- inorganic species
           k_hg2_hg0_rad = k_hg2_hg0_rad_base * radz * 
     &                     k_hg2_red_fraction
           k_hg2_hg0_bio = k_hg2_hg0_bio_base * fremino * 
     &                     k_hg2_red_fraction  ! mmolCm-3d-1
           k_hg2_hg0 = k_hg2_hg0_rad + k_hg2_hg0_bio
c          coast
           IF (doco .gt. 4.99 _d 2) k_hg2_hg0 = k_hg2_hg0 * 0.5
 
           k_hg0_hg2_rad = k_hg0_hg2_rad_base * radz
           k_hg0_hg2_bio = k_hg0_hg2_bio_base * fremino  ! mmolCm-3d-1
           k_hg0_hg2_dak = k_hg0_hg2_dak_base * radz0
           k_hg0_hg2 = k_hg0_hg2_rad
     &               + k_hg0_hg2_bio
     &               + k_hg0_hg2_dak

c     -- methylation/demethylation
#ifdef METHY_MODE          
           k_hg2_mmhg = k_hg2_mmhg_bio_base * fremino * 0.60  ! chl = 0.6 * fremin
           k_mmhg_hg2 = k_mmhg_hg2_rad_base * radz 
           k_mmhg_hg0 = k_mmhg_hg0_bio_base * fremino * 0.60  ! this also happens at subsurface waters

c     -- transfer between mmhg and dmhg                      
           k_mmhg_dmhg = k_mmhg_dmhg_bio_base * chlo
     &                 + k_mmhg_dmhg_dak_base      
           k_dmhg_mmhg = k_dmhg_mmhg_bio_base * chlo
     &                 + k_dmhg_mmhg_rad_base * radz
     &                 + k_dmhg_mmhg_dak_base                 
#endif
           
C     == Calculation Safety
           invdt = 1.0 _d 0 / deltaTclock * dble(nsubtime) * 9.9 _d -1
           k_hg0_hg2 = min (k_hg0_hg2, invdt)
           k_hg2_hg0 = min (k_hg2_hg0, invdt)
#ifdef METHY_MODE           
           k_hg2_mmhg = min (k_hg2_mmhg, invdt)
           k_mmhg_hg2 = min (k_mmhg_hg2, invdt)
           k_mmhg_hg0 = min (k_mmhg_hg0, invdt)
           k_mmhg_dmhg = min (k_mmhg_dmhg, invdt)
           k_dmhg_mmhg = min (k_dmhg_mmhg, invdt)           
#endif
           
C     == Local concentrations
           hg0_old = max( PTR(i,j,k,bi,bj,ihg0), 0d0)
           hg2_old = max( PTR(i,j,k,bi,bj,ihg2), 0d0)
#ifdef METHY_MODE
           mmhg_old = max( PTR(i,j,k,bi,bj,immhg), 0d0)
           dmhg_old = max( PTR(i,j,k,bi,bj,idmhg), 0d0)
#endif

C           CALL hg_dsolve(hg0_old,hg2_old,
C#ifdef METHY_MODE           
C     &                 mmhg_old,dmhg_old,                
C#endif     
C     &                 hg0_new,hg2_new,
C#ifdef METHY_MODE           
C     &                 mmhg_new,dmhg_new,                
C#endif
C     &                 k_hg0_hg2,k_hg2_hg0,
C#ifdef METHY_MODE           
C     &                 k_hg2_mmhg,k_mmhg_hg2,k_mmhg_hg0,
C     &                 k_mmhg_dmhg,k_dmhg_mmhg,                
C#endif
C     &                 hg0_hg2,deltaTclock)
C     Note: the hg0_hg2 has different unit!

C     == Tendency calcualtion                      
C          hg2_hg0   = hg0_hg2 - (hg2_new - hg2_old)
           hg2_hg0   = k_hg2_hg0 * hg2_old
           hg0_hg2   = k_hg0_hg2 * hg0_old
#ifdef HGPRIVER
            hgr_hg2 = 0d0
            DO nriver=1,nrmax
              hgr_hg2 = hgr_hg2 + k_hgr_hg2 
     &           * max( Ptr(i,j,k,bi,bj,ihgr+nriver-1), 0d0)
            ENDDO
#endif
#ifdef METHY_MODE           
           hg2_mmhg  = k_hg2_mmhg  * hg2_old
           mmhg_hg2  = k_mmhg_hg2  * mmhg_old
           mmhg_hg0  = k_mmhg_hg0  * mmhg_old
           mmhg_dmhg = k_mmhg_dmhg * mmhg_old
           dmhg_mmhg = k_dmhg_mmhg * dmhg_old
#endif           
           
C Calculate diagnistics                                                  
#ifdef ALLOW_DIAGNOSTICS
            hg2redn_diag(i,j,k) = hg2_hg0 - hg0_hg2   !net reduction, mol/m^3/s
            if ( k_hg2_hg0 .gt. 1. _d -48 ) then
              hg2redb_diag(i,j,k) = k_hg2_hg0_bio / 
     &                            k_hg2_hg0  * 
     &                            hg2_hg0 !/ deltaTclock   !mol/m^3/s    
              hg2redp_diag(i,j,k) = k_hg2_hg0_rad / 
     &                            k_hg2_hg0  * 
     &                            hg2_hg0 !/ deltaTclock   !mol/m^3/s
            else
              hg2redb_diag(i,j,k) = 0. _d 0    
              hg2redp_diag(i,j,k) = 0. _d 0
            endif    
            if ( k_hg0_hg2 .gt. 1. _d -48 ) then
              hg0oxdb_diag(i,j,k) = k_hg0_hg2_bio / 
     &                            k_hg0_hg2 * 
     &                            hg0_hg2 !/ deltaTclock   !mol/m^3/s
              hg0oxdp_diag(i,j,k) = k_hg0_hg2_rad / 
     &                            k_hg0_hg2  * 
     &                            hg0_hg2 !/ deltaTclock   !mol/m^3/s
              hg0oxdd_diag(i,j,k) = k_hg0_hg2_dak / 
     &                            k_hg0_hg2 * 
     &                            hg0_hg2 !/ deltaTclock   !mol/m^3/s
            else
              hg0oxdb_diag(i,j,k) = 0. _d 0
              hg0oxdp_diag(i,j,k) = 0. _d 0
              hg0oxdd_diag(i,j,k) = 0. _d 0
            endif
#ifdef HGPRIVER
            hgrdiss_diag(i,j,k) = hgr_hg2
#endif                            
#endif

C     == Calculate new tracer
           hg0_new = hg0_old + ( hg2_hg0 - hg0_hg2
#ifdef METHY_MODE           
     &             + mmhg_hg0
#endif     
     &             ) * deltaTclock / dble(nsubtime)
           hg2_new = hg2_old + ( hg0_hg2 - hg2_hg0           
#ifdef METHY_MODE           
     &             + mmhg_hg2 - hg2_mmhg
#endif
     &             ) * deltaTclock / dble(nsubtime) 
#ifdef METHY_MODE              
           mmhg_new = mmhg_old + ( hg2_mmhg + dmhg_mmhg 
     &              - mmhg_hg2 - mmhg_hg0
     &             ) * deltaTclock / dble(nsubtime)      
           dmhg_new = dmhg_old + ( mmhg_dmhg - dmhg_mmhg
     &             ) * deltaTclock / dble(nsubtime)            
#endif           

C     == Accumulate tendency
           Gchem(i,j,k,bi,bj,ihg0)=Gchem(i,j,k,bi,bj,ihg0)+
     &                             (hg0_new-hg0_old)
     &                             /deltaTclock * dble(nsubtime)           
           Gchem(i,j,k,bi,bj,ihg2)=Gchem(i,j,k,bi,bj,ihg2)+
     &                             (hg2_new-hg2_old)
     &                             /deltaTclock * dble(nsubtime)  
#ifdef HGPRIVER
           Gchem(i,j,k,bi,bj,ihg2)=Gchem(i,j,k,bi,bj,ihg2)+hgr_hg2
           DO nriver=1,nrmax
             Gchem(i,j,k,bi,bj,ihgr+nriver-1)=
     &            Gchem(i,j,k,bi,bj,ihgr+nriver-1) - k_hgr_hg2 * 
     &            max(Ptr(i,j,k,bi,bj,ihgr+nriver-1), 0d0)
           ENDDO
#endif                        
#ifdef METHY_MODE           
           Gchem(i,j,k,bi,bj,immhg)=Gchem(i,j,k,bi,bj,immhg)+
     &                              (mmhg_new-mmhg_old)
     &                             /deltaTclock * dble(nsubtime)    
           Gchem(i,j,k,bi,bj,idmhg)=Gchem(i,j,k,bi,bj,idmhg)+
     &                              (dmhg_new-dmhg_old)
     &                             /deltaTclock * dble(nsubtime)    
#endif

         ENDIF
        ENDDO
        
       endif
       ENDDO
      ENDDO
      
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'HG2REDN '
        CALL DIAGNOSTICS_FILL( hg2redn_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG2RBIO '
        CALL DIAGNOSTICS_FILL( hg2redb_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG2RPHO '
        CALL DIAGNOSTICS_FILL( hg2redp_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG0OBIO '
        CALL DIAGNOSTICS_FILL( hg0oxdb_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG0OPHO '
        CALL DIAGNOSTICS_FILL( hg0oxdp_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG0ODAK '
        CALL DIAGNOSTICS_FILL( hg0oxdd_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#ifdef HGPRIVER
        WRITE(diagname,'(A8)') 'HGRDISS '
        CALL DIAGNOSTICS_FILL( hgrdiss_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#endif       
     
#endif

#endif
#endif

       RETURN
       END
