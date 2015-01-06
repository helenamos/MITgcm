C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/cam_stub-mitgcm_ocn_app/main.F,v 1.1 2004/03/30 03:59:00 cnh Exp $
C $Name:  $

C     Stand alone driver for ocean only MITgcm confioguration that can be driven
C     from ESMF composition layer.

      PROGRAM MAIN

C     ESMF base library
      USE ESMF_MOD

C     Used for execution through standard ESMF component interfaces
C     Routine "ESMF_SET_SERVICES" in module "MITGCM_ORG_OCN_ESMF_DRIVER" provides
C     the directly visible call from which all other "MITGCM_ORG_OCN" component
C     interfaces are registered.
      USE MITGCM_ORG_OCN_ESMF_DRIVER, ONLY: OCN4ESMF_SETSERVICES    => ESMF_SET_SERVICES
      USE CAM_STUB_ESMF_DRIVER,       ONLY: ATM4ESMF_SETSERVICES    => ESMF_SET_SERVICES
      USE MITGCM_ORG_OCN_2_FVCAM,     ONLY: OCN2ATMESMF_SETSERVICES => ESMF_SET_SERVICES

      IMPLICIT NONE

C !DESCRIPTION:
C     *==========================================================*
C     | PROGRAM MAIN                                            
C     | o ESMF driver for single component MITgcm UV driver.
C     *==========================================================*

C     ocnStartStep, ocnStopStep :: These provide start and stop steps for each 
C                               :: run cycle of the ocean component.
C     esmfRC                    :: Return code for ESMF functions.
C     I,J,K                     :: Loop counters
      INTEGER ocnStartStep, ocnStopStep
      INTEGER esmfRC
      INTEGER I, J, K

C     ESMF variables
C     o top (app driver)
      TYPE(ESMF_DELayout)     :: topLayout
      INTEGER                 :: totalDECount
      TYPE(ESMF_Clock)        :: topClock
      TYPE(ESMF_Time)         :: topStart, topStop
      TYPE(ESMF_TimeInterval) :: timeStep
      TYPE(ESMF_Calendar)     :: ESMF_360DayCalendar
C     o ocn (gridded)
      INTEGER, DIMENSION(:), ALLOCATABLE :: ocnDEList
      INTEGER                        :: ocnDECount, ocnDEBase
      TYPE(ESMF_DELayout)            :: ocnLayout
      TYPE(ESMF_GridComp)            :: ocnComp
      TYPE(ESMF_State)               :: ocnImport
      TYPE(ESMF_State)               :: ocnExport
C     o atm (gridded)
      INTEGER, DIMENSION(:), ALLOCATABLE :: atmDEList
      INTEGER                        :: atmDECount, atmDEBase
      TYPE(ESMF_DELayout)            :: atmLayout
      TYPE(ESMF_GridComp)            :: atmComp
      TYPE(ESMF_State)               :: atmImport
      TYPE(ESMF_State)               :: atmExport
C     o ocn2atm (coupler)
      INTEGER, DIMENSION(:), ALLOCATABLE :: ocn2atmDEList
      INTEGER                        :: ocn2atmDECount, ocn2atmDEBase
      TYPE(ESMF_DELayout)            :: ocn2atmLayout
      TYPE(ESMF_CplComp)             :: ocn2atmComp
      TYPE(ESMF_State)               :: ocn2atmImport
      TYPE(ESMF_State)               :: ocn2atmExport
C     o Loop counter for stepping forward
      INTEGER :: iCpl

C     OK - first boot up ESMF
      CALL ESMF_Initialize(esmfRC)

C     Create the top layout and get total number of DEs
C     DEs are the independent streams of execution over which computation
C     is spread and between which communication is required.
      topLayout = ESMF_DELayoutCreate(rc=esmfRC)
      CALL ESMF_DELayoutGetNumDEs( topLayout, totalDECount, rc=esmfRC )

C     Set component DE counts to use full set.
      ocnDECount     = totalDECount
      ocnDEBase      = 0
      atmDECount     = totalDECount
      atmDEBase      = 0
      ocn2atmDECount = totalDECount
      ocn2atmDEBase  = 0

C     Now create gridded components
C     1. Create DE lists
      ALLOCATE( ocnDEList(ocnDECount) )
      DO I=1,ocnDECount
       ocnDEList(I) = I+ocnDEBase-1
      ENDDO
      ALLOCATE( atmDEList(atmDECount) )
      DO I=1,atmDECount
       atmDEList(I) = I+atmDEBase-1
      ENDDO
      ALLOCATE( ocn2atmDEList(ocn2atmDECount) )
      DO I=1,ocn2atmDECount
       ocn2atmDEList(I) = I+ocn2atmDEBase-1
      ENDDO
C     2. Create layouts using the DE lists
      ocnLayout = ESMF_DELayoutCreate( ocnDEList, 2,
     &            (/ 1, ocnDECount/), (/0, 0/),
     &            rc=esmfRC)
      atmLayout = ESMF_DELayoutCreate( atmDEList, 2,
     &            (/ 1, atmDECount/), (/0, 0/),
     &            rc=esmfRC)
      ocn2atmLayout = ESMF_DELayoutCreate( ocn2atmDEList, 2,
     &            (/ 1, ocn2atmDECount/), (/0, 0/),
     &            rc=esmfRC)
C     3. Create components for ocn, atm, o2a, a2o
      ocnComp     = ESMF_GridCompCreate('ocn Component',layout=ocnLayout,rc=esmfRC)
      atmComp     = ESMF_GridCompCreate('atm Component',layout=atmLayout,rc=esmfRC)
      ocn2atmComp = ESMF_CplCompCreate('ocn2atm Component',layout=ocn2atmLayout,rc=esmfRC)

C     Register service handlers for each component
      CALL ESMF_GridCompSetServices( ocnComp,     ocn4esmf_setservices, esmfRC)
      CALL ESMF_GridCompSetServices( atmComp,     atm4esmf_setservices, esmfRC)
      CALL ESMF_CplCompSetServices(  ocn2atmComp, ocn2atmesmf_setservices, esmfRC)

C     Do the constructor methods for the import and exports
      ocnImport = ESMF_StateCreate("ocn import", ESMF_STATEIMPORT, "ocn Component", rc=esmfRC )
      ocnExport = ESMF_StateCreate("ocn export", ESMF_STATEEXPORT, "ocn Component", rc=esmfRC )
      atmImport = ESMF_StateCreate("atm import", ESMF_STATEIMPORT, "atm Component", rc=esmfRC )
      atmExport = ESMF_StateCreate("atm export", ESMF_STATEEXPORT, "atm Component", rc=esmfRC )

C     Do the constructor methods for the clock object
#ifdef E_1_0_4
      CALL ESMF_CalendarSet(ESMF_360DayCalendar, ESMF_CAL_360DAY, esmfRC)
#endif
#ifdef E_1_0_5
      ESMF_360DayCalendar = ESMF_CalendarCreate("top calendar", ESMF_CAL_360DAY, esmfRC )
      CALL ESMF_CalendarSet(ESMF_360DayCalendar, "top calendar", ESMF_CAL_360DAY, esmfRC)
#endif
      CALL ESMF_TimeIntervalSet(timeStep, d=1, rc=esmfRC)
#ifdef E_1_0_4
      CALL ESMF_TimeSet(topStart, yr=0, mm=1, dd=1,
     &                          calendar=esmf_360dayCalendar, rc=esmfRC)
      CALL ESMF_TimeSet(topStop , yr=0, mm=1, dd=10,
     &                          calendar=esmf_360dayCalendar, rc=esmfRC)
#endif
#ifdef E_1_0_5
      CALL ESMF_TimeSet(topStart, yy=0, mm=1, dd=1,
     &                          calendar=esmf_360dayCalendar, rc=esmfRC)
      CALL ESMF_TimeSet(topStop , yy=0, mm=1, dd=10,
     &                          calendar=esmf_360dayCalendar, rc=esmfRC)
#endif
      topClock = ESMF_ClockCreate("360 Day Clock", timeStep, topStart,
     &                                   topStop, rc=ESMFrc)

C     Call the init method for each component
      CALL ESMF_GridCompInitialize( ocnComp, 
     &                              ocnImport,
     &                              ocnExport,
     &                              topClock,
     &                              esmfRC )
      CALL ESMF_GridCompInitialize( atmComp, 
     &                              atmImport,
     &                              atmExport,
     &                              topClock,
     &                              esmfRC )
      CALL ESMF_CplCompInitialize(  ocn2atmComp, 
     &                              ocnExport,
     &                              atmImport,
     &                              topClock,
     &                              esmfRC )

C     Iterate over the run methods for each component
      DO iCpl=1,10
       CALL ESMF_GridCompRun( ocnComp, 
     &                        ocnImport, ocnExport, topClock,
     &                        esmfRC )
       CALL ESMF_CplCompRun(  ocn2atmComp, 
     &                        ocnExport, atmImport, topClock,
     &                        esmfRC )
       CALL ESMF_GridCompRun( atmComp, 
     &                        atmImport, atmExport, topClock,
     &                        esmfRC )
       CALL ESMF_ClockAdvance(topClock, rc=esmfRC)
       IF ( ESMF_ClockIsStopTime(topClock, esmfRC )  ) THEN
        WRITE(0,*) ' I am DONE'
       ENDIF
      ENDDO
     
      CALL ESMF_Finalize(esmfRC)

      END
