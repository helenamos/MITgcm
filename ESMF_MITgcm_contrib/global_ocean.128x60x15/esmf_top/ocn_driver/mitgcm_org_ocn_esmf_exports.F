! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/ocn_driver/mitgcm_org_ocn_esmf_exports.F,v 1.2 2005/05/12 02:25:50 cnh Exp $
! $Name:  $
      MODULE MITGCM_ORG_OCN_ESMF_EXPORTS

      INTEGER      :: MAX_EXPORTS
      PARAMETER (MAX_EXPORTS=5)
      CHARACTER*80 :: EXPORT_NAMES(MAX_EXPORTS)
      DATA EXPORT_NAMES( 1) /"mitgcm_org_ocn hocn"/
      DATA EXPORT_NAMES( 2) /"mitgcm_org_ocn sstocn"/
      DATA EXPORT_NAMES( 3) /"mitgcm_org_ocn uvel"/
      DATA EXPORT_NAMES( 4) /"mitgcm_org_ocn vvel"/
      DATA EXPORT_NAMES( 5) /"mitgcm_org_ocn rvol"/

      END MODULE
