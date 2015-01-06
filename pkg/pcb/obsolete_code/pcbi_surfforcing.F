C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcbi_surfforcing.F,v 1.0
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      SUBROUTINE PCBi_SURFFORCING( PTR, SurfPCBi,
c     I           bi,bj,iMin,iMax,jMin,jMax,
c     I           myIter, myTime, myThid )

      SUBROUTINE PCBi_SURFFORCING( PTR,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )

C     /==========================================================\
C     | SUBROUTINE PCBi_SURFFORCING                               |
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
#include "PCB_SIZE.h" !in ./code/pcb_size.h
#include "PCB.h"

C     == Routine arguments ==
      INTEGER myIter, myThid
      _RL myTime
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
c      _RL  SurfPCBi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL  FluxPCBi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      _RL  pcbidepoo,pcbirivero, pcbiseasprayo
#ifdef ALLOW_DIAGNOSTICS      
c      _RL  pcbidepo_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL  pcbiriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL  pcbirivero_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#ifdef ALLOW_SEASPRAY     
c      _RL  pcbiseaspray_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
c      _RL  pcbiseasprayo_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#endif
      CHARACTER*8 diagname
#endif      
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
c Remove PCBi tracer. (hma, 15 Jul 2014)
c            pcbidepo_diag(i,j)=0.d0
c            pcbirivero_diag(i,j)=0.d0
#ifdef ALLOW_SEASPRAY
c            pcbiseasprayo_diag(i,j)=0.d0
#endif        
        ENDDO
      ENDDO
#endif
      
      DO j=jMin,jMax
        DO i=iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Localize variabls

c Remove PCBi tracer. (hma, 15 Jul 2014)
C            depo  : kg/m2/s -> mol/m2/s
c             pcbidepoo = PCBiDepo(i,j,bi,bj)*1000.d0/(Mb-1.d0)
C            pcbidepoo = 0.0   !for testing

C            river : kg/s    -> mol/m2/s
c             pcbirivero = PCBiRiver(i,j,bi,bj)*recip_rA(i,j,bi,bj)
c     &           *1000.d0/(Mb-1.d0)
C             pcbirivero = 1.0d-13   !for testing                        
c             FluxPCBi(i,j)=pcbidepoo+pcbirivero
c            write(*,*)'xz check FluxPCBi(i, j):',fluxPCBi(i,j)
            
c            If (i .eq. 180 .and. j .eq. 80) then
c            write(*,*)'PCBiSurfOcean at (180,80):',
c     &         max(PTR(i,j,1,bi,bj,ipcbi),0.d0)
c            write(*,*)'FluxPCBi no seaspray at (180,80):',fluxPCBi(i,j)
c            Endif    

            
#ifdef ALLOW_SEASPRAY
c       write(*,*) 'xz check seaspraywtrflux(i,j,bi,bj) 
c     &in pcb_surfforcing',
c     & seaspraywtrflux(i,j,bi,bj)  

c Remove PCBi tracer. (hma, 15 Jul 2014)
c       pcbiseasprayo = (1. _d 0 - fIce(i,j,bi,bj))
c     &          *seaspraywtrflux(i,j,bi,bj) !m3/m2/s
c     &          *enrichfactor*PTR(i,j,1,bi,bj,ipcbi)
cC                                     PTR: mol/m3   
c            fluxPCBi(i,j) = fluxPCBi(i,j)-pcbiseasprayo
c            
c            If (i .eq. 180 .and. j .eq. 80) then          
c            write(*,*)'FluxPCBi w seaspray at (180,80):',fluxPCBi(i,j)
c            Endif
              
#endif   
               
             
             
#ifdef ALLOW_DIAGNOSTICS             
c Remove PCBi tracer. (hma, 15 Jul 2014)
c             pcbidepo_diag(i,j)=pcbidepoo
c             pcbiriver_diag(i,j)=pcbirivero
#ifdef ALLOW_SEASPRAY
cc            pcbiseaspray_diag(i,j)=pcbiseasprayo
#endif                  
#endif             
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j=jMin,jMax
          DO i=iMin,iMax
c Remove PCBi tracer. (hma, 15 Jul 2014)
c           SURFPCBi(i,j)=
c     &         HFacC(i,j,1,bi,bj)*FluxPCBi(i,j)*recip_drF(1) 
C       drF-Cell face separation along Z axis ( units of r ).	
          ENDDO
         ENDDO
         
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
c Remove PCBi tracer. (hma, 15 Jul 2014)
c        WRITE(diagname,'(A8)') 'PCBiDEPO'
c        CALL DIAGNOSTICS_FILL( pcbidepo_diag(1-Olx,1-Oly), diagname,
c     &                         0,1,2,bi,bj,myThid ) 
#ifdef ALLOW_SEASPRAY
c        WRITE(diagname,'(A8)') 'PCBiSPRY'
c        CALL DIAGNOSTICS_FILL( pcbiseaspray_diag(1-Olx,1-Oly), diagname,
c     &                         0,1,2,bi,bj,myThid ) 
#endif            
c        WRITE(diagname,'(A8)') 'PCBiRIVR'
c        CALL DIAGNOSTICS_FILL( pcbiriver_diag(1-Olx,1-Oly), diagname,
c     &                         0,1,2,bi,bj,myThid )         
#endif
         
#endif
#endif

        RETURN
        END
