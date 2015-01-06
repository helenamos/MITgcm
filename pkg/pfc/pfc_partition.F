C $Header: /MITgcm/pkg/pfc/pfc_partition.F 
C based on the code of Hg species in the ocean by yanxu
C To calculate the partition of PFC species in the ocean
C Local equlibrium between the anionic, neutral, and particulate species are 
C assumed to be reached instantaneously
#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PFC_PARTITION( Ptr,
     &                         bi,bj,imin,imax,jmin,jmax,
     &                         myIter,myTime,myThid)

       
      IMPLICIT NONE
      
      

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PFC_SIZE.h"
#include "PFC.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
#ifdef ALLOW_DIAGNOSTICS      
      _RL  pfcipart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  pfcnpart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  pfcppart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)            
      CHARACTER*8 diagname
#endif
      _RL  TOT_PFC
      _RL FRAC_AnionDissolved, FRAC_NeutralDissolved, FRAC_TotDissolved,
      _RL FRAC_POCBound
      _RL poco, doco
      INTEGER i,j,k,bi, bj, imin, imax, jmin, jmax
      _RL  pfci_old,pfcn_old,pfcp_old,pfci_new,pfcn_new,pfcp_new
      _RL  FRAC_Dissolved

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC

C     == Parameters
C     -- Partition coefficient
c      _RL Koc_pfc  ! L/kg
c      data  Koc_pfc /372./ 
c xz: declared as a common variable in PFC.h and give the value in pfc_param.F
c  xz: Koc for PFOS 372 L/kg, need to be changed for other PFCs
c #ifdef METHY_MODE 
c       _RL Kd_mmhg_poc  ! L/kg
c       data Kd_mmhg_poc /126491./
c #endif

C     == Start calculation

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO k=1,Nr
        DO j=jMin,jMax
          DO i=iMin,iMax
            pfcipart_diag(i,j,k)=0d0
            pfcnpart_diag(i,j,k)=0d0  
            pfcppart_diag(i,j,k)=0d0         
          ENDDO
        ENDDO
      ENDDO
#endif

      DO j=jMin,jMax
       DO i=iMin,iMax
        DO k=1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
C     instantaneous equilibrium
#ifdef PART_EQ             
C     == Localize variables
           poco = max(poc(i,j,k,bi,bj),0d0)
           doco = max(doc(i,j,k,bi,bj),0d0)
 
C     == Hg2 and HgP
           pfci_old = max(Ptr(i,j,k,bi,bj,ipfci),0d0)
           pfcn_old = max(Ptr(i,j,k,bi,bj,ipfcn),0d0)
           pfcp_old = max(Ptr(i,j,k,bi,bj,ipfcp),0d0)
           TOT_PFC = pfci_old + pfcn_old + pfcp_old
           IF (TOT_PFC .gt. 0. _d 0) THEN
c             IF (doco .gt. 4.99 _d 2) THEN ! coast treatment for Hg by yanxu
c               FRAC_DISSOLVED = 1. _d 0 /
c     &             (1. _d 0 + Kd_pfci_poc * 0.2  * poco
c     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ELSE
              FRAC_Dissolved = 1. _d 0 
     &             /(1. _d 0 + Koc_pfc * poco 
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ENDIF
C           write(*,*) 'xz check FRAC_Dissolved in PFC_Partition.f',
C     &                FRAC_Dissolved 
           pH(i,j,k,bi,bj) = 8. _d 0   !xz currently not consider the real pH
           
                                                         
            FRAC_NeutralDissolved =  FRAC_Dissolved 
     &                   *1.d0/(1.d0+10.d0**(pH(i,j,k,bi,bj)-pKa))
            FRAC_AnionDissolved =  FRAC_Dissolved 
     &                   *10.d0**(pH(i,j,k,bi,bj)-pKa)
     &                   /(1.d0+10.d0**(pH(i,j, k, bi,bj)-pKa))
            FRAC_POCBound = 1.d0 - FRAC_Dissolved
        
c         write(*,*)'xz check PFRC_AnionDissolved, FRAC_NeutralDissolved, 
c     &            FRAC_POCBound in PFC_Partition.f',
c     &       FRAC_AnionDissolved, FRAC_NeutralDissolved, FRAC_POCBound

             pfci_new = TOT_PFC * FRAC_AnionDissolved
             pfcn_new = TOT_PFC * FRAC_NeutralDissolved
             pfcp_new = TOT_PFC * FRAC_POCBound
             Ptr(i,j,k,bi,bj,ipfci) = pfci_new
             Ptr(i,j,k,bi,bj,ipfcn) = pfcn_new
             Ptr(i,j,k,bi,bj,ipfcp) = pfcp_new

#ifdef ALLOW_DIAGNOSTICS
             pfcipart_diag(i,j,k) = (pfci_old - pfci_new) / deltaTclock
             pfcnpart_diag(i,j,k) = (pfcn_old - pfcn_new) / deltaTclock
             pfcppart_diag(i,j,k) = (pfcp_old - pfcp_new) / deltaTclock
#endif             
           ENDIF


C      no partitioning  
#ifdef PART_NO
#endif

C      slow dissolution or sorption
#ifdef PART_DI
#endif
         
         ENDIF !(HFacC(i,j,k,bi,bj).gt.0. _d 0) 
        ENDDO   !k
       ENDDO    !i
      ENDDO     !j

c write diagnostics
#ifdef ALLOW_DIAGNOSTICS   
        WRITE(diagname,'(A8)') 'PFCnPART'
        CALL DIAGNOSTICS_FILL( pfcnpart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
     
        WRITE(diagname,'(A8)') 'PFCiPART'
        CALL DIAGNOSTICS_FILL( pfcipart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )

        WRITE(diagname,'(A8)') 'PFCpPART'
        CALL DIAGNOSTICS_FILL( pfcppart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )   
#endif

#endif
#endif
C     write(*,*) 'xz checking call PFC_PARTITION end'

       RETURN
       END
