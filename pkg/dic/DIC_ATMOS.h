C $Header: /u/gcmpack/MITgcm/pkg/dic/DIC_ATMOS.h,v 1.4 2010/04/11 20:59:27 jmc Exp $
C $Name: checkpoint64g $

       COMMON /INTERACT_ATMOS_NEEDS/
     &              co2atmos,
     &              total_atmos_carbon, total_ocean_carbon,
     &              total_atmos_carbon_year,
     &              total_ocean_carbon_year,
     &              total_atmos_carbon_start,
     &              total_ocean_carbon_start,
     &              atpco2

       _RL co2atmos(1000)
       _RL total_atmos_carbon
       _RL total_ocean_carbon
       _RL total_atmos_carbon_year
       _RL total_atmos_carbon_start
       _RL total_ocean_carbon_year
       _RL total_ocean_carbon_start
       _RL atpco2