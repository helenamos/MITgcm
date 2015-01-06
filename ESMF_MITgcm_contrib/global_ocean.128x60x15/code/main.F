C $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/code/main.F,v 1.1 2004/03/30 03:58:56 cnh Exp $
C $Name:  $

CBOI
C
C !TITLE: WRAPPER CODE SYNOPSIS
C !AUTHORS: mitgcm developers ( support@mitgcm.org )
C !AFFILIATION: Massachussetts Institute of Technology
C !DATE:
C !INTRODUCTION: Wrapper synopsis and code
C Routines in the subdirectories under eesupp/ ( src/ and inc/ ) provide the core
C framework within which numerical and ancilliary software of MITgcm operates.
C The eesupp/ directories provide a collection of software we call {\bf WRAPPER} (
C ({\bf W}rappable {\bf A}pplication {\bf P}aralell {\bf P}rogramming {\bf E}nvironment {\bf R}esource).
C The {bf WRAPPER} provides a generic bootstrapping capability to start applications
C in a manner that allows them to exploit single and multi-processing environments on all present 
C day hardware platforms (spanning vector SMP systems to distributed memory and processing cluster
C systems). Numerical applications must be coded to fit within the {\bf WRAPPER}. This entails
C applications adopting a particular style for declaring data structures representing
C grids and values on grids. The {\bf WRAPPER} currently provides support for grid point
C models using a single global indexing system. This is sufficient for latitude-logitude,
C cylindrical, and cartesian coordinate configurations. There is also limited support for
C composing grids in which no single, sructured global index can be defined. At present, this 
C support is limited to specific configurations of projections of a cube onto the sphere.
C
C The main functions supported by the current {\bf WRAPPER} code are
C \begin{itemize}
C  \item program startup and termination including creation/management of multiple 
C        threads and/or processes
C  \item communication and synchronisatioin operations between multiple processes and/or threads 
C  \item multi-process input and output operations to disk and to other 
C  applications
C \end{itemize}
C
C Multi-process execution assumes the existence of MPI for process startup and termination. However,
C MPI does not have to be used for performance critical operations. Instead,
C {\bf WRAPPER} performance critical parallel primitives are implemented to allow them to bind to 
C different low-level system software layers. Bindings exist for using {\bf WRAPPER} with portable
C systems such as MPI and UNIX System V IPC memory mapping, as well bindings for high-performance 
C propreitary systems such as Myrinet GM software and Compaq IMC memory channel technology.
C 
CEOI


C--   Get C preprocessor options
#include "CPP_OPTIONS.h"
#include "CPP_EEOPTIONS.h"

CBOP
C !ROUTINE: MAIN

C !INTERFACE:
      PROGRAM MAIN
C     USE MITGCM_ORG_OCN, ONLY: OCN_INIT => DRIVER_INIT, OCN_RUN => DRIVER_RUN
      IMPLICIT NONE

C !DESCRIPTION:
C     *==========================================================*
C     | PROGRAM MAIN                                            
C     | o MAIN wrapper for MITgcm UV implementation.            
C     *==========================================================*
C     | MAIN controls the "execution environment".               
C     | Its main functions are                                   
C     | 1. call procedure EEBOOT to perform execution environment
C     |    initialisation.                                       
C     | 2. call procedure THE_MODEL_MAIN once for each concurrent
C     |    thread. THE_MODEL_MAIN is the user supplied top-level 
C     |    routine.                                              
C     | 3. call procedure EEDIE to perform execution environment 
C     |    shutdown.                                             
C     *==========================================================*
      INTEGER myThid
      INTEGER myCurrentIter
      _RL     myCurrentTime
      INTEGER nTimeSteps
      INTEGER I
      INTEGER iLoop
      
      nTimeSteps = 1

      CALL DRIVER_INIT(     myCurrentTime, myCurrentIter, 
     &                      iLoop, myThid )

      DO I=1,10
       CALL DRIVER_RUN(      myCurrentTime, myCurrentIter, 
     &                       iLoop,
     &                       nTimeSteps, myThid )
      ENDDO

      END
