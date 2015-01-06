! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/utils/mitgcm_org_esmf_utils.F,v 1.1 2004/03/30 03:59:02 cnh Exp $
! $Name:  $
! Useful utilities for interfacing to ESMF
      MODULE MITGCM_ORG_ESMF_UTILS

      USE ESMF_MOD
      IMPLICIT NONE
      PUBLIC

!     TYPE FIARDA ::
!     Create a useful type for communicating collected information about a field's 
!     grid, array, data composite.
!     fRef      -- Reference to the field
!     gRef      -- Reference to the grid contained in the field
!     aRef      -- Reference to the array contained in the field
!     dPR8      -- Pointer to the data in the array (for now we assume R8 here but
!               -- we could extend to carry pointers to other types)
!     nDims     -- No. of dimensions for the index space
!     LoC,HiC   -- Lower and upper bounds of the interior domain (compute domain).
!     LoT,HiT   -- Lower and upper bounds of the full domain (data domain).
!     LoCG,HiCG -- Lower and upper bounds of the interior domain in global index space.
!     hW        -- Halo width
      TYPE FIARDA
       TYPE(ESMF_Field)           :: fRef
       TYPE(ESMF_Grid)            :: gRef
       CHARACTER(LEN=ESMF_MAXSTR) :: fNam
       TYPE(ESMF_Array)           :: aRef
       CHARACTER(LEN=ESMF_MAXSTR) :: aNam
       INTEGER                    :: nDims
       INTEGER                    :: LoC(ESMF_MAXGRIDDIM)
       INTEGER                    :: HiC(ESMF_MAXGRIDDIM)
       INTEGER                    :: LoT(ESMF_MAXGRIDDIM)
       INTEGER                    :: HiT(ESMF_MAXGRIDDIM)
       INTEGER                    :: LoCG(ESMF_MAXGRIDDIM)
       INTEGER                    :: HiCG(ESMF_MAXGRIDDIM)
       INTEGER                    :: nI( ESMF_MAXGRIDDIM)
       INTEGER                    :: hW
       REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER :: dPR8
      END TYPE FIARDA

!     Collective information structure for component attributes
      TYPE GCINFO
       TYPE(ESMF_GridComp)        :: cRef
       CHARACTER(LEN=ESMF_MAXSTR) :: cNam
       TYPE(ESMF_DELayout)        :: cLayout
       INTEGER                    :: cLx
       INTEGER                    :: cLy
       INTEGER                    :: cMyDEx
       INTEGER                    :: cMyDEy
       INTEGER                    :: cType
      END TYPE GCINFO
      TYPE CCINFO
       TYPE(ESMF_CplComp)         :: cRef
       CHARACTER(LEN=ESMF_MAXSTR) :: cNam
       TYPE(ESMF_DELayout)        :: cLayout
       INTEGER                    :: cLx
       INTEGER                    :: cLy
       INTEGER                    :: cMyDEx
       INTEGER                    :: cMyDEy
       INTEGER                    :: cType
      END TYPE CCINFO
      TYPE CINFO
       INTEGER      :: cType
       TYPE(GCINFO) :: gcInfo
       TYPE(CCINFO) :: ccInfo
      END TYPE CINFO
      INTEGER  :: gcType=1
      INTEGER  :: ccType=2
     
      CONTAINS
      SUBROUTINE STATE_GET_FADP( theState, 
     &                           theFieldName, 
     &                           thePtr, 
     &                           theFieldRef,
     &                           fSpec )
!     =========================================================
!     = S/R STATE_GET_FADP: Get the data pointer for an array 
!     = within a field within a state. Optionally fills and 
!     = returns a structure (arg fSpec) containing information 
!     = about the field and the data it contains (bounds, 
!     = strides, grid etc..).
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_State)                                 :: theState
      CHARACTER*(*)                                    :: theFieldName
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), POINTER :: thePtr
      TYPE(ESMF_FIELD), OPTIONAL                       :: theFieldRef
      TYPE(FIARDA), OPTIONAL                           :: fSpec

!     == Local variables ==
      INTEGER                                          :: esmfRC
      TYPE(ESMF_Grid)                                  :: gridRef
      TYPE(ESMF_Field)                                 :: fieldRef
      TYPE(ESMF_Array)                                 :: arrayRef
      TYPE(ESMF_AxisIndex), dimension(ESMF_MAXGRIDDIM) :: indexc
      TYPE(ESMF_AxisIndex), dimension(ESMF_MAXGRIDDIM) :: indext
      INTEGER                    :: laxis( ESMF_MAXGRIDDIM)
      INTEGER                    :: gaxis( ESMF_MAXGRIDDIM)
      INTEGER                    :: myDE
      INTEGER                    :: gbase( ESMF_MAXGRIDDIM, ESMF_MAXGRIDDIM)
      INTEGER(ESMF_KIND_I4)      :: lTopCoord(2,1)
      INTEGER(ESMF_KIND_I4)      :: gTopCoord(2,1)
      TYPE(ESMF_AxisIndex), dimension(ESMF_MAXGRIDDIM) :: indexg

!     Default behavoir is to get the data pointer for the field
      CALL ESMF_StateGetData( theState, theFieldName, 
     &                        fieldRef, rc=esmfRC )
      CALL ESMF_FieldGetData( fieldRef, arrayRef, esmfRC )
      CALL ESMF_ArrayGetData( arrayRef, thePtr, ESMF_DATA_REF, esmfRC )

!     Optionally return field reference
      IF ( PRESENT(theFieldRef) ) THEN
       theFieldRef = fieldRef
      ENDIF

!     Optionally return the spec field
!     This is the most useful option and is a superset of the
!     other options.
      IF ( PRESENT(fSpec) ) THEN
       fSpec%fRef = fieldRef
       CALL ESMF_FieldGetData( fSpec%fRef,
     O                     array=fspec%aRef,
     O                        rc=esmfRC )
       CALL ESMF_FieldGetName( fSpec%fRef,
     O                      name=fspec%fNam,
     O                        rc=esmfRC )
       CALL ESMF_ArrayGetAxisIndex( fspec%aRef,
     O                               compindex=indexc,
     O                              totalindex=indext,
     O                                      rc=esmfRC)
       CALL ESMF_ArrayGetData( fspec%aRef,
     O                         fspec%dPR8,
     I                         ESMF_DATA_REF,
     O                         esmfRC )
       fSpec%nDims  = 2
!      Interior domain extents
       fSpec%LoC(1) = indexc(1)%min
       fSpec%LoC(2) = indexc(2)%min
       fSpec%HiC(1) = indexc(1)%max
       fSpec%HiC(2) = indexc(2)%max
!      Total domain extents
       fSpec%LoT(1) = indext(1)%min
       fSpec%LoT(2) = indext(2)%min
       fSpec%HiT(1) = indext(1)%max
       fSpec%HiT(2) = indext(2)%max
!      Inferred halo width and tile interior size
       fSpec%hW     = fSpec%HiT(1) - fSpec%HiC(1)
       fSpec%nI(1)  = fSpec%HiC(1) - fSpec%LoC(1)+1
       fSpec%nI(2)  = fSpec%HiC(2) - fSpec%LoC(2)+1
       CALL ESMF_FieldGetGrid(fSpec%fRef, 
     O                        grid=fSpec%gRef, 
     O                        rc=esmfRC)
       indexg(1)%min = 1
       indexg(1)%max = 1
       indexg(2)%min = 1
       indexg(2)%max = 1
#ifdef E_1_0_4
       CALL ESMF_GridGetDE(fSpec%gRef,
     O                     myDE=myDE,
     O                     ai_global=indexg,
     O                     rc=esmfRC)
#endif
#ifdef E_1_0_5
       CALL ESMF_GridGetDE(fSpec%gRef,
     O                     globalAIPerDim=indexg,
     O                     rc=esmfRC)
#endif
       fSpec%LoCG(1) = indexg(1)%min
       fSpec%HiCG(1) = indexg(1)%max
       fSpec%LoCG(2) = indexg(2)%min
       fSpec%HiCG(2) = indexg(2)%max
      ENDIF

      RETURN
      END SUBROUTINE
      SUBROUTINE GCOMP_GET_INFO( theGC,
     &                           gcInf )
      
!     =========================================================
!     = S/R GCOMP_GET_INFO: Get information about a gridded 
!     = component.
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_GridComp)  ::  theGC
      TYPE(GCINFO)         ::  gcInf

!     == Local variables ==
      INTEGER                    :: esmfRC
      TYPE(ESMF_DELayout)        :: theLayout
      INTEGER                    :: lNx, lNy, myDEx, myDEy
      CHARACTER(LEN=ESMF_MAXSTR) :: cName

      CALL ESMF_GridCompGet( theGC, layout=theLayout, rc=esmfRC )
      CALL ESMF_GridCompGet( theGC, name=cName,       rc=esmfRC )
      CALL ESMF_DELayoutGetSize( theLayout, lNx, lNy, rc=esmfRC )
      CALL ESMF_DELayoutGetDEPosition( theLayout, myDEx, myDEy, rc=esmfRC )

      gcInf%cLayout = theLayout
      gcInf%cNam    = cName
      gcInf%cLx     = lNx
      gcInf%cLy     = lNy
      gcInf%cMyDEx  = myDEx
      gcInf%cMyDEy  = myDEy
      gcInf%cType   = gcType

      RETURN
      END SUBROUTINE
      SUBROUTINE CCOMP_GET_INFO( theCC, 
     &                           ccInf )
!     =========================================================
!     = S/R CCOMP_GET_INFO: Get information about a gridded
!     = component.
!     =========================================================

!     == Routine arguments ==
      TYPE(ESMF_CplComp)   ::  theCC
      TYPE(CCINFO)         ::  ccInf

!     == Local variables ==
      INTEGER              :: esmfRC
      TYPE(ESMF_DELayout)  :: theLayout
      INTEGER              :: lNx, lNy, myDEx, myDEy
      CHARACTER(LEN=ESMF_MAXSTR) :: cName

      CALL ESMF_CplCompGet(    theCC, layout=theLayout,         rc=esmfRC )
      CALL ESMF_CplCompGet(    theCC, name=cName,               rc=esmfRC )
      CALL ESMF_DELayoutGetSize( theLayout, lNx, lNy,           rc=esmfRC )
      CALL ESMF_DELayoutGetDEPosition( theLayout, myDEx, myDEy, rc=esmfRC )

      ccInf%cLayout = theLayout
      ccInf%cNam    = cName
      ccInf%cLx     = lNx
      ccInf%cLy     = lNy
      ccInf%cMyDEx  = myDEx
      ccInf%cMyDEy  = myDEy
      ccInf%cType   = ccType

      RETURN
      END SUBROUTINE
      SUBROUTINE FIELD_WRITE( fSpec, cSpec, iter )
!
!     Write a fields interior values to a file named according to the
!     field name and the component layout location and a iteration stamp.
!     File name is formatted
!     C.F.DEX.DEY.ITER.data
!

!     == Routine arguments ==
      TYPE(FIARDA) fSpec
      TYPE(CINFO ) cSpec
      INTEGER      iter

!     == Local variables ==
      INTEGER                     :: fid
      INTEGER                     :: iLo, iHi
      CHARACTER(LEN=ESMF_MAXSTR)  :: namPart
      CHARACTER(LEN=ESMF_MAXSTR)  :: fNam
      INTEGER                     :: DEx, DEy
      INTEGER                     :: I, J, iLoA, iHiA, jLoA, jHiA
      REAL(KIND=ESMF_KIND_R8), DIMENSION(:,:), ALLOCATABLE :: tmpArr

      fid=32
      iLo=1
      namPart = 'NONAME'
      IF     ( cSpec%cType .EQ. gcType ) THEN
        WRITE(namPart,'(A)') TRIM(cSpec%gcInfo%cNam)
        WRITE(0,*) ' comp name = ',TRIM(cSpec%gcInfo%cNam)
        DEx = cSpec%gcInfo%cMyDEx
        DEy = cSpec%gcInfo%cMyDEy
      ELSEIF ( cSpec%cType .EQ. ccType ) THEN
        WRITE(namPart,'(A)') TRIM(cSpec%ccInfo%cNam)
        WRITE(0,*) ' comp name = ',TRIM(cSpec%ccInfo%cNam)
        DEx = cSpec%ccInfo%cMyDEx
        DEy = cSpec%ccInfo%cMyDEy
      ENDIF
      fNam  = TRIM(namPart)
      iLo   = LEN_TRIM(fNam)+1
      WRITE(fNam(iLo:),'(A,A)') '.',TRIM(fSpec%fNam)
      WRITE(0,*) ' field name = ',TRIM(fSpec%fNam)
      iLo   = LEN_TRIM(fNam)+1
      WRITE(fNam(iLo:),'(A,I6.6)') '.',DEx
      iLo   = LEN_TRIM(fNam)+1
      WRITE(fNam(iLo:),'(A,I6.6)') '.',DEy
      iLo   = LEN_TRIM(fNam)+1
      WRITE(fNam(iLo:),'(A,I6.6)') '.',iter

      iLo   = LEN_TRIM(fNam)+1
      WRITE(fNam(iLo:),'(A,A)') '.','bin'

      fNam = TRIM(fNam)
      DO I=1,LEN_TRIM(fNam)
       IF (fNam(I:I) .EQ. ' ' ) fNam(I:I) = '-'
      ENDDO

!     Write data
      iLoA = fSpec%LoC(1)
      iHiA = fSpec%HiC(1)
      jLoA = fSpec%LoC(2)
      jHiA = fSpec%HiC(2)
      ALLOCATE( tmpArr(iHiA-iLoA+1,jHiA-jLoA+1) )
      DO J=jLoA,jHiA
       DO I=iLoA,iHiA
        tmpArr(I-iLoA+1,J-jLoA+1)=fSpec%dpR8(I,J)
       ENDDO
      ENDDO

      OPEN(fid,file=TRIM(fNam),status='UNKNOWN',form='UNFORMATTED',
     &     ACCESS='DIRECT',RECL=SIZE(tmpArr)*8)
      WRITE(fid,REC=1) tmpArr
      CLOSE(fid)
      DEALLOCATE( tmpArr )

!     Write meta
      iLo = LEN_TRIM(fNam)-3
      WRITE(fNam(iLo:),'(A,A)') '.','m'
      fNam = TRIM(fNam)
      OPEN(fid,file=TRIM(fNam),status='UNKNOWN')
       WRITE(fid,'(A)' )    '%CNH_MYMETA_1.0'
       WRITE(fid,'(A)' )    '% File name'
       WRITE(fid,'(A,A,A,A,A)' )  'file=','''',TRIM(fNam),'''',';'
       WRITE(fid,'(A)' )    '% Index range within on DE field'
       WRITE(fid,'(A,I6,A)' ) 'iLoC =',iLoA,';'
       WRITE(fid,'(A,I6,A)' ) 'iHiC =',iHiA,';'
       WRITE(fid,'(A,I6,A)' ) 'jLoC =',jLoA,';'
       WRITE(fid,'(A,I6,A)' ) 'jHiC =',jHiA,';'
       iLoA = fSpec%LoCG(1)
       iHiA = fSpec%HiCG(1)
       jLoA = fSpec%LoCG(2)
       jHiA = fSpec%HiCG(2)
       WRITE(fid,'(A)' )    '% Global index range'
       WRITE(fid,'(A,I6,A)' ) 'iLoC_G =',iLoA,';'
       WRITE(fid,'(A,I6,A)' ) 'iHiC_G =',iHiA,';'
       WRITE(fid,'(A,I6,A)' ) 'jLoC_G =',jLoA,';'
       WRITE(fid,'(A,I6,A)' ) 'jHiC_G =',jHiA,';'

      CLOSE(fid)
      

      RETURN
      END SUBROUTINE
      END MODULE
