! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/mitgcm_ocn2cam/mitgcm_ocn2cam_cpl.F,v 1.1 2004/03/30 03:59:01 cnh Exp $
! $Name:  $
!
!     Basic coupler between MITgcm ocean and fvCAM.
!     Takes MITgcm export state and maps it to fvCAM import state.
!     In general export state and import state may be on different 
!     physical or distributed grids and reside on different DE sets:
!     At present:
!     o regrid appears faulty on most platforms so a CPP 
!       flag E_REGRID_IS_BROKEN can be used at compile time to
!       stop regridding. in this case the coupler simply copies
!       from the index space of the import state that is congruent
!       with the index space of the export state.
!     o for platforms where regrid appears to work (blackforest.ucar.edu)
!       it is used to map MITgcm ocean SST field to fvCAM
!       equivalent with appropriate adjustments in units (oC -> K) in
!       addition to spatial interpolation.
!
      MODULE MITGCM_ORG_OCN_2_FVCAM

      USE ESMF_MOD

      USE MITGCM_ORG_ESMF_UTILS
      USE MITGCM_ORG_OCN_ESMF_IMPORTS
      USE MITGCM_ORG_OCN_ESMF_EXPORTS

      IMPLICIT NONE
      PRIVATE

      PUBLIC ESMF_SET_SERVICES

!     Regrid setup that is saved during init and that maps mitgcm -> cam
!     The "regrid" is then used during coupler run.
!     Note - this will eventually move to being part of the component "attributes"
!            i.e. not static. this will be done when we are confident it works
!            as static.
      TYPE(ESMF_RouteHandle), SAVE :: mit2cam_regrid

      CONTAINS

      SUBROUTINE ESMF_SET_SERVICES( cC, esmfRC )
!     == Routine arguments ==
      TYPE(ESMF_CplComp)  :: cC
      INTEGER             :: esmfRC

!     Register init handler
      CALL ESMF_CplCompSetEntryPoint( cC, ESMF_SETINIT,
     &            driver_init, ESMF_SINGLEPHASE, esmfRC )

!     Register run handler
      CALL ESMF_CplCompSetEntryPoint( cC, ESMF_SETRUN,
     &            driver_run, ESMF_SINGLEPHASE, esmfRC )

      RETURN
      END SUBROUTINE

      SUBROUTINE DRIVER_INIT( cC, iState, eState, clock, esmfRC )

!     == Global variables ==

!     == Routine arguments ==
      TYPE(ESMF_CplComp)  :: cC
      TYPE(ESMF_State)    :: iState
      TYPE(ESMF_State)    :: eState
      TYPE(ESMF_Clock)    :: clock
      INTEGER             :: esmfRC

!     == Local variables ==
      TYPE(ESMF_DELayout)                :: cplLayout
      REAL(KIND=ESMF_KIND_R8), POINTER   :: sst_ocn(:,:)
      REAL(KIND=ESMF_KIND_R8), POINTER   :: sst_atm(:,:)
      TYPE(ESMF_Field)                   :: sst_ocn_field
      TYPE(ESMF_Field)                   :: sst_atm_field

      CALL ESMF_CplCompGet( component=cC, layout=cplLayout, rc=esmfRC )

!     Get the field handle for SST in import (ocn export) and export (atm import).
      CALL ESMF_StateGetData(iState,"mitgcm_org_ocn sstocn",
     &                       sst_ocn_field, rc=esmfRC)
      CALL ESMF_StateGetData(eState,"CAM_stub sst",
     &                       sst_atm_field, rc=esmfRC)
      CALL ESMF_FieldPrint(sst_ocn_field)
      CALL ESMF_FieldPrint(sst_atm_field)

!     Create a regrid that maps from ocn_sst -> atm_sst
#ifdef E_REGRID_IS_BROKEN
      WRITE(0,*) 'Regrid broken is defined so no Regrid is setup'
#else
      WRITE(0,*) 'Defining regrid...'
      CALL ESMF_FieldRegridStore(srcfield=sst_ocn_field,
     &                           dstfield=sst_atm_field,
     &                           parentlayout=cplLayout,
     &                           routehandle=mit2cam_regrid,
     &                           regridtype=ESMF_RegridMethod_Bilinear,
     &                           rc=esmfRC)
      WRITE(0,*) 'Regrid defined'
#endif

      RETURN
      END SUBROUTINE

      SUBROUTINE DRIVER_RUN(  gC, iState, eState, clock, esmfRC )

!     == Routine arguments ==
      TYPE(ESMF_CplComp) :: gC
      TYPE(ESMF_State)   :: iState
      TYPE(ESMF_State)   :: eState
      TYPE(ESMF_Clock)   :: clock
      INTEGER            :: esmfRC

!     == Local variables ==
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER     :: sst_ocn_dptr
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER     :: sst_atm_dptr
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), ALLOCATABLE :: sst_ocn_dtmp1
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), ALLOCATABLE :: sst_ocn_dtmp2
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), ALLOCATABLE :: sst_atm_dtmp1
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), ALLOCATABLE :: sst_atm_dtmp2
      TYPE(FIARDA)       :: sst_ocn_fspec
      TYPE(FIARDA)       :: sst_atm_fspec
      INTEGER            :: iLoSrc,  iHiSrc
      INTEGER            :: jLoSrc,  jHiSrc
      INTEGER            :: iLoTrg,  iHiTrg
      INTEGER            :: jLoTrg,  jHiTrg
      INTEGER            :: iLoSrcC, iHiSrcC
      INTEGER            :: jLoSrcC, jHiSrcC
      INTEGER            :: iLoTrgC, iHiTrgC
      INTEGER            :: jLoTrgC, jHiTrgC
      INTEGER            :: I,J, II, III

      TYPE(CINFO)        :: cSpec
      TYPE(CCINFO)       :: ccSpec
      REAL*8             :: tW, tE, tM, lsep

!     Decode the component information
      CALL CCOMP_GET_INFO( gC, ccSpec )
      cSpec%cType  = ccSpec%cType
      cSpec%ccInfo = ccSpec

!     Interrogate import and export state for fields we want to
!     couple.
      CALL STATE_GET_FADP( iState, "mitgcm_org_ocn sstocn", sst_ocn_dptr, 
     &                     fSpec=sst_ocn_fspec)
      CALL STATE_GET_FADP(eState,"CAM_stub sst", sst_atm_dptr,
     &                     fSpec=sst_atm_fspec)
      iLoSrc = sst_ocn_fSpec%LoCG(1)
      iHiSrc = sst_ocn_fSpec%HiCG(1)
      jLoSrc = sst_ocn_fSpec%LoCG(2)
      jHiSrc = sst_ocn_fSpec%HiCG(2)
      iLoTrg = sst_atm_fSpec%LoCG(1)
      iHiTrg = sst_atm_fSpec%HiCG(1)
      jLoTrg = sst_atm_fSpec%LoCG(2)
      jHiTrg = sst_atm_fSpec%HiCG(2)
!     sstocn(lo:hi,lo:hi) => sstatm(lo:hi,lo:hi)
      WRITE (0,'(A,I3,A,I3,A,I3,A,I3,A,A,I3,A,I3,A,I3,A,I3,A)') 'sstocn(',
     &                   iLoSrc,':',iHiSrc,',',
     &                   jLoSrc,':',jHiSrc,')',
     &                   ' => sstatm(',
     &                   iLoTrg,':',iHiTrg,',',
     &                   jLoTrg,':',jHiTrg,')'
      iLoSrcC = sst_ocn_fSpec%LoC(1)
      iHiSrcC = sst_ocn_fSpec%HiC(1)
      jLoSrcC = sst_ocn_fSpec%LoC(2)
      jHiSrcC = sst_ocn_fSpec%HiC(2)
      iLoTrgC = sst_atm_fSpec%LoC(1)
      iHiTrgC = sst_atm_fSpec%HiC(1)
      jLoTrgC = sst_atm_fSpec%LoC(2)
      jHiTrgC = sst_atm_fSpec%HiC(2)
      IF ( iLoSrc .EQ. iLoTrg .AND.
     &     iHiSrc .EQ. iHiTrg .AND.
     &     jLoSrc .EQ. jLoTrg .AND.
     &     jHiSrc .EQ. jHiTrg ) THEN
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC,iHiSrcC
         sst_atm_dptr(I,J) = sst_ocn_dptr(I,J)
        ENDDO
       ENDDO
      ELSE
!      Do basic regrid
       CALL ESMF_FieldRegrid(srcfield=sst_ocn_fSpec%fRef,
     &                       dstfield=sst_atm_fSpec%fRef,
     &                       routehandle=mit2cam_regrid,
     &                       rc=esmfRC)
!      STOP ' THATS ALL FOLKS '
       CALL FIELD_WRITE( sst_ocn_fSpec, cSpec, 0 )
       CALL FIELD_WRITE( sst_atm_fSpec, cSpec, 0 )

!      Do stop gap fix ups for land mask etc...
!      This involves a second regrid with a linear interp from ocean
!      point to ocean point around latitude circles through land.
!      Then the land mask from the original target regrid is overlaid.
!      This gives a reasonable regrid field. There are still issues at
!      the north and south boundaries. I think these may need a halo here,
!      but since a halo around latitude circles breaks things I haven't tried
!      this yet.
       ALLOCATE( sst_ocn_dtmp1(iLoSrcC:iHiSrcC,jLoSrcC:jHiSrcC) )
       ALLOCATE( sst_ocn_dtmp2(iLoSrcC:iHiSrcC,jLoSrcC:jHiSrcC) )
       ALLOCATE( sst_atm_dtmp1(iLoTrgC:iHiTrgC,jLoTrgC:jHiTrgC) )
       ALLOCATE( sst_atm_dtmp2(iLoTrgC:iHiTrgC,jLoTrgC:jHiTrgC) )

!      Make a linear interp along lat circles through land SST
!      ( after saving the original in dtmp1 )
!      We have perfect 0. values for temperature only in land.
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC,iHiSrcC
         sst_ocn_dtmp1(I,J) = sst_ocn_dptr(I,J)
         sst_ocn_dtmp2(I,J) = sst_ocn_dptr(I,J)
        ENDDO
       ENDDO
       tW=0.
       tE=0.
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC+1,iHiSrcC
         tW=sst_ocn_dtmp1(I-1,J)
         IF ( sst_ocn_dtmp1(I,J) .EQ. 0. .AND. tW .NE. 0. ) THEN
!         Scan ahead for valid tE
          lSep = 0.
          tE   = 0.
          DO II=I+1,iHiSrcC
           IF ( sst_ocn_dtmp1(II,J) .NE. 0. .AND. tE .EQ. 0. ) THEN
            tE   = sst_ocn_dtmp1(II,J)
            III  = II-1
            lSep = II-I+1
           ENDIF
          ENDDO
          IF ( tE .NE. 0. ) THEN
           DO II=I,III
            tM = tW+(tE-tW)/lSep*FLOAT(II-I+1)
            sst_ocn_dtmp2(II,J) = tM
           ENDDO
          ENDIF
         ENDIF
        ENDDO
       ENDDO
!      Now deal with the fact that if we had 0. at start|end we didn't find
!      an initial|final run.
       DO J=jLoSrcC,jHiSrcC
        DO I=iHiSrcC-1,iLoSrcC,-1
         tE = sst_ocn_dtmp2(I+1,J)
         IF (  sst_ocn_dtmp2(I,J) .EQ. 0. ) THEN
           sst_ocn_dtmp2(I,J) = tE
         ENDIF
        ENDDO
       ENDDO
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC+1,iHiSrcC
         tW = sst_ocn_dtmp2(I-1,J)
         IF (  sst_ocn_dtmp2(I,J) .EQ. 0. ) THEN
           sst_ocn_dtmp2(I,J) = tW
         ENDIF
        ENDDO
       ENDDO

!      Now regrid with the linear interp field 
!      save the regridded SST to atmos first.
       DO J=jLoTrgC,jHiTrgC
        DO I=iLoTrgC,iHiTrgC
         sst_atm_dtmp1(I,J) = sst_atm_dptr(I,J)
        ENDDO
       ENDDO
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC,iHiSrcC
         sst_ocn_dptr(I,J) = sst_ocn_dtmp2(I,J)
        ENDDO
       ENDDO
       CALL ESMF_FieldRegrid(srcfield=sst_ocn_fSpec%fRef,
     &                       dstfield=sst_atm_fSpec%fRef,
     &                       routehandle=mit2cam_regrid,
     &                       rc=esmfRC)
       CALL FIELD_WRITE( sst_ocn_fSpec, cSpec, 1 )
!      Now restore import state SST to its orginal values and
!      mask atmos grid SST with values from first stage regrid
       DO J=jLoSrcC,jHiSrcC
        DO I=iLoSrcC,iHiSrcC
         sst_ocn_dptr(I,J) = sst_ocn_dtmp1(I,J)
        ENDDO
       ENDDO
       DO J=jLoTrgC,jHiTrgC
        DO I=iLoTrgC,iHiTrgC
         IF ( sst_atm_dtmp1(I,J) .EQ. 0. ) THEN
          sst_atm_dptr(I,J) = 0.
         ENDIF
        ENDDO
       ENDDO
!      We're done - write out the fields to see what we have created
       CALL FIELD_WRITE( sst_atm_fSpec, cSpec, 1 )
       
       DEALLOCATE(sst_ocn_dtmp1)
       DEALLOCATE(sst_ocn_dtmp2)
       DEALLOCATE(sst_atm_dtmp1)
       DEALLOCATE(sst_atm_dtmp2)
      ENDIF
      WRITE (0,*) ' CPL 1 MAX SST ', maxval(sst_ocn_dptr(iLoSrcC:iHiSrcC,jLoSrcC:jHiSrcC))
      WRITE (0,*) ' CPL 1 MIN SST ', minval(sst_ocn_dptr(iLoSrcC:iHiSrcC,jLoSrcC:jHiSrcC))
      WRITE (0,*) ' CPL 2 MAX SST ', maxval(sst_atm_dptr(iLoTrgC:iHiTrgC,jLoTrgC:jHiTrgC))
      WRITE (0,*) ' CPL 2 MIN SST ', minval(sst_atm_dptr(iLoTrgC:iHiTrgC,jLoTrgC:jHiTrgC))
      RETURN
      END SUBROUTINE
      END MODULE
