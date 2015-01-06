C $Header: /u/gcmpack/MITgcm/pkg/hg/hg0_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "CPP_OPTIONS.h"
#include "GCHEM_OPTIONS.h"
#include "HG_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE hg0_SURFFORCING( PTR, surfhg0,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE HG0_SURFFORCING                               |
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
      _RL  surfhg0(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_HG

C     == Local variables ==
C I, J, K - Loop counters
      INTEGER I,J
C Solubility relation coefficients
      _RL SchmidtNohg0, ScCO2
      _RL Kwexch
      _RL FluxHG0(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL tk, tc, vi, D, H
      _RL doco
#ifdef ALLOW_DIAGNOSTICS      
      _RL hg0conc_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL hg0evas_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL hg0conco
      CHARACTER*8 diagname
#endif

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            hg0conc_diag(i,j)=0d0
            hg0evas_diag(i,j)=0d0
        ENDDO
      ENDDO
#endif
                  
C calculate SCHMIDT NO.
        DO j=jMin,jMax
          DO i=iMin,iMax
            IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Locoalize variables
              hg0conco = max(hg0conc(i,j,bi,bj),0d0)
              doco     = max(doc(i,j,1,bi,bj),0d0)
                              
C calculate SCHMIDT NO. for Hg0
C yxzhang, theta in Celcuis degree
              tc = max(theta(i,j,1,bi,bj), 0 _d 0)
              tk = tc + 273.15 _d 0
              vi = ( 10**( ( 1301.0d0 / ( 998.333d0 + 8.1855d0
     &              * ( tc - 20.0d0 )+ 0.00585d0 * (tc - 20.0d0 )**2 ) )
     &              - 3.30233d0 ) ) * 100.0d0
              D = 9.37 _d -8 * tk / vi
              SchmidtNohg0 =
     &            0.017 _d 0 * exp( - 0.025 _d 0 * tc ) / D
              ScCO2  = 644.7d0 + tc * ( -6.16d0 + tc * ( 0.11d0 ) )
c calculate Henry's law constant for Hg0, L air/L water
              H = exp( ( -2404.3d0 / tk ) + 6.92d0 )
C Determine surface flux (Fhg0), m/s
              Kwexch = (1. _d 0 - fice(i,j,bi,bj))
     &                    * pisvel(i,j,bi,bj)
     &                    / sqrt( SchmidtNoHG0 / ScCO2 )
              IF ( doco .gt. 499 ) THEN   !coast
                  Kwexch = Kwexch * 0.5
              ENDIF
                  
              FluxHG0(i,j) =
     &                    Kwexch * (hg0conco * 4.985 _d -12   !ng/m3->mol/m3
     &                    / H - max(PTR(i,j,1,bi,bj,ihg0),0d0))
            ELSE
              FluxHG0(i,j) = 0. _d 0
            ENDIF

C Calculate diagnistics
#ifdef ALLOW_DIAGNOSTICS
            hg0conc_diag(i,j) = HG0conco  !ng/m^3
            hg0evas_diag(i,j) = -FluxHG0(i,j)  !mol/m^2/s
#endif            
          ENDDO
        ENDDO

C update surface tendencies      
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFHG0(i,j)=
     &         HFacC(i,j,1,bi,bj)*FluxHG0(i,j)*recip_drF(1)
          ENDDO
         ENDDO

c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'HG0CONC '
        CALL DIAGNOSTICS_FILL( hg0conc_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'HG0EVAS '
        CALL DIAGNOSTICS_FILL( hg0evas_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )     
#endif

#endif
#endif
        RETURN
        END
