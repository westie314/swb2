module solar_calculations
  !! Functions for solar radiation analysis, especially earth-sun trigonometry. 

  use iso_c_binding
  use constants_and_conversions
  use meteorological_calculations
  use exceptions
  implicit none

  real (c_float) :: EARTH_SUN_DIST_Dr
  real (c_float) :: SOLAR_DECLINATION_Delta

contains

  function daylight_hours( dOmega_s )    result(dN)   bind(c)
    !! Calculate the number of daylight hours at a location.

    real (c_double), intent(in)   :: dOmega_s
      !! Sunset hour angle, in RADIANS
    real (c_double)               :: dN
      !! Number of daylight hours

    dN = 24_c_double / PI * dOmega_s

    !! @note 
    !!   Implementation follows equation 34, Allen and others (1998).
    !!
    !!  Reference:
    !!    Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
    !!    "Crop Evapotranspiration (Guidelines for computing crop water
    !!    requirements)", Food and Agriculture Organization, Rome, Italy.
    !! @endnote

  end function daylight_hours

  !------------------------------------------------------------------------------------------------

  elemental function extraterrestrial_radiation__Ra(dLatitude, dDelta, dOmega_s, dDsubR)    result(dRa)
    !! Calculate extraterrestrial radiation given latitude and time of year.

    real (c_double), intent(in) :: dLatitude
      !! Latitude of grid cell, in RADIANS
    real (c_double), intent(in) :: dDelta
      !! Solar declination, in RADIANS
    real (c_double), intent(in) :: dOmega_s
      !! Sunset hour angle, in RADIANS
    real (c_double), intent(in) :: dDsubR
      !! Inverse relative distance between earth and sun
    real (c_double) :: dRa
      !! Extraterrestrial radiation in MJ / m**2 / day.

    ! [ LOCALS ]
    real (c_double) :: dPartA, dPartB
    real (c_double), parameter :: dGsc = 0.0820_c_double  ! MJ / m**2 / min

    dPartA = dOmega_s * sin( dLatitude ) * sin( dDelta )
    dPartB = cos( dLatitude ) * cos( dDelta ) * sin( dOmega_s )

    dRa = 24_c_double * 60_c_double * dGsc * dDsubR * ( dPartA + dPartB ) / PI

    !! @note
    !!   1 MJ = 1e6 Joules; 1 Joule = 1 Watt / sec.
    !!   Therefore, multiply by 1e6 and divide by 86400 to get W/m*2-day.
    !! 
    !!   Source: Equation 21, Allen and others (1998).
    !!
    !!   Reference:
    !!        Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
    !!        "Crop Evapotranspiration (Guidelines for computing crop water
    !!        requirements)", Food and Agriculture Organization, Rome, Italy.
    !!
    !!   http://www.fao.org/docrep/x0490e/x0490e07.htm#solar%20radiation
    !! 
    !! @endnote

  end function extraterrestrial_radiation__Ra

  !------------------------------------------------------------------------------------------------

  function net_shortwave_radiation__Rns(dRs, dAlbedo)  result(dRns)
    !! Calculate net shortwave radiation

    real(c_double), intent(in) :: dRs
      !! Incoming shortwave solar radiation, in MJ / m**2 / day
    real(c_double), intent(in) :: dAlbedo
      !! Albedo or canopy reflection coefficient; 0.23 for grass reference crop
    real(c_double) :: dRns
      !! Net shortwave radiation, in MJ / m**2 / day

    dRns = (1_c_double - dAlbedo) * dRs

    !! @note
    !!   Implementation follows equation 38, Allen and others (1998).
    !!
    !!   Reference:
    !!     Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
    !!    "Crop Evapotranspiration (Guidelines for computing crop water
    !!    requirements)", Food and Agriculture Organization, Rome, Italy.
    !! @endnote

  end function net_shortwave_radiation__Rns

  !------------------------------------------------------------------------------------------------

  elemental function solar_declination_simple__delta(iDayOfYear, iNumDaysInYear) result(dDelta)
    !! Calculate the solar declination for a given day of the year.

    integer (c_int), intent(in) :: iDayOfYear
      !! Integer day of the year (January 1=1)
    integer (c_int), intent(in) :: iNumDaysInYear
      !! Number of days in the current year
    real (c_double) :: dDelta
      !! Solar declination, in RADIANS

    dDelta = 0.409_c_double &
             * sin( (TWOPI * real(iDayOfYear, c_double) / real(iNumDaysInYear, c_double) ) &
  		          - 1.39_c_double)

  !! @note
  !!  Implementation follows equation XXX? in:
  !!
  !!  Reference:
  !!    Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!    "Crop Evapotranspiration (Guidelines for computing crop water
  !!    requirements)", Food and Agriculture Organization, Rome, Italy.
  !! @endnote

  end function solar_declination_simple__delta


  !------------------------------------------------------------------------------------------------

  elemental function solar_declination__delta(iDayOfYear, iNumDaysInYear) result(dDelta)
    !! Calculate the solar declination for a given day of the year.
  
    integer (c_int), intent(in) :: iDayOfYear
      !! Integer day of the year (January 1 = 1)
    integer (c_int), intent(in) :: iNumDaysInYear
      !! Number of days in the current year
    real (c_double) :: dDelta
      !! Solar declination, in RADIANS
    
    ! [ LOCALS ]
    real (c_double) :: dGamma

    dGamma = day_angle__gamma( iDayOfYear, iNumDaysInYear )

    dDelta =   0.006918_c_double                                       &
             - 0.399912_c_double * cos( dGamma )                       &
             + 0.070257_c_double * sin( dGamma )                       &
             - 0.006758_c_double * cos( 2_c_double * dGamma )          &
             + 0.000907_c_double * sin( 2_c_double * dGamma )          &
             - 0.002697_c_double * cos( 3_c_double * dGamma )          &
             + 0.00148_c_double  * sin( 3_c_double * dGamma )

    !! @note
    !!  Implementation follows equation 1.3.1 in Iqbal (1983).
    !!
    !!  Iqbal (1983) reports maximum error of 0.0006 radians; if the last two terms are omitted,
    !!  the reported accuracy drops to 0.0035 radians.
    !!
    !!  Reference:
    !!    Iqbal, Muhammad (1983-09-28). An Introduction To Solar Radiation (p. 10). Elsevier Science. Kindle Edition.
    !! @endnote

  end function solar_declination__delta

  !------------------------------------------------------------------------------------------------

  elemental function relative_earth_sun_distance__D_r( iDayOfYear, iNumDaysInYear )   result( dDsubR )
    !! Calculate the inverse relative Earth-Sun distance for a given day of the year.

    integer (c_int), intent(in) :: iDayOfYear
      !! Integer day of the year (January 1 = 1)
    integer (c_int), intent(in) :: iNumDaysInYear
      !! Number of days in the current year
    real (c_double) :: dDsubR
      !! Relative earth-sun distance

    dDsubR = 1_c_double + 0.033_c_double &
             * cos( TWOPI * real( iDayOfYear, c_double )          &
                                      / real( iNumDaysInYear, c_double ) )

    !! @note
    !!   Implementation follows equation 23, Allen and others (1998):
    !!     \(d_r = 1 + 0.033 \cos \left( \frac{ 2 \pi }{365} J \right\)
    !!     where:
    !!       \( d_r \) is the inverse relative distance between Earth and the Sun
    !!       \( J \) is the current day of the year
    !!
    !! References:
    !!   Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
    !!   "Crop Evapotranspiration (Guidelines for computing crop water
    !!   requirements)", Food and Agriculture Organization, Rome, Italy.
    !!
    !!   Equation 1.2.3 in Iqbal, Muhammad (1983-09-28). An Introduction To Solar Radiation (p. 28).
    !!       Elsevier Science. Kindle Edition.
    !! @endnote

  end function relative_earth_sun_distance__D_r

  !------------------------------------------------------------------------------------------------

   elemental function sunrise_sunset_angle__omega_s( dLatitude, dDelta )   result( dOmega_s )
    !! Calculate sunrise/sunset angle, in RADIANS.

    real (c_double), intent(in) :: dLatitude
      !! Latitude, in RADIANS
    real (c_double), intent(in) :: dDelta
      !! Solar declination, in RADIANS
    real (c_double) :: dOmega_s
      !! Sunset angle, in RADIANS

    dOmega_s = acos( - tan(dLatitude) * tan(dDelta) )

  !! @note 
  !!   Implementation follows equation 25, Allen and others (1998).
  !!
  !!   Hour angle is zero at solar noon. Definition in Iqbal (1983) yields positive values before solar noon,
  !!       and negative values following solar noon.
  !!
  !!   Reference:
  !!     Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!     "Crop Evapotranspiration (Guidelines for computing crop water
  !!     requirements)", Food and Agriculture Organization, Rome, Italy.
  !! @endnote

  end function sunrise_sunset_angle__omega_s

  !------------------------------------------------------------------------------------------------

  function solar_radiation_Hargreaves__Rs( dRa, fTMin, fTMax )   result( dRs )   bind(c)
    !! Calculate shortwave solar radiation using Hargreave's radiation formula.
    !! For use when percent possible daily sunshine value is not available.

    real (c_double), intent(in) :: dRa
      !! Extraterrestrial radiation, in MJ / m**2 / day
    real (c_float), intent(in)  :: fTMin
    !! Minimum daily air temperature, in \(&deg\)C
    real (c_float), intent(in)  :: fTMax
    !! Maximum daily air temperature, in \(&deg\)C
    real (c_double)             :: dRs
    !! Solar radiation, in MJ / m**2 / day

    ! [ LOCALS ]
    real (c_double), parameter :: dKRs = 0.175

    dRs = dKRs * sqrt( C_to_K(fTMax) - C_to_K(fTMin) ) * dRa

  !! @note 
  !!   Implementation follows equation 50, Allen and others (1998).
  !!
  !!   Reference:
  !!     Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!     "Crop Evapotranspiration (Guidelines for computing crop water
  !!     requirements)", Food and Agriculture Organization, Rome, Italy.
  !! @endnote

  end function solar_radiation_Hargreaves__Rs

  !------------------------------------------------------------------------------------------------

  elemental function estimate_percent_of_possible_sunshine__psun(fTMax, fTMin)  result(fPsun)
    !! Estimate percent of possible sunshine.
    !! This function follows from equation 5 in "The Rational Use of the FAO Blaney-Criddle
    !! substituting the rearranged Hargreaves solar radiation formula into
    !! equation 5 results in the formulation as implemented.

    real (c_float), intent(in) :: fTMax
      !! Maximum daily air temperature, in Kelvin
    real (c_float), intent(in) :: fTMin
      !! Minimum daily air temperature, in Kelvin
    real (c_float) :: fPsun
      !! Percentage of possible sunshine, dimensionless percentage

    ! [ LOCALS ]
    real (c_float), parameter :: fKRs = 0.175

    fPsun = ( 2_c_float * fKRs * sqrt( fTMAX - fTMIN ) ) - 0.5_c_float

    if ( fPsun < 0_c_float ) then
      fPsun = 0_c_float
    elseif ( fPsun > 1.0_c_float ) then
      fPsun = 100_c_float
    else
      fPsun = fPsun * 100_c_float
    endif

  end function estimate_percent_of_possible_sunshine__psun

  !------------------------------------------------------------------------------------------------

  !> Calculate clear sky solar radiation.
  !!
  !! Calculate the clear sky solar radiation (i.e. when rPctSun = 100,
  !!   n/N=1.  Required for computing net longwave radiation.
  !!
  !! @param[in]  dRa   Extraterrestrial radiation, in MJ / m**2 / day
  !! @param[in]  dAs   Solar radiation regression constant, expressing the fraction
  !!                     of extraterrestrial radiation that reaches earth on OVERCAST days.
  !! @param[in]  sBs   Solar radiation regression constant. As + Bs express the fraction
  !!                     of extraterrestrial radiation that reaches earth on CLEAR days.
  !! @retval    dRso   Clear sky solar radiation, in MJ / m**2 / day
  !!
  !!  Implementation follows equation 36, Allen and others (1998).
  !!
  !!  Reference:
  !!   Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!    "Crop Evapotranspiration (Guidelines for computing crop water
  !!    requirements)", Food and Agriculture Organization, Rome, Italy.

  function clear_sky_solar_radiation__Rso( dRa, dAs, dBs )   result( dRso )   bind(c)

    real (c_double), intent(in)           :: dRa
    real (c_double), intent(in), optional :: dAs
    real (c_double), intent(in),optional  :: dBs
    real (c_double)                       :: dRso

    ! [ LOCALS ]
    real (c_double) :: dAs_l
    real (c_double) :: dBs_l

    ! assign default value to As if none is provided
    if ( present( dAs ) ) then
      dAs_l = dAs
    else
      dAs_l = 0.25_c_double
    end if

    ! assign default value to Bs if none is provided
    if ( present( dBs ) ) then
      dBs_l = dBs
    else
      dBs_l = 0.5_c_double
    end if

    dRso = (dAs_l + dBs_l * dRa)

  end function clear_sky_solar_radiation__Rso

  !------------------------------------------------------------------------------------------------

  !> Calculate the clear sky solar radiation.
  !!
  !! Calculate the clear sky solar radiation (i.e. when rPctSun = 100,
  !!   n/N=1.  Required for computing net longwave radiation.
  !!   For use when no regression coefficients (A, B) are known.
  !!
  !! @param[in]         dRa   Extraterrestrial radiation, in MJ / m**2 / day
  !! @param[in]  fElevation   Elevation, in METERS above sea level
  !! @retval           dRso   Clear sky solar radiation, in MJ / m**2 / day
  !!
  !! Implementation follows equation 37, Allen and others (1998).
  !!
  !! Reference:
  !!   Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!    "Crop Evapotranspiration (Guidelines for computing crop water
  !!    requirements)", Food and Agriculture Organization, Rome, Italy.

  function clear_sky_solar_radiation_noAB__Rso(dRa, fElevation) result(dRso)

    real (c_double), intent(in) :: dRa
    real (c_float), intent(in)  :: fElevation
    real (c_double)             :: dRso

    dRso = ( 0.75_c_double + 1.0E-5_c_double * fElevation ) * dRa

  end function clear_sky_solar_radiation_noAB__Rso

  !------------------------------------------------------------------------------------------------

  !> Calculate solar radiation by means of the Angstrom formula.
  !!
  !! @param[in]      dRa   Extraterrestrial radiation in MJ / m**2 / day
  !! @param[in]      dAs   Solar radiation regression constant, expressing the fraction
  !!                         of extraterrestrial radiation that reaches earth on OVERCAST days.
  !! @param[in]      dBs   Solar radiation regression constant. As + Bs express the fraction
  !!                         of extraterrestrial radiation that reaches earth on CLEAR days.
  !! @param[in]  fPctSun   Percent of TOTAL number of sunshine hours during which the
  !!                         sun actually shown.
  !! @retval         fRs   Solar radiation in MJ / m**2 / day
  !!
  !!  Implementation follows equation 35, Allen and others (1998).
  !!
  !!   Reference:
  !!   Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!    "Crop Evapotranspiration (Guidelines for computing crop water
  !!    requirements)", Food and Agriculture Organization, Rome, Italy.

  elemental function solar_radiation__Rs(dRa, dAs, dBs, fPctSun) result(dRs)

    real (c_double), intent(in) :: dRa
    real (c_double), intent(in) :: dAs
    real (c_double), intent(in) :: dBs
    real (c_double), intent(in) :: fPctSun
    real (c_double)             :: dRs

    dRs = ( dAs + (dBs * fPctSun / 100_c_float ) ) * dRa

  end function solar_radiation__Rs

  !------------------------------------------------------------------------------------------------

  elemental function net_longwave_radiation__Rnl(fTMin, fTMax, dRs, dRso)  result(dRnl)
    !! Calculate net longwave radiation flux

    real(c_float), intent(in)  :: fTMin
      !! Minimum daily air temperature, in \(deg\)C
    real(c_float), intent(in)  :: fTMax
      !! Maximum daily air temperature, in \(deg\)C
    real(c_double), intent(in) :: dRs
      !! Measured or calculated shortwave solar radiation, in MJ / m**2 / day
    real(c_double), intent(in) :: dRso
      !! Calculated clear-sky radiation, in MJ / m**2 / day
    real(c_double)             :: dRnl
      !! Net longwave solar radiation flux (incoming minus outgoing), in MJ / m**2 / day

    ! [ LOCALS ]
    real(c_double)             :: dTAvg_K
    real(c_double)             :: dTAvg_4
    real (c_double)            :: d_ea
    real (c_double)            :: dCloudFrac
    real (c_double), parameter :: dSIGMA = 4.903E-9_c_double

    dTAvg_K = C_to_K((fTMin + fTMax ) / 2.0_c_float )

    dTAvg_4 = dTAvg_K * dTAvg_K * dTAvg_K * dTAvg_K * dSIGMA
    d_ea = dewpoint_vapor_pressure__e_a( fTMin )

    dCloudFrac = min( dRs / dRso, 1.0_c_double )

    dRnl = dTAvg_4 * ( 0.34_c_double - 0.14_c_double * sqrt( d_ea ) ) &
            * ( 1.35_c_double * dCloudFrac - 0.35_c_double )

  !! @note
  !!   Implementation follows equation 39, Allen and others (1998).
  !!
  !!   Reference:
  !!     Allen, R.G., and others, 1998, FAO Irrigation and Drainage Paper No. 56,
  !!     "Crop Evapotranspiration (Guidelines for computing crop water
  !!     requirements)", Food and Agriculture Organization, Rome, Italy.
  !! @endnote

  end function net_longwave_radiation__Rnl

  !------------------------------------------------------------------------------------------------

  elemental function day_angle__gamma(iDayOfYear, iNumDaysInYear)     result(dGamma)
    !! Calculate the day angle, in RADIANS
    !! This function expresses the integer day number as an angle (in
    !! radians). Output values range from 0 (on January 1st) to
    !! just less than \(2\pi\) on December 31st.

    integer (c_int), intent(in)   :: iDayOfYear
      !! Current day of the year (January 1 = 1)
    integer (c_int), intent(in)   :: iNumDaysInYear
      !! Number of days in the current year
    real (c_double)               :: dGamma
      !! Day angle, in RADIANS

    dGamma = TWOPI * ( iDayOfYear - 1 ) / iNumDaysInYear

  !! @note 
  !!   Implementation follows equation 1.2.2 in Iqbal (1983)
  !!
  !!   Reference:
  !!     Iqbal, Muhammad (1983-09-28). An Introduction To Solar Radiation (p. 3). Elsevier Science. Kindle Edition.
  !! @endnote

  end function day_angle__gamma

  !------------------------------------------------------------------------------------------------

  function solar_altitude__alpha( dTheta_z )    result( dAlpha )   bind(c)
    !! Calculate the solar altitude given the zenith angle.

    real (c_double), intent(in)   :: dTheta_z
      !! Solar zenith angle for given location and time, in RADIANS
    real (c_double)               :: dAlpha
      !! Solar altitude angle for given location, in RADIANS

    call assert( dTheta_z >= 0.0_c_double .and. dTheta_z <= HALFPI, &
      "Internal programming error: solar zenith angle must be in radians and in the range 0 to pi/2", &
      __FILE__, __LINE__)

    dAlpha = HALFPI - dAlpha

  end function solar_altitude__alpha

  !------------------------------------------------------------------------------------------------

	function zenith_angle__theta_z( dLatitude, dDelta, dOmega ) result( dTheta_z )     bind(c)
	  !! Calculate solar zenith angle given latitude, declination, and (optionally) hour angle.
    !! Solar zenith angle is the angle between a point directly overhead and
	  !! the center of the sun's disk.

	  real (c_double), intent(in)            :: dLatitude
      !! Latitude of location for which estimate is being made, in RADIANS
    real (c_double), intent(in)            :: dDelta
      !! Solar declination angle, in RADIANS
    real (c_double), intent(in), optional  :: dOmega
      !! [OPTIONAL] Hour angle, measured at the celestial pole between the observer's meridian and
      !!            the solar meridian, in RADIANS
	  real (c_double) :: dTheta_z
      !! Solar zenith angle for the given location and time, in RADIANS

    ! [ LOCALS ]
    real (c_double) :: dOmega_l

    if ( present( dOmega ) ) then
      dOmega_l = dOmega_l
    else
      dOmega_l = 0.0_c_double
    endif

	  call assert( dLatitude <= HALFPI .and. dLatitude >= -HALFPI , &
	    "Internal programming error: Latitude must be expressed in RADIANS and range from -pi/2 to pi/2", &
	    __FILE__, __LINE__ )


	  dTheta_z = acos( sin(dLatitude) * sin(dDelta) + cos(dLatitude) * cos(dDelta) * cos(dOmega_l ) )

  !! @note
  !!  Implementation follows equation 9.67, Jacobson, 2005
  !!  
  !!  Reference:
  !!    Jacobson, M.Z., 2005, Fundamentals of atmospheric modeling, Second Edition:
  !!    Cambridge University Press.
  !! @endnote

	end function zenith_angle__theta_z

  !------------------------------------------------------------------------------------------------

  function azimuth_angle__psi(rAlpha, rLatitude, rDelta)   result(rPsi)    bind(c)
    !! Calculate solar azimuth angle

    real (c_double), intent(in)      :: rAlpha
      !! Solar altitude angle, in RADIANS
    real (c_double), intent(in)      :: rLatitude
      !! Latitude of location for which estimate is being made, in RADIANS
    real (c_double), intent(in)      :: rDelta
      !! Solar declination angle, in RADIANS
    real (c_double)                  :: rPsi
      !! Solar azimuth angle, in RADIANS

    ! [ LOCALS ]
    real (c_double) :: rTempval

    rTempval = ( sin( rAlpha ) * sin( rLatitude ) - sin( rDelta ) )          &
              /   ( cos( rAlpha ) * cos( rLatitude ) )

    ! avoid a NaN; cap value at 1.0
    if ( abs( rTempval ) > 1.0_c_double ) rTempval = sign( 1.0_c_double, rTempval )

    rPsi = acos( rTempval )

  !! @note
  !!   Implementation follows equation 1.5.2a in Iqbal (1983).
  !!
  !!   Reference:
  !!     Iqbal, Muhammad (1983-09-28). An Introduction To Solar Radiation (p. 15). Elsevier Science. Kindle Edition.
  !! @endnote

  end function azimuth_angle__psi

end module solar_calculations
