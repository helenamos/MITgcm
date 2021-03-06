C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_obcsw.F,v 1.11 2012/09/18 18:07:39 jmc Exp $
C $Name: checkpoint64g $

#include "ECCO_OPTIONS.h"

CBOP
C     !ROUTINE: COST_OBCSS
C     !INTERFACE:
      subroutine cost_obcsw(
     I                       myiter,
     I                       mytime,
     I                       startrec,
     I                       endrec,
     I                       mythid
     &                     )

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE cost_obcsw
c     ==================================================================
c
c     o cost function contribution obc
c
c     ==================================================================
c     SUBROUTINE cost_obcsw
c     ==================================================================
C     \ev

C     !USES:

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"
c#ifdef ALLOW_OBCS
c# include "OBCS_GRID.h"
c#endif

#include "cal.h"
#include "ecco_cost.h"
#include "CTRL_SIZE.h"
#include "ctrl.h"
#include "ctrl_dummy.h"
#include "optim.h"

C     !INPUT/OUTPUT PARAMETERS:
c     == routine arguments ==

      integer myiter
      _RL     mytime
      integer mythid
      integer startrec
      integer endrec

#ifdef ALLOW_OBCSW_COST_CONTRIBUTION

c     == external functions ==
      integer  ilnblnk
      external ilnblnk

C     !LOCAL VARIABLES:
c     == local variables ==

      integer bi,bj
      integer j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax
      integer irec
      integer iobcs
c     integer i, ip1
      integer nrec
      integer ilfld
      integer igg

      _RL fctile
      _RL fcthread
      _RL dummy
      _RL gg
      _RL tmpx
      _RL tmpfield (1-oly:sny+oly,nr,nsx,nsy)
      _RL maskyz   (1-oly:sny+oly,nr,nsx,nsy)

      character*(80) fnamefld

      logical doglobalread
      logical ladinit

#ifdef ECCO_VERBOSE
      character*(MAX_LEN_MBUF) msgbuf
#endif
c     == end of interface ==
CEOP

      jtlo = mybylo(mythid)
      jthi = mybyhi(mythid)
      itlo = mybxlo(mythid)
      ithi = mybxhi(mythid)
      jmin = 1
      jmax = sny
      imin = 1
      imax = snx

c--   Read tiled data.
      doglobalread = .false.
      ladinit      = .false.

c     Number of records to be used.
      nrec = endrec-startrec+1

c     ip1 = 1
      fcthread = 0. _d 0

#ifdef ECCO_VERBOSE
      _BEGIN_MASTER( mythid )
      write(msgbuf,'(a)') ' '
      call print_message( msgbuf, standardmessageunit,
     &                    SQUEEZE_RIGHT , mythid)
      write(msgbuf,'(a)') ' '
      call print_message( msgbuf, standardmessageunit,
     &                    SQUEEZE_RIGHT , mythid)
      write(msgbuf,'(a,i9.8)')
     &  ' cost_obcsw: number of records to process: ',nrec
      call print_message( msgbuf, standardmessageunit,
     &                    SQUEEZE_RIGHT , mythid)
      write(msgbuf,'(a)') ' '
      call print_message( msgbuf, standardmessageunit,
     &                    SQUEEZE_RIGHT , mythid)
      _END_MASTER( mythid )
#endif

      if (optimcycle .ge. 0) then
        ilfld=ilnblnk( xx_obcsw_file )
        write(fnamefld(1:80),'(2a,i10.10)')
     &       xx_obcsw_file(1:ilfld), '.', optimcycle
      endif

c--   Loop over records.
      do irec = 1,nrec

        call active_read_yz( fnamefld, tmpfield, irec, doglobalread,
     &                       ladinit, optimcycle, mythid
     &        , xx_obcsw_dummy )

cgg    Need to solve for iobcs would have been.
          gg    = (irec-1)/nobcs
          igg   = int(gg)
          iobcs = irec - igg*nobcs

          call active_read_yz( 'maskobcsw', maskyz,
     &                         iobcs,
     &                         doglobalread, ladinit, 0,
     &                         mythid, dummy )

c--     Loop over this thread s tiles.
        do bj = jtlo,jthi
          do bi = itlo,ithi

c--         Determine the weights to be used.
            fctile = 0. _d 0

            do k = 1, Nr
              do j = jmin,jmax
c               i = OB_Iw(j,bi,bj)
cgg                if (maskW(i+ip1,j,k,bi,bj) .ne. 0.) then
                  tmpx = tmpfield(j,k,bi,bj)
CMM                  fctile = fctile + wobcsw2(j,k,bi,bj,iobcs)
                  fctile = fctile + wobcsw(k,iobcs)
     &                        *tmpx*tmpx*maskyz(j,k,bi,bj)
cgg                endif
CMM                  if (wobcsw2(j,k,bi,bj,iobcs)*maskyz(j,k,bi,bj).ne.0.)
                  if (wobcsw(k,iobcs)*maskyz(j,k,bi,bj).ne.0.)
     &                    num_obcsw(bi,bj) = num_obcsw(bi,bj) + 1. _d 0
              enddo
            enddo

            objf_obcsw(bi,bj) = objf_obcsw(bi,bj) + fctile
            fcthread         = fcthread + fctile
          enddo
        enddo

#ifdef ECCO_VERBOSE
c--     Print cost function for all tiles.
        _GLOBAL_SUM_RL( fcthread , myThid )
        write(msgbuf,'(a)') ' '
        call print_message( msgbuf, standardmessageunit,
     &                      SQUEEZE_RIGHT , mythid)
        write(msgbuf,'(a,i8.8)')
     &    ' cost_obcsw: irec = ',irec
        call print_message( msgbuf, standardmessageunit,
     &                      SQUEEZE_RIGHT , mythid)
        write(msgbuf,'(a,a,d22.15)')
     &    ' global cost function value',
     &    ' (obcsw) = ',fcthread
        call print_message( msgbuf, standardmessageunit,
     &                      SQUEEZE_RIGHT , mythid)
        write(msgbuf,'(a)') ' '
        call print_message( msgbuf, standardmessageunit,
     &                      SQUEEZE_RIGHT , mythid)
#endif

      enddo
c--   End of loop over records.

#endif /* ALLOW_OBCSW_COST_CONTRIBUTION */

      return
      end
