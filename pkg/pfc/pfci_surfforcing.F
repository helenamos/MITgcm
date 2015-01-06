C $Header: /u/gcmpack/MITgcm/pkg/pfc/pfci_surfforcing.F,v 1.0
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PFCi_SURFFORCING( PTR, SurfPFCi,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE PFCi_SURFFORCING                               |
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
#include "PFC_SIZE.h" !in ./code/pfc_size.h
#include "PFC.h"

C     == Routine arguments ==
      INTEGER myIter, myThid
      _RL myTime
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  SurfPFCi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  FluxPFCi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  pfcidepoo,pfcirivero, pfciseasprayo
#ifdef ALLOW_DIAGNOSTICS      
      _RL  pfcidepo_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  pfciriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  pfcirivero_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#ifdef ALLOW_SEASPRAY     
      _RL  pfciseaspray_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  pfciseasprayo_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#endif
      CHARACTER*8 diagname
#endif      
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            pfcidepo_diag(i,j)=0.d0
            pfcirivero_diag(i,j)=0.d0
#ifdef ALLOW_SEASPRAY
            pfciseasprayo_diag(i,j)=0.d0
#endif        
        ENDDO
      ENDDO
#endif
      
      DO j=jMin,jMax
        DO i=iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Localize variabls
C            depo  : kg/m2/s -> mol/m2/s
             pfcidepoo = PFCiDepo(i,j,bi,bj)*1000.d0/(Mb-1.d0)
C            pfcidepoo = 0.0   !for testing
C            river : kg/s    -> mol/m2/s
             pfcirivero = PFCiRiver(i,j,bi,bj)*recip_rA(i,j,bi,bj)
     &           *1000.d0/(Mb-1.d0)
C             pfcirivero = 1.0d-13   !for testing                        
             FluxPFCi(i,j)=pfcidepoo+pfcirivero
c            write(*,*)'xz check FluxPFCi(i, j):',fluxPFCi(i,j)
            
            If (i .eq. 180 .and. j .eq. 80) then
            write(*,*)'PFCiSurfOcean at (180,80):',
     &         max(PTR(i,j,1,bi,bj,ipfci),0.d0)
            write(*,*)'FluxPFCi no seaspray at (180,80):',fluxPFCi(i,j)
            Endif    

            
#ifdef ALLOW_SEASPRAY
c       write(*,*) 'xz check seaspraywtrflux(i,j,bi,bj) 
c     &in pfc_surfforcing',
c     & seaspraywtrflux(i,j,bi,bj)  

       pfciseasprayo = (1. _d 0 - fIce(i,j,bi,bj))
     &          *seaspraywtrflux(i,j,bi,bj) !m3/m2/s
     &          *enrichfactor*PTR(i,j,1,bi,bj,ipfci)
C                                     PTR: mol/m3   
            fluxPFCi(i,j) = fluxPFCi(i,j)-pfciseasprayo
            
            If (i .eq. 180 .and. j .eq. 80) then          
            write(*,*)'FluxPFCi w seaspray at (180,80):',fluxPFCi(i,j)
            Endif
              
#endif   
               
             
             
#ifdef ALLOW_DIAGNOSTICS             
             pfcidepo_diag(i,j)=pfcidepoo
             pfciriver_diag(i,j)=pfcirivero
#ifdef ALLOW_SEASPRAY
            pfciseaspray_diag(i,j)=pfciseasprayo
#endif                  
#endif             
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFPFCi(i,j)=
     &         HFacC(i,j,1,bi,bj)*FluxPFCi(i,j)*recip_drF(1) 
C       drF-Cell face separation along Z axis ( units of r ).	
          ENDDO
         ENDDO
         
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'PFCiDEPO'
        CALL DIAGNOSTICS_FILL( pfcidepo_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid ) 
#ifdef ALLOW_SEASPRAY
        WRITE(diagname,'(A8)') 'PFCiSPRY'
        CALL DIAGNOSTICS_FILL( pfciseaspray_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid ) 
#endif            
        WRITE(diagname,'(A8)') 'PFCiRIVR'
        CALL DIAGNOSTICS_FILL( pfciriver_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )         
#endif
         
#endif
#endif

        RETURN
        END
