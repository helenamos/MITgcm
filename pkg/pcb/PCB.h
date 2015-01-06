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
#ifdef ALLOW_SEASPRAY
     &           , seaspraywtrflux
#endif     
      
#ifdef FOODW_MODE     
     &              , NO3, phytoP, zooP
#endif
      _RL  PCBaConc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric concentration
      _RL  PCBaDEP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition
      _RL  PCBpDEP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition
c Remove PCBi tracer. (hma, 15 Jul 2014)
c      _RL  PCBiDepo(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c      _RL  PCBiRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  PCBaRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! river inputs          , dissolved PCB
      _RL  PCBpRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! river inputs          , particulate PCB
c      _RL  PCBaAtmDep(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition, dissolved PCB
c      _RL  PCBpAtmDep(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! atmospheric deposition, particulate PCB 
      _RL  pisvel(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)     
      _RL  fice  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  wind (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)      ! wind speed
      _RL  ph (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  radsw (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  chl   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! chlorophyll
      _RL  npp   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! net primary productivity
      _RL  doc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! dissolved organic carbon  
      _RL  poc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)  ! particulate organic carbon
      _RL  Fdoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  Fpoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  Fremin(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

#ifdef ALLOW_SEASPRAY
      _RL  seaspraywtrflux (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#endif        
      
      
#ifdef FOODW_MODE      
      _RL  NO3   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)      
      _RL  phytoP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RL  zooP  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
#endif  

C     time-record currently loaded (in temp arrays *[1])
      COMMON /PCB_LOAD_I/
     &  PCB_ldRec_forcing, PCB_ldRec_chem, PCB_ldRec_emis
      INTEGER PCB_ldRec_forcing(nSx,nSy), PCB_ldRec_chem(nSx,nSy)
      INTEGER     PCB_ldRec_emis(nSx,nSy)

       COMMON /PCB_CHEM/
C      physicochemical properties
     &       pKa, Koc_pcb, Kiw     
        _RL     pKa, Koc_pcb, Kiw

         
      !---------------------------------------------------  
      ! Schmidt number coefficients used by XZ based on Tsilingiris (2008)
      !---------------------------------------------------
      COMMON /PCB_PARAMETER/
     &                    sv_0, sv_1, sv_2, sv_3, sv_4,
     &                    sd_0, sd_1, sd_2, sd_3,
     &                  Va, Vb, Ma, Mb, Patm,
     &          enrichfactor  ,
     &          dH, Kaw0, KH0                
      _RL                    sv_0, sv_1, sv_2, sv_3, sv_4
      _RL                   sd_0, sd_1, sd_2, sd_3
      _RL                Va, Vb, Ma, Mb, Patm
      _RL       enrichfactor 
      _RL       dH,  Kaw0, KH0

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
#ifdef FOODW_MODE     
     &    , NO30, NO31,phytoP0, phytoP1, zooP0, zoop1
#endif
      _RS wind0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS wind1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS ice0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS ice1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS radsw0   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS radsw1   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pcbaconc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric concentration
      _RS pcbaconc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric concentration
      _RS pcbadepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      _RS pcbadepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      _RS pcbpdepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
      _RS pcbpdepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c Remove PCBi tracer (hma, 15 Jul 2014)
c      _RS pcbidepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      _RS pcbidepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      _RS pcbidepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  ! atmospheric deposition
c      _RS pcbiriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
c      _RS pcbiriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      _RS pcbpriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      _RS pcbpriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) ! river inputs
      
      _RS chl0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS chl1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS npp0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS npp1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS doc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS doc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS poc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS poc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fdoc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fdoc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fpoc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fpoc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fremin0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fremin1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#ifdef FOODW_MODE      
      _RS NO30    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS NO31    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)      
      _RS phytoP0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RS phytoP1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RS zooP0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
      _RS zooP1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
#endif      


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
#ifdef FOODW_MODE     
     &        , NO3_file,phytoP_file, zooP_file
#endif
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
#ifdef FOODW_MODE      
      CHARACTER*(MAX_LEN_FNAM) NO3_File
      CHARACTER*(MAX_LEN_FNAM) phytoP_File
      CHARACTER*(MAX_LEN_FNAM) zooP_File
#endif
      _RL     PCB_forcingPeriod   ! data related to air-sea exchange
      _RL     PCB_forcingCycle
      _RL     PCB_chemPeriod      ! data related to PCB chemistry
      _RL     PCB_chemCycle
      _RL     PCB_emisPeriod      ! data related to PCB input(emission)
      _RL     PCB_emisCycle
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|



