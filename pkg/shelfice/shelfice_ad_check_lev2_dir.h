C $Header: /u/gcmpack/MITgcm/pkg/shelfice/shelfice_ad_check_lev2_dir.h,v 1.2 2011/05/10 07:49:19 mlosch Exp $
C $Name: checkpoint64g $

#ifdef ALLOW_SHELFICE
CADJ STORE cMeanSHIforT   = tapelev2, key = ilev_2
CADJ STORE cMeanSHIforS   = tapelev2, key = ilev_2
# ifdef ALLOW_SHIFWFLX_CONTROL
CADJ STORE xx_shifwflx0   = tapelev2, key = ilev_2
CADJ STORE xx_shifwflx1   = tapelev2, key = ilev_2
# endif
#endif /* ALLOW_SHELFICE */
