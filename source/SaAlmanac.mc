// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Sun Almanac (SunAlmanac)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
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

class SaAlmanac {

  //
  // CONSTANTS
  //

  // Event types
  private const EVENT_ZENITH = 0;
  private const EVENT_SUNRISE = 1;
  private const EVENT_SUNSET = 2;

  // Units conversion
  private const CONVERT_DEG2RAD = 0.01745329252d;
  private const CONVERT_RAD2DEG = 57.2957795131d;

  // Computation
  private const COMPUTE_ITERATIONS = 5;


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
  public var iEpochOffsetLT;

  // Zenith
  public var iEpochZenith;
  public var fAltitudeZenith;  // degrees
  public var fEclipticLongitude;  // degrees
  public var fDeclination;  // degrees

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

    // Date
    self.iEpochDate = null;
    self.iEpochOffsetLT = null;

    // Zenith
    self.iEpochZenith = null;
    self.fAltitudeZenith = null;
    self.fEclipticLongitude = null;
    self.fDeclination = null;

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
    //Sys.println(Lang.format("DEBUG: SaAlmanac.setLocation($1$, $2$, $3$, $4$)", [_sName, _dLatitude, _dLongitude, _fHeight]));

    self.sLocationName = _sName;
    self.dLocationLatitude = _dLatitude.toDouble();
    //Sys.println(Lang.format("DEBUG: latitude (l,omega) = $1$", [self.dLocationLatitude]));
    self.dLocationLongitude = _dLongitude.toDouble();
    //Sys.println(Lang.format("DEBUG: longitude (phi) = $1$", [self.dLocationLongitude]));
    self.fLocationHeight = _fHeight;
    //Sys.println(Lang.format("DEBUG: elevation = $1$", [self.fLocationHeight]));
  }

  function compute(_iEpochDate) {  // Time.today().value()
    //Sys.println(Lang.format("DEBUG: SaAlmanac.compute($1$)", [_iEpochDate]));

    // Location set ?
    if(self.dLocationLatitude == null or self.dLocationLongitude == null or self.fLocationHeight == null) {
      //Sys.println("DEBUG: location undefined!");
      return;
    }

    // Date
    // WARNING! Gregorian.{info <-> utcInfo} does NOT detect UTC offset based on the *passed Time.Moment* but the one corresponding to the *current* date/time. BUG!!!
    var oTime = new Time.Moment(_iEpochDate);
    var oTimeInfo_UTC = Gregorian.utcInfo(oTime, Time.FORMAT_SHORT);
    //Sys.println(Lang.format("DEBUG: UTC time = $1$:$2$:$3$", [oTimeInfo_UTC.hour, oTimeInfo_UTC.min, oTimeInfo_UTC.sec]));
    var oTimeInfo_LT = Gregorian.info(oTime, Time.FORMAT_SHORT);
    //Sys.println(Lang.format("DEBUG: LT time = $1$:$2$:$3$", [oTimeInfo_LT.hour, oTimeInfo_LT.min, oTimeInfo_LT.sec]));
    self.iEpochOffsetLT = (3600*oTimeInfo_LT.hour+60*oTimeInfo_LT.min+oTimeInfo_LT.sec) - (3600*oTimeInfo_UTC.hour+60*oTimeInfo_UTC.min+oTimeInfo_UTC.sec);
    if(self.iEpochOffsetLT >= 86400) {
      self.iEpochOffsetLT -= 86400;
    }
    else if(self.iEpochOffsetLT < 0) {
      self.iEpochOffsetLT += 86400;
    }
    if(oTimeInfo_UTC.hour == 0 and oTimeInfo_UTC.min == 0 and oTimeInfo_UTC.sec == 0) {
      self.iEpochDate = _iEpochDate;
    }
    else {
      self.iEpochDate = _iEpochDate + self.iEpochOffsetLT;  // date is Local Time (0:00 LT) -> offset to obtain the true UTC date (0:00 Z)
    }
    //Sys.println(Lang.format("DEBUG: local time offset = $1$", [self.iEpochOffsetLT]));

    // Internals
    // ... Delta-T (TT-UT1); http://maia.usno.navy.mil/ser7/deltat.data
    var dDeltaT = 68.8033d;  // 2017.06
    // ... julian day number (n)
    self.dJulianDayNumber = Math.round((self.iEpochDate+dDeltaT)/86400.0d+2440587.5d);
    //Sys.println(Lang.format("DEBUG: julian day number (n) = $1$", [self.dJulianDayNumber]));
    //Sys.println(Lang.format("DEBUG: Delta-T (TT-UT1) = $1$", [dDeltaT]));
    // ... DUT1 (UT1-UTC); http://maia.usno.navy.mil/ser7/ser7.dat
    var dBesselianYear = 1900.0d + (self.dJulianDayNumber-2415020.31352d)/365.242198781d;
    var dDUT21 = 0.022d*Math.sin(dBesselianYear*6.28318530718d) - 0.012d*Math.cos(dBesselianYear*6.28318530718d) - 0.006d*Math.sin(dBesselianYear*12.5663706144d) + 0.007d*Math.cos(dBesselianYear*12.5663706144d);
    var dDUT1 = 0.2677d - 0.00106d*(self.dJulianDayNumber-2458067.5d) - dDUT21;
    //Sys.println(Lang.format("DEBUG: DUT1 (UT1-UTC) = $1$", [dDUT1]));
    // ... mean solar time (J*)
    self.dJ2kMeanTime = self.dJulianDayNumber - 2451545.0d + (dDeltaT+dDUT1)/86400.0d - self.dLocationLongitude/360.0d;
    //Sys.println(Lang.format("DEBUG: mean solar time (J*) = $1$", [self.dJ2kMeanTime]));

    // Data computation
    var dJ2kCompute;
    var adData;

    // ... zenith
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_ZENITH, 90.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochZenith = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
      self.fAltitudeZenith = adData[1].toFloat();
      self.fEclipticLongitude = adData[3].toFloat();
      self.fDeclination = adData[4].toFloat();
    }
    else {
      self.iEpochZenith = null;
      self.fAltitudeZenith = null;
      self.fEclipticLongitude = null;
      self.fDeclination = null;
    }
    //Sys.println(Lang.format("DEBUG: zenith time = $1$", [self.iEpochZenith]));
    //Sys.println(Lang.format("DEBUG: zenith altitude = $1$", [self.fAltitudeZenith]));

    // ... sunrise (accounting for atmospheric refraction)
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNRISE, -0.83d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochSunrise = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
      self.fAzimuthSunrise = adData[2].toFloat();
    }
    else {
      self.iEpochSunrise = null;
      self.fAzimuthSunrise = null;
    }
    //Sys.println(Lang.format("DEBUG: sunrise time = $1$", [self.iEpochSunrise]));
    //Sys.println(Lang.format("DEBUG: sunrise azimuth = $1$", [self.fAzimuthSunrise]));

    // ... civil dawn
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNRISE, -6.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochCivilDawn = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochCivilDawn = null;
    }
    //Sys.println(Lang.format("DEBUG: civil dawn time = $1$", [self.iEpochCivilDawn]));

    // ... nautical dawn
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNRISE, -12.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochNauticalDawn = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochNauticalDawn = null;
    }
    //Sys.println(Lang.format("DEBUG: nautical dawn time = $1$", [self.iEpochNauticalDawn]));

    // ... astronomical dawn
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNRISE, -18.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochAstronomicalDawn = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochAstronomicalDawn = null;
    }
    //Sys.println(Lang.format("DEBUG: astronomical dawn time = $1$", [self.iEpochAstronomicalDawn]));

    // ... sunset (accounting for atmospheric refraction)
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNSET, -0.83d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochSunset = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
      self.fAzimuthSunset = adData[2].toFloat();
    }
    else {
      self.iEpochSunset = null;
      self.fAzimuthSunset = null;
    }
    //Sys.println(Lang.format("DEBUG: sunset time = $1$", [self.iEpochSunset]));
    //Sys.println(Lang.format("DEBUG: sunset azimuth = $1$", [self.fAzimuthSunset]));

    // ... civil dusk
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNSET, -6.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochCivilDusk = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochCivilDusk = null;
    }
    //Sys.println(Lang.format("DEBUG: civil dusk time = $1$", [self.iEpochCivilDusk]));

    // ... nautical dusk
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNSET, -12.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochNauticalDusk = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochNauticalDusk = null;
    }
    //Sys.println(Lang.format("DEBUG: nautical dusk time = $1$", [self.iEpochNauticalDusk]));

    // ... astronomical dusk
    dJ2kCompute = self.dJ2kMeanTime;
    for(var i=self.COMPUTE_ITERATIONS; i>0 and dJ2kCompute!=null; i--) {
      adData = self.computeIterative(self.EVENT_SUNSET, -18.0d, dJ2kCompute);
      dJ2kCompute = adData[0];
    }
    if(adData[0] != null) {
      self.iEpochAstronomicalDusk = Math.round((adData[0]+10957.5d)*86400.0d-dDeltaT-dDUT1).toNumber();
    }
    else {
      self.iEpochAstronomicalDusk = null;
    }
    //Sys.println(Lang.format("DEBUG: astronomical dusk time = $1$", [self.iEpochAstronomicalDusk]));
  }

  function computeIterative(_iEvent, _dHeight, _dJ2kCompute) {
    //Sys.println(Lang.format("DEBUG: SaAlmanac.computeIterative($1$, $2$, $3$)", [_iEvent, _dHeight, _dJ2kCompute]));
    var dJ2kCentury = _dJ2kCompute/36524.21897d;

    // Solar parameters
    // [ time (J2k), altitude (degree), azimuth (degree), ecliptic longitude, declination ]
    var adData = [ null, null, null, null, null ];

    // ... mean solar anomaly (M); http://www.jgiesen.de/elevaz/basics/meeus.htm
    var dMeanAnomaly = 357.5291d + 35999.05030d*dJ2kCentury;
    while(dMeanAnomaly >= 360.0d) {
      dMeanAnomaly -= 360.0d;
    }
    var dMeanAnomaly_rad = dMeanAnomaly * self.CONVERT_DEG2RAD;
    //Sys.println(Lang.format("DEBUG: mean solar anomaly (M) = $1$", [dMeanAnomaly]));

    // ... center coefficient (C); https://en.wikipedia.org/wiki/Equation_of_the_center
    var dCenterCoefficient = 1.91464354249d*Math.sin(dMeanAnomaly_rad) + 0.0199935127925d*Math.sin(2.0d*dMeanAnomaly_rad) + 0.0002895082313d*Math.sin(3.0d*dMeanAnomaly_rad);
    //Sys.println(Lang.format("DEBUG: center coefficient (C) = $1$", [dCenterCoefficient]));

    // ... ecliptic perihelion (Pi); https://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf (Table 1)
    var dEclipticPerihelion = 102.93768193d + 0.32327364*dJ2kCentury;
    //Sys.println(Lang.format("DEBUG: ecliptic perihelion (Pi) = $1$", [dEclipticPerihelion]));

    // ... ecliptic obliquity (epsilon); https://en.wikipedia.org/wiki/Ecliptic
    var dEclipticObliquity = 23.4392794444d - 0.0130102136111d*dJ2kCentury;
    var dEclipticObliquity_rad = dEclipticObliquity * self.CONVERT_DEG2RAD;
    //Sys.println(Lang.format("DEBUG: ecliptic obliquity (epsilon) = $1$", [dEclipticObliquity]));

    // ... ecliptic longitude (lambda)
    var dEclipticLongitude = dMeanAnomaly + dCenterCoefficient + dEclipticPerihelion + 180.0d;
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
    var dJ2kTransit = self.dJ2kMeanTime + 0.00531863988824d*Math.sin(dMeanAnomaly_rad) - Math.pow(Math.tan(dEclipticObliquity_rad/2.0d), 2.0d)*Math.sin(2.0d * dEclipticLongitude_rad)/6.28318530718d;
    //Sys.println(Lang.format("DEBUG: transit time (J,transit) = $1$", [dJ2kTransit]));
    if(_iEvent == self.EVENT_ZENITH) {
      var dAltitude = 90.0d - self.dLocationLatitude + dDeclination;
      if(dAltitude > 90.0d) {
        dAltitude = 180.0d - dAltitude;
      }
      adData[0] = dJ2kTransit;
      adData[1] = dAltitude;
      adData[3] = dEclipticLongitude;
      adData[4] = dDeclination;
      return adData;
    }

    // ... hour angle (H, omega,0)
    var dLocationLatitude_rad = self.dLocationLatitude * self.CONVERT_DEG2RAD;
    var dAltitudeCorrection = 2.076d*Math.sqrt(self.fLocationHeight)/60.0d;
    var dHourAngle_rad = Math.acos((Math.sin((_dHeight-dAltitudeCorrection)*self.CONVERT_DEG2RAD)-Math.sin(dLocationLatitude_rad)*Math.sin(dDeclination_rad))/(Math.cos(dLocationLatitude_rad)*Math.cos(dDeclination_rad)));
    var dHourAngle = dHourAngle_rad * self.CONVERT_RAD2DEG;
    //Sys.println(Lang.format("DEBUG: hour angle (H, omega,0) = $1$", [dHourAngle]));
    // ... valid ?
    if(!(dHourAngle_rad >= 0.0d and dHourAngle_rad <= Math.PI)) {  // == NaN does NOT work; BUG?
      //Sys.println("DEBUG: no such solar event!");
      return adData;  // null
    }

    // ... azimuth angle (A)
    var dAzimuthAngle_rad = Math.atan2(Math.sin(dHourAngle_rad), Math.cos(dHourAngle_rad)*Math.sin(dLocationLatitude_rad) - Math.tan(dDeclination_rad)*Math.cos(dLocationLatitude_rad));
    var dAzimuthAngle = dAzimuthAngle_rad * self.CONVERT_RAD2DEG;
    //Sys.println(Lang.format("DEBUG: azimuth angle (A) = $1$", [dAzimuthAngle]));

    // ... sunrise time
    if(_iEvent == self.EVENT_SUNRISE) {
      adData[0] = dJ2kTransit - dHourAngle/360.0d;
      adData[1] = _dHeight;
      adData[2] = 180.0d - dAzimuthAngle;
      return adData;
    }

    // ... sunset time
    if(_iEvent == self.EVENT_SUNSET) {
      adData[0] = dJ2kTransit + dHourAngle/360.0d;
      adData[1] = _dHeight;
      adData[2] = 180.0d + dAzimuthAngle;
      return adData;
    }

    // ... WTF !?!
    return adData;

  }

  function stringTime(_iEpochTimestamp) {
    // Components
    var oTime = new Time.Moment(_iEpochTimestamp);
    var oTimeInfo;
    if($.SA_Settings.bTimeUTC) {
      oTimeInfo = Gregorian.utcInfo(oTime, Time.FORMAT_SHORT);
    }
    else {
      oTimeInfo = Gregorian.info(oTime, Time.FORMAT_SHORT);
    }
    var iTime_hour = oTimeInfo.hour;
    var iTime_min = oTimeInfo.min;
    // ... round minutes
    if(oTimeInfo.sec >= 30) {
      iTime_min += 1;
      if(iTime_min >= 60) {
        iTime_min -= 60;
        iTime_hour += 1;
        if(iTime_hour >= 24) {
          iTime_hour -= 24;
        }
      }
    }

    // String
    return Lang.format("$1$:$2$", [iTime_hour.format("%d"), iTime_min.format("%02d")]);
  }

  function stringTimeDiff_hm(_iDuration) {
    // Components
    var iDuration_sign = _iDuration < 0.0d ? -1 : 1;
    _iDuration = _iDuration.abs();
    var iDuration_hour = Math.floor(_iDuration / 3600.0d).toNumber();
    _iDuration -= iDuration_hour * 3600;
    var iDuration_min = Math.round(_iDuration / 60.0d).toNumber();
    if(iDuration_min >= 60) {
      iDuration_min -= 60;
      iDuration_hour += 1;
    }
    iDuration_hour *= iDuration_sign;

    // String
    return Lang.format("$1$h$2$", [iDuration_hour.format("%d"), iDuration_min.format("%02d")]);
  }

  function stringTimeDiff_ms(_iDuration) {
    // Components
    var iDuration_sign = _iDuration < 0.0d ? -1 : 1;
    _iDuration = _iDuration.abs();
    var iDuration_min = Math.floor(_iDuration / 60.0d).toNumber();
    _iDuration -= iDuration_min * 60;
    var iDuration_sec = Math.round(_iDuration).toNumber();
    if(iDuration_sec >= 60) {
      iDuration_sec -= 60;
      iDuration_min += 1;
    }
    iDuration_min *= iDuration_sign;

    // String
    return Lang.format("$1$m$2$", [iDuration_min.format("%+d"), iDuration_sec.format("%02d")]);
  }

  function stringDegree(_fDegree) {
    return Lang.format("$1$°", [_fDegree.format("%.1f")]);
  }

  function stringLatitude(_dLatitude) {
    // Split components
    var iLatitude_qua = _dLatitude < 0.0d ? -1 : 1;
    _dLatitude = _dLatitude.abs();
    var iLatitude_deg = _dLatitude.toNumber();
    _dLatitude = (_dLatitude - iLatitude_deg) * 60.0d;
    var iLatitude_min = _dLatitude.toNumber();
    _dLatitude = (_dLatitude - iLatitude_min) * 60.0d + 0.5d;
    var iLatitude_sec = _dLatitude.toNumber();
    if(iLatitude_sec >= 60) {
      iLatitude_sec = 59;
    }

    // String
    return Lang.format("$1$°$2$'$3$\" $4$", [iLatitude_deg.format("%d"), iLatitude_min.format("%02d"), iLatitude_sec.format("%02d"), iLatitude_qua < 0 ? "S" : "N"]);
  }

  function stringLongitude(_dLongitude) {
    // Split components
    var iLongitude_qua = _dLongitude < 0.0d ? -1 : 1;
    _dLongitude = _dLongitude.abs();
    var iLongitude_deg = _dLongitude.toNumber();
    _dLongitude = (_dLongitude - iLongitude_deg) * 60.0d;
    var iLongitude_min = _dLongitude.toNumber();
    _dLongitude = (_dLongitude - iLongitude_min) * 60.0d + 0.5d;
    var iLongitude_sec = _dLongitude.toNumber();
    if(iLongitude_sec >= 60) {
      iLongitude_sec = 59;
    }

    // String
    return Lang.format("$1$°$2$'$3$\" $4$", [iLongitude_deg.format("%d"), iLongitude_min.format("%02d"), iLongitude_sec.format("%02d"), iLongitude_qua < 0 ? "W" : "E"]);
  }

  function stringHeight(_fHeight) {
    var fValue = _fHeight * $.SA_Settings.fUnitElevationConstant;
    return Lang.format("$1$ $2$", [fValue.format("%d"), $.SA_Settings.sUnitElevation]);
  }

}

