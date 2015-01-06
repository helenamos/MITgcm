C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_biopump.F 
C $Name: checkpoint64g $

C to calculate the sinking of PCB along POM
C

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE PCB_BIOPUMP(  Ptr,Gchem,      
     &                        bi,bj,imin,imax,jmin,jmax,
     &                        myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE PCB_BIOPUMP                                   |
C     | o Calculate the changes to PCBP               |
C     |   through particulate sinking                           |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PCB_SIZE.h"
#include "PCB.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  Gchem(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)    
#ifdef ALLOW_DIAGNOSTICS      
      _RL  pcbpsink_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      CHARACTER*8 diagname
#endif      
      _RL  Fout_PCBp(Nr)


c	#ifdef HGPRIVER
c	      INTEGER nriver
c	      _RL  whgr(nrmax)
c	      data whgr /100.0 _d 0, 10.0 _d 0, 1.0 _d 0/
c	#if nrmax > 3
c	      What is the sinking speed of riverine particles?
c	#endif             
c	      _RL  Fout_Hgr(Nr,nrmax)
c	#ifdef ALLOW_DIAGNOSTICS      
c	      _RL  hgrsink_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
c	#endif      
c	#endif        
c #ifdef METHY_MODE       
c      _RL  Fout_MMHgp(Nr)
c #ifdef ALLOW_DIAGNOSTICS      
c      _RL  mmhgpsink_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
c #endif      
c #endif      
      
      _RL  poco, fpoco
      _RL  tiny
      data tiny /1d-32/
      INTEGER i,j,k,bi, bj, imin, imax, jmin, jmax      

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PCB
C     == Local variables == 

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO k=1,Nr
        DO j=jMin,jMax
          DO i=iMin,iMax
            pcbpsink_diag(i,j,k)=0d0
c #ifdef HGPRIVER 
c            hgrsink_diag(i,j,k)=0d0
c #endif                        
c #ifdef METHY_MODE 
c            mmhgpsink_diag(i,j,k)=0d0
c #endif            
          ENDDO
        ENDDO
      ENDDO
#endif      
      
      DO j=jMin,jMax
       DO i=iMin,iMax

C       Zero flux
        DO k=1,Nr
         Fout_PCBp(k) = 0. _d 0
c #ifdef HGPRIVER
c         DO nriver=1,nrmax 
c         Fout_Hgr(k,nriver) = 0. _d 0
c         ENDDO
c#endif                     
c#ifdef METHY_MODE 
c         Fout_MMHgp(k) = 0. _d 0
c#endif            
        ENDDO

C       Flux calculation
        DO k=1,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
           ! localize variables
           poco =  max(poc(i,j,k,bi,bj),0d0) !mmolC/m3
           fpoco = max(Fpoc(i,j,k,bi,bj), 0d0) !mmolC/m2/d
             
           Fout_PCBp(k) = max(PTR(i,j,k,bi,bj,ipcbp),0d0)
     &          * fpoco / ( poco + tiny )
     &          / 8.64 d 4
c       mol/m2/s = mol/m3 * (mmolC/m2/d) / (mmolC/m3) /(s/d)     
     
C Calculate diagnistics
#ifdef ALLOW_DIAGNOSTICS
           pcbpsink_diag(i,j,k) = Fout_PCBp(k)  !mol/m^2/s   
#endif

c#ifdef HGPRIVER
c           DO nriver=1,nrmax
c            Fout_Hgr(k,nriver) = max(PTR(i,j,k,bi,bj,ihgr+nriver-1),0d0)
c     &          * whgr(nriver)
c     &          / 8.64 d 4
c           ENDDO
c#ifdef ALLOW_DIAGNOSTICS
c           DO nriver=1,nrmax
c            hgrsink_diag(i,j,k) = hgrsink_diag(i,j,k)+Fout_Hgr(k,nriver)  !mol/m^2/s
c           ENDDO 
c#endif
c#endif                
                                                
c#ifdef METHY_MODE
c#ifdef FOODW_MODE
c    need to figure it out, 8/21/2013
c           Fout_MMHgp(k) = max(PTR(i,j,k,bi,bj,immhgp),0d0)
c     &          * fpoco / ( poco + tiny )
c     &          / 8.64 d 4
c#else
c           Fout_MMHgp(k) = max(PTR(i,j,k,bi,bj,immhgp),0d0)
c     &          * fpoco / ( poco + tiny )
c     &          / 8.64 d 4
c#endif
c#ifdef ALLOW_DIAGNOSTICS
c           mmhgpsink_diag(i,j,k) = Fout_MMHgp(k)  !mol/m^2/s   
c#endif
c#endif

         ENDIF
        ENDDO

C----&---1---------2---------3---------4---------5---------6---------7--    
C       Tendency calculation
        IF (HFacC(i,j,1,bi,bj).gt.0. _d 0) THEN
         Gchem(i,j,1,bi,bj,ipcbp)=Gchem(i,j,1,bi,bj,ipcbp) 
     &                          - Fout_PCBp(1) * recip_drF(1)
c	#ifdef HGPRIVER
c	         DO nriver=1,nrmax
c	          Gchem(i,j,1,bi,bj,ihgr+nriver-1)=
c	     &     Gchem(i,j,1,bi,bj,ihgr+nriver-1) 
c	     &     - Fout_Hgr(1,nriver) * recip_drF(1)
c	         ENDDO
c	#endif         
c	#ifdef METHY_MODE         
c	         Gchem(i,j,1,bi,bj,immhgp)=Gchem(i,j,1,bi,bj,immhgp)
c	     &     - Fout_MMHgp(1) * recip_drF(1)
c	#endif         
        ENDIF
  
        DO k=2,Nr
         IF (HFacC(i,j,k,bi,bj).gt.0. _d 0) THEN
          Gchem(i,j,k,bi,bj,ipcbp)=Gchem(i,j,k,bi,bj,ipcbp) + 
     &             (Fout_PCBp(k-1) - Fout_PCBp(k)) * recip_drF(k)
c	#ifdef HGPRIVER
c	          DO nriver=1,nrmax     
c	           Gchem(i,j,k,bi,bj,ihgr+nriver-1)=
c	     &        Gchem(i,j,k,bi,bj,ihgr+nriver-1) + 
c	     &        (Fout_Hgr(k-1,nriver) - Fout_Hgr(k,nriver)) * recip_drF(k)
c	          ENDDO
c	#endif          
c	#ifdef METHY_MODE     
c	          Gchem(i,j,k,bi,bj,immhgp)=Gchem(i,j,k,bi,bj,immhgp) + 
c	     &             (Fout_MMHgp(k-1) - Fout_MMHgp(k)) * recip_drF(k)
c	#endif     
         ENDIF
        ENDDO

       ENDDO
      ENDDO

c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'PCBpSINK'
        CALL DIAGNOSTICS_FILL( PCBpsink_diag(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
c	#ifdef HGPRIVER
c	        WRITE(diagname,'(A8)') 'HGRSINK '
c	        CALL DIAGNOSTICS_FILL( hgrsink_diag(1-Olx,1-Oly,1), diagname,
c	     &                         0,Nr,2,bi,bj,myThid )
c	#endif     
c	#ifdef METHY_MODE
c	        WRITE(diagname,'(A8)') 'MHGPSINK'
c	        CALL DIAGNOSTICS_FILL( mmhgpsink_diag(1-Olx,1-Oly,1), diagname,
c	     &                         0,Nr,2,bi,bj,myThid )
c	#endif       
#endif !ALLOW_DIAGNOSTIC

#endif !allow_PCB
#endif !allow_PTracer

       RETURN
       END
