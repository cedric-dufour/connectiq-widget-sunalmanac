// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Sun Almanac (SunAlmanac)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Sun Almanac (SunAlmanac) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Sun Almanac (SunAlmanac) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

// REFERENCES:
//   https://en.wikipedia.org/wiki/Sunrise_equation
//   http://aa.quae.nl/en/reken/zonpositie.html

//
// CLASS
//

class SA_Almanac {

  //
  // CONSTANTS
  //

  // Event angles
  public const ANGLE_RISESET = -0.83d;  // accounting for atmospheric refraction
  public const ANGLE_CIVIL = -6.0d;
  public const ANGLE_NAUTICAL = -12.0d;
  public const ANGLE_ASTRONOMICAL = -18.0d;

  // Event types
  private const EVENT_TRANSIT = 0;
  private const EVENT_NOW = 1;
  private const EVENT_SUNRISE = 2;
  private const EVENT_SUNSET = 3;

  // Units conversion
  private const CONVERT_DEG2RAD = 0.01745329252d;
  private const CONVERT_RAD2DEG = 57.2957795131d;

  // Computation
  private const COMPUTE_ITERATIONS = 2;


  //
  // VARIABLES
  //

  // Location
  public var sLocationName;  // degrees
  public var dLocationLatitude;  // degrees
  public var dLocationLongitude;  // degrees
  public var fLocationHeight;  // meters

  // Date
  public var iEpochDate;

  // Transit
  public var iEpochTransit;
  public var fElevationTransit;  // degrees
  public var fEclipticLongitude;  // degrees
  public var fDeclination;  // degrees

  // Current
  public var iEpochCurrent;
  public var fElevationCurrent;  // degrees
  public var fAzimuthCurrent;  // degrees

  // Sunrise
  public var iEpochAstronomicalDawn;
  public var iEpochNauticalDawn;
  public var iEpochCivilDawn;
  public var iEpochSunrise;
  public var fAzimuthSunrise;  // degrees

  // Sunset
  public var iEpochAstronomicalDusk;
  public var iEpochNauticalDusk;
  public var iEpochCivilDusk;
  public var iEpochSunset;
  public var fAzimuthSunset;  // degrees

  // Internals
  private var dDeltaT;
  private var dDUT1;
  private var dJulianDayNumber;
  private var dJ2kMeanTime;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    self.reset();
  }

  function reset() {
    // Location
    self.sLocationName = null;
    self.dLocationLatitude = null;
    self.dLocationLongitude = null;
    self.fLocationHeight = null;

    // Compute data
    self.resetCompute();
  }

  function resetCompute() {
    // Date
    self.iEpochDate = null;

    // Transit
    self.iEpochTransit = null;
    self.fElevationTransit = null;
    self.fEclipticLongitude = null;
    self.fDeclination = null;

    // Current
    self.iEpochCurrent = null;
    self.fElevationCurrent = null;
    self.fAzimuthCurrent = null;

    // Sunrise
    self.iEpochAstronomicalDawn = null;
    self.iEpochNauticalDawn = null;
    self.iEpochCivilDawn = null;
    self.iEpochSunrise = null;
    self.fAzimuthSunrise = null;

    // Sunset
    self.iEpochAstronomicalDusk = null;
    self.iEpochNauticalDusk = null;
    self.iEpochCivilDusk = null;
    self.iEpochSunset = null;
    self.fAzimuthSunset = null;
  }

  function setLocation(_sName, _dLatitude, _dLongitude, _fHeight) {
    //Sys.println(Lang.format("DEBUG: SA_Almanac.setLocation($1$, $2$, $3$, $4$)", [_sName, _dLatitude, _dLongitude, _fHeight]));

    self.sLocationName = _sName;
    self.dLocationLatitude = _dLatitude.toDouble();
    //Sys.println(Lang.format("DEBUG: latitude (l,omega) = $1$", [self.dLocationLatitude]));
    self.dLocationLongitude = _dLongitude.toDouble();
    //Sys.println(Lang.format("DEBUG: longitude (phi) = $1$", [self.dLocationLongitude]));
    self.fLocationHeight = _fHeight;
    //Sys.println(Lang.format("DEBUG: elevation = $1$", [self.fLocationHeight]));
  }

  function compute(_iEpochDate, _iEpochTime, _bFullCompute) {
    //Sys.println(Lang.format("DEBUG: SA_Almanac.compute($1$, $2$)", [_iEpochDate, _iEpochTime]));
    // WARNING: _iEpochDate may be relative to locatime (LT) or UTC; we shall make sure we end up using the latter (UTC)!

    // Location set ?
    if(self.dLocationLatitude == null or self.dLocationLongitude == null or self.fLocationHeight == null) {
      //Sys.println("DEBUG: location undefined!");
      return;
    }

    // Reset compute data
    self.resetCompute();

    // Date
    var oTime = new Time.Moment(_iEpochDate);
    var oTimeInfo_UTC = Gregorian.utcInfo(oTime, Time.FORMAT_SHORT);
    var iDaySeconds_UTC = 3600*oTimeInfo_UTC.hour+60*oTimeInfo_UTC.min+oTimeInfo_UTC.sec;
    //Sys.println(Lang.format("DEBUG: UTC time = $1$:$2$:$3$ ($4$)", [oTimeInfo_UTC.hour, oTimeInfo_UTC.min, oTimeInfo_UTC.sec, iDaySeconds_UTC]));
    var oTimeInfo_LT = Gregorian.info(oTime, Time.FORMAT_SHORT);
    var iDaySeconds_LT = 3600*oTimeInfo_LT.hour+60*oTimeInfo_LT.min+oTimeInfo_LT.sec;
    //Sys.println(Lang.format("DEBUG: LT time = $1$:$2$:$3$ ($4$)", [oTimeInfo_LT.hour, oTimeInfo_LT.min, oTimeInfo_LT.sec, iDaySeconds_LT]));
    var iOffset_LT = iDaySeconds_LT - iDaySeconds_UTC;
    if(iOffset_LT >= 43200) {
      iOffset_LT -= 86400;
    }
    else if(iOffset_LT < -43200) {
      iOffset_LT += 86400;
    }
    if(iDaySeconds_UTC == 0) {
      // Date is UTC date (0h00 Z)
      self.iEpochDate = _iEpochDate;
    }
    else {
      // Date is Local Time (0h00 LT) -> offset to the UTC date (0h00 Z)
      self.iEpochDate = _iEpochDate + iOffset_LT;
    }
    //Sys.println(Lang.format("DEBUG: local time offset = $1$", [iOffset_LT]));

    // Internals
    // ... Delta-T (TT-UT1); http://maia.usno.navy.mil/ser7/deltat.data
    self.dDeltaT = 68.8033d;  // 2017.06
    //Sys.println(Lang.format("DEBUG: Delta-T (TT-UT1) = $1$", [self.dDeltaT]));
    // ... julian day number (n)
    self.dJulianDayNumber = Math.round((self.iEpochDate+self.dDeltaT)/86400.0d+2440587.5d);
    //Sys.println(Lang.format("DEBUG: julian day number (n) = $1$", [self.dJulianDayNumber]));
    // ... DUT1 (UT1-UTC); http://maia.usno.navy.mil/ser7/ser7.dat
    var dBesselianYear = 1900.0d + (self.dJulianDayNumber-2415020.31352d)/365.242198781d;
    var dDUT21 = 0.022d*Math.sin(dBesselianYear*6.28318530718d) - 0.012d*Math.cos(dBesselianYear*6.28318530718d) - 0.006d*Math.sin(dBesselianYear*12.5663706144d) + 0.007d*Math.cos(dBesselianYear*12.5663706144d);
    self.dDUT1 = 0.2677d - 0.00106d*(self.dJulianDayNumber-2458067.5d) - dDUT21;
    //Sys.println(Lang.format("DEBUG: DUT1 (UT1-UTC) = $1$", [self.dDUT1]));
    // ... mean solar time (J*)
    self.dJ2kMeanTime = self.dJulianDayNumber - 2451545.0d + (self.dDeltaT+self.dDUT1)/86400.0d - self.dLocationLongitude/360.0d;
    //Sys.println(Lang.format("DEBUG: mean solar time (J*) = $1$", [self.dJ2kMeanTime]));

    // Data computation
    var adData;

    // ... transit
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_TRANSIT, null, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochTransit = adData[0].toNumber();
        self.fElevationTransit = adData[1].toFloat();
        self.fEclipticLongitude = adData[3].toFloat();
        self.fDeclination = adData[4].toFloat();
      }
    }
    //Sys.println(Lang.format("DEBUG: transit time = $1$", [self.iEpochTransit]));
    //Sys.println(Lang.format("DEBUG: transit elevation = $1$", [self.fElevationTransit]));

    // ... current
    if(_bFullCompute and _iEpochTime != null and self.iEpochTransit != null) {
      self.iEpochCurrent = _iEpochTime;
      adData = self.computeIterative(self.EVENT_NOW, null, (self.iEpochCurrent.toDouble()+self.dDeltaT+self.dDUT1)/86400.0d-10957.5d);
      self.fElevationCurrent = adData[1].toFloat();
      self.fAzimuthCurrent = adData[2].toFloat();
    }

    // ... sunrise
    adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_RISESET, self.dJ2kMeanTime);
    if(adData[0] != null) {
      self.iEpochSunrise = adData[0].toNumber();
      self.fAzimuthSunrise = adData[2].toFloat();
    }
    //Sys.println(Lang.format("DEBUG: sunrise time = $1$", [self.iEpochSunrise]));
    //Sys.println(Lang.format("DEBUG: sunrise azimuth = $1$", [self.fAzimuthSunrise]));

    // ... civil dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_CIVIL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochCivilDawn = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: civil dawn time = $1$", [self.iEpochCivilDawn]));

    // ... nautical dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_NAUTICAL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochNauticalDawn = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: nautical dawn time = $1$", [self.iEpochNauticalDawn]));

    // ... astronomical dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_ASTRONOMICAL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochAstronomicalDawn = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: astronomical dawn time = $1$", [self.iEpochAstronomicalDawn]));

    // ... sunset
    adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_RISESET, self.dJ2kMeanTime);
    if(adData[0] != null) {
      self.iEpochSunset = adData[0].toNumber();
      self.fAzimuthSunset = adData[2].toFloat();
    }
    //Sys.println(Lang.format("DEBUG: sunset time = $1$", [self.iEpochSunset]));
    //Sys.println(Lang.format("DEBUG: sunset azimuth = $1$", [self.fAzimuthSunset]));

    // ... civil dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_CIVIL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochCivilDusk = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: civil dusk time = $1$", [self.iEpochCivilDusk]));

    // ... nautical dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_NAUTICAL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochNauticalDusk = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: nautical dusk time = $1$", [self.iEpochNauticalDusk]));

    // ... astronomical dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_ASTRONOMICAL, self.dJ2kMeanTime);
      if(adData[0] != null) {
        self.iEpochAstronomicalDusk = adData[0].toNumber();
      }
    }
    //Sys.println(Lang.format("DEBUG: astronomical dusk time = $1$", [self.iEpochAstronomicalDusk]));
  }

  function computeEvent(_iEvent, _dElevationAngle, _dJ2kCompute) {
    var adData;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and _dJ2kCompute!=null; i--) {
      adData = self.computeIterative(_iEvent, _dElevationAngle, _dJ2kCompute);
      _dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      adData[0] = Math.round((adData[0]+10957.5d)*86400.0d-self.dDeltaT-self.dDUT1);
    }
    return adData;
  }

  function computeIterative(_iEvent, _dElevationAngle, _dJ2kCompute) {
    //Sys.println(Lang.format("DEBUG: SA_Almanac.computeIterative($1$, $2$, $3$)", [_iEvent, _dElevationAngle, _dJ2kCompute]));
    var dJ2kCentury = _dJ2kCompute/36524.2198781d;

    // Return values
    // [ time (J2k), elevation (degree), azimuth (degree), ecliptic longitude, declination ]
    var adData = [ null, null, null, null, null ];

    // Solar parameters

    // ... orbital eccentricity (e); https://en.wikipedia.org/wiki/Equation_of_time
    var dOrbitalEccentricity = 0.016709d - 0.00004193d*dJ2kCentury - 0.000000126d*dJ2kCentury*dJ2kCentury;
    //Sys.println(Lang.format("DEBUG: orbital eccentricity (e) = $1$", [dOrbitalEccentricity]));

    // ... ecliptic obliquity (epsilon); https://en.wikipedia.org/wiki/Ecliptic
    var dEclipticObliquity = 23.4392794444d - 0.0130102136111d*dJ2kCentury - 0.000000050861d*dJ2kCentury*dJ2kCentury;
    var dEclipticObliquity_rad = dEclipticObliquity * self.CONVERT_DEG2RAD;
    //Sys.println(Lang.format("DEBUG: ecliptic obliquity (epsilon) = $1$", [dEclipticObliquity]));

    // ... periapsis eclipitic longitude (lambda,p); https://en.wikipedia.org/wiki/Equation_of_time
    //var dEplicticLongitudePeriapsis = 282.93807d + 1.795d*dJ2kCentury + 0.0003025d*dJ2kCentury*dJ2kCentury;
    //Sys.println(Lang.format("DEBUG: periapsis ecliptic longitude (lambda,p) = $1$", [dEplicticLongitudePeriapsis]));

    // ... argument of perihelion (Pi); https://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf (Table 1)
    var dPerihelionArgument = 102.93768193d + 0.32327364*dJ2kCentury;
    //Sys.println(Lang.format("DEBUG: argument of perihelion (Pi) = $1$", [dPerihelionArgument]));

    // ... mean anomaly (M); http://www.jgiesen.de/elevaz/basics/meeus.htm
    var dMeanAnomaly = 357.5291d + 35999.05030d*dJ2kCentury - 0.0001559d*dJ2kCentury*dJ2kCentury;
    while(dMeanAnomaly >= 360.0d) {
      dMeanAnomaly -= 360.0d;
    }
    var dMeanAnomaly_rad = dMeanAnomaly * self.CONVERT_DEG2RAD;
    //Sys.println(Lang.format("DEBUG: mean anomaly (M) = $1$", [dMeanAnomaly]));

    // ... center equation (C); https://en.wikipedia.org/wiki/Equation_of_the_center
    var adOrbitalEccentricity_pow = [1.0d, 0.0d, 0.0d, 0.0d, 0.0d];
    for(var p=1; p<=4; p++) {
      adOrbitalEccentricity_pow[p] = adOrbitalEccentricity_pow[p-1]*dOrbitalEccentricity;
    }
    var dCenterEquation_rad = (2.0d*adOrbitalEccentricity_pow[1]-0.25d*adOrbitalEccentricity_pow[3])*Math.sin(dMeanAnomaly_rad) + (1.25d*adOrbitalEccentricity_pow[2]-0.458333333333d*adOrbitalEccentricity_pow[4])*Math.sin(2.0d*dMeanAnomaly_rad) + 1.08333333333d*adOrbitalEccentricity_pow[3]*Math.sin(3.0d*dMeanAnomaly_rad) + 1.07291666667d*adOrbitalEccentricity_pow[4]*Math.sin(4.0d*dMeanAnomaly_rad);
    var dCenterEquation = dCenterEquation_rad * self.CONVERT_RAD2DEG;
    //Sys.println(Lang.format("DEBUG: center equation (C) = $1$", [dCenterEquation]));

    // ... ecliptic longitude (lambda)
    //var dEclipticLongitude = dMeanAnomaly + dCenterEquation + dEplicticLongitudePeriapsis;
    var dEclipticLongitude = dMeanAnomaly + dCenterEquation + dPerihelionArgument + 180.0d;
    while(dEclipticLongitude >= 360.0d) {
      dEclipticLongitude -= 360.0d;
    }
    var dEclipticLongitude_rad = dEclipticLongitude * self.CONVERT_DEG2RAD;
    //Sys.println(Lang.format("DEBUG: ecliptic longitude (lambda) = $1$", [dEclipticLongitude]));

    // ... declination (delta)
    var dDeclination_rad = Math.asin(Math.sin(dEclipticLongitude_rad)*Math.sin(dEclipticObliquity_rad));
    var dDeclination = dDeclination_rad * self.CONVERT_RAD2DEG;
    //Sys.println(Lang.format("DEBUG: declination (delta) = $1$", [dDeclination]));

    // ... transit time <-> equation of time; https://en.wikipedia.org/wiki/Equation_of_time
    var dJ2kTransit = self.dJ2kMeanTime + (2.0d*dOrbitalEccentricity*Math.sin(dMeanAnomaly_rad) - Math.pow(Math.tan(dEclipticObliquity_rad/2.0d), 2.0d)*Math.sin(2.0d*dEclipticLongitude_rad))/6.28318530718d;
    //Sys.println(Lang.format("DEBUG: transit time (J,transit) = $1$", [dJ2kTransit]));

    // Computation finalization
    var dLocationLatitude_rad = self.dLocationLatitude * self.CONVERT_DEG2RAD;
    var dHeightCorrection_rad = Math.acos(6371008.8d/(6371008.8d+self.fLocationHeight));
    var dHeightCorrection = dHeightCorrection_rad * self.CONVERT_RAD2DEG;
    var dHourAngle;
    var dHourAngle_rad;
    var dElevationAngle;
    var dElevationAngle_rad;
    var dAzimuthAngle;
    var dAzimuthAngle_rad;
    var dJ2kEvent;

    // Transit
    if(_iEvent == self.EVENT_TRANSIT) {
      // ... elevation angle (alpha)
      dElevationAngle = 90.0d - self.dLocationLatitude + dDeclination;
      if(dElevationAngle > 90.0d) {
        dElevationAngle = 180.0d - dElevationAngle;
      }
      dElevationAngle += dHeightCorrection;
      //Sys.println(Lang.format("DEBUG: elevation angle (alpha) = $1$", [dElevationAngle]));

      // ... azimuth angle (A)
      dAzimuthAngle = self.dLocationLatitude > dDeclination ? 180.0d : 0.0d;
      //Sys.println(Lang.format("DEBUG: azimuth angle (A) = $1$", [dAzimuthAngle]));

      adData[0] = dJ2kTransit;
      adData[1] = dElevationAngle;
      adData[2] = dAzimuthAngle;
      adData[3] = dEclipticLongitude;
      adData[4] = dDeclination;
      return adData;
    }

    // Current
    if(_iEvent == self.EVENT_NOW) {
      dJ2kEvent = _dJ2kCompute;

      // ... hour angle (h)
      dHourAngle_rad = (self.iEpochCurrent - self.iEpochTransit).toDouble()/86400.0d*6.28318530718d;
      dHourAngle = dHourAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(Lang.format("DEBUG: hour angle (h) = $1$", [dHourAngle]));

      // ... elevation angle (alpha)
      dElevationAngle_rad = Math.asin(Math.sin(dLocationLatitude_rad)*Math.sin(dDeclination_rad)+Math.cos(dLocationLatitude_rad)*Math.cos(dDeclination_rad)*Math.cos(dHourAngle_rad))+dHeightCorrection_rad;
      dElevationAngle = dElevationAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(Lang.format("DEBUG: elevation angle (alpha) = $1$", [dElevationAngle]));
    }

    // Sunrise/Sunset
    else {
      // ... elevation angle (alpha)
      dElevationAngle = _dElevationAngle;
      dElevationAngle_rad = dElevationAngle * self.CONVERT_DEG2RAD;

      // ... hour angle (H, omega,0)
      dHourAngle_rad = Math.acos((Math.sin(dElevationAngle_rad-dHeightCorrection_rad)-Math.sin(dLocationLatitude_rad)*Math.sin(dDeclination_rad))/(Math.cos(dLocationLatitude_rad)*Math.cos(dDeclination_rad)));  // always positive
      if(!(dHourAngle_rad >= 0.0d and dHourAngle_rad <= Math.PI)) {  // == NaN does NOT work; BUG?
        //Sys.println("DEBUG: no such solar event!");
        return adData;  // null
      }
      if(_iEvent == self.EVENT_SUNRISE) {
        dHourAngle_rad = -dHourAngle_rad;
      }
      dHourAngle = dHourAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(Lang.format("DEBUG: hour angle (H, omega,0) = $1$", [dHourAngle]));

      // ... event time
      dJ2kEvent = dJ2kTransit + dHourAngle/360.0d;
    }

    // ... azimuth angle (A)
    dAzimuthAngle_rad = Math.atan2(Math.sin(dHourAngle_rad), Math.cos(dHourAngle_rad)*Math.sin(dLocationLatitude_rad) - Math.tan(dDeclination_rad)*Math.cos(dLocationLatitude_rad));
    dAzimuthAngle = dAzimuthAngle_rad * self.CONVERT_RAD2DEG;
    dAzimuthAngle = 180.0d + dAzimuthAngle;
    //Sys.println(Lang.format("DEBUG: azimuth angle (A) = $1$", [dAzimuthAngle]));

    adData[0] = dJ2kEvent;
    adData[1] = dElevationAngle;
    adData[2] = dAzimuthAngle;
    return adData;
  }

}

