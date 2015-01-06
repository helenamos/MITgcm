C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_fields_load.F, Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"
#ifdef ALLOW_SEAICE
# include "SEAICE_OPTIONS.h"
#endif /* ALLOW_SEAICE */
#ifdef ALLOW_THSICE
# include "THSICE_OPTIONS.h"
#endif /* ALLOW_THSICE */

CBOP
C     !ROUTINE: PCB0*_FORCING
C     !INTERFACE:
      SUBROUTINE PCB_FIELDS_LOAD (
     I          myIter, myTime , myThid )

C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE PCB_FIELDS_LOAD
C     *==========================================================*

C     !USES:
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PCB_SIZE.h"
#include "PCB.h"
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

C     !INPUT/OUTPUT PARAMETERS:
C     myTime     :: current time in simulation
C     myIter     :: current iteration number
C     myThid     :: my Thread Id number
      _RL myTime
      INTEGER myIter
      INTEGER myThid


c=============from cfc code ======
C     !LOCAL VARIABLES:
c      INTEGER intimeP, intime0, intime1
c       INTEGER bi, bj, i, j
c      _RL aWght, bWght
c      _RL locWind(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
CEOP
c=================================

c===========from hg code=========
      INTEGER intimeP, intime0, intime1
      INTEGER bi, bj, i, j, k
      INTEGER prec
#ifdef FOODW_MODE
      CHARACTER*(MAX_LEN_FNAM) phytoP_File_Act, zooP_File_Act
      INTEGER np, nz
      CHARACTER*(2) nps, nzs
#endif
c#ifdef HGPRIVER
c      CHARACTER*(MAX_LEN_FNAM) hgR_File_Act
c      INTEGER nriver
c      CHARACTER*(2) nrivers
c#endif
      LOGICAL nowRead

      _RL aWght, bWght
c===========from hg code=========



      IF ( PCB_forcingCycle .GT. 0. _d 0 ) THEN

C First call requires that we initialize everything to zero for safety
cQQQ need to check timing
       IF ( myIter .EQ. nIter0 ) THEN
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            PCB_ldRec_forcing(bi,bj) = 0
c xz changed from original PCB_ldRec(bi,bj) in cfc to PCB_ldRec_forcing(bi,bj) = 0
c xz to accomodate PCB_ldRec_chem(bi,bj) later on      
          ENDDO
         ENDDO
c         CALL LEF_ZERO( wind0,myThid )
c         CALL LEF_ZERO( wind1,myThid )
c         CALL LEF_ZERO( atmosp0,myThid )
c         CALL LEF_ZERO( atmosp1,myThid )
c         CALL LEF_ZERO( ice0,myThid )
c         CALL LEF_ZERO( ice1,myThid )
       ENDIF

C--   Now calculate whether it is time to update the forcing arrays
       
c-------------------------------------------------------------
c CFC code
c-------------------------------------------------------------
c       CALL GET_PERIODIC_INTERVAL(
c     O                   intimeP, intime0, intime1, bWght, aWght,
c     I                   PCB_forcingCycle, PCB_forcingPeriod,
c    I                   deltaTclock, myTime, myThid )

c-------------------------------------------------------------
c PCB code             
c-------------------------------------------------------------
#ifdef ALLOW_CAL
       CALL CAL_GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   PCB_forcingCycle, PCB_forcingPeriod, nowRead,
     I                   deltaTclock, myIter, mymakTime, myThid )
        if ( myIter .eq. nIter0 ) THEN
            nowRead=.TRUE.
        endif    
#else
       CALL GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   PCB_forcingCycle, PCB_forcingPeriod,
     I                   deltaTclock, myTime, myThid )
#endif /* ALLOW_CAL */       
       
       bi = myBxLo(myThid)
       bj = myByLo(myThid)

#ifdef ALLOW_DEBUG
       IF ( debugLevel.GE.debLevB ) THEN
        _BEGIN_MASTER(myThid)
        WRITE(standardMessageUnit,'(A,I10,A,4I5,A,2F14.10)')
     &   ' PCB_FIELDS_LOAD, ', myIter ,
     &   ' : iP,iLd,i0,i1 = ', intimeP, PCB_ldRec_forcing(bi,bj), 
     &                         intime0, intime1,
     &   ' ; Wght         = ', bWght  , aWght
        _END_MASTER(myThid)
       ENDIF
#endif /* ALLOW_DEBUG */


#ifdef ALLOW_CAL
       IF ( nowRead ) THEN
#else 


#ifdef ALLOW_AUTODIFF_TAMC
C-    assuming that we call S/R PCB_FIELDS_LOAD at each time-step and
C     with increasing time, this will catch when we need to load new records;
C     But with Adjoint run, this is not always the case => might end-up using
C     the wrong time-records
       IF ( intime0.NE.intimeP .OR. myIter.EQ.nIter0 ) THEN
#else /* ALLOW_AUTODIFF_TAMC */
C-    Make no assumption on sequence of calls to PCB_FIELDS_LOAD ;
C     This is the correct formulation (works in Adjoint run).
C     Unfortunatly, might produce many recomputations <== not used until it is fixed
       IF ( intime1.NE.PCB_ldRec_forcing(bi,bj) ) THEN         
#endif /* ALLOW_AUTODIFF_TAMC */

C--   If the above condition is met then we need to read in
C     data for the period ahead and the period behind myTime.
        IF ( debugLevel.GE.debLevZero ) THEN
         _BEGIN_MASTER(myThid)
         WRITE(standardMessageUnit,'(A,I10,A,2(2I5,A))')
     &    ' PCB_FIELDS_LOAD, it=', myIter,
     &    ' : Reading new data, i0,i1=', intime0, intime1,
     &    ' (prev=', intimeP, PCB_ldRec_forcing(bi,bj), ' )'
         _END_MASTER(myThid)
        ENDIF

        _BARRIER

        IF ( PCB_windFile .NE. ' '  .AND. .NOT.useEXF ) THEN
         CALL READ_REC_XY_RS( PCB_windFile, wind0, intime0,
     &        myIter, myThid )
         CALL READ_REC_XY_RS( PCB_windFile, wind1, intime1,
     &        myIter, myThid )
        ENDIF
        
c===============from cfc====        
c        IF ( PCB_atmospFile .NE. ' '  ) THEN
c         CALL READ_REC_XY_RS( PCB_atmospFile,atmosp0,intime0,
c     &        myIter,myThid )
c        CALL READ_REC_XY_RS( PCB_atmospFile,atmosp1,intime1,
c     &        myIter,myThid )
c        ENDIF
c        IF ( PCB_iceFile .NE. ' ' .AND.
c     &       .NOT.useSEAICE .AND. .NOT.useThSIce ) THEN
c         CALL READ_REC_XY_RS( PCB_iceFile,ice0,intime0,
c     &       myIter,myThid )
c         CALL READ_REC_XY_RS( PCB_iceFile,ice1,intime1,
c     &       myIter,myThid )
c        ENDIF       
c        IF ( .NOT.useEXF ) THEN
c         _EXCH_XY_RS(wind0, myThid )
c         _EXCH_XY_RS(wind1, myThid )
c        ENDIF
c         _EXCH_XY_RS(atmosp0, myThid )
c         _EXCH_XY_RS(atmosp1, myThid )
c        IF ( .NOT.useSEAICE .AND. .NOT.useThSIce ) THEN
c         _EXCH_XY_RS(ice0, myThid )
c         _EXCH_XY_RS(ice1, myThid )
c        ENDIF
c============================        

         _EXCH_XY_RS(wind0, myThid )
         _EXCH_XY_RS(wind1, myThid )

c-------------------------------------------------------------
c Save newly loaded time-record
c-------------------------------------------------------------
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
           PCB_ldRec_forcing(bi,bj) = intime1
         ENDDO
        ENDDO

c-------------------------------------------------------------
c End if-block for loading new time-records
c-------------------------------------------------------------
       ENDIF


c-------------------------------------------------------------
c For PCBs
c-------------------------------------------------------------
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           IF ( PCB_windFile .NE. ' '  ) THEN
             wind(i,j,bi,bj) = bWght*wind0(i,j,bi,bj)
     &                           +aWght*wind1(i,j,bi,bj)
           ELSE
             wind = 5. _d 0*maskC(i,j,1,bi,bj)
           ENDIF

c-------------------------------------------------------------
c Calculate piston velocity.
c   QQ: note - we should have wind speed variance in here
c   following Wannikof (1992)
c   m/s
c   F = - D/Zfilm (Cg - Cl) = - D/Zfilm (KHPg - Cl) 
c   Because D/Zfilm has velocity units, it has been called the Piston Velocity 
c   piston velocity calculation is different for Hg0
c   according to Soerensen et al. 2010
c
c MODIFICATION HISTORY
c   yzh, 6/18/2013
c   xz: may need to be changed for POPs if gasesou air-sea exchange is important
c   xz: for PCB, this process is not important
c-------------------------------------------------------------

c #ifdef ALLOWHG
c           pisvel(i,j,bi,bj)=(0.25 _d 0*wind**2)/3.6 _d 5
c           if (i .eq. 180 .and. j .eq. 80) then
c             write(*,*)'wind      at (180,80):',wind
c            write(*,*)'pisvel    at (180,80):',pisvel(i,j,bi,bj)
c           endif
c#else
           pisvel(i,j,bi,bj)=(0.31 _d 0*wind(i,j,bi,bj)**2)/3.6 _d 5
           if (i .eq. 180 .and. j .eq. 80) then
              write(*,*)'wind      at (180,80):', wind(i,j,bi,bj)
              write(*,*)'pisvel    at (180,80):', pisvel(i,j,bi,bj)
           endif
c#endif
          ENDDO
         ENDDO
        ENDDO
       ENDDO
c===============================

c==================xz pcb seaspray start ===
#ifdef ALLOW_SEASPRAY !xz: numberical integration able to adjust steps 
C               get values of seaspraywtrflux in m3/m2/s
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx

c       write(*,*) 'myIter, myTime, myThid', myIter,myTime,myThid

           
            Call PCB_CalcWaterSpray( 
C     O                       seaspraywtrflux,
     I                          i, j, bi, bj) 

c     I                          myIter, myTime, myThid )
           
      
            if (i .eq. 180 .and. j .eq. 80) then
             write(*,*)'seaspraywtrflux at (180,80):'
     &          ,seaspraywtrflux (i,j,bi,bj)
            endif

          ENDDO
         ENDDO
        ENDDO
       ENDDO
#endif
c===============xz pcb seaspray end================

C endif for periodicForcing
      ENDIF

C=======================================================================
C read fields for PCB chemistry,from Hg code by yanxu
C=======================================================================
      IF ( PCB_chemCycle .GT. 0. _d 0 ) THEN

C First call requires that we initialize everything to zero for safety
       IF ( myIter .EQ. nIter0 ) THEN
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            PCB_ldRec_chem(bi,bj) = 0
          ENDDO
         ENDDO
       ENDIF

C--   Now calculate whether it is time to update the forcing arrays
#ifdef ALLOW_CAL
       CALL CAL_GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   PCB_chemCycle, PCB_chemPeriod, nowRead,
     I                   deltaTclock, myIter, myTime, myThid )
        if ( myIter .eq. nIter0 ) THEN
            nowRead=.TRUE.
        endif    
#else
       CALL GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   PCB_chemCycle, PCB_chemPeriod,
     I                   deltaTclock, myTime, myThid )
#endif

       bi = myBxLo(myThid)
       bj = myByLo(myThid)
#ifdef ALLOW_DEBUG
       IF ( debugLevel.GE.debLevB ) THEN
        _BEGIN_MASTER(myThid)
        WRITE(standardMessageUnit,'(A,I10,A,4I5,A,2F14.10)')
     &   ' PCB_FIELDS_LOAD,', myIter,
     &   ' : iP,iLd,i0,i1=', intimeP,PCB_ldRec_chem(bi,bj), 
     &                       intime0,intime1,
     &   ' ; Wght=', bWght, aWght
        _END_MASTER(myThid)
       ENDIF
#endif /* ALLOW_DEBUG */

#ifdef ALLOW_CAL
       IF ( nowRead ) THEN
#else
#ifdef ALLOW_AUTODIFF_TAMC
C-    assuming that we call S/R HG_FIELDS_LOAD at each time-step and
C     with increasing time, this will catch when we need to load new records;
C     But with Adjoint run, this is not always the case => might end-up using
C     the wrong time-records
       IF ( intime0.NE.intimeP .OR. myIter.EQ.nIter0 ) THEN
#else /* ALLOW_AUTODIFF_TAMC */
C-    Make no assumption on sequence of calls to HG_FIELDS_LOAD ;
C     This is the correct formulation (works in Adjoint run).
C     Unfortunatly, might produce many recomputations <== not used until it is fixed
       IF ( intime1.NE.PCB_ldRec_chem(bi,bj) ) THEN
#endif /* ALLOW_AUTODIFF_TAMC */
#endif
C--   If the above condition is met then we need to read in
C     data for the period ahead and the period behind myTime.
        IF ( debugLevel.GE.debLevZero ) THEN
         _BEGIN_MASTER(myThid)
         WRITE(standardMessageUnit,'(A,I10,A,2(2I5,A))')
     &    ' PCB_FIELDS_LOAD, it=', myIter,
     &    ' : Reading new data, i0,i1=', intime0, intime1,
     &    ' (prev=', intimeP, PCB_ldRec_chem(bi,bj), ' )'
         _END_MASTER(myThid)
        ENDIF

        _BARRIER

        IF ( radsw_File .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( radsw_File,radsw0,intime0,
     &        myIter,myThid )
         CALL READ_REC_XY_RS( radsw_File,radsw1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( PCB_iceFile .NE. ' '  .AND. .NOT.useSEAICE ) THEN
         CALL READ_REC_XY_RS( PCB_iceFile,ice0,intime0,
     &       myIter,myThid )
         CALL READ_REC_XY_RS( PCB_iceFile,ice1,intime1,
     &       myIter,myThid )
        ENDIF

c For now, set [PCBd] to a constant to get the ball rolling. 
c Eventually combe back to this when you are ready to read in
c PCBd concentrations from archived GEOS-Chem runs. 
c (hma, 11 Jul 2014)
c        IF ( PCBd_concFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBd_concFile,pbdconc0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBd_concFile,pcbdconc1,intime1,
c     &       myIter,myThid )
c        ENDIF
c
c        IF ( PCBd_depoFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBd_depoFile,pcbddepo0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBd_depoFile,pcbddepo1,intime1,
c     &       myIter,myThid )
c        ENDIF
c
c        IF ( PCBp_depoFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBp_depoFile,pcbpdepo0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBp_depoFile,pcbpdepo1,intime1,
c     &       myIter,myThid )
c        ENDIF

c I don't need the ionized tracer for PCBs. It's legacy code from PFCs. (hma, 08 Jul 2014)
c        IF ( PCBi_depoFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBi_depoFile,pcbidepo0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBi_depoFile,pcbidepo1,intime1,
c     &       myIter,myThid )
c        ENDIF
c        IF ( PCBi_riverFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBi_riverFile,pcbiriver0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBi_riverFile,pcbiriver1,intime1,
c     &       myIter,myThid )
c        ENDIF

c Not considering rivers for PCBS. (hma, 11 Jul 2014)
c        IF ( PCBP_riverFile .NE. ' ' ) THEN
c         CALL READ_REC_XY_RS( PCBP_riverFile,pcbpriver0,intime0,
c     &       myIter,myThid )
c        CALL READ_REC_XY_RS( PCBP_riverFile,pcbpriver1,intime1,
c     &       myIter,myThid )
c        ENDIF

c	#ifdef HGPRIVER        
c	        IF ( HGR_riverFile .NE. ' ' ) THEN
c	         DO nriver=1,nrmax
c	          WRITE (nrivers,'(I2.2)') nriver
c	          hgR_file_Act = trim(HGR_riverFile) // '.' 
c	     &                   // nrivers // '.bin'
c	          CALL READ_REC_XY_RS( HGR_file_Act,
c	     &       hgrriver0(1-OLx,1-OLy,1,1,nriver),intime0,
c	     &       myIter,myThid )
c	          CALL READ_REC_XY_RS( HGR_file_Act,
c	     &       hgrriver1(1-OLx,1-OLy,1,1,nriver),intime1,
c	     &       myIter,myThid )
c	         ENDDO
c	        ENDIF
c	#endif        
                
        prec=32
        IF ( chl_File .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( chl_File,prec,Nr,chl0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( chl_File,prec,Nr,chl1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( npp_File .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( npp_File,prec,Nr,npp0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( npp_File,prec,Nr,npp1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( doc_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( doc_file,prec,Nr,doc0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( doc_file,prec,Nr,doc1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( poc_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( poc_file,prec,Nr,poc0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( poc_file,prec,Nr,poc1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( Fdoc_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( Fdoc_file,prec,Nr,Fdoc0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( Fdoc_file,prec,Nr,Fdoc1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( Fpoc_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( Fpoc_file,prec,Nr,Fpoc0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( Fpoc_file,prec,Nr,Fpoc1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( Fremin_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( Fremin_file,prec,Nr,Fremin0,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( Fremin_file,prec,Nr,Fremin1,intime1,
     &        myIter,myThid )
        ENDIF
#ifdef FOODW_MODE        
        IF ( NO3_file .NE. ' ' ) THEN
         CALL READ_REC_3D_RS( NO3_file,prec,Nr,NO30,intime0,
     &        myIter,myThid )
         CALL READ_REC_3D_RS( NO3_file,prec,Nr,NO31,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( phytoP_file .NE. ' ' ) THEN
         DO np=1,npmax
           WRITE (nps,'(I2.2)') np
           phytoP_file_Act = trim(phytoP_file) // '.' // nps // '.bin'  
           CALL READ_REC_3D_RS( phytoP_file_Act,prec,Nr,
     &        phytoP0(1-OLx,1-OLy,1,1,1,np),intime0,
     &        myIter,myThid )
           CALL READ_REC_3D_RS( phytoP_file_Act,prec,Nr,
     &        phytoP1(1-OLx,1-OLy,1,1,1,np),intime1,
     &        myIter,myThid )
           ENDDO
        ENDIF
        IF ( zooP_file .NE. ' ' ) THEN
         DO nz=1,nzmax
           WRITE (nzs,'(I2.2)') nz
           zooP_file_Act = trim(zooP_file) // '.' // nzs // '.bin'   
           CALL READ_REC_3D_RS( zooP_file_Act,prec,Nr,
     &        zooP0(1-OLx,1-OLy,1,1,1,nz),intime0,
     &        myIter,myThid )
           CALL READ_REC_3D_RS( zooP_file_Act,prec,Nr,
     &        zooP1(1-OLx,1-OLy,1,1,1,nz),intime1,
     &        myIter,myThid )
           ENDDO
        ENDIF
#endif                
         _EXCH_XY_RS(radsw0, myThid )
         _EXCH_XY_RS(radsw1, myThid )
        IF (.NOT.useSEAICE) THEN
         _EXCH_XY_RS(ice0, myThid )
         _EXCH_XY_RS(ice1, myThid )
        ENDIF
c For now, set [PCBd] to a constant to get the ball rolling. 
c Eventually combe back to this when you are ready to read in
c PCBd concentrations from archived GEOS-Chem runs. Also set
c deposition to a constant for now. 
c (hma, 11 Jul 2014)
c         _EXCH_XY_RS(pcbdconc0, myThid )
c         _EXCH_XY_RS(pcbdconc1, myThid )
c         _EXCH_XY_RS(pcbddepo0, myThid )
c         _EXCH_XY_RS(pcbddepo1, myThid )
c         _EXCH_XY_RS(pcbpdepo0, myThid )
c         _EXCH_XY_RS(pcbpdepo1, myThid )

c Not considering rivers for PCBs. (hma, 11 Jul 2014)
c         _EXCH_XY_RS(pcbiriver0, myThid )
c         _EXCH_XY_RS(pcbiriver1, myThid )
c         _EXCH_XY_RS(pcbpriver0, myThid )
c         _EXCH_XY_RS(pcbpriver1, myThid ) 

c #ifdef HGPRIVER
c         DO nriver=1,nrmax
c          _EXCH_XY_RS(hgrriver0(1-OLx,1-OLy,1,1,nriver),myThid)
c          _EXCH_XY_RS(hgrriver1(1-OLx,1-OLy,1,1,nriver),myThid)
c         ENDDO 
c#endif                                  
         _EXCH_XYZ_RS(chl0, myThid )
         _EXCH_XYZ_RS(chl1, myThid )
         _EXCH_XYZ_RS(npp0, myThid )
         _EXCH_XYZ_RS(npp1, myThid )
         _EXCH_XYZ_RS(doc0, myThid )
         _EXCH_XYZ_RS(doc1, myThid )
         _EXCH_XYZ_RS(poc0, myThid )
         _EXCH_XYZ_RS(poc1, myThid )
         _EXCH_XYZ_RS(Fdoc0, myThid )
         _EXCH_XYZ_RS(Fdoc1, myThid )
         _EXCH_XYZ_RS(Fpoc0, myThid )
         _EXCH_XYZ_RS(Fpoc1, myThid )
         _EXCH_XYZ_RS(Fremin0, myThid )
         _EXCH_XYZ_RS(Fremin1, myThid )
#ifdef FOODW_MODE         
         _EXCH_XYZ_RS(NO30, myThid )
         _EXCH_XYZ_RS(NO31, myThid )
         DO np=1,npmax
           _EXCH_XYZ_RS(phytoP0(1-OLx,1-OLy,1,1,1,np), myThid )
           _EXCH_XYZ_RS(phytoP1(1-OLx,1-OLy,1,1,1,np), myThid )
         ENDDO
         DO nz=1,nzmax
           _EXCH_XYZ_RS(zooP0(1-OLx,1-OLy,1,1,1,nz), myThid )
           _EXCH_XYZ_RS(zooP1(1-OLx,1-OLy,1,1,1,nz), myThid )
         ENDDO
#endif
C-    save newly loaded time-record
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
           PCB_ldRec_chem(bi,bj) = intime1
         ENDDO
        ENDDO

C--   end if-block for loading new time-records
       ENDIF

C
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           IF ( radsw_File .NE. ' '  ) THEN
             radsw(i,j,bi,bj) = bWght*radsw0(i,j,bi,bj)
     &                          +aWght*radsw1(i,j,bi,bj)
           ELSE
             radsw(i,j,bi,bj) = 0. _d 0
           ENDIF
          ENDDO
         ENDDO
        ENDDO
       ENDDO
       
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           IF ( PCB_iceFile .NE. ' '  ) THEN
            FIce(i,j,bi,bj)    = bWght*ice0(i,j,bi,bj)
     &                          +aWght*ice1(i,j,bi,bj)
           ELSE
            FIce(i,j,bi,bj) =0. _d 0
           ENDIF
          ENDDO
         ENDDO
        ENDDO
       ENDDO
C       
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx

c For now, set [PCBd] to a constant to get the ball rolling. 
c Eventually combe back to this when you are ready to read in
c PCBd concentrations from archived GEOS-Chem runs. Also set
c deposition to a constant for now. 
c (hma, 11 Jul 2014)
           ! Atmospheric concentration (ng/m3)
c           IF ( PCBd_concFile .NE. ' '  ) THEN
c             PCBdConc(i,j,bi,bj) = bWght*pcbdconc0(i,j,bi,bj)
c     &                          +aWght*pcbdconc1(i,j,bi,bj)
c           ELSE
c             PCBdConc(i,j,bi,bj) = 0. _d 0  
c           ENDIF
            PCBdConc(i,j,bi,bj) = 2. _d -3 ! set to a constant (ng/m3)  
                                           ! Based on PCB 28 measured at Falkand Island,
                                           !   in Fig 1 (Ockenden et al., 2001).                                            
    
            ! Atmospheric deposition of PCBd (kg/m2/s)
c           IF ( PCBd_depoFile .NE. ' '  ) THEN
c             PCBdDepo(i,j,bi,bj) = bWght*pcbddepo0(i,j,bi,bj)
c     &                          +aWght*pcbddepo1(i,j,bi,bj)
c           ELSE
c             PCBdDepo(i,j,bi,bj) = 0. _d 0  
c           ENDIF
            PCBdDepo(i,j,bi,bj) = 1.9 _d -18  ! set to a constant (kg/m2/s)
                                              ! Based on Carrerra et al. (2002), measured
                                              !   PCB deposition to high mountain lakes in 
                                              !   Europe. Range, 1.4-15 ng/m2/month. I picked
                                              !   5 ng/m2/month as a mid value. 

            ! Atmospheric deposition of PCBp (kg/m2/s)
c           IF ( PCBp_depoFile .NE. ' '  ) THEN
c             PCBpDepo(i,j,bi,bj) = bWght*pcbpdepo0(i,j,bi,bj)
c     &                          +aWght*pcbpdepo1(i,j,bi,bj)
c           ELSE
c             PCBpDepo(i,j,bi,bj) = 0. _d 0  ! <-- set to a constant value here
c           ENDIF
            PCBpDepo(i,j,bi,bj) = 1.9 _d -18  ! set to a constant (kg/m2/s)
                                              ! Based on Carrerra et al. (2002), measured
                                              !   PCB deposition to high mountain lakes in 
                                              !   Europe. Range, 1.4-15 ng/m2/month. I picked
                                              !   5 ng/m2/month as a mid value. 

c Not considering rivers for PCBs. (hma, 11 Jul 2014)
c           IF ( PCBi_riverFile .NE. ' '  ) THEN
c             PCBiRiver(i,j,bi,bj) = bWght*pcbiriver0(i,j,bi,bj)
c     &                          +aWght*pcbiriver1(i,j,bi,bj)
c           ELSE
c             PCBiRiver(i,j,bi,bj) = 0. _d 0
c           ENDIF

c Not considering rivers for PCBs (hma, 11 Jul 2014)
c           IF ( PCBP_riverFile .NE. ' '  ) THEN
c             PCBPRiver(i,j,bi,bj) = bWght*pcbpriver0(i,j,bi,bj)
c     &                          +aWght*pcbpriver1(i,j,bi,bj)
c           ELSE
c             PCBPRiver(i,j,bi,bj) = 0. _d 0
c           ENDIF

c #ifdef HGPRIVER
c           DO nriver=1,nrmax
c            IF ( HGR_riverFile .NE. ' '  ) THEN
c              HgRRiver(i,j,bi,bj,nriver) =
c     &                           bWght*hgrriver0(i,j,bi,bj,nriver)
c     &                          +aWght*hgrriver1(i,j,bi,bj,nriver)
c            ELSE
c              HgrRiver(i,j,bi,bj,nriver) = 0. _d 0
c            ENDIF 
c           ENDDO
c #endif            
          ENDDO
         ENDDO
        ENDDO
       ENDDO
C
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO k=1,Nr
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           IF ( chl_File .NE. ' '  ) THEN
             chl(i,j,k,bi,bj) = bWght*chl0(i,j,k,bi,bj)
     &                          +aWght*chl1(i,j,k,bi,bj)
           ELSE
             chl(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( npp_File .NE. ' '  ) THEN
             npp(i,j,k,bi,bj) = bWght*npp0(i,j,k,bi,bj)
     &                          +aWght*npp1(i,j,k,bi,bj)
           ELSE
             npp(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( doc_File .NE. ' '  ) THEN
             doc(i,j,k,bi,bj) = bWght*doc0(i,j,k,bi,bj)
     &                          +aWght*doc1(i,j,k,bi,bj)
           ELSE
             doc(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( poc_File .NE. ' '  ) THEN
             poc(i,j,k,bi,bj) = bWght*poc0(i,j,k,bi,bj)
     &                          +aWght*poc1(i,j,k,bi,bj)
           ELSE
             poc(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( Fdoc_File .NE. ' '  ) THEN
             Fdoc(i,j,k,bi,bj) = bWght*Fdoc0(i,j,k,bi,bj)
     &                          +aWght*Fdoc1(i,j,k,bi,bj)
           ELSE
             Fdoc(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( Fpoc_File .NE. ' '  ) THEN
             Fpoc(i,j,k,bi,bj) = bWght*Fpoc0(i,j,k,bi,bj)
     &                          +aWght*Fpoc1(i,j,k,bi,bj)
           ELSE
             Fpoc(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           IF ( Fremin_File .NE. ' '  ) THEN
             Fremin(i,j,k,bi,bj) = bWght*Fremin0(i,j,k,bi,bj)
     &                          +aWght*Fremin1(i,j,k,bi,bj)
           ELSE
             Fremin(i,j,k,bi,bj) = 0. _d 0
           ENDIF
#ifdef FOODW_MODE           
           IF ( NO3_File .NE. ' '  ) THEN
             NO3(i,j,k,bi,bj) = bWght*NO30(i,j,k,bi,bj)
     &                          +aWght*NO31(i,j,k,bi,bj)
           ELSE
             NO3(i,j,k,bi,bj) = 0. _d 0
           ENDIF
           
           DO np=1,npmax
             IF ( phytoP_File .NE. ' '  ) THEN
               phytoP(i,j,k,bi,bj,np) = bWght*phytoP0(i,j,k,bi,bj,np)
     &                          +aWght*phytoP1(i,j,k,bi,bj,np)
             ELSE
               phytoP(i,j,k,bi,bj,np) = 0. _d 0
             ENDIF
           ENDDO
           DO nz=1,nzmax
             IF ( zooP_File .NE. ' '  ) THEN
               zooP(i,j,k,bi,bj,nz) = bWght*zooP0(i,j,k,bi,bj,nz)
     &                          +aWght*zooP1(i,j,k,bi,bj,nz)
             ELSE
               zooP(i,j,k,bi,bj,nz) = 0. _d 0
             ENDIF
           ENDDO
#endif           
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

C endif for periodicChem
      ENDIF











c==========below are originally from cfc=======
c	       IF ( PCB_forcingCycle.GT.zeroRL
c	     &       .AND. PCB_atmospFile.NE.' ' ) THEN
c	          DO j=1-OLy,sNy+OLy
c	           DO i=1-OLx,sNx+OLx
c	             ATMOSP(i,j,bi,bj) = bWght*atmosp0(i,j,bi,bj)
c	     &                         + aWght*atmosp1(i,j,bi,bj)
c	           ENDDO
c	          ENDDO
c	        ELSE
c	          DO j=1-OLy,sNy+OLy
c	           DO i=1-OLx,sNx+OLx
c	             ATMOSP(i,j,bi,bj) = maskC(i,j,1,bi,bj)
c	           ENDDO
c	          ENDDO
c	        ENDIF
c	
c	        IF ( useThSIce ) THEN
c	#ifdef ALLOW_THSICE
c	          DO j=1-OLy,sNy+OLy
c	           DO i=1-OLx,sNx+OLx
c	             FIce(I,J,bi,bj) = iceMask(i,j,bi,bj)
c	           ENDDO
c	          ENDDO
c	#endif /* ALLOW_THSICE */
c	        ELSEIF ( useSEAICE ) THEN
c	#ifdef ALLOW_SEAICE
c	          DO j=1-OLy,sNy+OLy
c	           DO i=1-OLx,sNx+OLx
c	             FIce(I,J,bi,bj) = AREA(I,J,bi,bj)
c	           ENDDO
c	          ENDDO
c	#endif /* ALLOW_SEAICE */
c	        ELSEIF ( PCB_forcingCycle.GT.zeroRL
c	     &           .AND. PCB_iceFile.NE.' ' ) THEN
c	         DO j=1-OLy,sNy+OLy
c	          DO i=1-OLx,sNx+OLx
c	             FIce(i,j,bi,bj) = bWght*ice0(i,j,bi,bj)
c	     &                       + aWght*ice1(i,j,bi,bj)
c	          ENDDO
c	         ENDDO
c	        ELSE
c	         DO j=1-OLy,sNy+OLy
c	          DO i=1-OLx,sNx+OLx
c	             FIce(i,j,bi,bj) = 0. _d 0
c	          ENDDO
c	         ENDDO
c	        ENDIF

C--   end bi.bj loops
c       ENDDO
c      ENDDO
c==========above are originally from cfc=======
      RETURN
      END
