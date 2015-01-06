! $Header: /u/gcmpack/MITgcm_contrib/ESMF/global_ocean.128x60x15/esmf_top/ocn_driver/mitgcm_org_ocn_esmf_imports.F,v 1.1 2004/03/30 03:59:01 cnh Exp $
! $Name:  $
      MODULE MITGCM_ORG_OCN_ESMF_IMPORTS

      INTEGER      :: MAX_IMPORTS
      PARAMETER (MAX_IMPORTS=11)
      CHARACTER*80 :: IMPORT_NAMES(MAX_IMPORTS)
      DATA IMPORT_NAMES( 1) /"mitgcm_org_ocn heatflux"/
      DATA IMPORT_NAMES( 2) /"mitgcm_org_ocn taux"/
      DATA IMPORT_NAMES( 3) /"mitgcm_org_ocn tauy"/
      DATA IMPORT_NAMES( 4) /"mitgcm_org_ocn latent heatflux"/
      DATA IMPORT_NAMES( 5) /"mitgcm_org_ocn sensible heatflux"/
      DATA IMPORT_NAMES( 6) /"mitgcm_org_ocn longwave heatflux"/
      DATA IMPORT_NAMES( 7) /"mitgcm_org_ocn shortwave heatflux"/
      DATA IMPORT_NAMES( 8) /"mitgcm_org_ocn uvelground"/
      DATA IMPORT_NAMES( 9) /"mitgcm_org_ocn vvelground"/
      DATA IMPORT_NAMES(10) /"mitgcm_org_ocn fwflux"/
      DATA IMPORT_NAMES(11) /"mitgcm_org_ocn hatm"/

      END MODULE
