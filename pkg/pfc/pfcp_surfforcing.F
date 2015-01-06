C $Header: /u/gcmpack/MITgcm/pkg/hg/hg2_surfforcing.F,v 1.3 2006/08/06 01:29:12 jmc Exp $
C $Name: checkpoint64g $

#include "GCHEM_OPTIONS.h"
#include "PFC_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE pfcp_SURFFORCING( PTR, surfpfcp,
     I           bi,bj,iMin,iMax,jMin,jMax,
     I           myIter, myTime, myThid )
C     /==========================================================\
C     | SUBROUTINE PFCp_SURFFORCING                               |
C     | particle bound PFC discharged by river                    |
C     |                                 |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PFC_SIZE.h"
#include "PFC.h"

C     == Routine arguments ==
      INTEGER myIter, myThid
      _RL myTime
      _RL  Ptr  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,PTRACERS_num)
      _RL  surfpfcp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  Fluxpfcp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  pfcprivero
#ifdef ALLOW_DIAGNOSTICS      
      _RL  pfcpriver_diag(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      CHARACTER*8 diagname
#endif      
      INTEGER iMin,iMax,jMin,jMax, bi, bj

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_PFC

C     == Local variables ==
C I, J - Loop counters
      INTEGER I,J

C Initialize diagnostics
#ifdef ALLOW_DIAGNOSTICS
      DO j=jMin,jMax
        DO i=iMin,iMax
            pfcpriver_diag(i,j)=0d0
        ENDDO
      ENDDO
#endif
      
      DO j=jMin,jMax
        DO i=iMin,iMax
          IF (HFacC(i,j,1,bi,bj).GT.0.5) THEN
C Localize variabls
C            kg/s -> mol/m2/s
             pfcprivero = PFCpriver(i,j,bi,bj)
     &             *recip_rA(i,j,bi,bj)*1000.d0/Mb
                           
             Fluxpfcp(i,j)=pfcprivero
#ifdef ALLOW_DIAGNOSTICS             
             pfcpriver_diag(i,j)=FluxPFCp(i,j)
#endif             
          ENDIF
        ENDDO
      ENDDO

C update surface tendencies
        DO j=jMin,jMax
          DO i=iMin,iMax
           SURFPFCP(i,j)=
     &         HFacC(i,j,1,bi,bj)*Fluxpfcp(i,j)*recip_drF(1)
          ENDDO
         ENDDO
         
c write diagnostics
#ifdef ALLOW_DIAGNOSTICS
        WRITE(diagname,'(A8)') 'PFCpRIVR'
        CALL DIAGNOSTICS_FILL( pfcpriver_diag(1-Olx,1-Oly), diagname,
     &                         0,1,2,bi,bj,myThid )         
#endif
         
#endif
#endif

        RETURN
        END
