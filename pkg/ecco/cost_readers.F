C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_readers.F,v 1.14 2013/02/05 14:51:09 gforget Exp $
C $Name: checkpoint64g $

#include "ECCO_OPTIONS.h"


      subroutine cost_readers( irec, mythid )

c     ==================================================================
c     SUBROUTINE cost_readers
c     ==================================================================
c
c     o Read a given record of the ERS SSH data.
c
c     started: Christian Eckert eckert@mit.edu 25-May-1999
c
c     changed: Christian Eckert eckert@mit.edu 25-Feb-2000
c
c              - Restructured the code in order to create a package
c                for the MITgcmUV.
c
c     ==================================================================
c     SUBROUTINE cost_readers
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"

#include "cal.h"
#include "ecco_cost.h"

c     == routine arguments ==

      integer irec
      integer mythid

#ifdef ALLOW_SSH_ERSANOM_COST_CONTRIBUTION
c     == local variables ==

      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax
      integer sshrec
      integer difftime(4)
      integer tempDate_1
      integer middate(4)
      integer noffset
      _RL diffsecs
      _RL spval
      _RL factor

cnew(
      integer  il
      _RL daytime
      integer dayiter
      integer daydate(4)
      integer yday, ymod
      integer md, dd, sd, ld, wd
      character*(80) fnametmp
      logical exst
cnew)

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      jtlo = mybylo(mythid)
      jthi = mybyhi(mythid)
      itlo = mybxlo(mythid)
      ithi = mybxhi(mythid)
      jmin = 1
      jmax = sny
      imin = 1
      imax = snx

      factor = 0.01 _d 0
      spval = -9990. _d 0

cnew(
      daytime = FLOAT(secondsperday*(irec-1)) + modelstart
      dayiter = hoursperday*(irec-1)+modeliter0
      call cal_getdate( dayiter, daytime, daydate, mythid )
      call cal_convdate( daydate,yday,md,dd,sd,ld,wd,mythid )
      ymod = ersstartdate(1)/10000

      if ( ymod .GE. yday ) then
         call cal_FullDate( ersstartdate(1), 0, middate, mythid)
      else
         tempDate_1 = yday*10000+100+1
         call cal_FullDate( tempDate_1, 0, middate, mythid)
      endif

      call cal_TimePassed( middate, daydate, difftime, mythid )
      call cal_ToSeconds( difftime, diffsecs, mythid )
c      sshrec = floor(diffsecs/ersperiod) + 1
      sshrec = int(diffsecs/ersperiod) + 1

      il=ilnblnk(ersfile)
      write(fnametmp(1:80),'(2a,i4)')
     &     ersfile(1:il), '_', yday
      inquire( file=fnametmp, exist=exst )
      if (.NOT. exst) then
         write(fnametmp(1:80),'(a)') ersfile(1:il)
         call cal_TimePassed(ersstartdate,daydate,difftime,mythid)
         call cal_ToSeconds( difftime, diffsecs, mythid )
c         sshrec = floor(diffsecs/ersperiod) + 1
         sshrec = int(diffsecs/ersperiod) + 1
         inquire( file=fnametmp, exist=exst )
      endif

cnew)

c read data:
      if ( (sshrec .GT. 0).AND.(exst) ) then
      call mdsreadfield( fnametmp, cost_iprec, cost_yftype, 1, ersobs,
     &                   sshrec, mythid )
      else
       do bj = jtlo,jthi
        do bi = itlo,ithi
         do j = jmin,jmax
          do i = imin,imax
            ersobs(i,j,bi,bj) = spval
          enddo
         enddo
        enddo
       enddo
      endif

      do bj = jtlo,jthi
        do bi = itlo,ithi
          k = 1
          do j = jmin,jmax
            do i = imin,imax
              if (_hFacC(i,j,k,bi,bj) .eq. 0.) then
                 ersmask(i,j,bi,bj) = 0. _d 0
              else
                 ersmask(i,j,bi,bj) = 1. _d 0
              endif
              if (ersobs(i,j,bi,bj) .le. spval) then
                ersmask(i,j,bi,bj) = 0. _d 0
              endif
              if (abs(ersobs(i,j,bi,bj)) .lt. 1.d-8 ) then
                 ersmask(i,j,bi,bj) = 0. _d 0
              endif

cph(
#ifndef ALLOW_SHALLOW_ALTIMETRY
              if ( R_low(i,j,bi,bj) .GT. -200. ) then
                ersmask(i,j,bi,bj) = 0. _d 0
              endif
#endif
cph)

              ersmask(i,j,bi,bj) = ersmask(i,j,bi,bj)*frame(i,j)
              ersobs(i,j,bi,bj)  = ersmask(i,j,bi,bj)*factor*
     &             ( ersobs(i,j,bi,bj) -
     &               ( ersintercept + ersslope*irec*hoursperday ) )
            enddo
          enddo
        enddo
      enddo

#endif

      return
      end
