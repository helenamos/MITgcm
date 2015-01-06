C $Header: /MITgcm/pkg/pcb/pcb_partition.F 

C==============================================================
C MODIFICATION HISTORY
C  From Xianming Zhang:
C    Cased on the code of Hg species in the ocean by Yanxu Zhang.
C    To calculate the partition of PFOS species in the ocean
C    Local equlibrium between the anionic, neutral, and 
C    particulate species are assumed to be reached instantaneously
C
C  From Helen Amos (06 Aug 2014):
C    PFOS code adopted for the simulation of PCBs in the ocean.
C    Comments added and obsolete/commented-out code deleted to 
C    clean things up.
C===============================================================

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PCB_PARTITION( Ptr,
     &                          bi    , bj    ,
     &                          imin  , imax  , jmin  , jmax ,
     &                          myIter, myTime, myThid        )

       
      IMPLICIT NONE
      
      !--------------------------------------------------------
      ! Global variables
      !--------------------------------------------------------
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PCB_SIZE.h"
#include "PCB.h"

      !--------------------------------------------------------
      ! Routine arguments
      !--------------------------------------------------------
      INTEGER myIter
      _RL     myTime
      INTEGER myThid
      _RL  Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
#ifdef ALLOW_DIAGNOSTICS      
      _RL     pcbapart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL     pcbppart_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)            
      CHARACTER*8 diagname
#endif
      _RL     TOT_PCB
      _RL     FRAC_TotDissolved
      _RL     FRAC_Dissolved
      _RL     FRAC_POCBound
      _RL     poco, doco
      INTEGER i,j,k,bi, bj, imin, imax, jmin, jmax
      _RL     pcba_old, pcbp_old, pcba_new, pcbp_new
      _RL     Kow   ! octanol-water partitioning coefficient <-- put this in pcb_param.F?

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB

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

      !--------------------------------------------------------
      ! Initialize diagnostics
      !--------------------------------------------------------
#ifdef ALLOW_DIAGNOSTICS
      DO k=1,Nr
        DO j=jMin,jMax
          DO i=iMin,iMax
            pcbapart_diag(i,j,k) = 0d0  
            pcbppart_diag(i,j,k) = 0d0         
          ENDDO
        ENDDO
      ENDDO
#endif

      !--------------------------------------------------------
      ! Start calculation
      !--------------------------------------------------------
      DO j=jMin,jMax
       DO i=iMin,iMax
        DO k=1,Nr

         
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN

         !---------------------------------------------------
         ! instantaneous equilibrium
         !---------------------------------------------------  
#ifdef PART_EQ             

           !------------------------------------------------
           ! Local variables
           !------------------------------------------------
           poco = max( poc(i,j,k,bi,bj), 0d0 )  ! POC concentration (units?)
           doco = max( doc(i,j,k,bi,bj), 0d0 )  ! DOC concentration (units?)

           !------------------------------------------------
           ! PCB concentrations before partitioning 
           !------------------------------------------------
           pcba_old = max(Ptr(i,j,k,bi,bj,ipcba),0d0)
           pcbp_old = max(Ptr(i,j,k,bi,bj,ipcbp),0d0)
           TOT_PCB = pcba_old + pcbp_old

           IF (TOT_PCB .gt. 0. _d 0) THEN

             !------------------------------------------------ 
             ! Calculate Koc (L/kg) from Kow in the event that
             ! a Koc value wasn't available in the literature.
             ! Kow is the octanol-water partition coefficent.
             !
             ! Reference: Seth et al. (1999)
             !------------------------------------------------ 
             IF ( Koc_pcb .EQ. -999d0 ) THEN        
                 Koc_pcb = 0.33d0 * Kow
             ENDIF

            !------------------------------------------------
            ! Calculate fraction in the dissolved phase
            !------------------------------------------------ 
c             IF (doco .gt. 4.99 _d 2) THEN ! coast treatment for Hg by yanxu
c               FRAC_DISSOLVED = 1. _d 0 /
c     &             (1. _d 0 + Kd_pcbi_poc * 0.2  * poco
c     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ELSE

              FRAC_Dissolved = 1. _d 0 
     &             /(1. _d 0 + Koc_pcb * poco 
     &             * 1.2 _d - 8 )  ! mmolC/m3 -> kgC/L
c             ENDIF

             !------------------------------------------------
             ! pH of seawater
             !
             ! Note: Currently not considering the real pH
             !       (xz)
             !------------------------------------------------
             pH(i,j,k,bi,bj) = 8. _d 0  
           
             !------------------------------------------------
             ! Particulate fraction (i.e., PCB bound to POC)
             !------------------------------------------------
             FRAC_POCBound = 1.d0 - FRAC_Dissolved
        
             !------------------------------------------------
             ! New PCB concentrations (units?) in the dissolved
             ! and particle phases after consdering partitioning
             !------------------------------------------------ 
             pcba_new = TOT_PCB * FRAC_Dissolved
             pcbp_new = TOT_PCB * FRAC_POCBound

             !------------------------------------------------
             ! Update tracer array
             !------------------------------------------------
             Ptr(i,j,k,bi,bj,ipcba) = pcba_new
             Ptr(i,j,k,bi,bj,ipcbp) = pcbp_new

#ifdef ALLOW_DIAGNOSTICS
             pcbapart_diag(i,j,k) = (pcba_old - pcba_new) / deltaTclock
             pcbppart_diag(i,j,k) = (pcbp_old - pcbp_new) / deltaTclock
#endif             
           ENDIF


C      No partitioning  
#ifdef PART_NO
#endif

C      Slow dissolution or sorption
#ifdef PART_DI
#endif
         
         ENDIF !(HFacC(i,j,k,bi,bj).gt.0. _d 0) 
        ENDDO   !k
       ENDDO    !i
      ENDDO     !j

      !--------------------------------------------------------
      ! Write diagnostics
      !--------------------------------------------------------
#ifdef ALLOW_DIAGNOSTICS   
        WRITE(diagname,'(A8)') 'PCBaPART'
        CALL DIAGNOSTICS_FILL( pcbapart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
     
        WRITE(diagname,'(A8)') 'PCBpPART'
        CALL DIAGNOSTICS_FILL( pcbppart_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )   
#endif

#endif
#endif

       RETURN
       END
