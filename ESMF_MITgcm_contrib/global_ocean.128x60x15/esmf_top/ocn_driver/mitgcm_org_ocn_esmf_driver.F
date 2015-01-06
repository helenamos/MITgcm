! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/ocn_driver/mitgcm_org_ocn_esmf_driver.F,v 1.3 2005/05/12 03:00:39 cnh Exp $
! $Name:  $
      MODULE MITGCM_ORG_OCN_ESMF_DRIVER

      USE ESMF_MOD
      USE MITGCM_ORG_ESMF_UTILS
      USE MITGCM_ORG_OCN_ESMF_IMPORTS
      USE MITGCM_ORG_OCN_ESMF_EXPORTS

      USE MITGCM_ORG_OCN, ONLY: OCN_INIT => DRIVER_INIT
      USE MITGCM_ORG_OCN, ONLY: OCN_RUN  => DRIVER_RUN
      USE MITGCM_ORG_OCN, ONLY: OCN_SIZE => GET_DOMAIN_SIZE

      IMPLICIT NONE

      PRIVATE
      PUBLIC ESMF_SET_SERVICES

      CONTAINS

      SUBROUTINE ESMF_SET_SERVICES( gC, esmfRC )
!     == Routine arguments ==
      TYPE(ESMF_GridComp) :: gC
      INTEGER             :: esmfRC

!     Register init handler
      CALL ESMF_GridCompSetEntryPoint( gC, ESMF_SETINIT,
     &            driver_init, ESMF_SINGLEPHASE, esmfRC )

!     Register run handler
      CALL ESMF_GridCompSetEntryPoint( gC, ESMF_SETRUN,
     &            driver_run, ESMF_SINGLEPHASE, esmfRC )

      RETURN
      END SUBROUTINE

      SUBROUTINE DRIVER_INIT( gC, iState, eState, clock, esmfRC )

!     == Global variables ==

!     == Routine arguments ==
      TYPE(ESMF_GridComp) :: gC
      TYPE(ESMF_State)    :: iState
      TYPE(ESMF_State)    :: eState
      TYPE(ESMF_Clock)    :: clock
      INTEGER             :: esmfRC

!     == Local variables ==
!     nx, ny, nr          ## Component index space extents
      INTEGER             :: nx, ny, nr, OL

!     Query component for its size
      CALL OCN_SIZE( nx, ny, nr, OL )

!     Create and attach the fields to the import and export states
      CALL OCN_MAKE_IMPEXP_FIELDS( gC, iState, eState,
     &                             nx, ny, OL )

!     Print out summary to make sure we have what we expected
      CALL ESMF_StatePrint( iState, "no-opt", esmfRC )
      CALL ESMF_StatePrint( eState, "no-opt", esmfRC )

!     Now call component internal initialization
      CALL DO_OCN_INIT( iState, eState )

      RETURN
      END SUBROUTINE

      SUBROUTINE DRIVER_RUN(  gC, iState, eState, clock, esmfRC )

!     == Routine arguments ==
      TYPE(ESMF_GridComp) :: gC
      TYPE(ESMF_State)    :: iState
      TYPE(ESMF_State)    :: eState
      TYPE(ESMF_Clock)    :: clock
      INTEGER             :: esmfRC
      REAL(KIND=ESMF_KIND_R8) :: days

!     == Local arguments ==
      TYPE(ESMF_Time)       :: currTime
      INTEGER(ESMF_KIND_I8) :: aCount
!     Variables for creating an array specification

!     Write out the time period we are going to execute
!     CALL ESMF_ClockGet( clock, currTime=currTime, rc=esmfRC )
!     CALL ESMF_ClockGet( clock, advanceCount=aCount, rc=esmfRC )
!     WRITE(0,*) 'OCN run called for period ',aCount,' to ',aCount+1,' days from start.'
      aCount = 1

      CALL DO_OCN_RUN( iState, eState, aCount )

      RETURN
      END SUBROUTINE
      SUBROUTINE OCN_MAKE_IMPEXP_FIELDS( gC, iState, eState, nx, ny, OL )
!     =========================================================
!     = S/R OCN_MAKE_IMPEXP_FIELDS: Creates esmf import and
!     = export fields for an OCN component and attaches them
!     = to the components import and export states.
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_GridComp) :: gC
      TYPE(ESMF_State)    :: iState
      TYPE(ESMF_State)    :: eState
      INTEGER             :: nx
      INTEGER             :: ny
      INTEGER             :: OL

!     == Local variables ==
      TYPE(ESMF_DELayout)  :: cLayout
      INTEGER              :: esmfRC
      INTEGER              :: cMyDEx, cMyDEy, cDEnx, cDEny
      INTEGER              :: gridCount(2)
      REAL(ESMF_KIND_R8)   :: gridLo(2), gridHi(2)
      TYPE(ESMF_Logical)   :: periodic(2)
      INTEGER              :: haloW
      TYPE(ESMF_Grid)      :: gridRef
      TYPE(ESMF_ArraySpec) :: arraySpec
      TYPE(ESMF_Field)     :: fieldRef
      INTEGER              :: I

!     Extract layout information for the component
      CALL ESMF_GridCompGet( gC, layout=cLayout, rc=esmfRC             )
      CALL ESMF_DELayoutGetSize( cLayout, cDEnx, cDEny, esmfRC         )
      CALL ESMF_DELayoutGetDEPosition( cLayout, cMyDEx, cMyDEy, esmfRC )

!     Create the fields for use in import and export state.
!     a) First we need a grid and an array spec, the we can create 
!        fields and put refences to the fields in iState and eState.
!        For MITgcm OCN ESMF driver grid is 2d with same size as OCN 
!        component horizontal extents and doubly periodic. 
!        o grid
      gridCount(1) = nx
      gridCount(2) = ny
      gridLo(1)    =   0.0
      gridLo(2)    = -84.375
      gridHi(1)    = 360.0
      gridHi(2)    =  84.375
!     For now create exchange fields without halo, bcause halo causes problems
!     in regrid for me in E_1_0_5
      haloW        = OL
      haloW        = 0.
      periodic(1)  = ESMF_TRUE
      periodic(2)  = ESMF_FALSE
#ifdef E_1_0_4
      gridRef      = ESMF_GridCreate(2,
     &               counts=gridCount,
     &               min=gridLo,
     &               max=gridHi,
     &               layout=cLayout,
     &               horz_gridtype=ESMF_GridType_XY,
     &               horz_stagger=ESMF_GridStagger_A,
     &               horz_coord_system=ESMF_CoordSystem_Cartesian,
     &               periodic=periodic,
     &               name="ocn horiz grid",
     &               rc=esmfRC)
#endif
#ifdef E_1_0_5
      gridRef      = ESMF_GridCreateLogRectUniform(2,
     &               counts=gridCount,
     &               minGlobalCoordPerDim=gridLo,
     &               maxGlobalCoordPerDim=gridHi,
     &               layout=cLayout,
     &               horzGridKind=ESMF_GridKind_XY,
     &               horzStagger=ESMF_GridStagger_A,
     &               horzCoordSystem=ESMF_CoordSystem_Cartesian,
     &               periodic=periodic,
     &               name="ocn horiz grid",
     &               rc=esmfRC)
#endif
C     gridRef      = ESMF_GridCreate(2,
C    &               counts=gridCount,
C    &               min=gridLo,
C    &               max=gridHi,
C    &               delta1=2.8125,delta2=2.8125,
C    &               layout=cLayout,
C    &               horz_gridtype=ESMF_GridType_XY,
C    &               horz_stagger=ESMF_GridStagger_A,
C    &               horz_coord_system=ESMF_CoordSystem_Cartesian,
C    &               periodic=periodic,
C    &               name="ocn horiz grid",
C    &               dim_names=(/"longitude","latitude "/), 
C    &               dim_units=(/"degrees", "degrees"/),
C    &               rc=esmfRC)
!        o array spec
      CALL ESMF_ArraySpecInit( arraySpec, rank=2, type=ESMF_DATA_REAL,
     &                         kind=ESMF_R8)

!     b) Now create the actual fields
!     o Imports list
!     "atm heatflux"           - W/m^2
!     "atm taux"               - N/m^2
!     "atm tauy"               - N/m^2
!     "atm latent heatflux"    - W/m^2
!     "atm sensible heatflux"  - W/m^2
!     "atm longwave heatflux"  - W/m^2
!     "atm shortwave heatflux" - W/m^2
!     "atm uvelground"         - m/s
!     "atm vvelground"         - m/s
!     "atm fwflux"             - m/s
!     "atm Hatm"               - Pa
      DO I=1,MAX_IMPORTS
#ifdef E_1_0_4
       fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            relloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name=import_names(I),
     &            rc=esmfRC)
#endif
#ifdef E_1_0_5
       fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            horizRelloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name=import_names(I),
     &            rc=esmfRC)
#endif
       CALL ESMF_StateAddData(iState, fieldRef, esmfRC )
      ENDDO
!     o exports list
!     "ocn hocn"           - m (0 at seasurface, +ve upward)
!     "ocn sstocn"         - oC
      DO I=1,MAX_EXPORTS
#ifdef E_1_0_4
       fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            relloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name=export_names(I),
     &            rc=esmfRC)
#endif
#ifdef E_1_0_5
       fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            horizRelloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name=export_names(I),
     &            rc=esmfRC)
#endif
       CALL ESMF_StateAddData(eState, fieldRef, esmfRC )
      ENDDO

      RETURN
      END SUBROUTINE
      SUBROUTINE DO_OCN_INIT( iState, eState )
!     =========================================================
!     = S/R DO_OCN_INIT: MITgcm OCN component initliatisation
!     = driver that binds to ESMF import/export state self-describing
!     = argument based inter-component data flow abstraction.
!     = Routine (1.) takes data from ESMF import/export name space
!     = into MITgcm OCN internal data structures at start, (2.)
!     = calls MITgcm OCN internal initialization sequence and (3.)
!     = puts data from MITgcm OCN internal data structures
!     = into ESMF import/export name space prior to return.
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_State)   :: iState
      TYPE(ESMF_State)   :: eState

!     == Local variables ==
      TYPE(ESMF_Field)   :: fieldRef
      TYPE(ESMF_Array)   :: arrayRef
      TYPE(ESMF_AxisIndex), dimension(ESMF_MAXGRIDDIM) :: indexc
      TYPE(ESMF_AxisIndex), dimension(ESMF_MAXGRIDDIM) :: indext
      INTEGER            :: esmfRC

!     Variables for communicating component for boundary state
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_HeatFlux
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_tauX
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_tauY
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qlatent
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qsensible
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qlongwave
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qshortwave
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_uVelGround
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_vVelGround
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_FWFlux
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Hatm
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_Hocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_SSTocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_uVelocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_vVelocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_rVolTop
      INTEGER                             :: compsNx, compsNy
      INTEGER                             :: iHiC, iLoC, jHiC, jLoC
      INTEGER                             :: iHiT, OL, I, J, OLe
      INTEGER                             :: nx, ny, nr
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER :: dataPtr
CcnhStart
      REAL*8  myCurrentTime
      INTEGER myCurrentIter
      INTEGER iLoop
      INTEGER myThid
CcnhEnd

!     Query component for its standard halo size
      CALL OCN_SIZE( nx, ny, nr, OL )

!     Determine size and bounds of work arrays
!     CALL ESMF_StateGetData( eState, export_names(1), fieldRef, esmfRC )
      CALL ESMF_StateGetData( eState, export_names(1), fieldRef, rc=esmfRC )
      CALL ESMF_FieldGetData( fieldRef, arrayRef, esmfRC)
      CALL ESMF_ArrayGetAxisIndex( arrayRef, totalindex=indext,
     &                                        compindex=indexc,
     &                                               rc=esmfRC)
      CALL ESMF_ArrayGetData( arrayRef, dataPtr, ESMF_DATA_REF, esmfRC)
!     Array (j[i]Lo[Hi]C interior bounds, j[i]Lo[Hi]T total bounds)
!     Bounds are indexed from 1 and sub-divided according to DE layout.
!     Index 1 corresponds to edge of overlap/ghost/halo region.
      jLoC = indexc(2)%min
      jHiC = indexc(2)%max
      iLoC = indexc(1)%min
      iHiC = indexc(1)%max
      iHiT = indext(1)%max
      OLe     = iHiT-iHiC
      compsNx = iHiC-iLoC+1
      compsNy = jHiC-jLoC+1
!     Allocate dynamic work arrays 
      ALLOCATE( atm_HeatFlux(      1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_TauX(          1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_TauY(          1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_Qlatent(       1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_Qsensible(     1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_Qlongwave(     1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_Qshortwave(    1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_uVelground(    1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_vVelground(    1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_FWFlux(        1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( atm_Hatm(          1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( ocn_Hocn(          1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( ocn_SSTocn(        1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( ocn_uVelocn(       1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( ocn_vVelocn(       1-OL:compsNx+OL, 1-OL:compsNy+OL) )
      ALLOCATE( ocn_rVolTop(       1-OL:compsNx+OL, 1-OL:compsNy+OL) )
!
!     (2.) Execute MITgcm OCN internal initialization sequence.
!
      CALL OCN_INIT(
     I              atm_HeatFlux, atm_TauX, atm_TauY,
     I              atm_Qlatent, atm_Qsensible, atm_Qlongwave,
     I              atm_Qshortwave,
     I              atm_uVelGround, atm_vVelGround,
     I              atm_FWFlux,
     I              atm_Hatm,
     O              ocn_SSTocn, ocn_Hocn,
     O              ocn_uVelocn, ocn_vVelocn,
     O              ocn_rVolTop
     &             )

!     mitgcm_org_ocn hocn
      CALL STATE_GET_FADP( eState, export_names(1), dataPtr , theFieldRef=fieldRef )
      DO J=1,compsNy
       DO I=1, compsNx
        dataPtr(iLoC+i-1,jLoc+j-1) = ocn_Hocn(i,j)
       ENDDO
      ENDDO
!     CALL ESMF_FieldHalo( fieldRef )
!     mitgcm_org_ocn sstocn  
      CALL STATE_GET_FADP( eState, export_names(2), dataPtr , theFieldRef=fieldRef )
      DO J=1,compsNy
       DO I=1, compsNx
        IF ( ocn_Hocn(i,j) .NE. 0. ) THEN
         dataPtr(iLoC+i-1,jLoc+j-1) = ocn_SSTocn(i,j)
        ELSE
         dataPtr(iLoC+i-1,jLoc+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     mitgcm_org_ocn uVel
      CALL STATE_GET_FADP( eState, export_names(3), dataPtr , theFieldRef=fieldRef )
      DO J=1,compsNy
       DO I=1, compsNx
        IF ( ocn_Hocn(i,j) .NE. 0. ) THEN
         dataPtr(iLoC+i-1,jLoc+j-1) = ocn_uVelocn(i,j)
        ELSE
         dataPtr(iLoC+i-1,jLoc+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     CALL ESMF_FieldHalo( fieldRef )
!     mitgcm_org_ocn vVel
      CALL STATE_GET_FADP( eState, export_names(4), dataPtr , theFieldRef=fieldRef )
      DO J=1,compsNy
       DO I=1, compsNx
        IF ( ocn_Hocn(i,j) .NE. 0. ) THEN
         dataPtr(iLoC+i-1,jLoc+j-1) = ocn_vVelocn(i,j)
        ELSE
         dataPtr(iLoC+i-1,jLoc+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     CALL ESMF_FieldHalo( fieldRef )
!     mitgcm_org_ocn recip_rVol
      CALL STATE_GET_FADP( eState, export_names(5), dataPtr , theFieldRef=fieldRef )
      DO J=1,compsNy
       DO I=1, compsNx
        IF ( ocn_Hocn(i,j) .NE. 0. ) THEN
         dataPtr(iLoC+i-1,jLoc+j-1) = ocn_rVolTop(i,j)
        ELSE
         dataPtr(iLoC+i-1,jLoc+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO

!     CALL ESMF_FieldHalo( fieldRef )
      WRITE(0,*) ' MAX 1 HOCN == ', maxval(ocn_Hocn(1:compsNx,1:compsNy))
      WRITE(0,*) ' MIN 1 HOCN == ', minval(ocn_Hocn(1:compsNx,1:compsNy))
      WRITE(0,*) ' MAX 1 SST  == ', maxval(ocn_SSTocn(1:compsNx,1:compsNy))
      WRITE(0,*) ' MIN 1 SST  == ', minval(ocn_SSTocn(1:compsNx,1:compsNy))

!     Clean up temporaries
      DEALLOCATE( atm_HeatFlux   )
      DEALLOCATE( atm_TauX       )
      DEALLOCATE( atm_TauY       )
      DEALLOCATE( atm_Qlatent    )
      DEALLOCATE( atm_Qsensible  )
      DEALLOCATE( atm_Qlongwave  )
      DEALLOCATE( atm_Qshortwave )
      DEALLOCATE( atm_uVelground )
      DEALLOCATE( atm_vVelground )
      DEALLOCATE( atm_FWFlux     )
      DEALLOCATE( atm_Hatm       )
      DEALLOCATE( ocn_SSTocn     )
      DEALLOCATE( ocn_Hocn       )
      DEALLOCATE( ocn_uVelocn     )
      DEALLOCATE( ocn_vVelocn     )
      DEALLOCATE( ocn_rVolTop    )

      RETURN
      END SUBROUTINE
      SUBROUTINE DO_OCN_RUN(  iState, eState, aCount )
!     =========================================================
!     = S/R DO_OCN_RUN: MITgcm OCN component runstep execution
!     = driver that binds to ESMF import/export state self-describing
!     = argument based inter-component data flow abstraction.
!     = Routine (1.) takes data from ESMF import/export name space
!     = into MITgcm OCN internal data structures at start, (2.)
!     = calls MITgcm OCN internal run step sequence and (3.)
!     = puts data from MITgcm OCN internal data structures
!     = into ESMF import/export name space prior to return.
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_State)      :: iState
      TYPE(ESMF_State)      :: eState
      INTEGER(ESMF_KIND_I8) :: aCount

!     == Local variables ==
      TYPE(FIARDA)       :: fS
!     Variables for communicating component for boundary state
!     data in MITgcm OCN import state
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_HeatFlux
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_tauX
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_tauY
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qlatent
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qsensible
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qlongwave
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Qshortwave
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_uVelGround
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_vVelGround
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_FWFlux
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: atm_Hatm
!     data in MITgcm OCN export state
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_Hocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_SSTocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_uVelocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_vVelocn
      REAL*8, DIMENSION(:,:), ALLOCATABLE :: ocn_rVolTop
!     data pointer used in extract data from ESMF state objects
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER :: dP
      INTEGER :: OLe, cNx, cNy, I, J
      INTEGER :: OL, nx, ny, nr, OLs
      TYPE(ESMF_Field)                    :: fieldRef
      INTEGER :: esmfRC
      INTEGER :: startStep, stopStep

CcnhStart
      INTEGER :: myThid 
      INTEGER :: myCurrentIter
      REAL*8  :: myCurrentTime
      INTEGER :: nTimeSteps
      INTEGER :: iLoop
CcnhStop

!     Query component for its standard halo size
      CALL OCN_SIZE( nx, ny, nr, OL )
!
!     Determine size and bounds of work arrays
      CALL STATE_GET_FADP( iState, import_names(1), dP, fSpec=fS )
!     Allocate dynamic work arrays
      OLe = fS%hW
      cNx = fS%nI(1)
      cNy = fS%nI(2)
      ALLOCATE( atm_HeatFlux(      1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_TauX(          1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_TauY(          1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_Qlatent(       1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_Qsensible(     1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_Qlongwave(     1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_Qshortwave(    1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_uVelground(    1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_vVelground(    1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_FWFlux(        1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( atm_Hatm(          1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( ocn_Hocn(          1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( ocn_SSTocn(        1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( ocn_uVelocn(       1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( ocn_vVelocn(       1-OL:cNx+OL, 1-OL:cNy+OL) )
      ALLOCATE( ocn_rVolTop(       1-OL:cNx+OL, 1-OL:cNy+OL) )

!     (2.) Extract import state (including overlap region)
      OLs = min(OL,OLe)
      CALL STATE_GET_FADP( iState, import_names( 1), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNy+OLs
        atm_HeatFlux(i,j) = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 2), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_TauX(i,j) = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 3), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_TauY(i,j)      = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 4), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_Qlatent(i,j)   = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 5), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_Qsensible(i,j)  = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 6), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_Qlongwave(i,j)  = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 7), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_Qshortwave(i,j) = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 8), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_uVelGround(i,j) = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names( 9), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_vVelGround(i,j) = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
      CALL STATE_GET_FADP( iState, import_names(10), dP , theFieldRef=fieldRef )
      DO J=1-OLs,cNy+OLs
       DO I=1-OLs, cNx+OLs
        atm_FWFlux(i,j)     = dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1)
       ENDDO
      ENDDO
!
!     (3.) Execute MITgcm OCN internal runstep execution sequence.
!
      startStep = aCount
      stopStep  = aCount+1
      myThid    = 1
      myCurrentTime = 0.
      myCurrentIter = 0
      CALL OCN_RUN(
     I              atm_HeatFlux, atm_TauX, atm_TauY,
     I              atm_Qlatent, atm_Qsensible, atm_Qlongwave,
     I              atm_Qshortwave,
     I              atm_uVelGround, atm_vVelGround,
     I              atm_FWFlux,
     I              atm_Hatm,   
     O              ocn_SSTocn,
     O              ocn_Hocn,  
     O              ocn_uVelocn,
     O              ocn_vVelocn,
     O              ocn_rVolTop,
     I              myCurrentTime, myCurrentIter,
     U              startStep,
     I              1, myThid)

!     (4.) Update export state (filling in export state halo regions update)
!     mitgcm_org_ocn SSTocn
      CALL STATE_GET_FADP( eState, export_names( 2), dP , theFieldRef=fieldRef )
      dP = 0.
      DO J=1,cNy
       DO I=1, cNx
        IF ( ocn_Hocn(i,j) .NE. 0.) THEN
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = ocn_SSTocn(i,j)
        ELSE
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
      WRITE(0,*) ' RUN 1 MAX SST == ', maxval(ocn_SSTocn)
      WRITE(0,*) ' RUN 1 MIN SST == ', minval(ocn_SSTocn)
      WRITE(0,*) ' RUN 2 MAX SST == ', maxval(dP)
      WRITE(0,*) ' RUN 2 MIN SST == ', minval(dP)
!     CALL ESMF_FieldHalo( fieldRef )
!     mitgcm_org_ocn Hocn
      CALL STATE_GET_FADP( eState, export_names( 1), dP , theFieldRef=fieldRef )
      dP = 0.
      DO J=1,cNy
       DO I=1, cNx
        IF ( ocn_Hocn(i,j) .NE. 0.) THEN
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = ocn_Hocn(i,j)
        ELSE
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     mitgcm_org_ocn uVelocn
      CALL STATE_GET_FADP( eState, export_names( 3), dP , theFieldRef=fieldRef )
      dP = 0.
      DO J=1,cNy
       DO I=1, cNx
        IF ( ocn_Hocn(i,j) .NE. 0.) THEN
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = ocn_uVelocn(i,j)
        ELSE
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     mitgcm_org_ocn vVelocn
      CALL STATE_GET_FADP( eState, export_names( 4), dP , theFieldRef=fieldRef )
      dP = 0.
      DO J=1,cNy
       DO I=1, cNx
        IF ( ocn_Hocn(i,j) .NE. 0.) THEN
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = ocn_vVelocn(i,j)
        ELSE
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO
!     mitgcm_org_ocn rVolTop
      CALL STATE_GET_FADP( eState, export_names( 5), dP , theFieldRef=fieldRef )
      dP = 0.
      DO J=1,cNy
       DO I=1, cNx
        IF ( ocn_Hocn(i,j) .NE. 0.) THEN
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = ocn_rVolTop(i,j)
        ELSE
         dP(fS%LoC(1)+i-1,fS%LoC(2)+j-1) = 0.
        ENDIF
       ENDDO
      ENDDO

!     Clean up temporaries
      DEALLOCATE( atm_HeatFlux   )
      DEALLOCATE( atm_TauX       )
      DEALLOCATE( atm_TauY       )
      DEALLOCATE( atm_Qlatent    )
      DEALLOCATE( atm_Qsensible  )
      DEALLOCATE( atm_Qlongwave  )
      DEALLOCATE( atm_Qshortwave )
      DEALLOCATE( atm_uVelground )
      DEALLOCATE( atm_vVelground )
      DEALLOCATE( atm_FWFlux     )
      DEALLOCATE( atm_Hatm       )
      DEALLOCATE( ocn_SSTocn     )
      DEALLOCATE( ocn_Hocn       )
      DEALLOCATE( ocn_uVelocn    )
      DEALLOCATE( ocn_vVelocn    )
      DEALLOCATE( ocn_rVolTop    )

      RETURN
      END SUBROUTINE
      END MODULE
