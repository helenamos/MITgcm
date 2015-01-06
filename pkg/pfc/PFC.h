C $Header: /u/gcmpack/MITgcm/pkg/pfc/PFC.h,Exp $
C $Name:  $

C     *==========================================================*
C     | PFC.h
C     *==========================================================*

       COMMON /PFC_FIELDS/
     &              PFCnConc, PFCiDepo, PFCiRiver, PFCpRiver,
     &              pisVel, fice, radsw, wind, ph,
     &              chl, npp, doc, poc,
     &              Fdoc, Fpoc, Fremin
#ifdef ALLOW_SEASPRAY
     &           , seaspraywtrflux
#endif     
      
#ifdef FOODW_MODE     
     &              , NO3, phytoP, zooP
#endif
      _RL  PFCnConc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  PFCiDepo(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  PFCiRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  PFCpRiver(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)  
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

#ifdef ALLOW_SEASPRAY
      _RL  seaspraywtrflux (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#endif        
      
      
#ifdef FOODW_MODE      
      _RL  NO3   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)      
      _RL  phytoP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,npmax)
      _RL  zooP  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nzmax)
#endif  

C     time-record currently loaded (in temp arrays *[1])
      COMMON /PFC_LOAD_I/
     &  PFC_ldRec_forcing, PFC_ldRec_chem, PFC_ldRec_emis
      INTEGER PFC_ldRec_forcing(nSx,nSy), PFC_ldRec_chem(nSx,nSy)
      INTEGER     PFC_ldRec_emis(nSx,nSy)

       COMMON /PFC_CHEM/
C      physicochemical properties
     &       pKa, Koc_pfc, Kiw     
        _RL     pKa, Koc_pfc, Kiw

           
C       schmidt number coefficients  used by XZ based on Tsilingiris (2008)
      COMMON /PFC_PARAMETER/
     &                    sv_0, sv_1, sv_2, sv_3, sv_4,
     &                    sd_0, sd_1, sd_2, sd_3,
     &                  Va, Vb, Ma, Mb, Patm,
     &          enrichfactor                
      _RL                    sv_0, sv_1, sv_2, sv_3, sv_4
      _RL                   sd_0, sd_1, sd_2, sd_3
      _RL                Va, Vb, Ma, Mb, Patm
      _RL       enrichfactor

      COMMON /PFC_LOAD/
     &    wind0, wind1, ice0, ice1, radsw0, radsw1,
     &    pfcnconc0, pfcnconc1, pfcidepo0, pfcidepo1,
     &    pfciriver0, pfciriver1, pfcpriver0, pfcpriver1,   
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
      _RS pfcnconc0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfcnconc1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfcidepo0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfcidepo1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfciriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfciriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfcpriver0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS pfcpriver1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy) 
      
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


      COMMON /PFC_FILENAMES/
C  PFC_windFile    :: file name of wind speeds
C  PFC_iceFile     :: file name of seaice fraction
C  PFC_forcingPeriod :: periodic forcing parameter specific for PFC (seconds)
C  PFC_forcingCycle  :: periodic forcing parameter specific for PFC (seconds)
C  PFCn_concFile     :: file name of PFCn concentration in atmosphere
C  PFCi_depoFile     :: file name of deposition flux from atmosphere
C  PFCi_riverFile    :: file name of PFCi riverine runoff
C  PFCp_riverFile    :: file name of PFCp riverine runoff
C  PFCR_riverFile    :: file name of PFCR riverine runoff
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
     &        PFC_windFile, PFC_iceFile, radsw_File,
     &        PFC_forcingPeriod, PFC_forcingCycle,
     &        PFC_chemPeriod, PFC_chemCycle,
     &        PFC_emisPeriod, PFC_emisCycle,
     &        PFCn_concFile, PFCi_depoFile,
     &        PFCi_riverFile, PFCp_riverFile,    
     &        chl_file, npp_file,
     &        doc_file, poc_file,
     &        Fdoc_file, Fpoc_file, Fremin_file 
#ifdef FOODW_MODE     
     &        , NO3_file,phytoP_file, zooP_file
#endif
      CHARACTER*(MAX_LEN_FNAM) PFC_windFile
      CHARACTER*(MAX_LEN_FNAM) PFC_iceFile
      CHARACTER*(MAX_LEN_FNAM) PFCn_concFile
      CHARACTER*(MAX_LEN_FNAM) PFCi_depoFile
      CHARACTER*(MAX_LEN_FNAM) PFCi_riverFile
      CHARACTER*(MAX_LEN_FNAM) PFCp_riverFile             
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
      _RL     PFC_forcingPeriod   ! data related to air-sea exchange
      _RL     PFC_forcingCycle
      _RL     PFC_chemPeriod      ! data related to PFC chemistry
      _RL     PFC_chemCycle
      _RL     PFC_emisPeriod      ! data related to PFC input(emission)
      _RL     PFC_emisCycle
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|



