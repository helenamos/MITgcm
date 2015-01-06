C $Header: /u/gcmpack/MITgcm/pkg/hg/dmhg_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "CPP_OPTIONS.h"
#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE dmhg_SURFFORCING( PTR, surfdmhg,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE dmhg_SURFFORCING                               |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "GCHEM.h"
#include "HG_SIZE.h"
#include "HG.h"

C     == Routine arguments ==
      INTEGER myIter, myThid
      _RL myTime
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  surfdmhg(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG
#ifdef METHY_MODE

C     == Local variables ==
C I, J, K - Loop counters
      INTEGER I,J
C Solubility relation coefficients
      _RL SchmidtNodmhg, ScCO2
      _RL Kwexch
      _RL Fluxdmhg(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL tk, tc, vi, D, H
#ifdef ALLOW_DIAGNOSTICS      
      _RL dmhgevas_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL dmhgconco
      CHARACTER*8 diagname
#endif      

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            dmhgevas_diag(i,j)=0d0
        ENDDO
      ENDDO
#endif
                  
C calculate SCHMIDT NO.
        DO j=jMin,jMax
          DO i=iMin,iMax
            IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Locoalize variables
              dmhgconco = 0d0
                              
C calculate SCHMIDT NO. for dmhg
c need to replace with parameters for dmhg!!!
C theta in Celcuis degree
              tc = max(theta(i,j,1,bi,bj), 0 _d 0)
              tk = tc + 273.15 _d 0
              
              vi = ( 10**( ( 1301.0d0 / ( 998.333d0 + 8.1855d0
     &              * ( tc - 20.0d0 )+ 0.00585d0 * (tc - 20.0d0 )**2 ) )
     &              - 3.30233d0 ) ) * 100.0d0
              D = 9.37 _d -8 * tk / vi
              
              SchmidtNodmhg =
     &            0.017 _d 0 * exp( - 0.025 _d 0 * tc ) / D
     
              ScCO2  = 644.7d0 + tc * ( -6.16d0 + tc * ( 0.11d0 ) )

c calculate Henry's law constant for dmhg, L air/L water
              H = exp( ( -2404.3d0 / tk ) + 6.92d0 )

C Determine surface flux (Fdmhg), m/s
              Kwexch = (1. _d 0 - fice(i,j,bi,bj))
     &                    * pisvel(i,j,bi,bj)
     &                    / sqrt( SchmidtNodmhg / ScCO2 )
              Fluxdmhg(i,j) =
     &                    Kwexch * (dmhgconco * 4.985 _d -12   !ng/m3->mol/m3
     &                    / H - max(PTR(i,j,1,bi,bj,idmhg),0d0))

            ELSE
              Fluxdmhg(i,j) = 0. _d 0
            ENDIF
C Calculate diagnistics
#ifdef ALLOW_DIAGNOSTICS
            dmhgevas_diag(i,j) = -Fluxdmhg(i,j)  !mol/m^2/s
#endif 
          ENDDO
        ENDDO

C update surface tendencies      
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFdmhg(i,j)=
     &         HFacC(i,j,1,bi,bj)*Fluxdmhg(i,j)*recip_drF(1)
          ENDDO
         ENDDO
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'DMHGEVAS'
        CALL DIAGNOSTICS_FILL( dmhgevas_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )     
#endif         
         
#endif
#endif
#endif
        RETURN
        END
