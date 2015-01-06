C $Header: /u/gcmpack/MITgcm/pkg/pcb/pcb_param.F,v 1.2  Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#include "PCB_OPTIONS.h"
CStartOfInterface
      SUBROUTINE PCB_PARAM( myThid )
      !==========================================================
      ! SUBROUTINE PCB_PARAM
      !   Set parameters needed for PCB runs
      !==========================================================
      IMPLICIT NONE
     
      !---------------------------------------------------------
      ! Global variables
      !---------------------------------------------------------
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PCB.h"

      !---------------------------------------------------------
      ! Routine arguments
      !---------------------------------------------------------
      INTEGER myThid   ! Number of this instance of PCB_PARAM
CEndOfInterface

#ifdef ALLOW_PCB

      !---------------------------------------------------------
      ! Local variables
      !---------------------------------------------------------

      _BEGIN_MASTER( myThid )
      !---------------------------------------------------------
      ! Coefficients for calculating the Schmidt number in air
      !   From Johnson (2010), Ocean Science:
      !
      !   Schmidt number in air:
      !   Sca = v_a / D_a = eta_a / ( rho_a * D_a )                [Eq. 23]
      !   
      !   dynamic viscosity:
      !   eta_a = sv_0 + sv_1*T + sv_2*T^2 + sv_3*T^3 + sv_4*T^4   [Eq. 24]
      !
      !   density:
      !   rho_a = sd_0 + sd_1*T + sd_2*T^2 + sd_3*T^3              [Eq. 25]
      !
      !   diffusion coefficient in air:
      !   Da = 0.001 * (T^1.75) * (Mr^0.5) / ( (P*Va^1/3) + Vb^1/3 )^2   [Eq. 26]
      !
      !   Mr = ( Ma + Mb ) / (Ma * Mb)                             [Eq. 27]
      !
      !   where t is temperature in degrees Celcius, the units on eta_a are
      !   kg m^-3, and the units on rho_a are kg m^-3. Values of sv_* and 
      !   sd_* are in Table A1 of Johnson (2010), which references 
      !   Tsilingiris (2008). P is the atmospheric pressure in atm. Va and
      !   Vb are the molar volumes of air and of the gas of interest, 
      !   respectively. Ma and Mb are the molecular masses of air and the
      !   gas of interest, respectively. 
      !  
      ! References:
      ! Johnson, M. T. A numerical scheme to calculate temperature and 
      !   salinity dependent air-water transfer velocities for any gas.
      !   Ocean Science, 6, 913-932, 2010.
      !
      ! Tsilingiris, P. Thermophysical and transport properties of 
      !   humid air at temperature ranges between 0 and 100 C. Energ.
      !   Convers. Manage, 49, 1098-1110, 2008.
      !
      ! Tucker, W. A. and Nelken, L. H. Diffusion coefficients in air
      !   and water, in: Handbook of Chemical Property Estimatation
      !   Methods, American Chemical Society, Washington D. C., 1990.
      !---------------------------------------------------------

      !---------------------------------------------------------
      ! Parameters from Table A1 in Johnson (2010)
      !---------------------------------------------------------
      sv_0 = 1.71575 _d -5
      sv_1 = 4.7224 _d -8
      sv_2 = -3.6630 _d -10
      sv_3 = 1.87324 _d -12
      sv_4 = -8.0502 _d -14
      sd_0 = 1.2934 _d 0 
      sd_1 = -5.5384 _d -3
      sd_2 = 3.8602 _d -5
      sd_3 = -5.2536 _d -7

      !---------------------------------------------------------     
      ! Molar volume of air (cm^3 mol^-1)
      ! Reference: Tucker & Nelken (1990) 
      !---------------------------------------------------------
      Va = 20.1 _d 0  
      
      !---------------------------------------------------------
      ! Molar volume of gas of interest (cm^3 mol^-1)
      !  PCB 28  : 247.3 cm3/mol
      !  PCB 52  : 268.2 
      !  PCB 101 : 289.1 
      !  PCB 118 : 289.1
      !  PCB 138 : 310
      !  PCB 153 : 310
      !  PCB 180 : 330.9
      !
      ! Reference: Shiu & Mackay (1986)
      ! Notes: Vb at 25 degrees C. Vb for PCB 180 is not listed
      !        in Shiu & Mackay (1986), so what's used here for 180
      !        is the same Vb as for PCBs 171, 179, 183, 185, and 187.
      !---------------------------------------------------------
      Vb = 247.3d0   ! for PCB 28

      !---------------------------------------------------------
      ! Molecular mass of air (g mol^-1)
      ! Reference: Tucker & Nelken (1990)
      !---------------------------------------------------------
      Ma = 28.97 _d 0 

      !---------------------------------------------------------
      ! Molecular mass of gas of interest (g mol^-1)
      !  PCB 28  : 257.54  g/mol
      !  PCB 52  : 291.99 
      !  PCB 101 : 326.43
      !  PCB 118 : 326.43
      !  PCB 138 : 360.88
      !  PCB 153 : 360.88
      !  PCB 180 : 395.32
      !
      ! Reference: Li et al. (2003), J. Phys. Chem. Ref. Data
      !---------------------------------------------------------
      Mb = 257.54d0  ! for PCB 28

      !---------------------------------------------------------
      ! Atmospheric pressure (atm). Johnson (2010) assumes P
      ! to be unity for all calculations.       
      !---------------------------------------------------------
      Patm = 1.0 _d 0 !atm
     
c Do not need a pKa for PCBs (hma, 21 july 2014)
c      !---------------------------------------------------------
c      ! pKa value
c      !---------------------------------------------------------
cc      pKa = 0.0d0  ! xz: for PFOA, even smaller for PFOS
c      pKa = -3.d0  ! xz: PFOS From Campbell et al  JPC-A 2009 113
      
      !---------------------------------------------------------
      ! Partition coefficient to organic carbon (L kg^-1)
      !
      ! Set to -999d0 if you don't have a value from literature.
      !---------------------------------------------------------
      Koc_pcb = 10d0**5.9d0  ! for PCB 28 (Sobek et al., 2004, ES&T)

c Do not need a Kiw for PCBs (hma, 21 july 2014)
c      !---------------------------------------------------------
c      ! Interface/water partition coefficient (m)
c      !
c      ! At dilute condition of the Langmuir adsorption equation.
c      ! Reference: Vecitis et al. 2008 JPC-C
c      !---------------------------------------------------------
c      Kiw = 5.1d-6*1.97d0   !xz PFOS
 
c Not considering sea spray for PCBs (hma, 21 Jul 2014)
#ifdef ALLOW_SEASPRAY
      enrichfactor = 5.6d0 !for PFOA MCMURDO et al. Environ. Sci. Technol. 2008, 42, 3969–3974
c        write(*,*)'xz check enrichfactor in pcb_param:',enrichfactor 
#endif /* ALLOW_SEASPRAY */

            !--------------------------------------------------- 
            ! Dimensionless gas-over-liquid Henry's law 
            ! constant (KawD)
            !
            ! -----------------------
            ! GAS-OVER-LIQUID
            ! -----------------------
            !
            ! From Johnson (2010):
            !   KawD = C_air / C_water                      [Eq. 2]
            !
            !   where C_air and C_water are the equilibrium 
            !   concentrations of the gas of interest in air 
            !   and water, respectively. 
            !
            ! -----------------------
            ! LIQUID-OVER-GAS
            ! -----------------------
            !
            ! From Sander et al. (1999):
            !  KH = KH0 * exp( -dH/R * (1/T - 1/T0)  )      [Eq. 4]
            !
            !  where dH is the enthalpy of solution (J mol^-1), T is in 
            !  Kelvin, T0 is the temperature at standard conditions
            !  (T0 = 25 C = 298.15 K), R is the gas constant 
            !  (8.314 m^3 Pa mol^-1 K^-1 or 8.314 J K^-1 mol^-1), and KH0
            !  is the Henry's law constant at standard conditions. 
            !  Both KH and KH0 are in units of M atm^-1.    
            !    
            !  To convert KH from M atm^-1 to mol m^-3 Pa^-1:
            !  KH (M atm^-1) = 101.325 * KH (mol m^-3 Pa^-1)
            !  
            !  The dimensionless liquid-over-gas Henry's law constant
            !  is then, 
            !  KHcc = C_water / C_air = KH * R * T          [Eq. 2]
            !
            ! -----------------------
            ! Convert liquid-over-gas to gas-over-liquid
            ! -----------------------
            !   KawD = 1/KHcc
            !
            ! References
            ! Sander, R: Compilation of Henry's law constant for inorganic 
            !   and organic species of potential importance in 
            !   environmental chemistry, 1999.
            !   http://www.mpch-mainz.mpg.de/~sander/res/henry.html.
            !  
            ! Johnson, M. T. A numerical scheme to calculate temperature and 
            !   salinity dependent air-water transfer velocities for any gas.
            !   Ocean Science, 6, 913-932, 2010.
            !--------------------------------------------------- 

            ! Ehthalpy of air-water exchange (J mol^-1)
            !
            !  PCB 28  : 39  +/- 9       [ref #1]
            !  PCB 52  : 54  +/- 9       [ref #1] 
            !  PCB 101 :  
            !  PCB 118 : 34  +/- 5       [ref #1]
            !  PCB 138 : 51  +/- 15      [ref #1]
            !  PCB 153 : 25  +/- 27      [ref #1]
            !  PCB 180 :
            !
            ! References:
            !  #1 : Gioia et al. (2010), JGR, Table 3 
            dH   = 39.d3      ! for PCB-28 (Gioia et al., 2010, JGR; Table 3)

            ! Gas-over-liquid Henry's law constant 
            ! at 25 C (Pa m^3 mol^-1)
            !
            !  PCB 28  : 87  +/- 37      [ref #1]
            !  PCB 52  : 108 +/- 45      [ref #1] 
            !  PCB 101 :  
            !  PCB 118 : 84  +/- 35      [ref #1]
            !  PCB 138 : 77  +/- 32      [ref #1]
            !  PCB 153 : 202 +/- 84      [ref #1]
            !  PCB 180 :
            ! 
            ! References:
            !  #1 : Gioia et al. (2010), JGR, Table 2
            Kaw0 = 87.d0      ! for PCB 28

            ! Convert to mol Pa^-1 m^-3
            KH0 = 1.d0 / Kaw0


      _END_MASTER( myThid )

       ! Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_PCB */

      RETURN
      END
