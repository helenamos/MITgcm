! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/cam_stub/cam_stub_esmf_driver.F,v 1.1 2004/03/30 03:58:59 cnh Exp $
! $Name:  $
      MODULE CAM_STUB_ESMF_DRIVER
!
!     Light weight component to use in place of NCAR CAM. For use in testing
!     aspects of coupling between MITgcm and CAM. This stub component is currently
!     just a consumer of the MITgcm export state that has been written mainly
!     to help validate the regridding and redistribution stages.
!

      USE ESMF_MOD

!     Its OK to use the module "MITGCM_ORG_ESMF_UTILS" because it is not 
!     specific to any component. Its just some useful ESMF convenience
!     functions.
      USE MITGCM_ORG_ESMF_UTILS

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
!     nx, ny              ## Component index space extents
      INTEGER             :: nx, ny, OL

!     Hard code these for now
      nx = 180
      ny =  90
!     Use zero halo because regrid likes that
      OL =   0

!     Create and attach the fields to the import and export states
      CALL MAKE_IMPEXP_FIELDS( gC, iState, eState,
     &                         nx, ny, OL )

!     Print out summary to make sure we have what we expected
      CALL ESMF_StatePrint( iState, "no-opt", esmfRC )
      CALL ESMF_StatePrint( eState, "no-opt", esmfRC )

      RETURN
      END SUBROUTINE

      SUBROUTINE DRIVER_RUN(  gC, iState, eState, clock, esmfRC )

!     == Routine arguments ==
      TYPE(ESMF_GridComp) :: gC
      TYPE(ESMF_State)    :: iState
      TYPE(ESMF_State)    :: eState
      TYPE(ESMF_Clock)    :: clock
      INTEGER             :: esmfRC

!     == Local variables ==
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER :: sstPtr
      TYPE(FIARDA)    :: sst_atm_fSpec

      CALL State_Get_FADP(iState,"CAM_stub sst", sstPtr,
     &                       fSpec=sst_atm_fSpec)
      WRITE(0,*) ' MAXVAL sstPtr ',MAXVAL(sstPtr)

      RETURN
      END SUBROUTINE
      SUBROUTINE MAKE_IMPEXP_FIELDS( gC, iState, eState, nx, ny, OL )
!     =========================================================
!     = S/R MAKE_IMPEXP_FIELDS: Creates esmf import and
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
      gridLo(2)    = -90.0
      gridHi(1)    = 360.0
      gridHi(2)    =  90.0
      haloW        = OL
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
     &               horzgridkind=ESMF_GridKind_XY,
     &               horzstagger=ESMF_GridStagger_A,
     &               horzcoordsystem=ESMF_CoordSystem_Cartesian,
     &               periodic=periodic,
     &               name="ocn horiz grid",
     &               rc=esmfRC)
#endif
!        o array spec
      CALL ESMF_ArraySpecInit( arraySpec, rank=2, type=ESMF_DATA_REAL,
     &                         kind=ESMF_R8)

!     b) Now create the actual fields
!     o Imports list
!     "CAM stub sst"               - oC
#ifdef E_1_0_4
      fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &           relloc=ESMF_CELL_CENTER,
     &           haloWidth=haloW,
     &           name="CAM_stub sst",
     &           rc=esmfRC)
#endif
#ifdef E_1_0_5
      fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &           horizrelloc=ESMF_CELL_CENTER,
     &           haloWidth=haloW,
     &           name="CAM_stub sst",
     &           rc=esmfRC)
#endif
      CALL ESMF_StateAddData(iState, fieldRef, esmfRC )
!     o exports list
!     "CAM_stub Hetaflux"  - W/m^2
#ifdef E_1_0_4
      fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            relloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name="CAM_stub Hetaflux",
     &            rc=esmfRC)
#endif
#ifdef E_1_0_5
      fieldRef = ESMF_FieldCreate( gridRef, arraySpec,
     &            horizrelloc=ESMF_CELL_CENTER,
     &            haloWidth=haloW,
     &            name="CAM_stub Hetaflux",
     &            rc=esmfRC)
#endif
      CALL ESMF_StateAddData(eState, fieldRef, esmfRC )

      RETURN
      END SUBROUTINE
      END MODULE
