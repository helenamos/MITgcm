C $Header: /u/gcmpack/MITgcm/pkg/diagnostics/diagnostics_fill_rs.F,v 1.2 2010/02/17 17:42:42 dimitri Exp $
C $Name: checkpoint64g $

C $Header: /u/gcmpack/MITgcm/pkg/diagnostics/DIAG_OPTIONS.h,v 1.9 2011/12/24 01:04:45 jmc Exp $
C $Name: checkpoint64g $







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
c#ifdef 
c# include "ECCO_CPPOPTIONS.h"
c#endif


C     Package-specific Options & Macros go here

C allow to define specific regions and the corresponding mask ;
C  used to perform regional statistics over a limited area

C allow to stop & restart at any time (i.e. not at a multiple of
C  the diagnostics frequency) reading diagnostics storage arrays
C  from pickup file.
C Note: Use with cautious since it does not work for all restart
C  cases (e.g., changing data.diagnostics).


CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***

CBOP
C     !ROUTINE: DIAGNOSTICS_FILL_RS
C     !INTERFACE:
      SUBROUTINE DIAGNOSTICS_FILL_RS(
     I               inpFld, chardiag,
     I               kLev, nLevs, bibjFlg, biArg, bjArg, myThid )

C     !DESCRIPTION:
C***********************************************************************
C   Wrapper routine to increment the diagnostics arrays with a RS field
C***********************************************************************
C     !USES:
      IMPLICIT NONE

C     == Global variables ===
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

C $Header: /u/gcmpack/MITgcm_contrib/darwin2/verification/monod_global_128x64x15/code/DIAGNOSTICS_SIZE.h,v 1.1 2011/04/13 19:26:00 jahn Exp $
C $Name:  $


C     Diagnostics Array Dimension
C     ---------------------------
C     ndiagMax   :: maximum total number of available diagnostics
C     numlists   :: maximum number of diagnostics list (in data.diagnostics)
C     numperlist :: maximum number of active diagnostics per list (data.diagnostics)
C     numLevels  :: maximum number of levels to write    (data.diagnostics)
C     numDiags   :: maximum size of the storage array for active 2D/3D diagnostics
C     nRegions   :: maximum number of regions (statistics-diagnostics)
C     sizRegMsk  :: maximum size of the regional-mask (statistics-diagnostics)
C     nStats     :: maximum number of statistics (e.g.: aver,min,max ...)
C     diagSt_size:: maximum size of the storage array for statistics-diagnostics
C Note : may need to increase "numDiags" when using several 2D/3D diagnostics,
C  and "diagSt_size" (statistics-diags) since values here are deliberately small.
      INTEGER    ndiagMax
      INTEGER    numlists, numperlist, numLevels
      INTEGER    numDiags
      INTEGER    nRegions, sizRegMsk, nStats
      INTEGER    diagSt_size
      PARAMETER( ndiagMax = 2000 )
      PARAMETER( numlists = 99, numperlist = 99, numLevels=Nr )
      PARAMETER( numdiags = 1+250*Nr )
      PARAMETER( nRegions = 0 , sizRegMsk = 1 , nStats = 4 )
      PARAMETER( diagSt_size = 20*Nr )


CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
C $Header: /u/gcmpack/MITgcm/pkg/diagnostics/DIAGNOSTICS.h,v 1.19 2013/02/06 21:25:49 jmc Exp $
C $Name: checkpoint64g $

C ======================================================================
C  Common blocks for diagnostics package.
C  - DIAG_DEFINE contains the definition of all available diagnostics
C        ndiagt :: total number of available diagnostics
C         kdiag :: number of levels associated with the diagnostic
C         hdiag :: mate number (in available diag. list) of the diagnostic
C         cdiag :: list of available diagnostic names
C         gdiag :: parser field with characteristics of the diagnostics
C         tdiag :: description of field in diagnostic
C         udiag :: physical units of the diagnostic field
C  - DIAG_STORE  contains the large array to store diagnostic fields
C         qdiag :: storage array for 2D/3D diagnostic fields
C        qSdiag :: storage array for diagnostics of (per level) statistics
C         ndiag :: holds number of times a diagnostic is filled (for time-mean diag)
C  - DIAG_SELECT contains the user selection of diagnostics to write
C         idiag :: slot number in large diagnostic array
C         mdiag :: slot number in large diagnostic array for the mate
C         jdiag :: short-list (active diag.) to long-list (available diag.)
C                  pointer
C  - DIAG_PARAMS contains general parameters (used for both 2D/3D & Stats diags)
C  - DIAG_STATIS contains the user selection of statistics-diags to write
C ======================================================================

C--   DIAG_DEFINE common block:
C       ndiagt :: total number of available diagnostics
C       kdiag  :: number of levels associated with the diagnostic
C       hdiag  :: mate number (in available diag. list) of the diagnostic
C       cdiag  :: list of available diagnostic names
C       gdiag  :: parser field with characteristics of the diagnostics
C       tdiag  :: description of field in diagnostic
C       udiag  :: physical units of the diagnostic field
C settingDiags :: internal flag: enable adding/changing available diagnostics list

      INTEGER        ndiagt
      INTEGER        kdiag(ndiagMax)
      INTEGER        hdiag(ndiagMax)
      CHARACTER*8    cdiag(ndiagMax)
      CHARACTER*80   tdiag(ndiagMax)
      CHARACTER*16   gdiag(ndiagMax)
      CHARACTER*16   udiag(ndiagMax)
      LOGICAL settingDiags

      COMMON / DIAG_DEFINE_I /
     &  ndiagt, kdiag, hdiag
      COMMON / DIAG_DEFINE_C /
     &  cdiag, gdiag, tdiag, udiag
      COMMON / DIAG_DEFINE_L /
     &  settingDiags

C--   DIAG_STORE common block:
C       qdiag  :: storage array for 2D/3D diagnostic fields
C       qSdiag :: storage array for (per level) statistics
C       ndiag  :: holds number of times a diagnostic is filled (for time-mean diag)
C       pdiag  :: index of current averaging interval within the averaging-cycle

      Real*8 qdiag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,numDiags,nSx,nSy)
      Real*8 qSdiag(0:nStats,0:nRegions,diagSt_size,nSx,nSy)
      INTEGER  ndiag(numDiags,nSx,nSy)
      INTEGER  pdiag(numLists,nSx,nSy)

      COMMON / DIAG_STORE_R / qdiag, qSdiag
      COMMON / DIAG_STORE_I / ndiag, pdiag

C--   DIAG_SELECT common block:
C     freq(n)     :: frequency (in s) to write output stream # n
C     phase(n)    :: phase     (in s) to write output stream # n
C     averageFreq :: frequency (in s) for periodic averaging interval
C     averagePhase:: phase     (in s) for periodic averaging interval
C     averageCycle:: number of averaging intervals in 1 cycle
C     misValFlt(n):: missing value for floats   to use in output stream #n
Cc    misValInt(n):: missing value for integers to use in output stream #n
C     levs(:,n)   :: list of selected levels to write for output stream # n
C     nlevels(n)  :: number of levels to write for output stream # n
C     nfields(n)  :: number of active diagnostics for output stream # n
C     nActive(n)  :: number of active diagnostics (including counters)
C                    for output stream # n
C     nlists      :: effective number of output streams
C     idiag(:,n)  :: list of diag slot number in long-list of available diag.
C     mdiag(:,n)  :: list of mate slot number in long-list of available diag.
C     jdiag(:,n)  :: short-list (active diag.) to long-list (available diag.) pointer
C     flds(:,n)   :: list of field names in output stream # n
C     fnames(n)   :: output file name for output stream # n
C     fflags(n)   :: character string with per-file flags
C useMissingValue :: put MissingValue where mask = 0 (NetCDF output only)

      Real*8 freq(numLists), phase(numLists)
      Real*8 averageFreq(numLists), averagePhase(numLists)
      Real*8 misValFlt(numLists)
      Real*8 levs (numLevels,numLists)
      INTEGER averageCycle(numLists)
c     INTEGER misValInt(numLists)
      INTEGER nlevels(numLists)
      INTEGER nfields(numLists)
      INTEGER nActive(numLists)
      INTEGER nlists
      INTEGER idiag(numperList,numLists)
      INTEGER mdiag(numperList,numLists)
      INTEGER jdiag(numperList,numLists)
      CHARACTER*8  flds  (numperList,numLists)
      CHARACTER*80 fnames(numLists)
      CHARACTER*8  fflags(numLists)
      LOGICAL diag_mdsio, diag_mnc, useMissingValue

      COMMON / DIAG_SELECT_R /
     &     freq, phase, averageFreq, averagePhase,
     &     misValFlt, levs
      COMMON / DIAG_SELECT_I /
     &     averageCycle,
     &     nlevels, nfields, nActive,
     &     nlists, idiag, mdiag, jdiag
c    &   , misValInt
      COMMON / DIAG_SELECT_C /
     &     flds, fnames, fflags
      COMMON / DIAG_SELECT_L /
     &     diag_mdsio, diag_mnc, useMissingValue

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C  - DIAG_PARAMS common block:
C    diagLoc_ioUnit :: internal parameter: I/O unit for local diagnostics output
C    dumpAtLast :: always write time-ave (freq>0) diagnostics at the end of the run
      INTEGER diagLoc_ioUnit
      LOGICAL dumpAtLast
      LOGICAL diag_pickup_read,        diag_pickup_write
      LOGICAL diag_pickup_read_mdsio,  diag_pickup_write_mdsio
      LOGICAL diag_pickup_read_mnc,    diag_pickup_write_mnc

      COMMON / DIAG_PARAMS_I /
     &     diagLoc_ioUnit
      COMMON / DIAG_PARAMS_L /
     &     dumpAtLast,
     &     diag_pickup_read,        diag_pickup_write,
     &     diag_pickup_read_mdsio,  diag_pickup_write_mdsio,
     &     diag_pickup_read_mnc,    diag_pickup_write_mnc

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   DIAG_STATIS common block:
C     diagSt_freq(n)   :: frequency (in s) to write output stream # n
C     diagSt_phase(n)  :: phase     (in s) to write output stream # n
C     iSdiag(:,n)      :: list of diag slot number in long-list of available diag.
C     mSdiag(:,n)      :: list of mate slot number in long-list of available diag.
C     jSdiag(:,n)      :: short-list (active diag.) to long-list (available
C                         diag.) pointer
C     diagSt_region(j,n) :: flag to perform (=1) or not (=0) regional-statistics
C                           over region # j for output stream # n
C     diagSt_nbFlds(n) :: number of active diagnostics for output stream # n
C     diagSt_nbActv(n) :: number of active diagnostics (including counters)
C                         for output stream # n
C     diagSt_nbLists   :: effective number of output streams
C     diagSt_ioUnit(n) :: fortran IO unit for output stream # n (ascii output)
C     diagSt_Flds(:,n) :: list of field names in output stream # n
C     diagSt_Fname(n)  :: output file name for output stream # n

      Real*8       diagSt_freq(numLists), diagSt_phase(numLists)
      INTEGER   iSdiag(numperList,numLists)
      INTEGER   mSdiag(numperList,numLists)
      INTEGER   jSdiag(numperList,numLists)
      INTEGER   diagSt_region(0:nRegions,numLists)
      INTEGER   diagSt_nbFlds(numLists)
      INTEGER   diagSt_nbActv(numLists)
      INTEGER   diagSt_nbLists
      INTEGER   diagSt_ioUnit(numLists)
      CHARACTER*8  diagSt_Flds(numperList,numLists)
      CHARACTER*80 diagSt_Fname(numLists)
      LOGICAL   diagSt_ascii, diagSt_mnc

      COMMON / DIAG_STATIS_R /
     &     diagSt_freq, diagSt_phase
      COMMON / DIAG_STATIS_I /
     &     iSdiag, mSdiag, jSdiag, diagSt_region,
     &     diagSt_nbFlds, diagSt_nbActv, diagSt_nbLists,
     &     diagSt_ioUnit
      COMMON / DIAG_STATIS_C /
     &     diagSt_Flds, diagSt_Fname
      COMMON / DIAG_STATIS_L /
     &     diagSt_Ascii, diagSt_mnc

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***

C     !INPUT PARAMETERS:
C***********************************************************************
C  Arguments Description
C  ----------------------
C     inpFld    :: Field to increment diagnostics array
C     chardiag  :: Character expression for diag to fill
C     kLev      :: Integer flag for vertical levels:
C                  > 0 (any integer): WHICH single level to increment in qdiag.
C                  0,-1 to increment "nLevs" levels in qdiag,
C                  0 : fill-in in the same order as the input array
C                  -1: fill-in in reverse order.
C     nLevs     :: indicates Number of levels of the input field array
C                  (whether to fill-in all the levels (kLev<1) or just one (kLev>0))
C     bibjFlg   :: Integer flag to indicate instructions for bi bj loop
C                  0 indicates that the bi-bj loop must be done here
C                  1 indicates that the bi-bj loop is done OUTSIDE
C                  2 indicates that the bi-bj loop is done OUTSIDE
C                     AND that we have been sent a local array (with overlap regions)
C                     (local array here means that it has no bi-bj dimensions)
C                  3 indicates that the bi-bj loop is done OUTSIDE
C                     AND that we have been sent a local array
C                     AND that the array has no overlap region (interior only)
C                  NOTE - bibjFlg can be NEGATIVE to indicate not to increment counter
C     biArg     :: X-direction tile number - used for bibjFlg=1-3
C     bjArg     :: Y-direction tile number - used for bibjFlg=1-3
C     myThid    ::  my thread Id number
C***********************************************************************
C                  NOTE: User beware! If a local (1 tile only) array
C                        is sent here, bibjFlg MUST NOT be set to 0
C                        or there will be out of bounds problems!
C***********************************************************************
      Real*8     inpFld(*)
      CHARACTER*8 chardiag
      INTEGER kLev, nLevs, bibjFlg, biArg, bjArg
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     ndId      :: diagnostic Id number (in available diagnostics list)
      INTEGER m, n, j, k, l, bi, bj
      INTEGER ndId, ipt, iSp
      INTEGER region2fill(0:nRegions)
      INTEGER arrType
      Real*8     scaleFact
      Real*8     dummyRL(1)
      Real*8     dummyRS(1)
C ===============

      arrType = 2
      scaleFact = 1.D0
      IF ( bibjFlg.EQ.0 ) THEN
        bi = myBxLo(myThid)
        bj = myByLo(myThid)
      ELSE
        bi = biArg
        bj = bjArg
      ENDIF
C--   2D/3D Diagnostics :
C Run through list of active diagnostics to make sure
C we are trying to fill a valid diagnostic
      DO n=1,nlists
       DO m=1,nActive(n)
        IF ( chardiag.EQ.flds(m,n) .AND. idiag(m,n).GT.0 ) THEN
         ipt = idiag(m,n)
         IF ( ndiag(ipt,bi,bj).GE.0 ) THEN
           ndId = jdiag(m,n)
           ipt = ipt + pdiag(n,bi,bj)*kdiag(ndId)
C-    diagnostic is valid & active, do the filling:
           CALL DIAGNOSTICS_FILL_FIELD(
     I              dummyRL, dummyRL, inpFld, dummyRS,
     I              scaleFact, 1, arrType, 0,
     I              ndId, ipt, kLev, nLevs,
     I              bibjFlg, biArg, bjArg, myThid )
         ENDIF
        ENDIF
       ENDDO
      ENDDO

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C--   Global/Regional Statistics :

C Run through list of active statistics-diagnostics to make sure
C we are trying to compute & fill a valid diagnostic

      DO n=1,diagSt_nbLists
       DO m=1,diagSt_nbActv(n)
        IF ( chardiag.EQ.diagSt_Flds(m,n) .AND. iSdiag(m,n).GT.0 ) THEN
         iSp = iSdiag(m,n)
         IF ( qSdiag(0,0,iSp,bi,bj).GE.0. ) THEN
           ndId = jSdiag(m,n)
C-    Find list of regions to fill:
           DO j=0,nRegions
            region2fill(j) = diagSt_region(j,n)
           ENDDO
C-    if this diagnostics appears in several lists (with same freq)
C     then add regions from other lists
           DO l=1,diagSt_nbLists
            DO k=1,diagSt_nbActv(l)
             IF ( iSdiag(k,l).EQ.-iSp ) THEN
              DO j=0,nRegions
               region2fill(j) = MAX(region2fill(j),diagSt_region(j,l))
              ENDDO
             ENDIF
            ENDDO
           ENDDO
C-    diagnostics is valid and Active: Now do the filling
           CALL DIAGSTATS_FILL(
     I              inpFld, dummyRL,
     I              scaleFact, 1, arrType, 0,
     I              ndId, iSp, region2fill, kLev, nLevs,
     I              bibjFlg, biArg, bjArg, myThid )
         ENDIF
        ENDIF
       ENDDO
      ENDDO

      RETURN
      END