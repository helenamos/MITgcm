C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb01_surfforcing.F, Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CBOP
C     !ROUTINE: PCBd_SURFFORCING
C     !INTERFACE:
      SUBROUTINE PCBd_SURFFORCING( Ptr, SurfPCBd,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE PCBd_SURFFORCING
C     | o Calculate the PCBd air-sea fluxes
C     *==========================================================*

C     !USES:
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PCB_SIZE.h" !in ./code/pcb_size.h
#include "PCB.h"

C------------------------------------------------------------
C INPUT/OUTPUT PARAMETERS:
C     pTr_PCB01  :: ocean PCB01 concentration
C     AtmosPCB01 :: atmospheric PCB01 field    ! I can't find this variable? Obsolete? (hma, 11 Jul 2014)
C     fluxPCB01  :: air-sea PCB01 fluxes
C     bi, bj     :: current tile indices
C     iMin,iMax  :: computation domain, 1st index bounds
C     jMin,jMax  :: computation domain, 2nd  index bounds
C     myTime     :: current time in simulation
C     myIter     :: current iteration number
C     myThid     :: my Thread Id number
C------------------------------------------------------------
      _RL  PTR     ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, 
     &               nSx          , nSy          , PTRACERS_num )
      _RL  SurfPCBd( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL  FluxPCBd( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
C      _RL  PCBdRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)   ! Don't need river tracers. (hma, 11 Jul 2014)
C      _RL  pcbnrivero, pcbnevaso                            ! Don't need river tracers. (hma, 11 Jul 2014)
      _RL pcbnevaso
#ifdef ALLOW_SEASPRAY
      _RL pcbnseasprayo
#endif
      _RL myTime
      INTEGER iMin, iMax, jMin, jMax, bi, bj
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

C     !LOCAL VARIABLES:
C i, j, k - Loop counters
      INTEGER i,j,k
C Solubility relation coefficients
      _RL etaA, rhoA
      _RL etaW
      _RL SchmidtAPCBd
      _RL SchmidtWPCBd
      _RL DiffusivityAir       ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL DiffusivitySurfWater ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL ka                   ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL kw                   ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL Kaexch               ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
c      _RL Kwexch(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL KawPCBd              ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL KawPCBeff            ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
c      _RL pcb01sat(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL Csat(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ttemp, ttemp2
      _RL temp1, temp2, temp3, temp4, temp5, temp6
      _RL doco
#ifdef ALLOW_DIAGNOSTICS      
      _RL pcbnconc_diag        ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
      _RL pcbnevas_diag        ( 1-OLx:sNx+OLx, 1-OLy:sNy+OLy )
c Not considering seaspray for PCBs (hma, 11 Jul 2014)
c#ifdef ALLOW_SEASPRAY
c      _RL pcbnseaspray_diag    ( 1-OLx:sNx+OLx ,1-OLy:sNy+OLy )
c#endif
C      _RL pcbnriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)   ! Don't need river tracers. (hma, 11 Jul 2014)
      _RL pcbnconco
      CHARACTER*8 diagname
#endif

C----------------------------------------------------                                    
C Initialize diagnostics
C---------------------------------------------------- 
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            pcbnconc_diag(i,j) = 0.d0
            pcbnevas_diag(i,j) = 0.d0
c Not considering seaspray for PCBs (hma, 11 Jul 2014)
c#ifdef ALLOW_SEASPRAY
c            pcbnseaspray_diag(i,j)=0.d0
c#endif
C            pcbnriver_diag(i,j)=0.d0   ! Don't need river tracers. (hma, 11 Jul 2014)
        ENDDO
      ENDDO
#endif      

      
c      write(*,*) 'pcbn air-sea exchange'
C---------------------------------------------------- 
C Calculate Schmidt number 
C---------------------------------------------------- 
        DO j=jMin,jMax
         DO i=iMin,iMax
C           IF ( maskC(i,j,k,bi,bj).NE.zeroRS ) THEN !CFC code
C     yanxu hg code  IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN 
            IF (HFacC(i,j,1,bi,bj).GT.0.1) THEN 

C---------------------------------------------------- 
C Local variables
C---------------------------------------------------- 
              pcbnconco = max(pcbnconc(i,j,bi,bj),0.d0)
C            river : kg/s    -> mol/m2/s
C             pcbnrivero = PCBdRiver(i,j,bi,bj)*recip_rA(i,j,bi,bj)    ! Don't need river tracers. (hma, 11 Jul 2014)
     &           *1000.d0/(Mb-1.d0)
              doco     = max(doc(i,j,1,bi,bj),0.d0)

C----------------------------------------------------                   
C Calculate Schmidt number for PCBd used by XZ following Tsilingiris 2008
C---------------------------------------------------- 
            k=1
            etaA = sv_0
     &          + sv_1 * theta(i,j,k,bi,bj)
     &          + sv_2 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
     &          + sv_3 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
     &                 * theta(i,j,k,bi,bj)
     &          + sv_4 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
     &                 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
C       write(*,*) 'xmz check sv_1, etaA', sv_1, etaA
            rhoA = sd_0
     &          + sd_1 * theta(i,j,k,bi,bj)
     &          + sd_2 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
     &          + sd_3 * theta(i,j,k,bi,bj) * theta(i,j,k,bi,bj)
     &                 * theta(i,j,k,bi,bj)
     
            temp1                = (Ma + Mb) / (Ma * Mb)
            temp2                = Va**(1.0d0/3.0d0) + Vb**(1.0d0/3.0d0)
            DiffusivityAir (i,j) = 1.0d-3*(theta(i,j,k,bi,bj)+273.15d0)
     &       **1.75d0*temp1**0.5d0/(Patm*temp2**2.0d0) !cm2/s
         
            SchmidtAPCBd         = etaA / rhoA / DiffusivityAir(i,j) 
            
            DiffusivitySurfWater (i,j) !cm2/s
     &   = 1.25d-8*(theta(i,j,k,bi,bj)+273.15d0)
     &     *1.219**(9.58d0/Vb-1.12d0)*(Vb**(-0.19d0)-0.292d0)
        
            temp3 = 0.05594d0*theta(i,j,k,bi,bj)**2
     &    +5.2842d0*theta(i,j,k,bi,bj)+137.37d0
            
            etaW = (theta(i,j,k,bi,bj)+246d0)
     &   /(temp3)
            
            SchmidtWPCBd = etaW/1.03d3/DiffusivitySurfWater (i,j)
            
            temp4 =  wind(i,j,bi,bj)
     &           *sqrt(6.1d-4+6.3d-5*wind(i,j,bi,bj))
            
            temp5 = 13.3d0*sqrt(SchmidtAPCBd)
     &           +1.3d-3**(-0.5d0)-5
     &           +log(SchmidtAPCBd)/2.d0/0.4d0
            
            ka (i,j) = (1.0d-3+temp4/temp5)
            
            temp6 = 0.222d0*wind(i,j,bi,bj)*wind(i,j,bi,bj)
     &   +0.333d0*wind(i,j,bi,bj)
            
            kw = temp6*(SchmidtWPCBd/600.d0)**(-0.5d0)
            
            KawPCBd (i,j) = 1.0d-3 ! Li et al. for PFOA
            !currently as a constant 
c                               simplifications good for PCBs but not for others
c                       Kaw changes w/ Temperature, Salinity, etc
            KawPCBeff(i,j) = KawPCBd (i,j)
     &   /(1.d0+10.d0**(pH(i,j,1,bi,bj)-pKa)) 
                        
            Kaexch (i,j) = (1. _d 0 - fIce(i,j,bi,bj))
     &                   / (1.d0/ka(i, j)+KawPCBeff(i,j)/kw(i,j)) !m/s
            
            pcbnevaso = Kaexch(i,j)
     &                * (pcbnconco * 1.0d-9 / Mb                ! ng/m3 to mol/m3
     &                - PTR(i,j,1,bi,bj,ipcbn) * KawPCBeff(i,j))  
     & !!mol/m2/s          
C            write(*,*)'xz check pcbnevaso:',pcbnevaso                                                                                                                   
C            fluxPCBd(i,j) = -pcbnevaso +pcbnrivero !mol/m2/s   ! Not considering rivers. (hma, 11 Jul 2014)
            fluxPCBd(i,j) = -pcbnevaso  !mol/m2/s           
     
            if (i .eq. 180 .and. j .eq. 80) then
              write(*,*)'fice          at (180,80): ', fice(i,j,bi,bj)
              write(*,*)'pisvel        at (180,80): ', pisvel(i,j,bi,bj)
              write(*,*)'Schmidt#air   at (180,80): ', SchmidtAPCBd
              write(*,*)'Schmidt#water at (180,80): ', SchmidtWPCBd
              write(*,*)'PCBdSurfOcean at (180,80): ',
     &                   max(PTR(i,j,1,bi,bj,ipcbn),0d0)
              write(*,*)'KawPCBeff     at (180,80): ', KawPCBeff(i,j)
              write(*,*)'Kaexch        at (180,80): ', kaexch (i,j)
              write(*,*)'FluxPCBd no seaspray at (180,80): ',
     &                   fluxPCBd(i,j)
            endif

c Not considering sea spray for PCBs. (hma, 11 Jul 2014)
c#ifdef ALLOW_SEASPRAY
c        pcbnseasprayo     =  (1. _d 0 - fIce(i,j,bi,bj))
c     &                * seaspraywtrflux(i,j,bi,bj)              ! m3/m2/s
c     &                * enrichfactor * PTR(i,j,1,bi,bj,ipcbn)   ! mol/m3
cC            write(*,*)'xz check enrichfactor:',enrichfactor                                             
c            fluxPCBd(i,j) = fluxPCBd(i,j) - pcbnseasprayo
c     &       
c        If (i .eq. 180 .and. j .eq. 80) then          
c        write(*,*)'FluxPCBd w/ seaspray at (180,80):',fluxPCBd(i,j)
c        Endif
c#endif        


           ELSE
             fluxPCBd(i,j) = 0. _d 0
           ENDIF

C----------------------------------------------------            
C Calculate diagnistics
C---------------------------------------------------- 
#ifdef ALLOW_DIAGNOSTICS
            pcbnconc_diag(i,j) = pcbnconco  !air concentration ng/m^3
C            pcbnriver_diag(i,j) = pcbnrivero !mol/m^2/s   ! Not considering rivers. (hma, 11 Jul 2014)
            pcbnevas_diag(i,j) = pcbnevaso  !ocean to air evaporations mol/m^2/s

c Not considering sea spray for PCFs (hma, 11 July 2014)
c#ifdef ALLOW_SEASPRAY
c            pcbnseaspray_diag(i,j) = pcbnseasprayo
c#endif          

#endif       

         ENDDO
        ENDDO

C---------------------------------------------------- 
C update surface tendencies      
C---------------------------------------------------- 
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFPCBd(i,j)=
     &         HFacC(i,j,1,bi,bj)*FluxPCBd(i,j)*recip_drF(1)
C       xz: drF-Cell face separation along Z axis ( units of r ).     
          ENDDO
         ENDDO

C---------------------------------------------------- 
c write diagnostics
C---------------------------------------------------- 
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'PCBdCONC'
        CALL DIAGNOSTICS_FILL( pcbnconc_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )
C Not considering rivers or sea spray for PCBs. (hma, 11 Jul 2014)
C        WRITE(diagname,'(A8)') 'PCBdRIVR'
C        CALL DIAGNOSTICS_FILL( pcbnriver_diag(1-Olx,1-Oly), diagname,
C     &                         0,1,2,bi,bj,myThid )
c#ifdef ALLOW_SEASPRAY
c        WRITE(diagname,'(A8)') 'PCBdSPRY'
c        CALL DIAGNOSTICS_FILL( pcbnseaspray_diag(1-Olx,1-Oly), diagname,
c     &                         0,1,2,bi,bj,myThid )
c#endif
        WRITE(diagname,'(A8)') 'PCBdEVAS'
        CALL DIAGNOSTICS_FILL( pcbnevas_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )     
#endif

#endif /* ALLOW_PCB */
#endif /* ALLOW_PTRACERS */

      RETURN
 
      END




        
        

        
        
        
