// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Sun Almanac (SunAlmanac)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
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

import Toybox.Lang;
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

(:glance)
class MyAlmanac {

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
  public var sLocationName as String = "";
  public var dLocationLatitude as Decimal = NaN;  // degrees
  public var dLocationLongitude as Decimal = NaN;  // degrees
  public var fLocationHeight as Float = NaN;  // meters

  // Date
  public var iEpochDate as Number = -1;

  // Transit
  public var iEpochTransit as Number = -1;
  public var fElevationTransit as Float = NaN;  // degrees
  public var fEclipticLongitude as Float = NaN;  // degrees
  public var fDeclination as Float = NaN;  // degrees

  // Current
  public var iEpochCurrent as Number = -1;
  public var fElevationCurrent as Float = NaN;  // degrees
  public var fAzimuthCurrent as Float = NaN;  // degrees

  // Sunrise
  public var iEpochAstronomicalDawn as Number = -1;
  public var iEpochNauticalDawn as Number = -1;
  public var iEpochCivilDawn as Number = -1;
  public var iEpochSunrise as Number = -1;
  public var fAzimuthSunrise as Float = NaN;  // degrees

  // Sunset
  public var iEpochAstronomicalDusk as Number = -1;
  public var iEpochNauticalDusk as Number = -1;
  public var iEpochCivilDusk as Number = -1;
  public var iEpochSunset as Number = -1;
  public var fAzimuthSunset as Float = NaN;  // degrees

  // Internals
  private var dDeltaT as Decimal = NaN;
  private var dDUT1 as Decimal = NaN;
  private var dJulianDayNumber as Decimal = NaN;
  private var dJ2kMeanTime as Decimal = NaN;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    self.reset();
  }

  function reset() as Void {
    // Location
    self.sLocationName = "";
    self.dLocationLatitude = NaN;
    self.dLocationLongitude = NaN;
    self.fLocationHeight = NaN;

    // Compute data
    self.resetCompute();
  }

  function resetCompute() as Void {
    // Date
    self.iEpochDate = -1;

    // Transit
    self.iEpochTransit = -1;
    self.fElevationTransit = NaN;
    self.fEclipticLongitude = NaN;
    self.fDeclination = NaN;

    // Current
    self.iEpochCurrent = -1;
    self.fElevationCurrent = NaN;
    self.fAzimuthCurrent = NaN;

    // Sunrise
    self.iEpochAstronomicalDawn = -1;
    self.iEpochNauticalDawn = -1;
    self.iEpochCivilDawn = -1;
    self.iEpochSunrise = -1;
    self.fAzimuthSunrise = NaN;

    // Sunset
    self.iEpochAstronomicalDusk = -1;
    self.iEpochNauticalDusk = -1;
    self.iEpochCivilDusk = -1;
    self.iEpochSunset = -1;
    self.fAzimuthSunset = NaN;
  }

  function setLocation(_sName as String, _dLatitude as Decimal, _dLongitude as Decimal, _fHeight as Float) as Void {
    //Sys.println(format("DEBUG: MyAlmanac.setLocation($1$, $2$, $3$, $4$)", [_sName, _dLatitude, _dLongitude, _fHeight]));

    self.sLocationName = _sName;
    self.dLocationLatitude = _dLatitude.toDouble();
    //Sys.println(format("DEBUG: latitude (l,omega) = $1$", [self.dLocationLatitude]));
    self.dLocationLongitude = _dLongitude.toDouble();
    //Sys.println(format("DEBUG: longitude (phi) = $1$", [self.dLocationLongitude]));
    self.fLocationHeight = _fHeight;
    //Sys.println(format("DEBUG: elevation = $1$", [self.fLocationHeight]));
  }

  function compute(_iEpochDate as Number, _iEpochTime as Number?, _bFullCompute as Boolean) as Void {
    //Sys.println(format("DEBUG: MyAlmanac.compute($1$, $2$)", [_iEpochDate, _iEpochTime]));
    // WARNING: _iEpochDate may be relative to locatime (LT) or UTC; we shall make sure we end up using the latter (UTC)!

    // Location set ?
    if(LangUtils.isNaN(self.dLocationLatitude) or LangUtils.isNaN(self.dLocationLongitude) or LangUtils.isNaN(self.fLocationHeight)) {
      //Sys.println("DEBUG: location undefined!");
      return;
    }

    // Reset compute data
    self.resetCompute();

    // Date
    var oTime = new Time.Moment(_iEpochDate + 43200);
    var oTimeInfo_UTC = Gregorian.utcInfo(oTime, Time.FORMAT_SHORT);
    var iDaySeconds_UTC = 3600*oTimeInfo_UTC.hour+60*oTimeInfo_UTC.min+oTimeInfo_UTC.sec;
    //Sys.println(format("DEBUG: UTC time = $1$:$2$:$3$ ($4$)", [oTimeInfo_UTC.hour, oTimeInfo_UTC.min, oTimeInfo_UTC.sec, iDaySeconds_UTC]));
    var oTimeInfo_LT = Gregorian.info(oTime, Time.FORMAT_SHORT);
    var iDaySeconds_LT = 3600*oTimeInfo_LT.hour+60*oTimeInfo_LT.min+oTimeInfo_LT.sec;
    //Sys.println(format("DEBUG: LT time = $1$:$2$:$3$ ($4$)", [oTimeInfo_LT.hour, oTimeInfo_LT.min, oTimeInfo_LT.sec, iDaySeconds_LT]));
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
    //Sys.println(format("DEBUG: local time offset = $1$", [iOffset_LT]));

    // Internals
    // ... Delta-T (TT-UT1)
    self.dDeltaT = 70.91d;  // ALMANAC: 2021.12.23 (#49)
    //Sys.println(format("DEBUG: Delta-T (TT-UT1) = $1$", [self.dDeltaT]));
    // ... julian day number (JD, n)
    var iJD_year = oTimeInfo_UTC.year as Number;
    var iJD_month = oTimeInfo_UTC.month as Number;
    if(iJD_month <= 2) {
      iJD_year -= 1;
      iJD_month += 12;
    }
    var dJD_century = Math.floor(iJD_year/100.0d);
    self.dJulianDayNumber =
      - dJD_century
      + Math.floor(dJD_century/4.0d)
      + oTimeInfo_UTC.day
      + Math.floor(365.25d * (iJD_year+4716))
      + Math.floor(30.6001d * (iJD_month+1))
      - 1522.0d;  // at noon
    //Sys.println(format("DEBUG: julian day number (JD, n) = $1$", [self.dJulianDayNumber]));
    // ... DUT1 (UT1-UTC)
    var dBesselianYear =
      1900.0d + (self.dJulianDayNumber - 2415020.31352d) / 365.242198781d;
    var dDUT21 =
      0.022d * Math.sin(dBesselianYear * 6.28318530718d)
      - 0.012d * Math.cos(dBesselianYear * 6.28318530718d)
      - 0.006d * Math.sin(dBesselianYear * 12.5663706144d)
      + 0.007d * Math.cos(dBesselianYear * 12.5663706144d);  // ALMANAC: 2021.12.23 (#50)
    self.dDUT1 =
      -0.1173d
      + 0.00021d * (self.dJulianDayNumber - 2459572.5d)
      - dDUT21;  // ALMANAC: 2021.12.23 (#50)
    //Sys.println(format("DEBUG: DUT1 (UT1-UTC) = $1$", [self.dDUT1]));
    // ... mean solar time (J*)
    self.dJ2kMeanTime =
      self.dJulianDayNumber
      - 2451545.0d
      + (self.dDeltaT + self.dDUT1) / 86400.0d
      - self.dLocationLongitude / 360.0d;
    //Sys.println(format("DEBUG: mean solar time (J*) = $1$", [self.dJ2kMeanTime]));

    // Data computation
    var adData = [ NaN, NaN, NaN, NaN, NaN ] as Array<Decimal>;

    // ... transit
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_TRANSIT, null, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochTransit = adData[0].toNumber();
        self.fElevationTransit = adData[1].toFloat();
        self.fEclipticLongitude = adData[3].toFloat();
        self.fDeclination = adData[4].toFloat();
      }
    }
    //Sys.println(format("DEBUG: transit time = $1$", [self.iEpochTransit]));
    //Sys.println(format("DEBUG: transit elevation = $1$", [self.fElevationTransit]));

    // ... current
    if(_bFullCompute and _iEpochTime != null and self.iEpochTransit >= 0) {
      self.iEpochCurrent = _iEpochTime;
      adData = self.computeIterative(self.EVENT_NOW,
                                     null,
                                     (self.iEpochCurrent.toDouble() + self.dDeltaT + self.dDUT1) / 86400.0d - 10957.5d);
      self.fElevationCurrent = adData[1].toFloat();
      self.fAzimuthCurrent = adData[2].toFloat();
    }

    // ... sunrise
    adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_RISESET, self.dJ2kMeanTime);
    if(LangUtils.notNaN(adData[0])) {
      self.iEpochSunrise = adData[0].toNumber();
      self.fAzimuthSunrise = adData[2].toFloat();
    }
    //Sys.println(format("DEBUG: sunrise time = $1$", [self.iEpochSunrise]));
    //Sys.println(format("DEBUG: sunrise azimuth = $1$", [self.fAzimuthSunrise]));

    // ... civil dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_CIVIL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochCivilDawn = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: civil dawn time = $1$", [self.iEpochCivilDawn]));

    // ... nautical dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_NAUTICAL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochNauticalDawn = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: nautical dawn time = $1$", [self.iEpochNauticalDawn]));

    // ... astronomical dawn
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNRISE, self.ANGLE_ASTRONOMICAL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochAstronomicalDawn = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: astronomical dawn time = $1$", [self.iEpochAstronomicalDawn]));

    // ... sunset
    adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_RISESET, self.dJ2kMeanTime);
    if(LangUtils.notNaN(adData[0])) {
      self.iEpochSunset = adData[0].toNumber();
      self.fAzimuthSunset = adData[2].toFloat();
    }
    //Sys.println(format("DEBUG: sunset time = $1$", [self.iEpochSunset]));
    //Sys.println(format("DEBUG: sunset azimuth = $1$", [self.fAzimuthSunset]));

    // ... civil dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_CIVIL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochCivilDusk = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: civil dusk time = $1$", [self.iEpochCivilDusk]));

    // ... nautical dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_NAUTICAL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochNauticalDusk = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: nautical dusk time = $1$", [self.iEpochNauticalDusk]));

    // ... astronomical dusk
    if(_bFullCompute) {
      adData = self.computeEvent(self.EVENT_SUNSET, self.ANGLE_ASTRONOMICAL, self.dJ2kMeanTime);
      if(LangUtils.notNaN(adData[0])) {
        self.iEpochAstronomicalDusk = adData[0].toNumber();
      }
    }
    //Sys.println(format("DEBUG: astronomical dusk time = $1$", [self.iEpochAstronomicalDusk]));
  }

  function computeEvent(_iEvent as Number, _dElevationAngle as Decimal?, _dJ2kCompute as Decimal) as Array<Decimal> {
    var adData = [ NaN, NaN, NaN, NaN, NaN ] as Array<Decimal>;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and LangUtils.notNaN(_dJ2kCompute); i--) {
      adData = self.computeIterative(_iEvent, _dElevationAngle, _dJ2kCompute);
      _dJ2kCompute = adData[0];
    }
    if(LangUtils.notNaN(adData[0])) {
      adData[0] = Math.round((adData[0] + 10957.5d) * 86400.0d - self.dDeltaT - self.dDUT1);
    }
    return adData;
  }

  function computeIterative(_iEvent as Number, _dElevationAngle as Decimal?, _dJ2kCompute as Decimal) as Array<Decimal> {
    //Sys.println(format("DEBUG: MyAlmanac.computeIterative($1$, $2$, $3$)", [_iEvent, _dElevationAngle, _dJ2kCompute]));
    var dJ2kCentury = _dJ2kCompute / 36524.2198781d;

    // Return values
    // [ time (J2k), elevation (degree), azimuth (degree), ecliptic longitude, declination ]
    var adData = [ NaN, NaN, NaN, NaN, NaN ] as Array<Decimal>;

    // Solar parameters

    // ... orbital eccentricity (e); https://en.wikipedia.org/wiki/Equation_of_time
    var dOrbitalEccentricity =
      0.016709d
      - 0.00004193d * dJ2kCentury
      - 0.000000126d * dJ2kCentury*dJ2kCentury;
    //Sys.println(format("DEBUG: orbital eccentricity (e) = $1$", [dOrbitalEccentricity]));

    // ... ecliptic obliquity (epsilon); https://en.wikipedia.org/wiki/Ecliptic
    var dEclipticObliquity =
      23.4392794444d
      - 0.0130102136111d * dJ2kCentury
      - 0.000000050861d * dJ2kCentury * dJ2kCentury;
    var dEclipticObliquity_rad =
      dEclipticObliquity * self.CONVERT_DEG2RAD;
    //Sys.println(format("DEBUG: ecliptic obliquity (epsilon) = $1$", [dEclipticObliquity]));

    // ... periapsis eclipitic longitude (lambda,p); https://en.wikipedia.org/wiki/Equation_of_time
    //var dEplicticLongitudePeriapsis = 282.93807d + 1.795d*dJ2kCentury + 0.0003025d*dJ2kCentury*dJ2kCentury;
    //Sys.println(format("DEBUG: periapsis ecliptic longitude (lambda,p) = $1$", [dEplicticLongitudePeriapsis]));

    // ... argument of perihelion (Pi); https://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf (Table 1)
    var dPerihelionArgument =
      102.93768193d
      + 0.32327364 * dJ2kCentury;
    //Sys.println(format("DEBUG: argument of perihelion (Pi) = $1$", [dPerihelionArgument]));

    // ... mean anomaly (M); http://www.jgiesen.de/elevaz/basics/meeus.htm
    var dMeanAnomaly =
      357.5291d
      + 35999.05030d * dJ2kCentury
      - 0.0001559d * dJ2kCentury * dJ2kCentury;
    while(dMeanAnomaly >= 360.0d) {
      dMeanAnomaly -= 360.0d;
    }
    var dMeanAnomaly_rad =
      dMeanAnomaly * self.CONVERT_DEG2RAD;
    //Sys.println(format("DEBUG: mean anomaly (M) = $1$", [dMeanAnomaly]));

    // ... center equation (C); https://en.wikipedia.org/wiki/Equation_of_the_center
    var adOrbitalEccentricity_pow = [1.0d, 0.0d, 0.0d, 0.0d, 0.0d] as Array<Decimal>;
    for(var p=1; p<=4; p++) {
      adOrbitalEccentricity_pow[p] = adOrbitalEccentricity_pow[p-1] * dOrbitalEccentricity;
    }
    var dCenterEquation_rad =
      (2.0d * adOrbitalEccentricity_pow[1] - 0.25d * adOrbitalEccentricity_pow[3]) * Math.sin(dMeanAnomaly_rad)
      + (1.25d*adOrbitalEccentricity_pow[2] - 0.458333333333d * adOrbitalEccentricity_pow[4]) * Math.sin(2.0d*dMeanAnomaly_rad)
      + 1.08333333333d * adOrbitalEccentricity_pow[3] * Math.sin(3.0d*dMeanAnomaly_rad)
      + 1.07291666667d * adOrbitalEccentricity_pow[4] * Math.sin(4.0d*dMeanAnomaly_rad);
    var dCenterEquation =
      dCenterEquation_rad * self.CONVERT_RAD2DEG;
    //Sys.println(format("DEBUG: center equation (C) = $1$", [dCenterEquation]));

    // ... ecliptic longitude (lambda)
    //var dEclipticLongitude = dMeanAnomaly + dCenterEquation + dEplicticLongitudePeriapsis;
    var dEclipticLongitude =
      dMeanAnomaly + dCenterEquation + dPerihelionArgument + 180.0d;
    while(dEclipticLongitude >= 360.0d) {
      dEclipticLongitude -= 360.0d;
    }
    var dEclipticLongitude_rad =
      dEclipticLongitude * self.CONVERT_DEG2RAD;
    //Sys.println(format("DEBUG: ecliptic longitude (lambda) = $1$", [dEclipticLongitude]));

    // ... declination (delta)
    var dDeclination_rad =
      Math.asin(Math.sin(dEclipticLongitude_rad) * Math.sin(dEclipticObliquity_rad));
    var dDeclination =
      dDeclination_rad * self.CONVERT_RAD2DEG;
    //Sys.println(format("DEBUG: declination (delta) = $1$", [dDeclination]));

    // ... transit time <-> equation of time; https://en.wikipedia.org/wiki/Equation_of_time
    var dJ2kTransit =
      self.dJ2kMeanTime
      + (2.0d * dOrbitalEccentricity * Math.sin(dMeanAnomaly_rad)
         - Math.pow(Math.tan(dEclipticObliquity_rad/2.0d), 2.0d) * Math.sin(2.0d*dEclipticLongitude_rad)) / 6.28318530718d;
    //Sys.println(format("DEBUG: transit time (J,transit) = $1$", [dJ2kTransit]));

    // Computation finalization
    var dLocationLatitude_rad =
      self.dLocationLatitude * self.CONVERT_DEG2RAD;
    var dHeightCorrection_rad =
      Math.acos(6371008.8d / (6371008.8d + self.fLocationHeight));
    var dHeightCorrection =
      dHeightCorrection_rad * self.CONVERT_RAD2DEG;
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
      //Sys.println(format("DEBUG: elevation angle (alpha) = $1$", [dElevationAngle]));

      // ... azimuth angle (A)
      dAzimuthAngle = self.dLocationLatitude > dDeclination ? 180.0d : 0.0d;
      //Sys.println(format("DEBUG: azimuth angle (A) = $1$", [dAzimuthAngle]));

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
      dHourAngle_rad =
        (self.iEpochCurrent - self.iEpochTransit).toDouble() / 86400.0d * 6.28318530718d;
      dHourAngle =
        dHourAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(format("DEBUG: hour angle (h) = $1$", [dHourAngle]));

      // ... elevation angle (alpha)
      dElevationAngle_rad =
        Math.asin(Math.sin(dLocationLatitude_rad)*Math.sin(dDeclination_rad)
                  + Math.cos(dLocationLatitude_rad)*Math.cos(dDeclination_rad)*Math.cos(dHourAngle_rad))
        + dHeightCorrection_rad;
      dElevationAngle =
        dElevationAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(format("DEBUG: elevation angle (alpha) = $1$", [dElevationAngle]));
    }

    // Sunrise/Sunset
    else {
      // ... elevation angle (alpha)
      dElevationAngle = _dElevationAngle != null ? _dElevationAngle : 0.0d;
      dElevationAngle_rad = dElevationAngle * self.CONVERT_DEG2RAD;

      // ... hour angle (H, omega,0)
      dHourAngle_rad = Math.acos((Math.sin(dElevationAngle_rad-dHeightCorrection_rad)-Math.sin(dLocationLatitude_rad)*Math.sin(dDeclination_rad))/(Math.cos(dLocationLatitude_rad)*Math.cos(dDeclination_rad)));  // always positive
      if(!(dHourAngle_rad >= 0.0d and dHourAngle_rad <= Math.PI)) {
        //Sys.println("DEBUG: no such solar event!");
        return adData;  // NaN
      }
      if(_iEvent == self.EVENT_SUNRISE) {
        dHourAngle_rad = -dHourAngle_rad;
      }
      dHourAngle = dHourAngle_rad * self.CONVERT_RAD2DEG;
      //Sys.println(format("DEBUG: hour angle (H, omega,0) = $1$", [dHourAngle]));

      // ... event time
      dJ2kEvent = dJ2kTransit + dHourAngle/360.0d;
    }

    // ... azimuth angle (A)
    dAzimuthAngle_rad = Math.atan2(Math.sin(dHourAngle_rad), Math.cos(dHourAngle_rad)*Math.sin(dLocationLatitude_rad) - Math.tan(dDeclination_rad)*Math.cos(dLocationLatitude_rad));
    dAzimuthAngle = dAzimuthAngle_rad * self.CONVERT_RAD2DEG;
    dAzimuthAngle = 180.0d + dAzimuthAngle;
    //Sys.println(format("DEBUG: azimuth angle (A) = $1$", [dAzimuthAngle]));

    adData[0] = dJ2kEvent;
    adData[1] = dElevationAngle;
    adData[2] = dAzimuthAngle;
    return adData;
  }

}
