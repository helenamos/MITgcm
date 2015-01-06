C $Header: /u/gcmpack/MITgcm/pkg/pcb/PCB.h,Exp $
C $Name:  $

C     *==========================================================*
C     | PCB.h
C     *==========================================================*

       COMMON /PCB_FIELDS/
     &              PCBdConc, PCBiDepo,
     &              pisVel, fice, radsw, wind, ph,
     &              chl, npp, doc, poc,
     &              Fdoc, Fpoc, Fremin

c Not considering sea spray for PCBs (hma, 11 Jul 2014)
c#ifdef ALLOW_SEASPRAY
c     &           , seaspraywtrflux
c#endif     
      
#ifdef FOODW_MODE     
     &              , NO3, phytoP, zooP
#endif
      _RL  PCBdConc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  PCBiDepo(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  pisvel(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  fice  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  wind (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  ph (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  radsw (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  chl   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  npp   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  doc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)   
      _RL  poc   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  Fdoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  Fpoc  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL  Fremin(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

c Not considering sea spray for PCBs (hma, 11 Jul 2014)
c#ifdef ALLOW_SEASPRAY
c      _RL  seaspraywtrflux (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c#endif        
      
      
#ifdef FOODW_MODE      
      _RL  NO3   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)      
      _RL  phytoP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RL  zooP  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
#endif  

C     time-record currently loaded (in temp arrays *[1])
      COMMON /PCB_LOAD_I/ PCB_ldRec_forcing, PCB_ldRec_chem
      INTEGER PCB_ldRec_forcing(nSx,nSy), PCB_ldRec_chem(nSx,nSy)

       COMMON /PCB_CHEM/
C      physicochemical properties
     &       pKa, Koc_pfc     
      _RL  pKa, Koc_pfc

           
C     Schmidt number coefficients  used by XZ based on Tsilingiris (2008)
      COMMON /PCB_PARAMETER/
     &       sv_0, sv_1, sv_2, sv_3, sv_4,
     &       sd_0, sd_1, sd_2, sd_3,
     &       Va  , Vb  , Ma  , Mb  , Patm,
     &       enrichfactor                
      _RL  sv_0, sv_1, sv_2, sv_3, sv_4
      _RL  sd_0, sd_1, sd_2, sd_3
      _RL  Va  , Vb  , Ma  , Mb  , Patm
      _RL  enrichfactor

      COMMON /PCB_LOAD/
     &    wind0     , wind1     , ice0      , ice1       , radsw0, radsw1,
     &    pfcnconc0 , pfcnconc1 , pfcidepo0 , pfcidepo1  ,
     &    chl0      , chl1      , npp0      , npp1       , doc0  , doc1  ,
     &    poc0      , poc1      , Fdoc0     , Fdoc1      , Fpoc0 , Fpoc1 ,
     &    Fremin0   , Fremin1
#ifdef FOODW_MODE     
     &    , NO30    , NO31      ,phytoP0    , phytoP1    , zooP0 , zoop1
#endif
      _RS wind0      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS wind1      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS ice0       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS ice1       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS radsw0     (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS radsw1     (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pcbdconc0  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pcbdconc1  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      
      _RS chl0       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS chl1       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS npp0       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS npp1       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS doc0       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS doc1       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS poc0       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS poc1       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fdoc0      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fdoc1      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fpoc0      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fpoc1      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fremin0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS Fremin1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#ifdef FOODW_MODE      
      _RS NO30       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS NO31       (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)      
      _RS phytoP0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RS phytoP1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RS zooP0      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
      _RS zooP1      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
#endif      


      COMMON /PCB_FILENAMES/
C  PCB_windFile      :: file name of wind speeds
C  PCB_iceFile       :: file name of seaice fraction
C  PCB_forcingPeriod :: periodic forcing parameter specific for PCB (seconds)
C  PCB_forcingCycle  :: periodic forcing parameter specific for PCB (seconds)
C  PCBd_concFile     :: file name of PCBd concentration in atmosphere
C  PCBd_depoFile     :: file name of deposition flux from atmosphere
C  PCBp_depoFile     :: file name of deposition flux from atmosphere
C  radsw_file        :: file name of short-wave radiation
C  chl_file          :: file name of chl concentration
C  npp_file          :: file name of net primary production
C  doc_file          :: file name of dissolved organic carbon concentration
C  poc_file          :: file name of particualte organic carbon concentration
C  Fdoc_file         :: file name of sinking dissolved organic carbon
C  Fpoc_file         :: file name of sinking particualte organic carbon
C  Fremin_file       :: file name of particualte organic carbon remineralization rate
C  NO3_file          :: file name of NO3 concentration
C  phytoP_file       :: file name of phytoplankton concentration
C  zooP_file         :: file name of zooplankton concentration
     &        PCB_windFile     , PCB_iceFile     , radsw_File,
     &        PCB_forcingPeriod, PCB_forcingCycle,
     &        PCB_chemPeriod   , PCB_chemCycle   ,
     &        PCBd_concFile    , PCBd_depoFile   , PCBp_depoFile
     &        chl_file         , npp_file        ,
     &        doc_file         , poc_file        ,
     &        Fdoc_file        , Fpoc_file       , Fremin_file 
#ifdef FOODW_MODE     
     &        , NO3_file       , phytoP_file     , zooP_file
#endif
      CHARACTER*(MAX_LEN_FNAM) PCB_windFile
      CHARACTER*(MAX_LEN_FNAM) PCB_iceFile
      CHARACTER*(MAX_LEN_FNAM) PCBd_concFile
      CHARACTER*(MAX_LEN_FNAM) PCBd_depoFile
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
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|


