C $Header: /u/gcmpack/pkg/pcb/pcb_init_fixed.F

C $Header: /u/gcmpack/MITgcm/model/inc/CPP_OPTIONS.h,v 1.51 2012/11/09 22:29:32 jmc Exp $
C $Name:  $


CBOP
C !ROUTINE: CPP_OPTIONS.h
C !INTERFACE:
C #include "CPP_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | main CPP options file for the model:
C | Control which optional features to compile in model/src code.
C *==================================================================*
CEOP

C CPP flags controlling particular source code features

C o Shortwave heating as extra term in external_forcing.F
C Note: this should be a run-time option


C o Include/exclude phi_hyd calculation code


C o Include/exclude call to S/R CONVECT


C o Include/exclude call to S/R CALC_DIFFUSIVITY


C o Allow full 3D specification of vertical diffusivity


C o Allow latitudinally varying BryanLewis79 vertical diffusivity


C o Include/exclude Implicit vertical advection code


C o Include/exclude AdamsBashforth-3rd-Order code


C o Include/exclude nonHydrostatic code


C o Allow to account for heating due to friction (and momentum dissipation)


C o Allow mass source or sink of Fluid in the interior
C   (3-D generalisation of oceanic real-fresh water flux)


C o Include pressure loading code


C o exclude/allow external forcing-fields load
C   this allows to read & do simple linear time interpolation of oceanic
C   forcing fields, if no specific pkg (e.g., EXF) is used to compute them.


C o Include/exclude balancing surface forcing fluxes code


C o Include/exclude balancing surface forcing relaxation code


C o Include/exclude GM-like eddy stress in momentum code


C o Use "Exact Convervation" of fluid in Free-Surface formulation
C   so that d/dt(eta) is exactly equal to - Div.Transport


C o Allow the use of Non-Linear Free-Surface formulation
C   this implies that surface thickness (hFactors) vary with time


C o Include/exclude code for single reduction Conjugate-Gradient solver


C o Choices for implicit solver routines solve_*diagonal.F
C   The following has low memory footprint, but not suitable for AD

C   The following one suitable for AD but does not vectorize


C o ALLOW isotropic scaling of harmonic and bi-harmonic terms when
C   using an locally isotropic spherical grid with (dlambda) x (dphi*cos(phi))
C *only for use on a lat-lon grid*
C   Setting this flag here affects both momentum and tracer equation unless
C   it is set/unset again in other header fields (e.g., GAD_OPTIONS.h).
C   The definition of the flag is commented to avoid interference with
C   such other header files.
C   The preferred method is specifying a value for viscAhGrid or viscA4Grid
C   in data which is then automatically scaled by the grid size;
C   the old method of specifying viscAh/viscA4 and this flag is provided
C   for completeness only (and for use with the adjoint).
C#define ISOTROPIC_COS_SCALING

C o This flag selects the form of COSINE(lat) scaling of bi-harmonic term.
C *only for use on a lat-lon grid*
C   Has no effect if ISOTROPIC_COS_SCALING is undefined.
C   Has no effect on vector invariant momentum equations.
C   Setting this flag here affects both momentum and tracer equation unless
C   it is set/unset again in other header fields (e.g., GAD_OPTIONS.h).
C   The definition of the flag is commented to avoid interference with
C   such other header files.
C#define COSINEMETH_III

C o Use "OLD" UV discretisation near boundaries (*not* recommended)
C   Note - only works with  #undef NO_SLIP_LATERAL  in calc_mom_rhs.F
C          because the old code did not have no-slip BCs


C o Use LONG.bin, LATG.bin, etc., initialization for ini_curviliear_grid.F
C   Default is to use "new" grid files (OLD_GRID_IO undef) but OLD_GRID_IO
C   is still useful with, e.g., single-domain curvilinear configurations.


C o Execution environment support options
C $Header: /u/gcmpack/MITgcm/eesupp/inc/CPP_EEOPTIONS.h,v 1.35 2012/09/06 21:55:59 jmc Exp $
C $Name: checkpoint64g $

CBOP
C     !ROUTINE: CPP_EEOPTIONS.h
C     !INTERFACE:
C     include "CPP_EEOPTIONS.h"
C
C     !DESCRIPTION:
C     *==========================================================*
C     | CPP\_EEOPTIONS.h                                         |
C     *==========================================================*
C     | C preprocessor "execution environment" supporting        |
C     | flags. Use this file to set flags controlling the        |
C     | execution environment in which a model runs - as opposed |
C     | to the dynamical problem the model solves.               |
C     | Note: Many options are implemented with both compile time|
C     |       and run-time switches. This allows options to be   |
C     |       removed altogether, made optional at run-time or   |
C     |       to be permanently enabled. This convention helps   |
C     |       with the data-dependence analysis performed by the |
C     |       adjoint model compiler. This data dependency       |
C     |       analysis can be upset by runtime switches that it  |
C     |       is unable to recoginise as being fixed for the     |
C     |       duration of an integration.                        |
C     |       A reasonable way to use these flags is to          |
C     |       set all options as selectable at runtime but then  |
C     |       once an experimental configuration has been        |
C     |       identified, rebuild the code with the appropriate  |
C     |       options set at compile time.                       |
C     *==========================================================*
CEOP


C     In general the following convention applies:
C     ALLOW  - indicates an feature will be included but it may
C     CAN      have a run-time flag to allow it to be switched
C              on and off.
C              If ALLOW or CAN directives are "undef'd" this generally
C              means that the feature will not be available i.e. it
C              will not be included in the compiled code and so no
C              run-time option to use the feature will be available.
C
C     ALWAYS - indicates the choice will be fixed at compile time
C              so no run-time option will be present

C=== Macro related options ===
C--   Control storage of floating point operands
C     On many systems it improves performance only to use
C     8-byte precision for time stepped variables.
C     Constant in time terms ( geometric factors etc.. )
C     can use 4-byte precision, reducing memory utilisation and
C     boosting performance because of a smaller working set size.
C     However, on vector CRAY systems this degrades performance.
C     Enable to switch REAL4_IS_SLOW from genmake2 (with LET_RS_BE_REAL4):

C--   Control use of "double" precision constants.
C     Use D0 where it means REAL*8 but not where it means REAL*16

C--   Enable some old macro conventions for backward compatibility

C=== IO related options ===
C--   Flag used to indicate whether Fortran formatted write
C     and read are threadsafe. On SGI the routines can be thread
C     safe, on Sun it is not possible - if you are unsure then
C     undef this option.

C--   Flag used to indicate whether Binary write to Local file (i.e.,
C     a different file for each tile) and read are thread-safe.

C--   Flag to turn off the writing of error message to ioUnit zero

C--   Alternative formulation of BYTESWAP, faster than
C     compiler flag -byteswapio on the Altix.

C=== MPI, EXCH and GLOBAL_SUM related options ===
C--   Flag turns off MPI_SEND ready_to_receive polling in the
C     gather_* subroutines to speed up integrations.

C--   Control MPI based parallel processing
CXXX We no longer select the use of MPI via this file (CPP_EEOPTIONS.h)
CXXX To use MPI, use an appropriate genmake2 options file or use
CXXX genmake2 -mpi .
CXXX #undef  ALLOW_USE_MPI

C--   Control use of communication that might overlap computation.
C     Under MPI selects/deselects "non-blocking" sends and receives.
C--   Control use of communication that is atomic to computation.
C     Under MPI selects/deselects "blocking" sends and receives.

C--   Control use of JAM routines for Artic network
C     These invoke optimized versions of "exchange" and "sum" that
C     utilize the programmable aspect of Artic cards.
CXXX No longer supported ; started to remove JAM routines.
CXXX #undef  LETS_MAKE_JAM
CXXX #undef  JAM_WITH_TWO_PROCS_PER_NODE

C--   Control XY periodicity in processor to grid mappings
C     Note: Model code does not need to know whether a domain is
C           periodic because it has overlap regions for every box.
C           Model assume that these values have been
C           filled in some way.

C--   disconnect tiles (no exchange between tiles, just fill-in edges
C     assuming locally periodic subdomain)

C--   Alternative way of doing global sum without MPI allreduce call
C     but instead, explicit MPI send & recv calls.

C--   Alternative way of doing global sum on a single CPU
C     to eliminate tiling-dependent roundoff errors.
C     Note: This is slow.

C=== Other options (to add/remove pieces of code) ===
C--   Flag to turn on checking for errors from all threads and procs
C     (calling S/R STOP_IF_ERROR) before stopping.

C--   Control use of communication with other component:
C     allow to import and export from/to Coupler interface.


C $Header: /u/gcmpack/MITgcm/eesupp/inc/CPP_EEMACROS.h,v 1.24 2012/09/19 20:46:03 utke Exp $
C $Name: checkpoint64g $

CBOP
C     !ROUTINE: CPP_EEMACROS.h
C     !INTERFACE:
C     include "CPP_EEMACROS.h "
C     !DESCRIPTION:
C     *==========================================================*
C     | CPP_EEMACROS.h
C     *==========================================================*
C     | C preprocessor "execution environment" supporting
C     | macros. Use this file to define macros for  simplifying
C     | execution environment in which a model runs - as opposed
C     | to the dynamical problem the model solves.
C     *==========================================================*
CEOP


C     In general the following convention applies:
C     ALLOW  - indicates an feature will be included but it may
C     CAN      have a run-time flag to allow it to be switched
C              on and off.
C              If ALLOW or CAN directives are "undef'd" this generally
C              means that the feature will not be available i.e. it
C              will not be included in the compiled code and so no
C              run-time option to use the feature will be available.
C
C     ALWAYS - indicates the choice will be fixed at compile time
C              so no run-time option will be present

C     Flag used to indicate which flavour of multi-threading
C     compiler directives to use. Only set one of these.
C     USE_SOLARIS_THREADING  - Takes directives for SUN Workshop
C                              compiler.
C     USE_KAP_THREADING      - Takes directives for Kuck and
C                              Associates multi-threading compiler
C                              ( used on Digital platforms ).
C     USE_IRIX_THREADING     - Takes directives for SGI MIPS
C                              Pro Fortran compiler.
C     USE_EXEMPLAR_THREADING - Takes directives for HP SPP series
C                              compiler.
C     USE_C90_THREADING      - Takes directives for CRAY/SGI C90
C                              system F90 compiler.






C--   Define the mapping for the _BARRIER macro
C     On some systems low-level hardware support can be accessed through
C     compiler directives here.

C--   Define the mapping for the BEGIN_CRIT() and  END_CRIT() macros.
C     On some systems we simply execute this section only using the
C     master thread i.e. its not really a critical section. We can
C     do this because we do not use critical sections in any critical
C     sections of our code!

C--   Define the mapping for the BEGIN_MASTER_SECTION() and
C     END_MASTER_SECTION() macros. These are generally implemented by
C     simply choosing a particular thread to be "the master" and have
C     it alone execute the BEGIN_MASTER..., END_MASTER.. sections.

CcnhDebugStarts
C      Alternate form to the above macros that increments (decrements) a counter each
C      time a MASTER section is entered (exited). This counter can then be checked in barrier
C      to try and detect calls to BARRIER within single threaded sections.
C      Using these macros requires two changes to Makefile - these changes are written
C      below.
C      1 - add a filter to the CPP command to kill off commented _MASTER lines
C      2 - add a filter to the CPP output the converts the string N EWLINE to an actual newline.
C      The N EWLINE needs to be changes to have no space when this macro and Makefile changes
C      are used. Its in here with a space to stop it getting parsed by the CPP stage in these
C      comments.
C      #define IF ( a .EQ. 1 ) THEN  IF ( a .EQ. 1 ) THEN  N EWLINE      CALL BARRIER_MS(a)
C      #define ENDIF    CALL BARRIER_MU(a) N EWLINE        ENDIF
C      'CPP = cat $< | $(TOOLSDIR)/set64bitConst.sh |  grep -v '^[cC].*_MASTER' | cpp  -traditional -P'
C      .F.f:
C      $(CPP) $(DEFINES) $(INCLUDES) |  sed 's/N EWLINE/\n/' > $@
CcnhDebugEnds

C--   Control storage of floating point operands
C     On many systems it improves performance only to use
C     8-byte precision for time stepped variables.
C     Constant in time terms ( geometric factors etc.. )
C     can use 4-byte precision, reducing memory utilisation and
C     boosting performance because of a smaller working
C     set size. However, on vector CRAY systems this degrades
C     performance.
C- Note: global_sum/max macros were used to switch to  JAM routines (obsolete);
C  in addition, since only the R4 & R8 S/R are coded, GLOBAL RS & RL macros
C  enable to call the corresponding R4 or R8 S/R.



C- Note: a) exch macros were used to switch to  JAM routines (obsolete)
C        b) exch R4 & R8 macros are not practically used ; if needed,
C           will directly call the corrresponding S/R.

C--   Control use of JAM routines for Artic network (no longer supported)
C     These invoke optimized versions of "exchange" and "sum" that
C     utilize the programmable aspect of Artic cards.
CXXX No longer supported ; started to remove JAM routines.
CXXX #ifdef LETS_MAKE_JAM
CXXX #define CALL GLOBAL_SUM_R8 ( a, b) CALL GLOBAL_SUM_R8_JAM ( a, b)
CXXX #define CALL GLOBAL_SUM_R8 ( a, b ) CALL GLOBAL_SUM_R8_JAM ( a, b )
CXXX #define CALL EXCH_XY_RS ( a, b ) CALL EXCH_XY_R8_JAM ( a, b )
CXXX #define CALL EXCH_XY_RL ( a, b ) CALL EXCH_XY_R8_JAM ( a, b )
CXXX #define CALL EXCH_XYZ_RS ( a, b ) CALL EXCH_XYZ_R8_JAM ( a, b )
CXXX #define CALL EXCH_XYZ_RL ( a, b ) CALL EXCH_XYZ_R8_JAM ( a, b )
CXXX #endif

C--   Control use of "double" precision constants.
C     Use d0 where it means REAL*8 but not where it means REAL*16

C--   Substitue for 1.D variables
C     Sun compilers do not use 8-byte precision for literals
C     unless .Dnn is specified. CRAY vector machines use 16-byte
C     precision when they see .Dnn which runs very slowly!



C o Include/exclude single header file containing multiple packages options
C   (AUTODIFF, COST, CTRL, ECCO, EXF ...) instead of the standard way where
C   each of the above pkg get its own options from its specific option file.
C   Although this method, inherited from ECCO setup, has been traditionally
C   used for all adjoint built, work is in progress to allow to use the
C   standard method also for adjoint built.
c#ifdef PACKAGES_CONFIG_H
c# include "ECCO_CPPOPTIONS.h"
c#endif

C $Header: /u/gcmpack/MITgcm/pkg/ptracers/PTRACERS_OPTIONS.h,v 1.8 2011/12/24 01:09:40 jmc Exp $
C $Name: checkpoint64g $

C CPP options file for PTRACERS package
C Use this file for selecting options within the PTRACERS package







C $Header: /u/gcmpack/MITgcm/model/inc/CPP_OPTIONS.h,v 1.51 2012/11/09 22:29:32 jmc Exp $
C $Name:  $


C     Package-specific Options & Macros go here

C NUMBER_OF_PTRACERS defines how many passive tracers are allocated/exist.
C This CPP macro is *only* used in PTRACERS.h to set an integer parameter.
C <Please> do not make use of it elsewhere.
C   Note: this CPP macro has been removed to avoid confusion and risk of
C    error resulting from multiple definitions (default + explicit) within
C    the code.
C    The maximum number of tracers is now defined within PTRACERS_SIZE.h
C---

C     This enables the dynamically allocated internal state data structures
C     for PTracers.  Needed for PTRACERS_SOM_Advection.
C     This requires a Fortran 90 compiler!


CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
C---------------------------------------------------------------
C MODIFICATION HISTORY
C   14 Jul 2014 - hma - Copied from Xianming's PFC simulation
C                       for my PCB simulation.
C---------------------------------------------------------------   

C == choose one mode to build the code

C = inorganic mercury chemistry is the default mode

C = mercury chemistry with methylmercury 

C = with food web, following model of Asif Quesi

C = FOODW_MODE needs METHY_MODE

C = partition
C no partition
C instantaneous equilibrium
C release

C = a seperate tracer for riverine HgP

C Sea spray, for PFCs



c===============================================================================
C===============================================================================
CStartofinterface
      SUBROUTINE PCB_INIT_FIXED(myThid)
C     =============== Global data ==========================================
C     === Global variables ===
         implicit none
C $Header: /u/gcmpack/MITgcm/model/inc/SIZE.h,v 1.28 2009/05/17 21:15:07 jmc Exp $
C $Name:  $
C
CBOP
C    !ROUTINE: SIZE.h
C    !INTERFACE:
C    include SIZE.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | SIZE.h Declare size of underlying computational grid.     
C     *==========================================================*
C     | The design here support a three-dimensional model grid    
C     | with indices I,J and K. The three-dimensional domain      
C     | is comprised of nPx*nSx blocks of size sNx along one axis 
C     | nPy*nSy blocks of size sNy along another axis and one     
C     | block of size Nz along the final axis.                    
C     | Blocks have overlap regions of size OLx and OLy along the 
C     | dimensions that are subdivided.                           
C     *==========================================================*
C     \ev
CEOP
C     Voodoo numbers controlling data layout.
C     sNx :: No. X points in sub-grid.
C     sNy :: No. Y points in sub-grid.
C     OLx :: Overlap extent in X.
C     OLy :: Overlat extent in Y.
C     nSx :: No. sub-grids in X.
C     nSy :: No. sub-grids in Y.
C     nPx :: No. of processes to use in X.
C     nPy :: No. of processes to use in Y.
C     Nx  :: No. points in X for the total domain.
C     Ny  :: No. points in Y for the total domain.
C     Nr  :: No. points in Z for full process domain.
      INTEGER sNx
      INTEGER sNy
      INTEGER OLx
      INTEGER OLy
      INTEGER nSx
      INTEGER nSy
      INTEGER nPx
      INTEGER nPy
      INTEGER Nx
      INTEGER Ny
      INTEGER Nr
      PARAMETER (
     &           sNx = 360,
     &           sNy = 160,
     &           OLx =   4,
     &           OLy =   4,
     &           nSx =   1,
     &           nSy =   1,
     &           nPx =   1,
     &           nPy =   1,
     &           Nx  = sNx*nSx*nPx,
     &           Ny  = sNy*nSy*nPy,
     &           Nr  =  23)

C     MAX_OLX :: Set to the maximum overlap region size of any array
C     MAX_OLY    that will be exchanged. Controls the sizing of exch
C                routine buffers.
      INTEGER MAX_OLX
      INTEGER MAX_OLY
      PARAMETER ( MAX_OLX = OLx,
     &            MAX_OLY = OLy )

C $Header: /u/gcmpack/MITgcm/eesupp/inc/EEPARAMS.h,v 1.32 2013/04/25 06:12:09 dimitri Exp $
C $Name: checkpoint64g $
CBOP
C     !ROUTINE: EEPARAMS.h
C     !INTERFACE:
C     include "EEPARAMS.h"
C
C     !DESCRIPTION:
C     *==========================================================*
C     | EEPARAMS.h                                               |
C     *==========================================================*
C     | Parameters for "execution environemnt". These are used   |
C     | by both the particular numerical model and the execution |
C     | environment support routines.                            |
C     *==========================================================*
CEOP

C     ========  EESIZE.h  ========================================

C     MAX_LEN_MBUF  - Default message buffer max. size
C     MAX_LEN_FNAM  - Default file name max. size
C     MAX_LEN_PREC  - Default rec len for reading "parameter" files

      INTEGER MAX_LEN_MBUF
      PARAMETER ( MAX_LEN_MBUF = 512 )
      INTEGER MAX_LEN_FNAM
      PARAMETER ( MAX_LEN_FNAM = 512 )
      INTEGER MAX_LEN_PREC
      PARAMETER ( MAX_LEN_PREC = 200 )

C     MAX_NO_THREADS  - Maximum number of threads allowed.
C     MAX_NO_PROCS    - Maximum number of processes allowed.
C     MAX_NO_BARRIERS - Maximum number of distinct thread "barriers"
      INTEGER MAX_NO_THREADS
      PARAMETER ( MAX_NO_THREADS =  4 )
      INTEGER MAX_NO_PROCS
      PARAMETER ( MAX_NO_PROCS   =  8192 )
      INTEGER MAX_NO_BARRIERS
      PARAMETER ( MAX_NO_BARRIERS = 1 )

C     Particularly weird and obscure voodoo numbers
C     lShare  - This wants to be the length in
C               [148]-byte words of the size of
C               the address "window" that is snooped
C               on an SMP bus. By separating elements in
C               the global sum buffer we can avoid generating
C               extraneous invalidate traffic between
C               processors. The length of this window is usually
C               a cache line i.e. small O(64 bytes).
C               The buffer arrays are usually short arrays
C               and are declared REAL ARRA(lShare[148],LBUFF).
C               Setting lShare[148] to 1 is like making these arrays
C               one dimensional.
      INTEGER cacheLineSize
      INTEGER lShare1
      INTEGER lShare4
      INTEGER lShare8
      PARAMETER ( cacheLineSize = 256 )
      PARAMETER ( lShare1 =  cacheLineSize )
      PARAMETER ( lShare4 =  cacheLineSize/4 )
      PARAMETER ( lShare8 =  cacheLineSize/8 )

      INTEGER MAX_VGS
      PARAMETER ( MAX_VGS = 8192 )

C     ========  EESIZE.h  ========================================

C     Symbolic values
C     precXXXX :: precision used for I/O
      INTEGER precFloat32
      PARAMETER ( precFloat32 = 32 )
      INTEGER precFloat64
      PARAMETER ( precFloat64 = 64 )

C     Real-type constant for some frequently used simple number (0,1,2,1/2):
      Real*8     zeroRS, oneRS, twoRS, halfRS
      PARAMETER ( zeroRS = 0.0D0 , oneRS  = 1.0D0 )
      PARAMETER ( twoRS  = 2.0D0 , halfRS = 0.5D0 )
      Real*8     zeroRL, oneRL, twoRL, halfRL
      PARAMETER ( zeroRL = 0.0D0 , oneRL  = 1.0D0 )
      PARAMETER ( twoRL  = 2.0D0 , halfRL = 0.5D0 )

C     UNSET_xxx :: Used to indicate variables that have not been given a value
      Real*8  UNSET_FLOAT8
      PARAMETER ( UNSET_FLOAT8 = 1.234567D5 )
      Real*4  UNSET_FLOAT4
      PARAMETER ( UNSET_FLOAT4 = 1.234567E5 )
      Real*8     UNSET_RL
      PARAMETER ( UNSET_RL     = 1.234567D5 )
      Real*8     UNSET_RS
      PARAMETER ( UNSET_RS     = 1.234567D5 )
      INTEGER UNSET_I
      PARAMETER ( UNSET_I      = 123456789  )

C     debLevX  :: used to decide when to print debug messages
      INTEGER debLevZero
      INTEGER debLevA, debLevB,  debLevC, debLevD, debLevE
      PARAMETER ( debLevZero=0 )
      PARAMETER ( debLevA=1 )
      PARAMETER ( debLevB=2 )
      PARAMETER ( debLevC=3 )
      PARAMETER ( debLevD=4 )
      PARAMETER ( debLevE=5 )

C     SQUEEZE_RIGHT       - Flag indicating right blank space removal
C                           from text field.
C     SQUEEZE_LEFT        - Flag indicating left blank space removal
C                           from text field.
C     SQUEEZE_BOTH        - Flag indicating left and right blank
C                           space removal from text field.
C     PRINT_MAP_XY        - Flag indicating to plot map as XY slices
C     PRINT_MAP_XZ        - Flag indicating to plot map as XZ slices
C     PRINT_MAP_YZ        - Flag indicating to plot map as YZ slices
C     commentCharacter    - Variable used in column 1 of parameter
C                           files to indicate comments.
C     INDEX_I             - Variable used to select an index label
C     INDEX_J               for formatted input parameters.
C     INDEX_K
C     INDEX_NONE
      CHARACTER*(*) SQUEEZE_RIGHT
      PARAMETER ( SQUEEZE_RIGHT = 'R' )
      CHARACTER*(*) SQUEEZE_LEFT
      PARAMETER ( SQUEEZE_LEFT = 'L' )
      CHARACTER*(*) SQUEEZE_BOTH
      PARAMETER ( SQUEEZE_BOTH = 'B' )
      CHARACTER*(*) PRINT_MAP_XY
      PARAMETER ( PRINT_MAP_XY = 'XY' )
      CHARACTER*(*) PRINT_MAP_XZ
      PARAMETER ( PRINT_MAP_XZ = 'XZ' )
      CHARACTER*(*) PRINT_MAP_YZ
      PARAMETER ( PRINT_MAP_YZ = 'YZ' )
      CHARACTER*(*) commentCharacter
      PARAMETER ( commentCharacter = '#' )
      INTEGER INDEX_I
      INTEGER INDEX_J
      INTEGER INDEX_K
      INTEGER INDEX_NONE
      PARAMETER ( INDEX_I    = 1,
     &            INDEX_J    = 2,
     &            INDEX_K    = 3,
     &            INDEX_NONE = 4 )

C     EXCH_IGNORE_CORNERS - Flag to select ignoring or
C     EXCH_UPDATE_CORNERS   updating of corners during
C                           an edge exchange.
      INTEGER EXCH_IGNORE_CORNERS
      INTEGER EXCH_UPDATE_CORNERS
      PARAMETER ( EXCH_IGNORE_CORNERS = 0,
     &            EXCH_UPDATE_CORNERS = 1 )

C     FORWARD_SIMULATION
C     REVERSE_SIMULATION
C     TANGENT_SIMULATION
      INTEGER FORWARD_SIMULATION
      INTEGER REVERSE_SIMULATION
      INTEGER TANGENT_SIMULATION
      PARAMETER ( FORWARD_SIMULATION = 0,
     &            REVERSE_SIMULATION = 1,
     &            TANGENT_SIMULATION = 2 )

C--   COMMON /EEPARAMS_L/ Execution environment public logical variables.
C     eeBootError    :: Flags indicating error during multi-processing
C     eeEndError     :: initialisation and termination.
C     fatalError     :: Flag used to indicate that the model is ended with an error
C     debugMode      :: controls printing of debug msg (sequence of S/R calls).
C     useSingleCpuIO :: When useSingleCpuIO is set, MDS_WRITE_FIELD outputs from
C                       master MPI process only. -- NOTE: read from main parameter
C                       file "data" and not set until call to INI_PARMS.
C     printMapIncludesZeros  :: Flag that controls whether character constant
C                               map code ignores exact zero values.
C     useCubedSphereExchange :: use Cubed-Sphere topology domain.
C     useCoupler     :: use Coupler for a multi-components set-up.
C     useNEST_PARENT :: use Parent Nesting interface (pkg/nest_parent)
C     useNEST_CHILD  :: use Child  Nesting interface (pkg/nest_child)
C     useOASIS       :: use OASIS-coupler for a multi-components set-up.
      COMMON /EEPARAMS_L/
c    &  eeBootError, fatalError, eeEndError,
     &  eeBootError, eeEndError, fatalError, debugMode,
     &  useSingleCpuIO, printMapIncludesZeros,
     &  useCubedSphereExchange, useCoupler,
     &  useNEST_PARENT, useNEST_CHILD, useOASIS,
     &  useSETRLSTK, useSIGREG
      LOGICAL eeBootError
      LOGICAL eeEndError
      LOGICAL fatalError
      LOGICAL debugMode
      LOGICAL useSingleCpuIO
      LOGICAL printMapIncludesZeros
      LOGICAL useCubedSphereExchange
      LOGICAL useCoupler
      LOGICAL useNEST_PARENT
      LOGICAL useNEST_CHILD
      LOGICAL useOASIS
      LOGICAL useSETRLSTK
      LOGICAL useSIGREG

C--   COMMON /EPARAMS_I/ Execution environment public integer variables.
C     errorMessageUnit    - Fortran IO unit for error messages
C     standardMessageUnit - Fortran IO unit for informational messages
C     maxLengthPrt1D :: maximum length for printing (to Std-Msg-Unit) 1-D array
C     scrUnit1      - Scratch file 1 unit number
C     scrUnit2      - Scratch file 2 unit number
C     eeDataUnit    - Unit # for reading "execution environment" parameter file.
C     modelDataUnit - Unit number for reading "model" parameter file.
C     numberOfProcs - Number of processes computing in parallel
C     pidIO         - Id of process to use for I/O.
C     myBxLo, myBxHi - Extents of domain in blocks in X and Y
C     myByLo, myByHi   that each threads is responsble for.
C     myProcId      - My own "process" id.
C     myPx     - My X coord on the proc. grid.
C     myPy     - My Y coord on the proc. grid.
C     myXGlobalLo - My bottom-left (south-west) x-index
C                   global domain. The x-coordinate of this
C                   point in for example m or degrees is *not*
C                   specified here. A model needs to provide a
C                   mechanism for deducing that information if it
C                   is needed.
C     myYGlobalLo - My bottom-left (south-west) y-index in
C                   global domain. The y-coordinate of this
C                   point in for example m or degrees is *not*
C                   specified here. A model needs to provide a
C                   mechanism for deducing that information if it
C                   is needed.
C     nThreads    - No. of threads
C     nTx         - No. of threads in X
C     nTy         - No. of threads in Y
C                   This assumes a simple cartesian
C                   gridding of the threads which is not required elsewhere
C                   but that makes it easier.
C     ioErrorCount - IO Error Counter. Set to zero initially and increased
C                    by one every time an IO error occurs.
      COMMON /EEPARAMS_I/
     &  errorMessageUnit, standardMessageUnit, maxLengthPrt1D,
     &  scrUnit1, scrUnit2, eeDataUnit, modelDataUnit,
     &  numberOfProcs, pidIO, myProcId,
     &  myPx, myPy, myXGlobalLo, myYGlobalLo, nThreads,
     &  myBxLo, myBxHi, myByLo, myByHi,
     &  nTx, nTy, ioErrorCount
      INTEGER errorMessageUnit
      INTEGER standardMessageUnit
      INTEGER maxLengthPrt1D
      INTEGER scrUnit1
      INTEGER scrUnit2
      INTEGER eeDataUnit
      INTEGER modelDataUnit
      INTEGER ioErrorCount(MAX_NO_THREADS)
      INTEGER myBxLo(MAX_NO_THREADS)
      INTEGER myBxHi(MAX_NO_THREADS)
      INTEGER myByLo(MAX_NO_THREADS)
      INTEGER myByHi(MAX_NO_THREADS)
      INTEGER myProcId
      INTEGER myPx
      INTEGER myPy
      INTEGER myXGlobalLo
      INTEGER myYGlobalLo
      INTEGER nThreads
      INTEGER nTx
      INTEGER nTy
      INTEGER numberOfProcs
      INTEGER pidIO

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
C $Header: /u/gcmpack/MITgcm/model/inc/PARAMS.h,v 1.268 2013/04/22 02:32:47 jmc Exp $
C $Name: checkpoint64g $
C

CBOP
C     !ROUTINE: PARAMS.h
C     !INTERFACE:
C     #include PARAMS.h

C     !DESCRIPTION:
C     Header file defining model "parameters".  The values from the
C     model standard input file are stored into the variables held
C     here. Notes describing the parameters can also be found here.

CEOP

C     Macros for special grid options
C $Header: /u/gcmpack/MITgcm/model/inc/PARAMS_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: PARAMS_MACROS.h
C    !INTERFACE:
C    include PARAMS_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | PARAMS_MACROS.h                                           
C     *==========================================================*
C     | These macros are used to substitute definitions for       
C     | PARAMS.h variables for particular configurations.         
C     | In setting these variables the following convention       
C     | applies.                                                  
C     | define phi_CONST   - Indicates the variable phi is fixed  
C     |                      in X, Y and Z.                       
C     | define phi_FX      - Indicates the variable phi only      
C     |                      varies in X (i.e.not in X or Z).     
C     | define phi_FY      - Indicates the variable phi only      
C     |                      varies in Y (i.e.not in X or Z).     
C     | define phi_FXY     - Indicates the variable phi only      
C     |                      varies in X and Y ( i.e. not Z).     
C     *==========================================================*
C     \ev
CEOP

C $Header: /u/gcmpack/MITgcm/model/inc/FCORI_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: FCORI_MACROS.h
C    !INTERFACE:
C    include FCORI_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | FCORI_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C--   Contants
C     Useful physical values
      Real*8 PI
      PARAMETER ( PI    = 3.14159265358979323844d0   )
      Real*8 deg2rad
      PARAMETER ( deg2rad = 2.d0*PI/360.d0           )

C--   COMMON /PARM_C/ Character valued parameters used by the model.
C     buoyancyRelation :: Flag used to indicate which relation to use to
C                         get buoyancy.
C     eosType         :: choose the equation of state:
C                        LINEAR, POLY3, UNESCO, JMD95Z, JMD95P, MDJWF, IDEALGAS
C     pickupSuff      :: force to start from pickup files (even if nIter0=0)
C                        and read pickup files with this suffix (max 10 Char.)
C     mdsioLocalDir   :: read-write tiled file from/to this directory name
C                        (+ 4 digits Processor-Rank) instead of current dir.
C     adTapeDir       :: read-write checkpointing tape files from/to this
C                        directory name instead of current dir. Conflicts
C                        mdsioLocalDir, so only one of the two can be set.
C                        In contrast to mdsioLocalDir, if specified adTapeDir
C                        must exist before the model starts.
C     tRefFile      :: File containing reference Potential Temperat.  tRef (1.D)
C     sRefFile      :: File containing reference salinity/spec.humid. sRef (1.D)
C     rhoRefFile    :: File containing reference density profile rhoRef (1.D)
C     delRFile      :: File containing vertical grid spacing delR  (1.D array)
C     delRcFile     :: File containing vertical grid spacing delRc (1.D array)
C     hybSigmFile   :: File containing hybrid-sigma vertical coord. coeff. (2x 1.D)
C     delXFile      :: File containing X-spacing grid definition (1.D array)
C     delYFile      :: File containing Y-spacing grid definition (1.D array)
C     horizGridFile :: File containing horizontal-grid definition
C                        (only when using curvilinear_grid)
C     bathyFile       :: File containing bathymetry. If not defined bathymetry
C                        is taken from inline function.
C     topoFile        :: File containing the topography of the surface (unit=m)
C                        (mainly used for the atmosphere = ground height).
C     hydrogThetaFile :: File containing initial hydrographic data (3-D)
C                        for potential temperature.
C     hydrogSaltFile  :: File containing initial hydrographic data (3-D)
C                        for salinity.
C     diffKrFile      :: File containing 3D specification of vertical diffusivity
C     viscAhDfile     :: File containing 3D specification of horizontal viscosity
C     viscAhZfile     :: File containing 3D specification of horizontal viscosity
C     viscA4Dfile     :: File containing 3D specification of horizontal viscosity
C     viscA4Zfile     :: File containing 3D specification of horizontal viscosity
C     zonalWindFile   :: File containing zonal wind data
C     meridWindFile   :: File containing meridional wind data
C     thetaClimFile   :: File containing surface theta climataology used
C                        in relaxation term -lambda(theta-theta*)
C     saltClimFile    :: File containing surface salt climataology used
C                        in relaxation term -lambda(salt-salt*)
C     surfQfile       :: File containing surface heat flux, excluding SW
C                        (old version, kept for backward compatibility)
C     surfQnetFile    :: File containing surface net heat flux
C     surfQswFile     :: File containing surface shortwave radiation
C     EmPmRfile       :: File containing surface fresh water flux
C           NOTE: for backward compatibility EmPmRfile is specified in
C                 m/s when using external_fields_load.F.  It is converted
C                 to kg/m2/s by multiplying by rhoConstFresh.
C     saltFluxFile    :: File containing surface salt flux
C     pLoadFile       :: File containing pressure loading
C     addMassFile     :: File containing source/sink of fluid in the interior
C     eddyPsiXFile    :: File containing zonal Eddy streamfunction data
C     eddyPsiYFile    :: File containing meridional Eddy streamfunction data
C     the_run_name    :: string identifying the name of the model "run"
      COMMON /PARM_C/
     &                buoyancyRelation, eosType,
     &                pickupSuff, mdsioLocalDir, adTapeDir,
     &                tRefFile, sRefFile, rhoRefFile,
     &                delRFile, delRcFile, hybSigmFile,
     &                delXFile, delYFile, horizGridFile,
     &                bathyFile, topoFile,
     &                viscAhDfile, viscAhZfile,
     &                viscA4Dfile, viscA4Zfile,
     &                hydrogThetaFile, hydrogSaltFile, diffKrFile,
     &                zonalWindFile, meridWindFile, thetaClimFile,
     &                saltClimFile,
     &                EmPmRfile, saltFluxFile,
     &                surfQfile, surfQnetFile, surfQswFile,
     &                lambdaThetaFile, lambdaSaltFile,
     &                uVelInitFile, vVelInitFile, pSurfInitFile,
     &                pLoadFile, addMassFile,
     &                eddyPsiXFile, eddyPsiYFile,
     &                the_run_name
      CHARACTER*(MAX_LEN_FNAM) buoyancyRelation
      CHARACTER*(6)  eosType
      CHARACTER*(10) pickupSuff
      CHARACTER*(MAX_LEN_FNAM) mdsioLocalDir
      CHARACTER*(MAX_LEN_FNAM) adTapeDir
      CHARACTER*(MAX_LEN_FNAM) tRefFile
      CHARACTER*(MAX_LEN_FNAM) sRefFile
      CHARACTER*(MAX_LEN_FNAM) rhoRefFile
      CHARACTER*(MAX_LEN_FNAM) delRFile
      CHARACTER*(MAX_LEN_FNAM) delRcFile
      CHARACTER*(MAX_LEN_FNAM) hybSigmFile
      CHARACTER*(MAX_LEN_FNAM) delXFile
      CHARACTER*(MAX_LEN_FNAM) delYFile
      CHARACTER*(MAX_LEN_FNAM) horizGridFile
      CHARACTER*(MAX_LEN_FNAM) bathyFile, topoFile
      CHARACTER*(MAX_LEN_FNAM) hydrogThetaFile, hydrogSaltFile
      CHARACTER*(MAX_LEN_FNAM) diffKrFile
      CHARACTER*(MAX_LEN_FNAM) viscAhDfile
      CHARACTER*(MAX_LEN_FNAM) viscAhZfile
      CHARACTER*(MAX_LEN_FNAM) viscA4Dfile
      CHARACTER*(MAX_LEN_FNAM) viscA4Zfile
      CHARACTER*(MAX_LEN_FNAM) zonalWindFile
      CHARACTER*(MAX_LEN_FNAM) meridWindFile
      CHARACTER*(MAX_LEN_FNAM) thetaClimFile
      CHARACTER*(MAX_LEN_FNAM) saltClimFile
      CHARACTER*(MAX_LEN_FNAM) surfQfile
      CHARACTER*(MAX_LEN_FNAM) surfQnetFile
      CHARACTER*(MAX_LEN_FNAM) surfQswFile
      CHARACTER*(MAX_LEN_FNAM) EmPmRfile
      CHARACTER*(MAX_LEN_FNAM) saltFluxFile
      CHARACTER*(MAX_LEN_FNAM) uVelInitFile
      CHARACTER*(MAX_LEN_FNAM) vVelInitFile
      CHARACTER*(MAX_LEN_FNAM) pSurfInitFile
      CHARACTER*(MAX_LEN_FNAM) pLoadFile
      CHARACTER*(MAX_LEN_FNAM) addMassFile
      CHARACTER*(MAX_LEN_FNAM) eddyPsiXFile
      CHARACTER*(MAX_LEN_FNAM) eddyPsiYFile
      CHARACTER*(MAX_LEN_FNAM) lambdaThetaFile
      CHARACTER*(MAX_LEN_FNAM) lambdaSaltFile
      CHARACTER*(MAX_LEN_PREC/2) the_run_name

C--   COMMON /PARM_I/ Integer valued parameters used by the model.
C     cg2dMaxIters        :: Maximum number of iterations in the
C                            two-dimensional con. grad solver.
C     cg2dChkResFreq      :: Frequency with which to check residual
C                            in con. grad solver.
C     cg2dPreCondFreq     :: Frequency for updating cg2d preconditioner
C                            (non-linear free-surf.)
C     cg2dUseMinResSol    :: =0 : use last-iteration/converged solution
C                            =1 : use solver minimum-residual solution
C     cg3dMaxIters        :: Maximum number of iterations in the
C                            three-dimensional con. grad solver.
C     cg3dChkResFreq      :: Frequency with which to check residual
C                            in con. grad solver.
C     printResidualFreq   :: Frequency for printing residual in CG iterations
C     nIter0              :: Start time-step number of for this run
C     nTimeSteps          :: Number of timesteps to execute
C     writeStatePrec      :: Precision used for writing model state.
C     writeBinaryPrec     :: Precision used for writing binary files
C     readBinaryPrec      :: Precision used for reading binary files
C     selectCoriMap       :: select setting of Coriolis parameter map:
C                           =0 f-Plane (Constant Coriolis, = f0)
C                           =1 Beta-Plane Coriolis (= f0 + beta.y)
C                           =2 Spherical Coriolis (= 2.omega.sin(phi))
C                           =3 Read Coriolis 2-d fields from files.
C     selectSigmaCoord    :: option related to sigma vertical coordinate
C     nonlinFreeSurf      :: option related to non-linear free surface
C                           =0 Linear free surface ; >0 Non-linear
C     select_rStar        :: option related to r* vertical coordinate
C                           =0 (default) use r coord. ; > 0 use r*
C     selectNHfreeSurf    :: option for Non-Hydrostatic (free-)Surface formulation:
C                           =0 (default) hydrostatic surf. ; > 0 add NH effects.
C     selectAddFluid      :: option to add mass source/sink of fluid in the interior
C                            (3-D generalisation of oceanic real-fresh water flux)
C                           =0 off ; =1 add fluid ; =-1 virtual flux (no mass added)
C     momForcingOutAB     :: =1: take momentum forcing contribution
C                            out of (=0: in) Adams-Bashforth time stepping.
C     tracForcingOutAB    :: =1: take tracer (Temp,Salt,pTracers) forcing contribution
C                            out of (=0: in) Adams-Bashforth time stepping.
C     tempAdvScheme       :: Temp. Horiz.Advection scheme selector
C     tempVertAdvScheme   :: Temp. Vert. Advection scheme selector
C     saltAdvScheme       :: Salt. Horiz.advection scheme selector
C     saltVertAdvScheme   :: Salt. Vert. Advection scheme selector
C     selectKEscheme      :: Kinetic Energy scheme selector (Vector Inv.)
C     selectVortScheme    :: Scheme selector for Vorticity term (Vector Inv.)
C     monitorSelect       :: select group of variables to monitor
C                            =1 : dynvars ; =2 : + vort ; =3 : + surface
C-    debugLevel          :: controls printing of algorithm intermediate results
C                            and statistics ; higher -> more writing

      COMMON /PARM_I/
     &        cg2dMaxIters, cg2dChkResFreq,
     &        cg2dPreCondFreq, cg2dUseMinResSol,
     &        cg3dMaxIters, cg3dChkResFreq,
     &        printResidualFreq,
     &        nIter0, nTimeSteps, nEndIter,
     &        writeStatePrec,
     &        writeBinaryPrec, readBinaryPrec,
     &        selectCoriMap,
     &        selectSigmaCoord,
     &        nonlinFreeSurf, select_rStar,
     &        selectNHfreeSurf,
     &        selectAddFluid,
     &        momForcingOutAB, tracForcingOutAB,
     &        tempAdvScheme, tempVertAdvScheme,
     &        saltAdvScheme, saltVertAdvScheme,
     &        selectKEscheme, selectVortScheme,
     &        monitorSelect, debugLevel
      INTEGER cg2dMaxIters
      INTEGER cg2dChkResFreq
      INTEGER cg2dPreCondFreq
      INTEGER cg2dUseMinResSol
      INTEGER cg3dMaxIters
      INTEGER cg3dChkResFreq
      INTEGER printResidualFreq
      INTEGER nIter0
      INTEGER nTimeSteps
      INTEGER nEndIter
      INTEGER writeStatePrec
      INTEGER writeBinaryPrec
      INTEGER readBinaryPrec
      INTEGER selectCoriMap
      INTEGER selectSigmaCoord
      INTEGER nonlinFreeSurf
      INTEGER select_rStar
      INTEGER selectNHfreeSurf
      INTEGER selectAddFluid
      INTEGER momForcingOutAB, tracForcingOutAB
      INTEGER tempAdvScheme, tempVertAdvScheme
      INTEGER saltAdvScheme, saltVertAdvScheme
      INTEGER selectKEscheme
      INTEGER selectVortScheme
      INTEGER monitorSelect
      INTEGER debugLevel

C--   COMMON /PARM_L/ Logical valued parameters used by the model.
C- Coordinate + Grid params:
C     fluidIsAir       :: Set to indicate that the fluid major constituent
C                         is air
C     fluidIsWater     :: Set to indicate that the fluid major constituent
C                         is water
C     usingPCoords     :: Set to indicate that we are working in a pressure
C                         type coordinate (p or p*).
C     usingZCoords     :: Set to indicate that we are working in a height
C                         type coordinate (z or z*)
C     useDynP_inEos_Zc :: use the dynamical pressure in EOS (with Z-coord.)
C                         this requires specific code for restart & exchange
C     usingCartesianGrid :: If TRUE grid generation will be in a cartesian
C                           coordinate frame.
C     usingSphericalPolarGrid :: If TRUE grid generation will be in a
C                                spherical polar frame.
C     rotateGrid      :: rotate grid coordinates to geographical coordinates
C                        according to Euler angles phiEuler, thetaEuler, psiEuler
C     usingCylindricalGrid :: If TRUE grid generation will be Cylindrical
C     usingCurvilinearGrid :: If TRUE, use a curvilinear grid (to be provided)
C     hasWetCSCorners :: domain contains CS-type corners where dynamics is solved
C     deepAtmosphere :: deep model (drop the shallow-atmosphere approximation)
C     setInterFDr    :: set Interface depth (put cell-Center at the middle)
C     setCenterDr    :: set cell-Center depth (put Interface at the middle)
C- Momentum params:
C     no_slip_sides  :: Impose "no-slip" at lateral boundaries.
C     no_slip_bottom :: Impose "no-slip" at bottom boundary.
C     useFullLeith   :: Set to true to use full Leith viscosity(may be unstable
C                       on irregular grids)
C     useStrainTensionVisc:: Set to true to use Strain-Tension viscous terms
C     useAreaViscLength :: Set to true to use old scaling for viscous lengths,
C                          e.g., L2=Raz.  May be preferable for cube sphere.
C     momViscosity  :: Flag which turns momentum friction terms on and off.
C     momAdvection  :: Flag which turns advection of momentum on and off.
C     momForcing    :: Flag which turns external forcing of momentum on
C                      and off.
C     momPressureForcing :: Flag which turns pressure term in momentum equation
C                          on and off.
C     metricTerms   :: Flag which turns metric terms on or off.
C     useNHMTerms   :: If TRUE use non-hydrostatic metric terms.
C     useCoriolis   :: Flag which turns the coriolis terms on and off.
C     use3dCoriolis :: Turns the 3-D coriolis terms (in Omega.cos Phi) on - off
C     useCDscheme   :: use CD-scheme to calculate Coriolis terms.
C     vectorInvariantMomentum :: use Vector-Invariant form (mom_vecinv package)
C                                (default = F = use mom_fluxform package)
C     useJamartWetPoints :: Use wet-point method for Coriolis (Jamart & Ozer 1986)
C     useJamartMomAdv :: Use wet-point method for V.I. non-linear term
C     upwindVorticity :: bias interpolation of vorticity in the Coriolis term
C     highOrderVorticity :: use 3rd/4th order interp. of vorticity (V.I., advection)
C     useAbsVorticity :: work with f+zeta in Coriolis terms
C     upwindShear        :: use 1rst order upwind interp. (V.I., vertical advection)
C     momStepping    :: Turns momentum equation time-stepping off
C     calc_wVelocity :: Turns of vertical velocity calculation off
C- Temp. & Salt params:
C     tempStepping   :: Turns temperature equation time-stepping on/off
C     saltStepping   :: Turns salinity equation time-stepping on/off
C     addFrictionHeating :: account for frictional heating
C     tempAdvection  :: Flag which turns advection of temperature on and off.
C     tempVertDiff4  :: use vertical bi-harmonic diffusion for temperature
C     tempIsActiveTr :: Pot.Temp. is a dynamically active tracer
C     tempForcing    :: Flag which turns external forcing of temperature on/off
C     saltAdvection  :: Flag which turns advection of salinity on and off.
C     saltVertDiff4  :: use vertical bi-harmonic diffusion for salinity
C     saltIsActiveTr :: Salinity  is a dynamically active tracer
C     saltForcing    :: Flag which turns external forcing of salinity on/off
C     maskIniTemp    :: apply mask to initial Pot.Temp.
C     maskIniSalt    :: apply mask to initial salinity
C     checkIniTemp   :: check for points with identically zero initial Pot.Temp.
C     checkIniSalt   :: check for points with identically zero initial salinity
C- Pressure solver related parameters (PARM02)
C     useSRCGSolver  :: Set to true to use conjugate gradient
C                       solver with single reduction (only one call of
C                       s/r mpi_allreduce), default is false
C- Time-stepping & free-surface params:
C     rigidLid            :: Set to true to use rigid lid
C     implicitFreeSurface :: Set to true to use implicit free surface
C     uniformLin_PhiSurf  :: Set to true to use a uniform Bo_surf in the
C                            linear relation Phi_surf = Bo_surf*eta
C     uniformFreeSurfLev  :: TRUE if free-surface level-index is uniform (=1)
C     exactConserv        :: Set to true to conserve exactly the total Volume
C     linFSConserveTr     :: Set to true to correct source/sink of tracer
C                            at the surface due to Linear Free Surface
C     useRealFreshWaterFlux :: if True (=Natural BCS), treats P+R-E flux
C                         as a real Fresh Water (=> changes the Sea Level)
C                         if F, converts P+R-E to salt flux (no SL effect)
C     quasiHydrostatic :: Using non-hydrostatic terms in hydrostatic algorithm
C     nonHydrostatic   :: Using non-hydrostatic algorithm
C     use3Dsolver      :: set to true to use 3-D pressure solver
C     implicitIntGravWave :: treat Internal Gravity Wave implicitly
C     staggerTimeStep   :: enable a Stagger time stepping U,V (& W) then T,S
C     doResetHFactors   :: Do reset thickness factors @ beginning of each time-step
C     implicitDiffusion :: Turns implicit vertical diffusion on
C     implicitViscosity :: Turns implicit vertical viscosity on
C     tempImplVertAdv :: Turns on implicit vertical advection for Temperature
C     saltImplVertAdv :: Turns on implicit vertical advection for Salinity
C     momImplVertAdv  :: Turns on implicit vertical advection for Momentum
C     multiDimAdvection :: Flag that enable multi-dimension advection
C     useMultiDimAdvec  :: True if multi-dim advection is used at least once
C     momDissip_In_AB   :: if False, put Dissipation tendency contribution
C                          out off Adams-Bashforth time stepping.
C     doAB_onGtGs       :: if the Adams-Bashforth time stepping is used, always
C                          apply AB on tracer tendencies (rather than on Tracer)
C- Other forcing params -
C     balanceEmPmR    :: substract global mean of EmPmR at every time step
C     balanceQnet     :: substract global mean of Qnet at every time step
C     balancePrintMean:: print substracted global means to STDOUT
C     doThetaClimRelax :: Set true if relaxation to temperature
C                        climatology is required.
C     doSaltClimRelax  :: Set true if relaxation to salinity
C                        climatology is required.
C     balanceThetaClimRelax :: substract global mean effect at every time step
C     balanceSaltClimRelax :: substract global mean effect at every time step
C     allowFreezing  :: Allows surface water to freeze and form ice
C     useOldFreezing :: use the old version (before checkpoint52a_pre, 2003-11-12)
C     periodicExternalForcing :: Set true if forcing is time-dependant
C- I/O parameters -
C     globalFiles    :: Selects between "global" and "tiled" files.
C                       On some platforms with MPI, option globalFiles is either
C                       slow or does not work. Use useSingleCpuIO instead.
C     useSingleCpuIO :: moved to EEPARAMS.h
C     pickupStrictlyMatch :: check and stop if pickup-file do not stricly match
C     startFromPickupAB2 :: with AB-3 code, start from an AB-2 pickup
C     usePickupBeforeC54 :: start from old-pickup files, generated with code from
C                           before checkpoint-54a, Jul 06, 2004.
C     pickup_write_mdsio :: use mdsio to write pickups
C     pickup_read_mdsio  :: use mdsio to read  pickups
C     pickup_write_immed :: echo the pickup immediately (for conversion)
C     writePickupAtEnd   :: write pickup at the last timestep
C     timeave_mdsio      :: use mdsio for timeave output
C     snapshot_mdsio     :: use mdsio for "snapshot" (dumpfreq/diagfreq) output
C     monitor_stdio      :: use stdio for monitor output
C     dumpInitAndLast :: dumps model state to files at Initial (nIter0)
C                        & Last iteration, in addition multiple of dumpFreq iter.
C     printDomain     :: controls printing of domain fields (bathy, hFac ...).

      COMMON /PARM_L/
     & fluidIsAir, fluidIsWater,
     & usingPCoords, usingZCoords, useDynP_inEos_Zc,
     & usingCartesianGrid, usingSphericalPolarGrid, rotateGrid,
     & usingCylindricalGrid, usingCurvilinearGrid, hasWetCSCorners,
     & deepAtmosphere, setInterFDr, setCenterDr,
     & no_slip_sides, no_slip_bottom,
     & useFullLeith, useStrainTensionVisc, useAreaViscLength,
     & momViscosity, momAdvection, momForcing,
     & momPressureForcing, metricTerms, useNHMTerms,
     & useCoriolis, use3dCoriolis,
     & useCDscheme, vectorInvariantMomentum,
     & useEnergyConservingCoriolis, useJamartWetPoints, useJamartMomAdv,
     & upwindVorticity, highOrderVorticity,
     & useAbsVorticity, upwindShear,
     & momStepping, calc_wVelocity, tempStepping, saltStepping,
     & addFrictionHeating,
     & tempAdvection, tempVertDiff4, tempIsActiveTr, tempForcing,
     & saltAdvection, saltVertDiff4, saltIsActiveTr, saltForcing,
     & maskIniTemp, maskIniSalt, checkIniTemp, checkIniSalt,
     & useSRCGSolver,
     & rigidLid, implicitFreeSurface,
     & uniformLin_PhiSurf, uniformFreeSurfLev,
     & exactConserv, linFSConserveTr, useRealFreshWaterFlux,
     & quasiHydrostatic, nonHydrostatic, use3Dsolver,
     & implicitIntGravWave, staggerTimeStep, doResetHFactors,
     & implicitDiffusion, implicitViscosity,
     & tempImplVertAdv, saltImplVertAdv, momImplVertAdv,
     & multiDimAdvection, useMultiDimAdvec,
     & momDissip_In_AB, doAB_onGtGs,
     & balanceEmPmR, balanceQnet, balancePrintMean,
     & balanceThetaClimRelax, balanceSaltClimRelax,
     & doThetaClimRelax, doSaltClimRelax,
     & allowFreezing, useOldFreezing,
     & periodicExternalForcing,
     & globalFiles,
     & pickupStrictlyMatch, usePickupBeforeC54, startFromPickupAB2,
     & pickup_read_mdsio, pickup_write_mdsio, pickup_write_immed,
     & writePickupAtEnd,
     & timeave_mdsio, snapshot_mdsio, monitor_stdio,
     & outputTypesInclusive, dumpInitAndLast,
     & printDomain

      LOGICAL fluidIsAir
      LOGICAL fluidIsWater
      LOGICAL usingPCoords
      LOGICAL usingZCoords
      LOGICAL useDynP_inEos_Zc
      LOGICAL usingCartesianGrid
      LOGICAL usingSphericalPolarGrid, rotateGrid
      LOGICAL usingCylindricalGrid
      LOGICAL usingCurvilinearGrid, hasWetCSCorners
      LOGICAL deepAtmosphere
      LOGICAL setInterFDr
      LOGICAL setCenterDr

      LOGICAL no_slip_sides
      LOGICAL no_slip_bottom
      LOGICAL useFullLeith
      LOGICAL useStrainTensionVisc
      LOGICAL useAreaViscLength
      LOGICAL momViscosity
      LOGICAL momAdvection
      LOGICAL momForcing
      LOGICAL momPressureForcing
      LOGICAL metricTerms
      LOGICAL useNHMTerms

      LOGICAL useCoriolis
      LOGICAL use3dCoriolis
      LOGICAL useCDscheme
      LOGICAL vectorInvariantMomentum
      LOGICAL useEnergyConservingCoriolis
      LOGICAL useJamartWetPoints
      LOGICAL useJamartMomAdv
      LOGICAL upwindVorticity
      LOGICAL highOrderVorticity
      LOGICAL useAbsVorticity
      LOGICAL upwindShear
      LOGICAL momStepping
      LOGICAL calc_wVelocity
      LOGICAL tempStepping
      LOGICAL saltStepping
      LOGICAL addFrictionHeating
      LOGICAL tempAdvection
      LOGICAL tempVertDiff4
      LOGICAL tempIsActiveTr
      LOGICAL tempForcing
      LOGICAL saltAdvection
      LOGICAL saltVertDiff4
      LOGICAL saltIsActiveTr
      LOGICAL saltForcing
      LOGICAL maskIniTemp
      LOGICAL maskIniSalt
      LOGICAL checkIniTemp
      LOGICAL checkIniSalt
      LOGICAL useSRCGSolver
      LOGICAL rigidLid
      LOGICAL implicitFreeSurface
      LOGICAL uniformLin_PhiSurf
      LOGICAL uniformFreeSurfLev
      LOGICAL exactConserv
      LOGICAL linFSConserveTr
      LOGICAL useRealFreshWaterFlux
      LOGICAL quasiHydrostatic
      LOGICAL nonHydrostatic
      LOGICAL use3Dsolver
      LOGICAL implicitIntGravWave
      LOGICAL staggerTimeStep
      LOGICAL doResetHFactors
      LOGICAL implicitDiffusion
      LOGICAL implicitViscosity
      LOGICAL tempImplVertAdv
      LOGICAL saltImplVertAdv
      LOGICAL momImplVertAdv
      LOGICAL multiDimAdvection
      LOGICAL useMultiDimAdvec
      LOGICAL momDissip_In_AB
      LOGICAL doAB_onGtGs
      LOGICAL balanceEmPmR
      LOGICAL balanceQnet
      LOGICAL balancePrintMean
      LOGICAL doThetaClimRelax
      LOGICAL doSaltClimRelax
      LOGICAL balanceThetaClimRelax
      LOGICAL balanceSaltClimRelax
      LOGICAL allowFreezing
      LOGICAL useOldFreezing
      LOGICAL periodicExternalForcing
      LOGICAL globalFiles
      LOGICAL pickupStrictlyMatch
      LOGICAL usePickupBeforeC54
      LOGICAL startFromPickupAB2
      LOGICAL pickup_read_mdsio, pickup_write_mdsio
      LOGICAL pickup_write_immed, writePickupAtEnd
      LOGICAL timeave_mdsio, snapshot_mdsio, monitor_stdio
      LOGICAL outputTypesInclusive
      LOGICAL dumpInitAndLast
      LOGICAL printDomain

C--   COMMON /PARM_R/ "Real" valued parameters used by the model.
C     cg2dTargetResidual
C          :: Target residual for cg2d solver; no unit (RHS normalisation)
C     cg2dTargetResWunit
C          :: Target residual for cg2d solver; W unit (No RHS normalisation)
C     cg3dTargetResidual
C               :: Target residual for cg3d solver.
C     cg2dpcOffDFac :: Averaging weight for preconditioner off-diagonal.
C     Note. 20th May 1998
C           I made a weird discovery! In the model paper we argue
C           for the form of the preconditioner used here ( see
C           A Finite-volume, Incompressible Navier-Stokes Model
C           ...., Marshall et. al ). The algebra gives a simple
C           0.5 factor for the averaging of ac and aCw to get a
C           symmettric pre-conditioner. By using a factor of 0.51
C           i.e. scaling the off-diagonal terms in the
C           preconditioner down slightly I managed to get the
C           number of iterations for convergence in a test case to
C           drop form 192 -> 134! Need to investigate this further!
C           For now I have introduced a parameter cg2dpcOffDFac which
C           defaults to 0.51 but can be set at runtime.
C     delR      :: Vertical grid spacing ( units of r ).
C     delRc     :: Vertical grid spacing between cell centers (r unit).
C     delX      :: Separation between cell faces (m) or (deg), depending
C     delY         on input flags. Note: moved to header file SET_GRID.h
C     xgOrigin   :: Origin of the X-axis (Cartesian Grid) / Longitude of Western
C                :: most cell face (Lat-Lon grid) (Note: this is an "inert"
C                :: parameter but it makes geographical references simple.)
C     ygOrigin   :: Origin of the Y-axis (Cartesian Grid) / Latitude of Southern
C                :: most face (Lat-Lon grid).
C     gravity   :: Accel. due to gravity ( m/s^2 )
C     recip_gravity and its inverse
C     gBaro     :: Accel. due to gravity used in barotropic equation ( m/s^2 )
C     rhoNil    :: Reference density for the linear equation of state
C     rhoConst  :: Vertically constant reference density (Boussinesq)
C     rhoFacC   :: normalized (by rhoConst) reference density at cell-Center
C     rhoFacF   :: normalized (by rhoConst) reference density at cell-interFace
C     rhoConstFresh :: Constant reference density for fresh water (rain)
C     rho1Ref   :: reference vertical profile for density
C     tRef      :: reference vertical profile for potential temperature
C     sRef      :: reference vertical profile for salinity/specific humidity
C     phiRef    :: reference potential (pressure/rho, geopotential) profile
C     dBdrRef   :: vertical gradient of reference buoyancy  [(m/s/r)^2]:
C               :: z-coord: = N^2_ref = Brunt-Vaissala frequency [s^-2]
C               :: p-coord: = -(d.alpha/dp)_ref          [(m^2.s/kg)^2]
C     rVel2wUnit :: units conversion factor (Non-Hydrostatic code),
C                :: from r-coordinate vertical velocity to vertical velocity [m/s].
C                :: z-coord: = 1 ; p-coord: wSpeed [m/s] = rVel [Pa/s] * rVel2wUnit
C     wUnit2rVel :: units conversion factor (Non-Hydrostatic code),
C                :: from vertical velocity [m/s] to r-coordinate vertical velocity.
C                :: z-coord: = 1 ; p-coord: rVel [Pa/s] = wSpeed [m/s] * wUnit2rVel
C     mass2rUnit :: units conversion factor (surface forcing),
C                :: from mass per unit area [kg/m2] to vertical r-coordinate unit.
C                :: z-coord: = 1/rhoConst ( [kg/m2] / rho = [m] ) ;
C                :: p-coord: = gravity    ( [kg/m2] *  g = [Pa] ) ;
C     rUnit2mass :: units conversion factor (surface forcing),
C                :: from vertical r-coordinate unit to mass per unit area [kg/m2].
C                :: z-coord: = rhoConst  ( [m] * rho = [kg/m2] ) ;
C                :: p-coord: = 1/gravity ( [Pa] /  g = [kg/m2] ) ;
C     rSphere    :: Radius of sphere for a spherical polar grid ( m ).
C     recip_rSphere  :: Reciprocal radius of sphere ( m ).
C     radius_fromHorizGrid :: sphere Radius of input horiz. grid (Curvilinear Grid)
C     f0         :: Reference coriolis parameter ( 1/s )
C                   ( Southern edge f for beta plane )
C     beta       :: df/dy ( s^-1.m^-1 )
C     fPrime     :: Second Coriolis parameter ( 1/s ), related to Y-component
C                   of rotation (reference value = 2.Omega.Cos(Phi))
C     omega      :: Angular velocity ( rad/s )
C     rotationPeriod :: Rotation period (s) (= 2.pi/omega)
C     viscArNr   :: vertical profile of Eddy viscosity coeff.
C                   for vertical mixing of momentum ( units of r^2/s )
C     viscAh     :: Eddy viscosity coeff. for mixing of
C                   momentum laterally ( m^2/s )
C     viscAhW    :: Eddy viscosity coeff. for mixing of vertical
C                   momentum laterally, no effect for hydrostatic
C                   model, defaults to viscAh if unset ( m^2/s )
C                   Not used if variable horiz. viscosity is used.
C     viscA4     :: Biharmonic viscosity coeff. for mixing of
C                   momentum laterally ( m^4/s )
C     viscA4W    :: Biharmonic viscosity coeff. for mixing of vertical
C                   momentum laterally, no effect for hydrostatic
C                   model, defaults to viscA4 if unset ( m^2/s )
C                   Not used if variable horiz. viscosity is used.
C     viscAhD    :: Eddy viscosity coeff. for mixing of momentum laterally
C                   (act on Divergence part) ( m^2/s )
C     viscAhZ    :: Eddy viscosity coeff. for mixing of momentum laterally
C                   (act on Vorticity  part) ( m^2/s )
C     viscA4D    :: Biharmonic viscosity coeff. for mixing of momentum laterally
C                   (act on Divergence part) ( m^4/s )
C     viscA4Z    :: Biharmonic viscosity coeff. for mixing of momentum laterally
C                   (act on Vorticity  part) ( m^4/s )
C     viscC2leith  :: Leith non-dimensional viscosity factor (grad(vort))
C     viscC2leithD :: Modified Leith non-dimensional visc. factor (grad(div))
C     viscC4leith  :: Leith non-dimensional viscosity factor (grad(vort))
C     viscC4leithD :: Modified Leith non-dimensional viscosity factor (grad(div))
C     viscC2smag   :: Smagorinsky non-dimensional viscosity factor (harmonic)
C     viscC4smag   :: Smagorinsky non-dimensional viscosity factor (biharmonic)
C     viscAhMax    :: Maximum eddy viscosity coeff. for mixing of
C                    momentum laterally ( m^2/s )
C     viscAhReMax  :: Maximum gridscale Reynolds number for eddy viscosity
C                     coeff. for mixing of momentum laterally (non-dim)
C     viscAhGrid   :: non-dimensional grid-size dependent viscosity
C     viscAhGridMax:: maximum and minimum harmonic viscosity coefficients ...
C     viscAhGridMin::  in terms of non-dimensional grid-size dependent visc.
C     viscA4Max    :: Maximum biharmonic viscosity coeff. for mixing of
C                     momentum laterally ( m^4/s )
C     viscA4ReMax  :: Maximum Gridscale Reynolds number for
C                     biharmonic viscosity coeff. momentum laterally (non-dim)
C     viscA4Grid   :: non-dimensional grid-size dependent bi-harmonic viscosity
C     viscA4GridMax:: maximum and minimum biharmonic viscosity coefficients ...
C     viscA4GridMin::  in terms of non-dimensional grid-size dependent viscosity
C     diffKhT   :: Laplacian diffusion coeff. for mixing of
C                 heat laterally ( m^2/s )
C     diffK4T   :: Biharmonic diffusion coeff. for mixing of
C                 heat laterally ( m^4/s )
C     diffKrNrT :: vertical profile of Laplacian diffusion coeff.
C                 for mixing of heat vertically ( units of r^2/s )
C     diffKr4T  :: vertical profile of Biharmonic diffusion coeff.
C                 for mixing of heat vertically ( units of r^4/s )
C     diffKhS  ::  Laplacian diffusion coeff. for mixing of
C                 salt laterally ( m^2/s )
C     diffK4S   :: Biharmonic diffusion coeff. for mixing of
C                 salt laterally ( m^4/s )
C     diffKrNrS :: vertical profile of Laplacian diffusion coeff.
C                 for mixing of salt vertically ( units of r^2/s ),
C     diffKr4S  :: vertical profile of Biharmonic diffusion coeff.
C                 for mixing of salt vertically ( units of r^4/s )
C     diffKrBL79surf :: T/S surface diffusivity (m^2/s) Bryan and Lewis, 1979
C     diffKrBL79deep :: T/S deep diffusivity (m^2/s) Bryan and Lewis, 1979
C     diffKrBL79scl  :: depth scale for arctan fn (m) Bryan and Lewis, 1979
C     diffKrBL79Ho   :: depth offset for arctan fn (m) Bryan and Lewis, 1979
C     BL79LatVary    :: polarwise of this latitude diffKrBL79 is applied with
C                       gradual transition to diffKrBLEQ towards Equator
C     diffKrBLEQsurf :: same as diffKrBL79surf but at Equator
C     diffKrBLEQdeep :: same as diffKrBL79deep but at Equator
C     diffKrBLEQscl  :: same as diffKrBL79scl but at Equator
C     diffKrBLEQHo   :: same as diffKrBL79Ho but at Equator
C     deltaT    :: Default timestep ( s )
C     deltaTClock  :: Timestep used as model "clock". This determines the
C                    IO frequencies and is used in tagging output. It can
C                    be totally different to the dynamical time. Typically
C                    it will be the deep-water timestep for accelerated runs.
C                    Frequency of checkpointing and dumping of the model state
C                    are referenced to this clock. ( s )
C     deltaTMom    :: Timestep for momemtum equations ( s )
C     dTtracerLev  :: Timestep for tracer equations ( s ), function of level k
C     deltaTFreeSurf :: Timestep for free-surface equation ( s )
C     freeSurfFac  :: Parameter to turn implicit free surface term on or off
C                     freeSurFac = 1. uses implicit free surface
C                     freeSurFac = 0. uses rigid lid
C     abEps        :: Adams-Bashforth-2 stabilizing weight
C     alph_AB      :: Adams-Bashforth-3 primary factor
C     beta_AB      :: Adams-Bashforth-3 secondary factor
C     implicSurfPress :: parameter of the Crank-Nickelson time stepping :
C                     Implicit part of Surface Pressure Gradient ( 0-1 )
C     implicDiv2Dflow :: parameter of the Crank-Nickelson time stepping :
C                     Implicit part of barotropic flow Divergence ( 0-1 )
C     implicitNHPress :: parameter of the Crank-Nickelson time stepping :
C                     Implicit part of Non-Hydrostatic Pressure Gradient ( 0-1 )
C     hFacMin      :: Minimum fraction size of a cell (affects hFacC etc...)
C     hFacMinDz    :: Minimum dimensional size of a cell (affects hFacC etc..., m)
C     hFacMinDp    :: Minimum dimensional size of a cell (affects hFacC etc..., Pa)
C     hFacMinDr    :: Minimum dimensional size of a cell (-> hFacC etc..., r units)
C     hFacInf      :: Threshold (inf and sup) for fraction size of surface cell
C     hFacSup          that control vanishing and creating levels
C     tauCD         :: CD scheme coupling timescale ( s )
C     rCD           :: CD scheme normalised coupling parameter (= 1 - deltaT/tauCD)
C     epsAB_CD      :: Adams-Bashforth-2 stabilizing weight used in CD scheme
C     baseTime      :: model base time (time origin) = time @ iteration zero
C     startTime     :: Starting time for this integration ( s ).
C     endTime       :: Ending time for this integration ( s ).
C     chkPtFreq     :: Frequency of rolling check pointing ( s ).
C     pChkPtFreq    :: Frequency of permanent check pointing ( s ).
C     dumpFreq      :: Frequency with which model state is written to
C                      post-processing files ( s ).
C     diagFreq      :: Frequency with which model writes diagnostic output
C                      of intermediate quantities.
C     afFacMom      :: Advection of momentum term tracer parameter
C     vfFacMom      :: Momentum viscosity tracer parameter
C     pfFacMom      :: Momentum pressure forcing tracer parameter
C     cfFacMom      :: Coriolis term tracer parameter
C     foFacMom      :: Momentum forcing tracer parameter
C     mtFacMom      :: Metric terms tracer parameter
C     cosPower      :: Power of cosine of latitude to multiply viscosity
C     cAdjFreq      :: Frequency of convective adjustment
C
C     taveFreq      :: Frequency with which time-averaged model state
C                      is written to post-processing files ( s ).
C     tave_lastIter :: (for state variable only) fraction of the last time
C                      step (of each taveFreq period) put in the time average.
C                      (fraction for 1rst iter = 1 - tave_lastIter)
C     tauThetaClimRelax :: Relaxation to climatology time scale ( s ).
C     tauSaltClimRelax :: Relaxation to climatology time scale ( s ).
C     latBandClimRelax :: latitude band where Relaxation to Clim. is applied,
C                         i.e. where |yC| <= latBandClimRelax
C     externForcingPeriod :: Is the period of which forcing varies (eg. 1 month)
C     externForcingCycle :: Is the repeat time of the forcing (eg. 1 year)
C                          (note: externForcingCycle must be an integer
C                           number times externForcingPeriod)
C     convertFW2Salt :: salinity, used to convert Fresh-Water Flux to Salt Flux
C                       (use model surface (local) value if set to -1)
C     temp_EvPrRn :: temperature of Rain & Evap.
C     salt_EvPrRn :: salinity of Rain & Evap.
C     temp_addMass :: temperature of addMass array
C     salt_addMass :: salinity of addMass array
C        (notes: a) tracer content of Rain/Evap only used if both
C                     NonLin_FrSurf & useRealFreshWater are set.
C                b) use model surface (local) value if set to UNSET_RL)
C     hMixCriteria:: criteria for mixed-layer diagnostic
C     dRhoSmall   :: parameter for mixed-layer diagnostic
C     hMixSmooth  :: Smoothing parameter for mixed-layer diag (default=0=no smoothing)
C     ivdc_kappa  :: implicit vertical diffusivity for convection [m^2/s]
C     Ro_SeaLevel :: standard position of Sea-Level in "R" coordinate, used as
C                    starting value (k=1) for vertical coordinate (rf(1)=Ro_SeaLevel)
C     rSigmaBnd   :: vertical position (in r-unit) of r/sigma transition (Hybrid-Sigma)
C     sideDragFactor     :: side-drag scaling factor (used only if no_slip_sides)
C                           (default=2: full drag ; =1: gives half-slip BC)
C     bottomDragLinear    :: Linear    bottom-drag coefficient (units of [r]/s)
C     bottomDragQuadratic :: Quadratic bottom-drag coefficient (units of [r]/m)
C               (if using zcoordinate, units becomes linear: m/s, quadratic: [-])
C     smoothAbsFuncRange :: 1/2 of interval around zero, for which FORTRAN ABS
C                           is to be replace by a smoother function
C                           (affects myabs, mymin, mymax)
C     nh_Am2        :: scales the non-hydrostatic terms and changes internal scales
C                      (i.e. allows convection at different Rayleigh numbers)
C     tCylIn        :: Temperature of the cylinder inner boundary
C     tCylOut       :: Temperature of the cylinder outer boundary
C     phiEuler      :: Euler angle, rotation about original z-axis
C     thetaEuler    :: Euler angle, rotation about new x-axis
C     psiEuler      :: Euler angle, rotation about new z-axis
      COMMON /PARM_R/ cg2dTargetResidual, cg2dTargetResWunit,
     & cg2dpcOffDFac, cg3dTargetResidual,
     & delR, delRc, xgOrigin, ygOrigin,
     & deltaT, deltaTMom, dTtracerLev, deltaTFreeSurf, deltaTClock,
     & abEps, alph_AB, beta_AB,
     & rSphere, recip_rSphere, radius_fromHorizGrid,
     & f0, beta, fPrime, omega, rotationPeriod,
     & viscFacAdj, viscAh, viscAhW, viscAhMax,
     & viscAhGrid, viscAhGridMax, viscAhGridMin,
     & viscC2leith, viscC2leithD,
     & viscC2smag, viscC4smag,
     & viscAhD, viscAhZ, viscA4D, viscA4Z,
     & viscA4, viscA4W, viscA4Max,
     & viscA4Grid, viscA4GridMax, viscA4GridMin,
     & viscAhReMax, viscA4ReMax,
     & viscC4leith, viscC4leithD, viscArNr,
     & diffKhT, diffK4T, diffKrNrT, diffKr4T,
     & diffKhS, diffK4S, diffKrNrS, diffKr4S,
     & diffKrBL79surf, diffKrBL79deep, diffKrBL79scl, diffKrBL79Ho,
     & BL79LatVary,
     & diffKrBLEQsurf, diffKrBLEQdeep, diffKrBLEQscl, diffKrBLEQHo,
     & tauCD, rCD, epsAB_CD,
     & freeSurfFac, implicSurfPress, implicDiv2Dflow, implicitNHPress,
     & hFacMin, hFacMinDz, hFacInf, hFacSup,
     & gravity, recip_gravity, gBaro,
     & rhoNil, rhoConst, recip_rhoConst,
     & rhoFacC, recip_rhoFacC, rhoFacF, recip_rhoFacF,
     & rhoConstFresh, rho1Ref, tRef, sRef, phiRef, dBdrRef,
     & rVel2wUnit, wUnit2rVel, mass2rUnit, rUnit2mass,
     & baseTime, startTime, endTime,
     & chkPtFreq, pChkPtFreq, dumpFreq, adjDumpFreq,
     & diagFreq, taveFreq, tave_lastIter, monitorFreq, adjMonitorFreq,
     & afFacMom, vfFacMom, pfFacMom, cfFacMom, foFacMom, mtFacMom,
     & cosPower, cAdjFreq,
     & tauThetaClimRelax, tauSaltClimRelax, latBandClimRelax,
     & externForcingCycle, externForcingPeriod,
     & convertFW2Salt, temp_EvPrRn, salt_EvPrRn,
     & temp_addMass, salt_addMass, hFacMinDr, hFacMinDp,
     & ivdc_kappa, hMixCriteria, dRhoSmall, hMixSmooth,
     & Ro_SeaLevel, rSigmaBnd,
     & sideDragFactor, bottomDragLinear, bottomDragQuadratic, nh_Am2,
     & smoothAbsFuncRange,
     & tCylIn, tCylOut,
     & phiEuler, thetaEuler, psiEuler

      Real*8 cg2dTargetResidual
      Real*8 cg2dTargetResWunit
      Real*8 cg3dTargetResidual
      Real*8 cg2dpcOffDFac
      Real*8 delR(Nr)
      Real*8 delRc(Nr+1)
      Real*8 xgOrigin
      Real*8 ygOrigin
      Real*8 deltaT
      Real*8 deltaTClock
      Real*8 deltaTMom
      Real*8 dTtracerLev(Nr)
      Real*8 deltaTFreeSurf
      Real*8 abEps, alph_AB, beta_AB
      Real*8 rSphere
      Real*8 recip_rSphere
      Real*8 radius_fromHorizGrid
      Real*8 f0
      Real*8 beta
      Real*8 fPrime
      Real*8 omega
      Real*8 rotationPeriod
      Real*8 freeSurfFac
      Real*8 implicSurfPress
      Real*8 implicDiv2Dflow
      Real*8 implicitNHPress
      Real*8 hFacMin
      Real*8 hFacMinDz
      Real*8 hFacMinDp
      Real*8 hFacMinDr
      Real*8 hFacInf
      Real*8 hFacSup
      Real*8 viscArNr(Nr)
      Real*8 viscFacAdj
      Real*8 viscAh
      Real*8 viscAhW
      Real*8 viscAhD
      Real*8 viscAhZ
      Real*8 viscAhMax
      Real*8 viscAhReMax
      Real*8 viscAhGrid, viscAhGridMax, viscAhGridMin
      Real*8 viscC2leith
      Real*8 viscC2leithD
      Real*8 viscC2smag
      Real*8 viscA4
      Real*8 viscA4W
      Real*8 viscA4D
      Real*8 viscA4Z
      Real*8 viscA4Max
      Real*8 viscA4ReMax
      Real*8 viscA4Grid, viscA4GridMax, viscA4GridMin
      Real*8 viscC4leith
      Real*8 viscC4leithD
      Real*8 viscC4smag
      Real*8 diffKhT
      Real*8 diffK4T
      Real*8 diffKrNrT(Nr)
      Real*8 diffKr4T(Nr)
      Real*8 diffKhS
      Real*8 diffK4S
      Real*8 diffKrNrS(Nr)
      Real*8 diffKr4S(Nr)
      Real*8 diffKrBL79surf
      Real*8 diffKrBL79deep
      Real*8 diffKrBL79scl
      Real*8 diffKrBL79Ho
      Real*8 BL79LatVary
      Real*8 diffKrBLEQsurf
      Real*8 diffKrBLEQdeep
      Real*8 diffKrBLEQscl
      Real*8 diffKrBLEQHo
      Real*8 tauCD, rCD, epsAB_CD
      Real*8 gravity
      Real*8 recip_gravity
      Real*8 gBaro
      Real*8 rhoNil
      Real*8 rhoConst,      recip_rhoConst
      Real*8 rhoFacC(Nr),   recip_rhoFacC(Nr)
      Real*8 rhoFacF(Nr+1), recip_rhoFacF(Nr+1)
      Real*8 rhoConstFresh
      Real*8 rho1Ref(Nr)
      Real*8 tRef(Nr)
      Real*8 sRef(Nr)
      Real*8 phiRef(2*Nr+1)
      Real*8 dBdrRef(Nr)
      Real*8 rVel2wUnit(Nr+1), wUnit2rVel(Nr+1)
      Real*8 mass2rUnit, rUnit2mass
      Real*8 baseTime
      Real*8 startTime
      Real*8 endTime
      Real*8 chkPtFreq
      Real*8 pChkPtFreq
      Real*8 dumpFreq
      Real*8 adjDumpFreq
      Real*8 diagFreq
      Real*8 taveFreq
      Real*8 tave_lastIter
      Real*8 monitorFreq
      Real*8 adjMonitorFreq
      Real*8 afFacMom
      Real*8 vfFacMom
      Real*8 pfFacMom
      Real*8 cfFacMom
      Real*8 foFacMom
      Real*8 mtFacMom
      Real*8 cosPower
      Real*8 cAdjFreq
      Real*8 tauThetaClimRelax
      Real*8 tauSaltClimRelax
      Real*8 latBandClimRelax
      Real*8 externForcingCycle
      Real*8 externForcingPeriod
      Real*8 convertFW2Salt
      Real*8 temp_EvPrRn
      Real*8 salt_EvPrRn
      Real*8 temp_addMass
      Real*8 salt_addMass
      Real*8 ivdc_kappa
      Real*8 hMixCriteria
      Real*8 dRhoSmall
      Real*8 hMixSmooth
      Real*8 Ro_SeaLevel
      Real*8 rSigmaBnd
      Real*8 sideDragFactor
      Real*8 bottomDragLinear
      Real*8 bottomDragQuadratic
      Real*8 smoothAbsFuncRange
      Real*8 nh_Am2
      Real*8 tCylIn, tCylOut
      Real*8 phiEuler, thetaEuler, psiEuler

C--   COMMON /PARM_A/ Thermodynamics constants ?
      COMMON /PARM_A/ HeatCapacity_Cp,recip_Cp
      Real*8 HeatCapacity_Cp
      Real*8 recip_Cp

C--   COMMON /PARM_ATM/ Atmospheric physical parameters (Ideal Gas EOS, ...)
C     celsius2K :: convert centigrade (Celsius) degree to Kelvin
C     atm_Po    :: standard reference pressure
C     atm_Cp    :: specific heat (Cp) of the (dry) air at constant pressure
C     atm_Rd    :: gas constant for dry air
C     atm_kappa :: kappa = R/Cp (R: constant of Ideal Gas EOS)
C     atm_Rq    :: water vapour specific volume anomaly relative to dry air
C                  (e.g. typical value = (29/18 -1) 10^-3 with q [g/kg])
C     integr_GeoPot :: option to select the way we integrate the geopotential
C                     (still a subject of discussions ...)
C     selectFindRoSurf :: select the way surf. ref. pressure (=Ro_surf) is
C             derived from the orography. Implemented: 0,1 (see INI_P_GROUND)
      COMMON /PARM_ATM/
     &            celsius2K,
     &            atm_Cp, atm_Rd, atm_kappa, atm_Rq, atm_Po,
     &            integr_GeoPot, selectFindRoSurf
      Real*8 celsius2K
      Real*8 atm_Po, atm_Cp, atm_Rd, atm_kappa, atm_Rq
      INTEGER integr_GeoPot, selectFindRoSurf

C Logical flags for selecting packages
      LOGICAL useGAD
      LOGICAL useOBCS
      LOGICAL useSHAP_FILT
      LOGICAL useZONAL_FILT
      LOGICAL useOPPS
      LOGICAL usePP81
      LOGICAL useMY82
      LOGICAL useGGL90
      LOGICAL useKPP
      LOGICAL useGMRedi
      LOGICAL useDOWN_SLOPE
      LOGICAL useBBL
      LOGICAL useCAL
      LOGICAL useEXF
      LOGICAL useBulkForce
      LOGICAL useEBM
      LOGICAL useCheapAML
      LOGICAL useGrdchk
      LOGICAL useSMOOTH
      LOGICAL usePROFILES
      LOGICAL useECCO
      LOGICAL useSBO
      LOGICAL useFLT
      LOGICAL usePTRACERS
      LOGICAL useGCHEM
      LOGICAL useRBCS
      LOGICAL useOffLine
      LOGICAL useMATRIX
      LOGICAL useFRAZIL
      LOGICAL useSEAICE
      LOGICAL useSALT_PLUME
      LOGICAL useShelfIce
      LOGICAL useStreamIce
      LOGICAL useICEFRONT
      LOGICAL useThSIce
      LOGICAL useATM2d
      LOGICAL useAIM
      LOGICAL useLand
      LOGICAL useFizhi
      LOGICAL useGridAlt
      LOGICAL useDiagnostics
      LOGICAL useREGRID
      LOGICAL useLayers
      LOGICAL useMNC
      LOGICAL useRunClock
      LOGICAL useEMBED_FILES
      LOGICAL useMYPACKAGE
      COMMON /PARM_PACKAGES/
     &        useGAD, useOBCS, useSHAP_FILT, useZONAL_FILT,
     &        useOPPS, usePP81, useMY82, useGGL90, useKPP,
     &        useGMRedi, useBBL, useDOWN_SLOPE,
     &        useCAL, useEXF, useBulkForce, useEBM, useCheapAML,
     &        useGrdchk,useSMOOTH,usePROFILES,useECCO,useSBO, useFLT,
     &        usePTRACERS, useGCHEM, useRBCS, useOffLine, useMATRIX,
     &        useFRAZIL, useSEAICE, useSALT_PLUME, useShelfIce,
     &        useStreamIce, useICEFRONT, useThSIce,
     &        useATM2D, useAIM, useLand, useFizhi, useGridAlt,
     &        useDiagnostics, useREGRID, useLayers, useMNC,
     &        useRunClock, useEMBED_FILES,
     &        useMYPACKAGE

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
C $Header: /u/gcmpack/MITgcm/model/inc/GRID.h,v 1.42 2013/02/17 02:08:13 jmc Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: GRID.h
C    !INTERFACE:
C    include GRID.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | GRID.h
C     | o Header file defining model grid.
C     *==========================================================*
C     | Model grid is defined for each process by reference to
C     | the arrays set here.
C     | Notes
C     | =====
C     | The standard MITgcm convention of westmost, southern most
C     | and upper most having the (1,1,1) index is used here.
C     | i.e.
C     |----------------------------------------------------------
C     | (1)  Plan view schematic of model grid (top layer i.e. )
C     |      ================================= ( ocean surface )
C     |                                        ( or top of     )
C     |                                        ( atmosphere    )
C     |      This diagram shows the location of the model
C     |      prognostic variables on the model grid. The "T"
C     |      location is used for all tracers. The figure also
C     |      shows the southern most, western most indexing
C     |      convention that is used for all model variables.
C     |
C     |
C     |             V(i=1,                     V(i=Nx,
C     |               j=Ny+1,                    j=Ny+1,
C     |               k=1)                       k=1)
C     |                /|\                       /|\  "PWX"
C     |       |---------|------------------etc..  |---- *---
C     |       |                     |                   *  |
C     |"PWY"*******************************etc..  **********"PWY"
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |U(i=1, ==>       x           |             x     *==>U
C     |  j=Ny,|      T(i=1,         |          T(i=Nx,  *(i=Nx+1,
C     |  k=1) |        j=Ny,        |            j=Ny,  *  |j=Ny,
C     |       |        k=1)         |            k=1)   *  |k=1)
C     |
C     |       .                     .                      .
C     |       .                     .                      .
C     |       .                     .                      .
C     |       e                     e                   *  e
C     |       t                     t                   *  t
C     |       c                     c                   *  c
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |U(i=1, ==>       x           |             x     *  |
C     |  j=2, |      T(i=1,         |          T(i=Nx,  *  |
C     |  k=1) |        j=2,         |            j=2,   *  |
C     |       |        k=1)         |            k=1)   *  |
C     |       |                     |                   *  |
C     |       |        /|\          |            /|\    *  |
C     |      -----------|------------------etc..  |-----*---
C     |       |       V(i=1,        |           V(i=Nx, *  |
C     |       |         j=2,        |             j=2,  *  |
C     |       |         k=1)        |             k=1)  *  |
C     |       |                     |                   *  |
C     |U(i=1, ==>       x         ==>U(i=2,       x     *==>U
C     |  j=1, |      T(i=1,         |  j=1,    T(i=Nx,  *(i=Nx+1,
C     |  k=1) |        j=1,         |  k=1)      j=1,   *  |j=1,
C     |       |        k=1)         |            k=1)   *  |k=1)
C     |       |                     |                   *  |
C     |       |        /|\          |            /|\    *  |
C     |"SB"++>|---------|------------------etc..  |-----*---
C     |      /+\      V(i=1,                    V(i=Nx, *
C     |       +         j=1,                      j=1,  *
C     |       +         k=1)                      k=1)  *
C     |     "WB"                                      "PWX"
C     |
C     |   N, y increasing northwards
C     |  /|\ j increasing northwards
C     |   |
C     |   |
C     |   ======>E, x increasing eastwards
C     |             i increasing eastwards
C     |
C     |    i: East-west index
C     |    j: North-south index
C     |    k: up-down index
C     |    U: x-velocity (m/s)
C     |    V: y-velocity (m/s)
C     |    T: potential temperature (oC)
C     | "SB": Southern boundary
C     | "WB": Western boundary
C     |"PWX": Periodic wrap around in X.
C     |"PWY": Periodic wrap around in Y.
C     |----------------------------------------------------------
C     | (2) South elevation schematic of model grid
C     |     =======================================
C     |     This diagram shows the location of the model
C     |     prognostic variables on the model grid. The "T"
C     |     location is used for all tracers. The figure also
C     |     shows the upper most, western most indexing
C     |     convention that is used for all model variables.
C     |
C     |      "WB"
C     |       +
C     |       +
C     |      \+/       /|\                       /|\       .
C     |"UB"++>|-------- | -----------------etc..  | ----*---
C     |       |    rVel(i=1,        |        rVel(i=Nx, *  |
C     |       |         j=1,        |             j=1,  *  |
C     |       |         k=1)        |             k=1)  *  |
C     |       |                     |                   *  |
C     |U(i=1, ==>       x         ==>U(i=2,       x     *==>U
C     |  j=1, |      T(i=1,         |  j=1,    T(i=Nx,  *(i=Nx+1,
C     |  k=1) |        j=1,         |  k=1)      j=1,   *  |j=1,
C     |       |        k=1)         |            k=1)   *  |k=1)
C     |       |                     |                   *  |
C     |       |        /|\          |            /|\    *  |
C     |       |-------- | -----------------etc..  | ----*---
C     |       |    rVel(i=1,        |        rVel(i=Nx, *  |
C     |       |         j=1,        |             j=1,  *  |
C     |       |         k=2)        |             k=2)  *  |
C     |
C     |       .                     .                      .
C     |       .                     .                      .
C     |       .                     .                      .
C     |       e                     e                   *  e
C     |       t                     t                   *  t
C     |       c                     c                   *  c
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |       |                     |                   *  |
C     |       |        /|\          |            /|\    *  |
C     |       |-------- | -----------------etc..  | ----*---
C     |       |    rVel(i=1,        |        rVel(i=Nx, *  |
C     |       |         j=1,        |             j=1,  *  |
C     |       |         k=Nr)       |             k=Nr) *  |
C     |U(i=1, ==>       x         ==>U(i=2,       x     *==>U
C     |  j=1, |      T(i=1,         |  j=1,    T(i=Nx,  *(i=Nx+1,
C     |  k=Nr)|        j=1,         |  k=Nr)     j=1,   *  |j=1,
C     |       |        k=Nr)        |            k=Nr)  *  |k=Nr)
C     |       |                     |                   *  |
C     |"LB"++>==============================================
C     |                                               "PWX"
C     |
C     | Up   increasing upwards.
C     |/|\                                                       .
C     | |
C     | |
C     | =====> E  i increasing eastwards
C     | |         x increasing eastwards
C     | |
C     |\|/
C     | Down,k increasing downwards.
C     |
C     | Note: r => height (m) => r increases upwards
C     |       r => pressure (Pa) => r increases downwards
C     |
C     |
C     |    i: East-west index
C     |    j: North-south index
C     |    k: up-down index
C     |    U: x-velocity (m/s)
C     | rVel: z-velocity ( units of r )
C     |       The vertical velocity variable rVel is in units of
C     |       "r" the vertical coordinate. r in m will give
C     |       rVel m/s. r in Pa will give rVel Pa/s.
C     |    T: potential temperature (oC)
C     | "UB": Upper boundary.
C     | "LB": Lower boundary (always solid - therefore om|w == 0)
C     | "WB": Western boundary
C     |"PWX": Periodic wrap around in X.
C     |----------------------------------------------------------
C     | (3) Views showing nomenclature and indexing
C     |     for grid descriptor variables.
C     |
C     |      Fig 3a. shows the orientation, indexing and
C     |      notation for the grid spacing terms used internally
C     |      for the evaluation of gradient and averaging terms.
C     |      These varaibles are set based on the model input
C     |      parameters which define the model grid in terms of
C     |      spacing in X, Y and Z.
C     |
C     |      Fig 3b. shows the orientation, indexing and
C     |      notation for the variables that are used to define
C     |      the model grid. These varaibles are set directly
C     |      from the model input.
C     |
C     | Figure 3a
C     | =========
C     |       |------------------------------------
C     |       |                       |
C     |"PWY"********************************* etc...
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |
C     |       .                       .
C     |       .                       .
C     |       .                       .
C     |       e                       e
C     |       t                       t
C     |       c                       c
C     |       |-----------v-----------|-----------v----------|-
C     |       |                       |                      |
C     |       |                       |                      |
C     |       |                       |                      |
C     |       |                       |                      |
C     |       |                       |                      |
C     |       u<--dxF(i=1,j=2,k=1)--->u           t          |
C     |       |/|\       /|\          |                      |
C     |       | |         |           |                      |
C     |       | |         |           |                      |
C     |       | |         |           |                      |
C     |       |dyU(i=1,  dyC(i=1,     |                      |
C     | ---  ---|--j=2,---|--j=2,-----------------v----------|-
C     | /|\   | |  k=1)   |  k=1)     |          /|\         |
C     |  |    | |         |           |          dyF(i=2,    |
C     |  |    | |         |           |           |  j=1,    |
C     |dyG(   |\|/       \|/          |           |  k=1)    |
C     |   i=1,u---        t<---dxC(i=2,j=1,k=1)-->t          |
C     |   j=1,|                       |           |          |
C     |   k=1)|                       |           |          |
C     |  |    |                       |           |          |
C     |  |    |                       |           |          |
C     | \|/   |           |<---dxV(i=2,j=1,k=1)--\|/         |
C     |"SB"++>|___________v___________|___________v__________|_
C     |       <--dxG(i=1,j=1,k=1)----->
C     |      /+\                                              .
C     |       +
C     |       +
C     |     "WB"
C     |
C     |   N, y increasing northwards
C     |  /|\ j increasing northwards
C     |   |
C     |   |
C     |   ======>E, x increasing eastwards
C     |             i increasing eastwards
C     |
C     |    i: East-west index
C     |    j: North-south index
C     |    k: up-down index
C     |    u: x-velocity point
C     |    V: y-velocity point
C     |    t: tracer point
C     | "SB": Southern boundary
C     | "WB": Western boundary
C     |"PWX": Periodic wrap around in X.
C     |"PWY": Periodic wrap around in Y.
C     |
C     | Figure 3b
C     | =========
C     |
C     |       .                       .
C     |       .                       .
C     |       .                       .
C     |       e                       e
C     |       t                       t
C     |       c                       c
C     |       |-----------v-----------|-----------v--etc...
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       u<--delX(i=1)---------->u           t
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |                       |
C     |       |-----------v-----------------------v--etc...
C     |       |          /|\          |
C     |       |           |           |
C     |       |           |           |
C     |       |           |           |
C     |       u        delY(j=1)      |           t
C     |       |           |           |
C     |       |           |           |
C     |       |           |           |
C     |       |           |           |
C     |       |          \|/          |
C     |"SB"++>|___________v___________|___________v__etc...
C     |      /+\                                                 .
C     |       +
C     |       +
C     |     "WB"
C     |
C     *==========================================================*
C     \ev
CEOP

C     Macros that override/modify standard definitions
C $Header: /u/gcmpack/MITgcm/model/inc/GRID_MACROS.h,v 1.12 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: GRID_MACROS.h
C    !INTERFACE:
C    include GRID_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | GRID_MACROS.h                                             
C     *==========================================================*
C     | These macros are used to substitute definitions for       
C     | GRID.h variables for particular configurations.           
C     | In setting these variables the following convention       
C     | applies.                                                  
C     | undef  phi_CONST   - Indicates the variable phi is fixed  
C     |                      in X, Y and Z.                       
C     | undef  phi_FX      - Indicates the variable phi only      
C     |                      varies in X (i.e.not in X or Z).     
C     | undef  phi_FY      - Indicates the variable phi only      
C     |                      varies in Y (i.e.not in X or Z).     
C     | undef  phi_FXY     - Indicates the variable phi only      
C     |                      varies in X and Y ( i.e. not Z).     
C     *==========================================================*
C     \ev
CEOP

C $Header: /u/gcmpack/MITgcm/model/inc/DXC_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DXC_MACROS.h
C    !INTERFACE:
C    include DXC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DXC_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DXF_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DXF_MACROS.h
C    !INTERFACE:
C    include DXF_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DXF_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DXG_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DXG_MACROS.h
C    !INTERFACE:
C    include DXG_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DXG_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DXV_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DXV_MACROS.h
C    !INTERFACE:
C    include DXV_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DXV_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DYC_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DYC_MACROS.h
C    !INTERFACE:
C    include DYC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DYC_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DYF_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DYF_MACROS.h
C    !INTERFACE:
C    include DYF_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DYF_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DYG_MACROS.h,v 1.4 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DYG_MACROS.h
C    !INTERFACE:
C    include DYG_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DYG_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/DYU_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: DYU_MACROS.h
C    !INTERFACE:
C    include DYU_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | DYU_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/HFACC_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: HFACC_MACROS.h
C    !INTERFACE:
C    include HFACC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | HFACC_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/HFACS_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: HFACS_MACROS.h
C    !INTERFACE:
C    include HFACS_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | HFACS_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/HFACW_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: HFACW_MACROS.h
C    !INTERFACE:
C    include HFACW_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | HFACW_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DXC_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DXC_MACROS.h
C    !INTERFACE:
C    include RECIP_DXC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DXC_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DXF_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DXF_MACROS.h
C    !INTERFACE:
C    include RECIP_DXF_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DXF_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DXG_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DXG_MACROS.h
C    !INTERFACE:
C    include RECIP_DXG_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DXG_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DXV_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DXV_MACROS.h
C    !INTERFACE:
C    include RECIP_DXV_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DXV_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DYC_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DYC_MACROS.h
C    !INTERFACE:
C    include RECIP_DYC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DYC_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DYF_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DYF_MACROS.h
C    !INTERFACE:
C    include RECIP_DYF_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DYF_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DYG_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DYG_MACROS.h
C    !INTERFACE:
C    include RECIP_DYG_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DYG_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_DYU_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_DYU_MACROS.h
C    !INTERFACE:
C    include RECIP_DYU_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_DYU_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_HFACC_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_HFACC_MACROS.h
C    !INTERFACE:
C    include RECIP_HFACC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_HFACC_MACROS.h                                      
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_HFACS_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_HFACS_MACROS.h
C    !INTERFACE:
C    include RECIP_HFACS_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_HFACS_MACROS.h                                      
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/RECIP_HFACW_MACROS.h,v 1.4 2006/06/07 01:55:12 heimbach Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RECIP_HFACW_MACROS.h
C    !INTERFACE:
C    include RECIP_HFACW_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RECIP_HFACW_MACROS.h                                      
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP







C $Header: /u/gcmpack/MITgcm/model/inc/XC_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: XC_MACROS.h
C    !INTERFACE:
C    include XC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | XC_MACROS.h                                               
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/YC_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: YC_MACROS.h
C    !INTERFACE:
C    include YC_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | YC_MACROS.h                                               
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/RA_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RA_MACROS.h
C    !INTERFACE:
C    include RA_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RA_MACROS.h                                               
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP




C $Header: /u/gcmpack/MITgcm/model/inc/RAW_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RAW_MACROS.h
C    !INTERFACE:
C    include RAW_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RAW_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP




C $Header: /u/gcmpack/MITgcm/model/inc/RAS_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: RAS_MACROS.h
C    !INTERFACE:
C    include RAS_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | RAS_MACROS.h                                              
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/MASKW_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: MASKW_MACROS.h
C    !INTERFACE:
C    include MASKW_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | MASKW_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP






C $Header: /u/gcmpack/MITgcm/model/inc/MASKS_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: MASKS_MACROS.h
C    !INTERFACE:
C    include MASKS_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | MASKS_MACROS.h                                            
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP






C $Header: /u/gcmpack/MITgcm/model/inc/TANPHIATU_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: TANPHIATU_MACROS.h
C    !INTERFACE:
C    include TANPHIATU_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | TANPHIATU_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C $Header: /u/gcmpack/MITgcm/model/inc/TANPHIATV_MACROS.h,v 1.3 2001/09/21 15:13:31 cnh Exp $
C $Name: checkpoint64g $
C
CBOP
C    !ROUTINE: TANPHIATV_MACROS.h
C    !INTERFACE:
C    include TANPHIATV_MACROS.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | TANPHIATV_MACROS.h                                        
C     *==========================================================*
C     | These macros are used to reduce memory requirement and/or 
C     | memory references when variables are fixed along a given  
C     | axis or axes.                                             
C     *==========================================================*
C     \ev
CEOP





C--   COMMON /GRID_RL/ RL valued grid defining variables.
C     deepFacC  :: deep-model grid factor (fct of vertical only) for dx,dy
C     deepFacF     at level-center (deepFacC)  and level interface (deepFacF)
C     deepFac2C :: deep-model grid factor (fct of vertical only) for area dx*dy
C     deepFac2F    at level-center (deepFac2C) and level interface (deepFac2F)
C     gravitySign :: indicates the direction of gravity relative to R direction
C                   (= -1 for R=Z (Z increases upward, -gravity direction  )
C                   (= +1 for R=P (P increases downward, +gravity direction)
C     rkSign     :: Vertical coordinate to vertical index orientation.
C                   ( +1 same orientation, -1 opposite orientation )
C     globalArea :: Domain Integrated horizontal Area [m2]
      COMMON /GRID_RL/
     &  cosFacU, cosFacV, sqCosFacU, sqCosFacV,
     &  deepFacC, deepFac2C, recip_deepFacC, recip_deepFac2C,
     &  deepFacF, deepFac2F, recip_deepFacF, recip_deepFac2F,
     &  gravitySign, rkSign, globalArea
      Real*8 cosFacU        (1-Oly:sNy+Oly,nSx,nSy)
      Real*8 cosFacV        (1-Oly:sNy+Oly,nSx,nSy)
      Real*8 sqCosFacU      (1-Oly:sNy+Oly,nSx,nSy)
      Real*8 sqCosFacV      (1-Oly:sNy+Oly,nSx,nSy)
      Real*8 deepFacC       (Nr)
      Real*8 deepFac2C      (Nr)
      Real*8 deepFacF       (Nr+1)
      Real*8 deepFac2F      (Nr+1)
      Real*8 recip_deepFacC (Nr)
      Real*8 recip_deepFac2C(Nr)
      Real*8 recip_deepFacF (Nr+1)
      Real*8 recip_deepFac2F(Nr+1)
      Real*8 gravitySign
      Real*8 rkSign
      Real*8 globalArea

C--   COMMON /GRID_RS/ RS valued grid defining variables.
C     dxC     :: Cell center separation in X across western cell wall (m)
C     dxG     :: Cell face separation in X along southern cell wall (m)
C     dxF     :: Cell face separation in X thru cell center (m)
C     dxV     :: V-point separation in X across south-west corner of cell (m)
C     dyC     :: Cell center separation in Y across southern cell wall (m)
C     dyG     :: Cell face separation in Y along western cell wall (m)
C     dyF     :: Cell face separation in Y thru cell center (m)
C     dyU     :: U-point separation in Y across south-west corner of cell (m)
C     drC     :: Cell center separation along Z axis ( units of r ).
C     drF     :: Cell face separation along Z axis ( units of r ).
C     R_low   :: base of fluid in r_unit (Depth(m) / Pressure(Pa) at top Atmos.)
C     rLowW   :: base of fluid column in r_unit at Western  edge location.
C     rLowS   :: base of fluid column in r_unit at Southern edge location.
C     Ro_surf :: surface reference (at rest) position, r_unit.
C     rSurfW  :: surface reference position at Western  edge location [r_unit].
C     rSurfS  :: surface reference position at Southern edge location [r_unit].
C     hFac    :: Fraction of cell in vertical which is open i.e how
C              "lopped" a cell is (dimensionless scale factor).
C              Note: The code needs terms like MIN(hFac,hFac(I+1))
C                    On some platforms it may be better to precompute
C                    hFacW, hFacE, ... here than do MIN on the fly.
C     maskInC :: Cell Center 2-D Interior mask (i.e., zero beyond OB)
C     maskInW :: West  face 2-D Interior mask (i.e., zero on and beyond OB)
C     maskInS :: South face 2-D Interior mask (i.e., zero on and beyond OB)
C     maskC   :: cell Center land mask
C     maskW   :: West face land mask
C     maskS   :: South face land mask
C     recip_dxC   :: Reciprocal of dxC
C     recip_dxG   :: Reciprocal of dxG
C     recip_dxF   :: Reciprocal of dxF
C     recip_dxV   :: Reciprocal of dxV
C     recip_dyC   :: Reciprocal of dxC
C     recip_dyG   :: Reciprocal of dyG
C     recip_dyF   :: Reciprocal of dyF
C     recip_dyU   :: Reciprocal of dyU
C     recip_drC   :: Reciprocal of drC
C     recip_drF   :: Reciprocal of drF
C     recip_Rcol  :: Inverse of cell center column thickness (1/r_unit)
C     recip_hFacC :: Inverse of cell open-depth f[X,Y,Z] ( dimensionless ).
C     recip_hFacW    rhFacC center, rhFacW west, rhFacS south.
C     recip_hFacS    Note: This is precomputed here because it involves division.
C     xC        :: X-coordinate of cell center f[X,Y]. The units of xc, yc
C                  depend on the grid. They are not used in differencing or
C                  averaging but are just a convient quantity for I/O,
C                  diagnostics etc.. As such xc is in m for cartesian
C                  coordinates but degrees for spherical polar.
C     yC        :: Y-coordinate of center of cell f[X,Y].
C     yG        :: Y-coordinate of corner of cell ( c-grid vorticity point) f[X,Y].
C     rA        :: R-face are f[X,Y] ( m^2 ).
C                  Note: In a cartesian framework zA is simply dx*dy,
C                      however we use zA to allow for non-globally
C                      orthogonal coordinate frames (with appropriate
C                      metric terms).
C     rC        :: R-coordinate of center of cell f[Z] (units of r).
C     rF        :: R-coordinate of face of cell f[Z] (units of r).
C - *HybSigm* - :: Hybrid-Sigma vert. Coord coefficients
C     aHybSigmF    at level-interface (*HybSigmF) and level-center (*HybSigmC)
C     aHybSigmC    aHybSigm* = constant r part, bHybSigm* = sigma part, such as
C     bHybSigmF    r(ij,k,t) = rLow(ij) + aHybSigm(k)*[rF(1)-rF(Nr+1)]
C     bHybSigmC              + bHybSigm(k)*[eta(ij,t)+Ro_surf(ij) - rLow(ij)]
C     dAHybSigF :: vertical increment of Hybrid-Sigma coefficient: constant r part,
C     dAHybSigC    between interface (dAHybSigF) and between center (dAHybSigC)
C     dBHybSigF :: vertical increment of Hybrid-Sigma coefficient: sigma part,
C     dBHybSigC    between interface (dBHybSigF) and between center (dBHybSigC)
C     tanPhiAtU :: tan of the latitude at U point. Used for spherical polar
C                  metric term in U equation.
C     tanPhiAtV :: tan of the latitude at V point. Used for spherical polar
C                  metric term in V equation.
C     angleCosC :: cosine of grid orientation angle relative to Geographic direction
C               at cell center: alpha=(Eastward_dir,grid_uVel_dir)=(North_d,vVel_d)
C     angleSinC :: sine   of grid orientation angle relative to Geographic direction
C               at cell center: alpha=(Eastward_dir,grid_uVel_dir)=(North_d,vVel_d)
C     u2zonDir  :: cosine of grid orientation angle at U point location
C     v2zonDir  :: minus sine of  orientation angle at V point location
C     fCori     :: Coriolis parameter at grid Center point
C     fCoriG    :: Coriolis parameter at grid Corner point
C     fCoriCos  :: Coriolis Cos(phi) parameter at grid Center point (for NH)

      COMMON /GRID_RS/
     &  dxC,dxF,dxG,dxV,dyC,dyF,dyG,dyU,
     &  R_low, rLowW, rLowS,
     &  Ro_surf, rSurfW, rSurfS,
     &  hFacC, hFacW, hFacS,
     &  recip_dxC,recip_dxF,recip_dxG,recip_dxV,
     &  recip_dyC,recip_dyF,recip_dyG,recip_dyU,
     &  recip_Rcol,
     &  recip_hFacC,recip_hFacW,recip_hFacS,
     &  xC,yC,rA,rAw,rAs,rAz,xG,yG,
     &  maskInC, maskInW, maskInS,
     &  maskC, maskW, maskS,
     &  recip_rA,recip_rAw,recip_rAs,recip_rAz,
     &  drC, drF, recip_drC, recip_drF, rC, rF,
     &  aHybSigmF, bHybSigmF, aHybSigmC, bHybSigmC,
     &  dAHybSigF, dBHybSigF, dBHybSigC, dAHybSigC,
     &  tanPhiAtU, tanPhiAtV,
     &  angleCosC, angleSinC, u2zonDir, v2zonDir,
     &  fCori, fCoriG, fCoriCos
      Real*8 dxC            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dxF            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dxG            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dxV            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dyC            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dyF            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dyG            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 dyU            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 R_low          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rLowW          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rLowS          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 Ro_surf        (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rSurfW         (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rSurfS         (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 hFacC          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 hFacW          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 hFacS          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 recip_dxC      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dxF      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dxG      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dxV      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dyC      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dyF      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dyG      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_dyU      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_Rcol     (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_hFacC    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 recip_hFacW    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 recip_hFacS    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 xC             (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 xG             (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 yC             (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 yG             (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rA             (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rAw            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rAs            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 rAz            (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_rA       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_rAw      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_rAs      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 recip_rAz      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 maskInC        (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 maskInW        (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 maskInS        (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 maskC          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 maskW          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 maskS          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 drC            (Nr)
      Real*8 drF            (Nr)
      Real*8 recip_drC      (Nr)
      Real*8 recip_drF      (Nr)
      Real*8 rC             (Nr)
      Real*8 rF             (Nr+1)
      Real*8 aHybSigmF      (Nr+1)
      Real*8 bHybSigmF      (Nr+1)
      Real*8 aHybSigmC      (Nr)
      Real*8 bHybSigmC      (Nr)
      Real*8 dAHybSigF      (Nr)
      Real*8 dBHybSigF      (Nr)
      Real*8 dBHybSigC      (Nr+1)
      Real*8 dAHybSigC      (Nr+1)
      Real*8 tanPhiAtU      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 tanPhiAtV      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 angleCosC      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 angleSinC      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 u2zonDir       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 v2zonDir       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 fCori          (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 fCoriG         (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 fCoriCos       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)


C--   COMMON /GRID_I/ INTEGER valued grid defining variables.
C     kSurfC  :: vertical index of the surface tracer cell
C     kSurfW  :: vertical index of the surface U point
C     kSurfS  :: vertical index of the surface V point
C     kLowC   :: index of the r-lowest "wet cell" (2D)
C IMPORTANT: ksurfC,W,S = Nr+1 and kLowC = 0 where the fluid column
C            is empty (continent)
      COMMON /GRID_I/
     &  kSurfC, kSurfW, kSurfS,
     &  kLowC
      INTEGER kSurfC(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER kSurfW(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER kSurfS(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER kLowC (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C $Header: /u/gcmpack/MITgcm/model/inc/DYNVARS.h,v 1.44 2013/02/26 19:38:18 jmc Exp $
C $Name: checkpoint64g $

CBOP
C     !ROUTINE: DYNVARS.h
C     !INTERFACE:
C     include "DYNVARS.h"
C     !DESCRIPTION:
C     \bv
C     *==========================================================*
C     | DYNVARS.h
C     | o Dynamical model variables (common block DYNVARS_R)
C     *==========================================================*
C     | The value and two levels of time tendency are held for
C     | each prognostic variable.
C     *==========================================================*
C     \ev
CEOP

C     State Variables:
C     etaN  :: free-surface r-anomaly (r unit) at current time level
C     uVel  :: zonal velocity (m/s, i=1 held at western face)
C     vVel  :: meridional velocity (m/s, j=1 held at southern face)
C     theta :: potential temperature (oC, held at pressure/tracer point)
C     salt  :: salinity (ppt, held at pressure/tracer point)
C     gX, gxNm1 :: Time tendencies at current and previous time levels.
C     etaH  :: surface r-anomaly, advanced in time consistently
C              with 2.D flow divergence (Exact-Conservation):
C                etaH^n+1 = etaH^n - delta_t*Div.(H^n U^n+1)
C  note: a) used with "exactConserv", necessary for Non-Lin free-surf and mixed
C           forward/backward free-surf time stepping (e.g., Crank-Nickelson)
C        b) same as etaN but not necessarily at the same time, e.g.:
C           implicDiv2DFlow=1 => etaH=etaN ; =0 => etaH=etaN^(n-1);

      COMMON /DYNVARS_R/
     &                   etaN,
     &                   uVel,vVel,wVel,theta,salt,
     &                   gU,   gV,   gT,   gS,
     &                   guNm1,gvNm1,gtNm1,gsNm1
      Real*8  etaN  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  uVel (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  vVel (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  wVel (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  theta(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  salt (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gU(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gV(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gT(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gS(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  guNm1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gvNm1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gtNm1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  gsNm1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

      COMMON /DYNVARS_R_2/
     &                   etaH
      Real*8  etaH  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)


cph(
cph the following block will eventually move to a separate
cph header file containing requires anomaly fields of control vars.
cph)


C     Diagnostic Variables:
C     phiHydLow    :: Phi-Hydrostatic at r-lower boundary
C                     (bottom in z-coordinates, top in p-coordinates)
C     totPhiHyd    :: total hydrostatic Potential (anomaly, for now),
C                     at cell center level ; includes surface contribution.
C                     (for diagnostic + used in Z-coord with EOS_funct_P)
C     rhoInSitu    :: In-Situ density anomaly [kg/m^3] at cell center level.
C     hMixLayer    :: Mixed layer depth [m]
C                     (for diagnostic + used GMRedi "fm07")
C     IVDConvCount :: Impl.Vert.Diffusion convection counter:
C                     = 0 (not convecting) or 1 (convecting)
      COMMON /DYNVARS_DIAG/
     &                       phiHydLow, totPhiHyd,
     &                       rhoInSitu,
     &                       hMixLayer, IVDConvCount
      Real*8  phiHydLow(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  totPhiHyd(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  rhoInSitu(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  hMixLayer(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  IVDConvCount(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

C $Header: /u/gcmpack/MITgcm/pkg/gchem/GCHEM.h,v 1.13 2009/06/30 16:43:00 jahn Exp $
C $Name: checkpoint64g $


CBOP
C !ROUTINE: GCHEM.h
C !INTERFACE:
C
C !DESCRIPTION:
C   Contains tracer parameters and input files for chemical tracers.
C   These can be read in from data.gchem
C
C--   COMMON /GCHEM_PARM_L/ Logical valued parameters used by GCHEM pkg.
C     useDIC    :: flag to turn on/off DIC pkg
C     useCFC    :: flag to turn on/off CFC pkg
C     useDARWIN :: flag to turn on/off darwin pkg
C
C--   COMMON /GCHEM_PARAMS/
C  nsubtime    :: number of chemistry timesteps per deltaTtracer
C                 (default 1)
C  Filename*   :: various spare filenames
C  gchem_int*  :: place holder to read in a integer number, set at run time
C  gchem_rl*   :: place holder to read in a real number, set at run time
C  gchem_ForcingPeriod :: periodic forcing parameter specific for gchem (seconds)
C  gchem_ForcingCycle  :: periodic forcing parameter specific for gchem (seconds)
C
C !MODIFICATION HISTORY
C 16 May 2013 - Yanxu Zhang    - Add Hg support
C        2014 - Xianming Zhang - Add PFCs
C 08 Jul 2014 - Helen Amos     - Add PCBs

CEOP

      COMMON /GCHEM_PARM_L/
     &          useDIC             ,
     &          useCFC             ,
     &          useHG              ,    !yxzhang,5/16/13
     &          usePFC             ,    !xmzhang
     &          usePCB             ,    !hma, 08 Jul 2014
     &          useDARWIN

      LOGICAL useDIC, useCFC, useHG, usePFC, usePCB, useDARWIN  !yxzhang, 5/16/13

      COMMON /GCHEM_PARAMS/
     &          Filename1          ,
     &          Filename2          ,
     &          Filename3          ,
     &          Filename4          ,
     &          Filename5          ,
     &          nsubtime           ,
     &          gchem_int1         , gchem_int2        , gchem_int3,
     &          gchem_int4         , gchem_int5        ,
     &          gchem_rl1          , gchem_rl2         , gchem_rl3,
     &          gchem_rl4          , gchem_rl5         ,
     &          gchem_ForcingPeriod, gchem_ForcingCycle

      INTEGER nsubtime
      CHARACTER*(MAX_LEN_FNAM) Filename1
      CHARACTER*(MAX_LEN_FNAM) Filename2
      CHARACTER*(MAX_LEN_FNAM) Filename3
      CHARACTER*(MAX_LEN_FNAM) Filename4
      CHARACTER*(MAX_LEN_FNAM) Filename5
      INTEGER gchem_int1
      INTEGER gchem_int2
      INTEGER gchem_int3
      INTEGER gchem_int4
      INTEGER gchem_int5
      Real*8     gchem_rl1
      Real*8     gchem_rl2
      Real*8     gchem_rl3
      Real*8     gchem_rl4
      Real*8     gchem_rl5
      Real*8     gchem_ForcingPeriod
      Real*8     gchem_ForcingCycle

C $Header: PCB_SIZE.h,v 1.0 2014/07/14 15:53:31 hma Exp $
C $Name:  $

c============================================================
c PCB_SIZE.h
c
c DESCRIPTION: 
c   Size specification for PCB model
c
c
c npmax = no of "functional groups" of phytoplankton
c nzmax = no of "functional groups" of zooplankton
c
c MODIFICATION HISTORY
c   15 Jul 2014 - hma - Remove PCBi tracer. 
c============================================================


      INTEGER iPCBa,iPCBi,iPCBp


c Remove PCBi tracer and rename PCBn to PCBa. (hma, 15 Jul 2014)
c      PARAMETER (iPCBn  =1)
c      PARAMETER (iPCBi  =2)
c      PARAMETER (iPCBp  =3)
      PARAMETER (iPCBa  =1)
      PARAMETER (iPCBp  =2)

      

C $Header: /u/gcmpack/MITgcm/pkg/pcb/PCB.h,Exp $
C $Name:  $

C     *==========================================================*
C     | PCB.h
C     *==========================================================*

       COMMON /PCB_FIELDS/
c Remove PCBi tracer. (hma, 15 Jul 2014)
c     &              PCBaConc, PCBiDepo, PCBiRiver, PCBpRiver,
     &              PCBaConc,
     &              PCBaDEP, PCBpDEP,  
     &              PCBaRiver, PCBpRiver,
     &              pisVel, fice, radsw, wind, ph,
     &              chl, npp, doc, poc,
     &              Fdoc, Fpoc, Fremin
      
      Real*8  PCBaConc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric concentration
      Real*8  PCBaDEP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition
      Real*8  PCBpDEP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      Real*8  PCBiDepo(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c      Real*8  PCBiRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  PCBaRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! river inputs          , dissolved PCB
      Real*8  PCBpRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! river inputs          , particulate PCB
c      Real*8  PCBaAtmDep(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition, dissolved PCB
c      Real*8  PCBpAtmDep(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition, particulate PCB 
      Real*8  pisvel(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)     
      Real*8  fice  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  wind (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)      ! wind speed
      Real*8  ph (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  radsw (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8  chl   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! chlorophyll
      Real*8  npp   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! net primary productivity
      Real*8  doc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! dissolved organic carbon  
      Real*8  poc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! particulate organic carbon
      Real*8  Fdoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  Fpoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8  Fremin(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

      
      

C     time-record currently loaded (in temp arrays *[1])
      COMMON /PCB_LOAD_I/
     &  PCB_ldRec_forcing, PCB_ldRec_chem, PCB_ldRec_emis
      INTEGER PCB_ldRec_forcing(nSx,nSy), PCB_ldRec_chem(nSx,nSy)
      INTEGER     PCB_ldRec_emis(nSx,nSy)

       COMMON /PCB_CHEM/
C      physicochemical properties
     &       pKa, Koc_pcb, Kiw     
        Real*8     pKa, Koc_pcb, Kiw

         
      !---------------------------------------------------  
      ! Schmidt number coefficients used by XZ based on Tsilingiris (2008)
      !---------------------------------------------------
      COMMON /PCB_PARAMETER/
     &                    sv_0, sv_1, sv_2, sv_3, sv_4,
     &                    sd_0, sd_1, sd_2, sd_3,
     &                  Va, Vb, Ma, Mb, Patm,
     &          enrichfactor  ,
     &          dH, Kaw0, KH0                
      Real*8                    sv_0, sv_1, sv_2, sv_3, sv_4
      Real*8                   sd_0, sd_1, sd_2, sd_3
      Real*8                Va, Vb, Ma, Mb, Patm
      Real*8       enrichfactor 
      Real*8       dH,  Kaw0, KH0

      COMMON /PCB_LOAD/
     &    wind0, wind1, ice0, ice1, radsw0, radsw1,
c Remove PCBi tracer. (hma, 15 Jul 2014)
c     &    pcbaconc0, pcbaconc1, pcbidepo0, pcbidepo1,
c     &    pcbiriver0, pcbiriver1, pcbpriver0, pcbpriver1,
     &    pcbaconc0, pcbaconc1,    
     &    pcbadepo0, pcbadepo1,
     &    pcbpdepo0, pcbpdepo1,
     &    pcbpriver0, pcbpriver1,   
     &    chl0, chl1, npp0, npp1, doc0, doc1,
     &    poc0, poc1, Fdoc0, Fdoc1, Fpoc0, Fpoc1,
     &    Fremin0, Fremin1
      Real*8 wind0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 wind1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 ice0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 ice1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 radsw0   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 radsw1   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      Real*8 pcbaconc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric concentration
      Real*8 pcbaconc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric concentration
      Real*8 pcbadepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      Real*8 pcbadepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      Real*8 pcbpdepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      Real*8 pcbpdepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c Remove PCBi tracer (hma, 15 Jul 2014)
c      Real*8 pcbidepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      Real*8 pcbidepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      Real*8 pcbidepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      Real*8 pcbiriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
c      Real*8 pcbiriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      Real*8 pcbpriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      Real*8 pcbpriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      
      Real*8 chl0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 chl1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 npp0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 npp1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 doc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 doc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 poc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 poc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fdoc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fdoc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fpoc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fpoc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fremin0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      Real*8 Fremin1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)


      COMMON /PCB_FILENAMES/
C  PCB_windFile    :: file name of wind speeds
C  PCB_iceFile     :: file name of seaice fraction
C  PCB_forcingPeriod :: periodic forcing parameter specific for PCB (seconds)
C  PCB_forcingCycle  :: periodic forcing parameter specific for PCB (seconds)
C  PCBa_concFile     :: file name of PCBa concentration in atmosphere
C  PCBi_depoFile     :: file name of deposition flux from atmosphere - REMOVED (hma, 15 Jul 2014)

C The river files are just dummy files for now. They're actually PFC
C inputs just renamed to PCBs. PCB river inputs are negligible and will
C likely not be considered in the final PCB simulation. (hma, 14 Jul 2014)
C  PCBi_riverFile    :: file name of PCBi riverine runoff - REMOVED (hma, 15 Jul 2014)
C  PCBp_riverFile    :: file name of PCBp riverine runoff
C  PCBR_riverFile    :: file name of PCBR riverine runoff
C  PCBa_depoFile     :: file name of PCBa atmospheric deposition
C  PCBp_depoFile     :: file name of PCBp atmospheric deposition

C  radsw_file       :: file name of short-wave radiation
C  chl_file         :: file name of chl concentration
C  npp_file         :: file name of net primary production
C  doc_file         :: file name of dissolved organic carbon concentration
C  poc_file         :: file name of particualte organic carbon concentration
C  Fdoc_file        :: file name of sinking dissolved organic carbon
C  Fpoc_file        :: file name of sinking particualte organic carbon
C  Fremin_file      :: file name of particualte organic carbon remineralization rate
C  NO3_file         :: file name of NO3 concentration
C  phytoP_file      :: file name of phytoplankton concentration
C  zooP_file        :: file name of zooplankton concentration
     &        PCB_windFile, PCB_iceFile, radsw_File,
     &        PCB_forcingPeriod, PCB_forcingCycle,
     &        PCB_chemPeriod, PCB_chemCycle,
     &        PCB_emisPeriod, PCB_emisCycle,
c Remove PCBi tracer. (hma, 15 Jul 2014)
c     &        PCBa_concFile , PCBi_depoFile,
c     &        PCBi_riverFile, PCBp_riverFile,   
     &        PCBa_concFile  , 
     &        PCBp_riverFile , 
     &        PCBa_depoFile  , 
     &        PCBp_depoFile  ,
     &        chl_file       , npp_file ,
     &        doc_file       , poc_file ,
     &        Fdoc_file      , Fpoc_file, Fremin_file 
      CHARACTER*(MAX_LEN_FNAM) PCB_windFile
      CHARACTER*(MAX_LEN_FNAM) PCB_iceFile
      CHARACTER*(MAX_LEN_FNAM) PCBa_concFile
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      CHARACTER*(MAX_LEN_FNAM) PCBi_depoFile
c      CHARACTER*(MAX_LEN_FNAM) PCBi_riverFile
      CHARACTER*(MAX_LEN_FNAM) PCBp_riverFile 
      CHARACTER*(MAX_LEN_FNAM) PCBa_depoFile
      CHARACTER*(MAX_LEN_FNAM) PCBp_depoFile            
      CHARACTER*(MAX_LEN_FNAM) radsw_File
      CHARACTER*(MAX_LEN_FNAM) chl_File
      CHARACTER*(MAX_LEN_FNAM) npp_File
      CHARACTER*(MAX_LEN_FNAM) doc_File
      CHARACTER*(MAX_LEN_FNAM) poc_File
      CHARACTER*(MAX_LEN_FNAM) Fdoc_File
      CHARACTER*(MAX_LEN_FNAM) Fpoc_File
      CHARACTER*(MAX_LEN_FNAM) Fremin_File
      Real*8     PCB_forcingPeriod   ! data related to air-sea exchange
      Real*8     PCB_forcingCycle
      Real*8     PCB_chemPeriod      ! data related to PCB chemistry
      Real*8     PCB_chemCycle
      Real*8     PCB_emisPeriod      ! data related to PCB input(emission)
      Real*8     PCB_emisCycle
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|




        INTEGER myThid

C set up diagnostics
      IF ( useDIAGNOSTICS ) THEN
        CALL PCB_DIAGNOSTICS_INIT( myThid )
      ENDIF
C

        RETURN
        END
C============================================================================

