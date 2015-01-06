C $Header: /u/gcmpack/MITgcm/pkg/hg/hg_fields_load.F,v 1.19 2012/03/06 15:37:24 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE HG_FIELDS_LOAD (
     I           myIter,myTime,myThid)

C     *==========================================================*
C     | SUBROUTINE HG_FIELDS_LOAD
C     *==========================================================*

      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "HG_SIZE.h"
#include "HG.h"

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid

C     == Local variables ==
      INTEGER intimeP, intime0, intime1
      INTEGER bi, bj, i, j, k
      INTEGER prec
#ifdef FOODW_MODE
      CHARACTER*(MAX_LEN_FNAM) phytoP_File_Act, zooP_File_Act
      INTEGER np, nz
      CHARACTER*(2) nps, nzs
#endif
#ifdef HGPRIVER
      CHARACTER*(MAX_LEN_FNAM) hgR_File_Act
      INTEGER nriver
      CHARACTER*(2) nrivers
#endif
      LOGICAL nowRead

      _RL aWght, bWght
      _RL wind

      IF ( HG_forcingCycle .GT. 0. _d 0 ) THEN

C First call requires that we initialize everything to zero for safety
       IF ( myIter .EQ. nIter0 ) THEN
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            HG_ldRec_forcing(bi,bj) = 0
          ENDDO
         ENDDO
       ENDIF

C--   Now calculate whether it is time to update the forcing arrays
#ifdef ALLOW_CAL
       CALL CAL_GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   HG_forcingCycle, HG_forcingPeriod, nowRead,
     I                   deltaTclock, myIter, myTime, myThid )
        if ( myIter .eq. nIter0 ) THEN
            nowRead=.TRUE.
        endif    
#else
       CALL GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   HG_forcingCycle, HG_forcingPeriod,
     I                   deltaTclock, myTime, myThid )
#endif /* ALLOW_CAL */

       bi = myBxLo(myThid)
       bj = myByLo(myThid)
#ifdef ALLOW_DEBUG
       IF ( debugLevel.GE.debLevB ) THEN
        _BEGIN_MASTER(myThid)
        WRITE(standardMessageUnit,'(A,I10,A,4I5,A,2F14.10)')
     &   ' HG_FIELDS_LOAD,', myIter,
     &   ' : iP,iLd,i0,i1=', intimeP,HG_ldRec_forcing(bi,bj), 
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
       IF ( intime1.NE.HG_ldRec_forcing(bi,bj) ) THEN
#endif /* ALLOW_AUTODIFF_TAMC */
#endif

C--   If the above condition is met then we need to read in
C     data for the period ahead and the period behind myTime.
        IF ( debugLevel.GE.debLevZero ) THEN
         _BEGIN_MASTER(myThid)
         WRITE(standardMessageUnit,'(A,I10,A,2(2I5,A))')
     &    ' HG_FIELDS_LOAD, it=', myIter,
     &    ' : Reading new data, i0,i1=', intime0, intime1,
     &    ' (prev=', intimeP, HG_ldRec_forcing(bi,bj), ' )'
         _END_MASTER(myThid)
        ENDIF

        _BARRIER

        IF ( HG_windFile .NE. ' '  .AND. .NOT.useEXF ) THEN
         CALL READ_REC_XY_RS( HG_windFile,wind0,intime0,
     &        myIter,myThid )
         CALL READ_REC_XY_RS( HG_windFile,wind1,intime1,
     &        myIter,myThid )
        ENDIF

         _EXCH_XY_RS(wind0, myThid )
         _EXCH_XY_RS(wind1, myThid )

C-    save newly loaded time-record
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
           HG_ldRec_forcing(bi,bj) = intime1
         ENDDO
        ENDDO

C--   end if-block for loading new time-records
       ENDIF

       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           IF ( HG_windFile .NE. ' '  ) THEN
             wind = bWght*wind0(i,j,bi,bj)
     &                           +aWght*wind1(i,j,bi,bj)
           ELSE
             wind = 5. _d 0*maskC(i,j,1,bi,bj)
           ENDIF
c calculate piston velocity
c QQ: note - we should have wind speed variance in here
c following Wannikof (1992)
c m/s

c piston velocity calculation is different for Hg0
c according to Soerensen et al. 2010
c yzh, 6/18/2013
#ifdef ALLOW_HG
           pisvel(i,j,bi,bj)=(0.25 _d 0*wind**2)/3.6 _d 5
#else
           pisvel(i,j,bi,bj)=(0.31 _d 0*wind**2)/3.6 _d 5
#endif
          ENDDO
         ENDDO
        ENDDO
       ENDDO
C endif for periodicForcing
      ENDIF

C=======================================================================
C read fields for Hg chemistry                                         |
C=======================================================================
      IF ( HG_chemCycle .GT. 0. _d 0 ) THEN

C First call requires that we initialize everything to zero for safety
       IF ( myIter .EQ. nIter0 ) THEN
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            HG_ldRec_chem(bi,bj) = 0
          ENDDO
         ENDDO
       ENDIF

C--   Now calculate whether it is time to update the forcing arrays
#ifdef ALLOW_CAL
       CALL CAL_GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   HG_chemCycle, HG_chemPeriod, nowRead,
     I                   deltaTclock, myIter, myTime, myThid )
        if ( myIter .eq. nIter0 ) THEN
            nowRead=.TRUE.
        endif    
#else
       CALL GET_PERIODIC_INTERVAL(
     O                   intimeP, intime0, intime1, bWght, aWght,
     I                   HG_chemCycle, HG_chemPeriod,
     I                   deltaTclock, myTime, myThid )
#endif

       bi = myBxLo(myThid)
       bj = myByLo(myThid)
#ifdef ALLOW_DEBUG
       IF ( debugLevel.GE.debLevB ) THEN
        _BEGIN_MASTER(myThid)
        WRITE(standardMessageUnit,'(A,I10,A,4I5,A,2F14.10)')
     &   ' HG_FIELDS_LOAD,', myIter,
     &   ' : iP,iLd,i0,i1=', intimeP,HG_ldRec_chem(bi,bj), 
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
       IF ( intime1.NE.HG_ldRec_chem(bi,bj) ) THEN
#endif /* ALLOW_AUTODIFF_TAMC */
#endif
C--   If the above condition is met then we need to read in
C     data for the period ahead and the period behind myTime.
        IF ( debugLevel.GE.debLevZero ) THEN
         _BEGIN_MASTER(myThid)
         WRITE(standardMessageUnit,'(A,I10,A,2(2I5,A))')
     &    ' HG_FIELDS_LOAD, it=', myIter,
     &    ' : Reading new data, i0,i1=', intime0, intime1,
     &    ' (prev=', intimeP, HG_ldRec_chem(bi,bj), ' )'
         _END_MASTER(myThid)
        ENDIF

        _BARRIER

        IF ( radsw_File .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( radsw_File,radsw0,intime0,
     &        myIter,myThid )
         CALL READ_REC_XY_RS( radsw_File,radsw1,intime1,
     &        myIter,myThid )
        ENDIF
        IF ( HG_iceFile .NE. ' '  .AND. .NOT.useSEAICE ) THEN
         CALL READ_REC_XY_RS( HG_iceFile,ice0,intime0,
     &       myIter,myThid )
         CALL READ_REC_XY_RS( HG_iceFile,ice1,intime1,
     &       myIter,myThid )
        ENDIF
        IF ( Hg0_concFile .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( Hg0_concFile,hg0conc0,intime0,
     &       myIter,myThid )
        CALL READ_REC_XY_RS( Hg0_concFile,hg0conc1,intime1,
     &       myIter,myThid )
        ENDIF
        IF ( HG2_depoFile .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( HG2_depoFile,hg2depo0,intime0,
     &       myIter,myThid )
        CALL READ_REC_XY_RS( HG2_depoFile,hg2depo1,intime1,
     &       myIter,myThid )
        ENDIF
        IF ( HG2_riverFile .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( HG2_riverFile,hg2river0,intime0,
     &       myIter,myThid )
        CALL READ_REC_XY_RS( HG2_riverFile,hg2river1,intime1,
     &       myIter,myThid )
        ENDIF
        IF ( HGP_riverFile .NE. ' ' ) THEN
         CALL READ_REC_XY_RS( HGP_riverFile,hgpriver0,intime0,
     &       myIter,myThid )
        CALL READ_REC_XY_RS( HGP_riverFile,hgpriver1,intime1,
     &       myIter,myThid )
        ENDIF
#ifdef HGPRIVER        
        IF ( HGR_riverFile .NE. ' ' ) THEN
         DO nriver=1,nrmax
          WRITE (nrivers,'(I2.2)') nriver
          hgR_file_Act = trim(HGR_riverFile) // '.' 
     &                   // nrivers // '.bin'
          CALL READ_REC_XY_RS( HGR_file_Act,
     &       hgrriver0(1-OLx,1-OLy,1,1,nriver),intime0,
     &       myIter,myThid )
          CALL READ_REC_XY_RS( HGR_file_Act,
     &       hgrriver1(1-OLx,1-OLy,1,1,nriver),intime1,
     &       myIter,myThid )
         ENDDO
        ENDIF
#endif        
                
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
         _EXCH_XY_RS(hg0conc0, myThid )
         _EXCH_XY_RS(hg0conc1, myThid )
         _EXCH_XY_RS(hg2depo0, myThid )
         _EXCH_XY_RS(hg2depo1, myThid )
         _EXCH_XY_RS(hg2river0, myThid )
         _EXCH_XY_RS(hg2river1, myThid )
         _EXCH_XY_RS(hgpriver0, myThid )
         _EXCH_XY_RS(hgpriver1, myThid ) 
#ifdef HGPRIVER
         DO nriver=1,nrmax
          _EXCH_XY_RS(hgrriver0(1-OLx,1-OLy,1,1,nriver),myThid)
          _EXCH_XY_RS(hgrriver1(1-OLx,1-OLy,1,1,nriver),myThid)
         ENDDO 
#endif                                  
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
           HG_ldRec_chem(bi,bj) = intime1
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
           IF ( HG_iceFile .NE. ' '  ) THEN
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
           IF ( Hg0_concFile .NE. ' '  ) THEN
             Hg0Conc(i,j,bi,bj) = bWght*hg0conc0(i,j,bi,bj)
     &                          +aWght*hg0conc1(i,j,bi,bj)
           ELSE
             Hg0Conc(i,j,bi,bj) = 0. _d 0
           ENDIF
           IF ( HG2_depoFile .NE. ' '  ) THEN
             Hg2Depo(i,j,bi,bj) = bWght*hg2depo0(i,j,bi,bj)
     &                          +aWght*hg2depo1(i,j,bi,bj)
           ELSE
             Hg2Depo(i,j,bi,bj) = 0. _d 0
           ENDIF
           IF ( HG2_riverFile .NE. ' '  ) THEN
             Hg2River(i,j,bi,bj) = bWght*hg2river0(i,j,bi,bj)
     &                          +aWght*hg2river1(i,j,bi,bj)
           ELSE
             Hg2River(i,j,bi,bj) = 0. _d 0
           ENDIF
           IF ( HGP_riverFile .NE. ' '  ) THEN
             HgPRiver(i,j,bi,bj) = bWght*hgpriver0(i,j,bi,bj)
     &                          +aWght*hgpriver1(i,j,bi,bj)
           ELSE
             HgpRiver(i,j,bi,bj) = 0. _d 0
           ENDIF
#ifdef HGPRIVER
           DO nriver=1,nrmax
            IF ( HGR_riverFile .NE. ' '  ) THEN
              HgRRiver(i,j,bi,bj,nriver) =
     &                           bWght*hgrriver0(i,j,bi,bj,nriver)
     &                          +aWght*hgrriver1(i,j,bi,bj,nriver)
            ELSE
              HgrRiver(i,j,bi,bj,nriver) = 0. _d 0
            ENDIF 
           ENDDO
#endif            
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

      RETURN
      END
