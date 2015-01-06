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

#ifdef FOODW_MODE      
         INTEGER npmax
         INTEGER nzmax
         PARAMETER(npmax=3,nzmax=2)
#endif

      INTEGER iPCBa,iPCBi,iPCBp

#ifdef FOODW_MODE      
C iZoo          :: index of first zooplankton
C iPhy          :: index of first phytoplankton
C remember to bring the fields in data.ptracers in the right order !
      INTEGER iPhy
      INTEGER iZoo
#endif
#ifdef PCBRIVER
      INTEGER nrmax
      PARAMETER(nrmax=3)
      INTEGER iPCBr
#endif

c Remove PCBi tracer and rename PCBn to PCBa. (hma, 15 Jul 2014)
c      PARAMETER (iPCBn  =1)
c      PARAMETER (iPCBi  =2)
c      PARAMETER (iPCBp  =3)
      PARAMETER (iPCBa  =1)
      PARAMETER (iPCBp  =2)

#ifdef PCBRIVER
c Adjust because PCBi tracer has been removed. (hma, 15 Jul 2014)
c      PARAMETER (iPCBr  =4)
      PARAMETER (iPCBr  =3)
#endif
      
#ifdef FOODW_MODE 
#ifdef PCBRIVER
      PARAMETER (iPhy  =iPCBr+nrmax)
      PARAMETER (iZoo  =iPhy  +npmax)
#else
      PARAMETER (iPhy  =4)
      PARAMETER (iZoo  =iPhy  +npmax)
#endif                                      
#endif

