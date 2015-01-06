C $Header: /MITgcm/pkg/pcb/pcb_partition.F
C 
C OBJECTIVE
C   To calculate the partition of PCB species in the ocean.
C   Local equlibrium is assumed to be reached instantaneously.
C
C NOTES
C (01) Based on the code of Hg species in the ocean by yanxu
C
C MODIFICATION HISTORY
C   07 Jul 2014 - hma - copy of code downloaded from Xianming
C                       Zhang (PFC simulation)
C=============================================================

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PCB_PARTITION( Ptr   ,
     &                          bi    ,bj    ,imin  ,imax, jmin, jmax,
     &                          myIter,myTime,myThid )

       
      IMPLICIT NONE
      
      
C--------------------------------------------------
C Global variables
C--------------------------------------------------
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PCB_SIZE.h"
#include "PCB.h"

C--------------------------------------------------
C Routine arguments 
C--------------------------------------------------
      INTEGER myIter
      _RL  myTime
      INTEGER myThid
      _RL  Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
#ifdef ALLOW_DIAGNOSTICS      
c      _RL  pcbipart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  pcbdpart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  pcbppart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)            
      CHARACTER*8 diagname
#endif
      _RL  TOT_PCB
      _RL  FRAC_AnionDissolved, FRAC_NeutralDissolved, FRAC_TotDissolved,
      _RL  FRAC_POCBound
      _RL  poco, doco
      INTEGER i,j,k,bi, bj, imin, imax, jmin, jmax
      _RL  pcbd_old,pcbp_old,pcbd_new,pcbp_new
      _RL  FRAC_Dissolved

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

C--------------------------------------------------
C     == Parameters
C     -- Partition coefficient
c      _RL Koc_pcb  ! L/kg
c      data  Koc_pcb /372./ 
c xz: declared as a common variable in PCB.h and give the value in pcb_param.F
c  xz: Koc for PFOS 372 L/kg, need to be changed for other PCBs
c #ifdef METHY_MODE 
c       _RL Kd_mmhg_poc  ! L/kg
c       data Kd_mmhg_poc /126491./
c #endif
C--------------------------------------------------

C--------------------------------------------------
C     == Start calculation
C--------------------------------------------------

C--------------------------------------------------
C Initialize diagnostics
C--------------------------------------------------
#ifdef ALLOW_DIAGNOSTICS
      DO k = 1,Nr
        DO j = jMin,jMax
          DO i = iMin,iMax
c            pcbipart_diag(i,j,k) = 0d0
            pcbdpart_diag(i,j,k) = 0d0  
            pcbppart_diag(i,j,k) = 0d0         
          ENDDO
        ENDDO
      ENDDO
#endif

      DO j = jMin,jMax
       DO i = iMin,iMax
        DO k = 1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
C--------------------------------------------------
C     instantaneous equilibrium
C--------------------------------------------------
#ifdef PART_EQ             

C--------------------------------------------------
C     == Localize variables
C--------------------------------------------------
           poco = max(poc(i,j,k,bi,bj),0d0)
           doco = max(doc(i,j,k,bi,bj),0d0)

C-------------------------------------------------- 
C     == Hg2 and HgP
C--------------------------------------------------
c           pcbi_old = max(Ptr(i,j,k,bi,bj,ipcbi),0d0)
           pcbd_old = max(Ptr(i,j,k,bi,bj,ipcbd),0d0)
           pcbp_old = max(Ptr(i,j,k,bi,bj,ipcbp),0d0)
           TOT_PCB = pcbd_old + pcbp_old
           IF (TOT_PCB .gt. 0. _d 0) THEN
c             IF (doco .gt. 4.99 _d 2) THEN ! coast treatment for Hg by yanxu
c               FRAC_DISSOLVED = 1. _d 0 /
c     &             (1. _d 0 + Kd_pcbi_poc * 0.2  * poco
c     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ELSE
              FRAC_Dissolved = 1. _d 0 
     &             /(1. _d 0 + Koc_pcb * poco 
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ENDIF
C           write(*,*) 'xz check FRAC_Dissolved in PCB_Partition.f',
C     &                FRAC_Dissolved 
           pH(i,j,k,bi,bj) = 8. _d 0   !xz currently not consider the real pH
           
                                                         
            FRAC_NeutralDissolved =  FRAC_Dissolved 
     &                   *1.d0/(1.d0+10.d0**(pH(i,j,k,bi,bj)-pKa))
            FRAC_AnionDissolved =  FRAC_Dissolved 
     &                   *10.d0**(pH(i,j,k,bi,bj)-pKa)
     &                   /(1.d0+10.d0**(pH(i,j, k, bi,bj)-pKa))
            FRAC_POCBound = 1.d0 - FRAC_Dissolved
        
c         write(*,*)'xz check PFRC_AnionDissolved, FRAC_NeutralDissolved, 
c     &            FRAC_POCBound in PCB_Partition.f',
c     &       FRAC_AnionDissolved, FRAC_NeutralDissolved, FRAC_POCBound

c             pcbi_new               = TOT_PCB * FRAC_AnionDissolved
             pcbd_new               = TOT_PCB * FRAC_NeutralDissolved
             pcbp_new               = TOT_PCB * FRAC_POCBound
c             Ptr(i,j,k,bi,bj,ipcbi) = pcbi_new
             Ptr(i,j,k,bi,bj,ipcbd) = pcbd_new
             Ptr(i,j,k,bi,bj,ipcbp) = pcbp_new

#ifdef ALLOW_DIAGNOSTICS
c             pcbipart_diag(i,j,k)  = (pcbi_old - pcbi_new) / deltaTclock
             pcbdpart_diag(i,j,k)  = (pcbd_old - pcbd_new) / deltaTclock
             pcbppart_diag(i,j,k)  = (pcbp_old - pcbp_new) / deltaTclock
#endif             
           ENDIF

C--------------------------------------------------
C no partitioning  
C--------------------------------------------------
#ifdef PART_NO
#endif

C--------------------------------------------------
C slow dissolution or sorption
C--------------------------------------------------
#ifdef PART_DI
#endif
         
         ENDIF !(HFacC(i,j,k,bi,bj).gt.0. _d 0) 
        ENDDO   !k
       ENDDO    !i
      ENDDO     !j

C--------------------------------------------------
C write diagnostics
C--------------------------------------------------
#ifdef ALLOW_DIAGNOSTICS   
        WRITE(diagname,'(A8)') 'PCBdPART'
        CALL DIAGNOSTICS_FILL( pcbdpart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
     
c PCBs don't need an ionized tracer (hma, 08 Jul 2014)
c        WRITE(diagname,'(A8)') 'PCBiPART'
c        CALL DIAGNOSTICS_FILL( pcbipart_diag(1-Olx,1-Oly,1), diagname,
c     &                         0,Nr,2,bi,bj,myThid )

        WRITE(diagname,'(A8)') 'PCBpPART'
        CALL DIAGNOSTICS_FILL( pcbppart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )   
#endif

#endif
#endif
C     write(*,*) 'xz checking call PCB_PARTITION end'

       RETURN
       END
