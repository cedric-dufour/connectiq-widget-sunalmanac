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

using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class SaSettings {

  //
  // CONSTANTS
  //

  // Default values
  private const DEFAULT_LOCATIONAUTO = false;
  private const DEFAULT_LOCATIONHEIGHT = 0.0f;
  private const DEFAULT_DATEAUTO = true;
  private const DEFAULT_TIMEUTC = false;
  private const DEFAULT_BACKGROUNDCOLOR = Gfx.COLOR_BLACK;


  //
  // VARIABLES
  //

  // Settings
  public var bLocationAuto;
  public var fLocationHeight;
  public var bDateAuto;
  public var bTimeUTC;
  public var iBackgroundColor;
  // ... device
  public var iUnitElevation;

  // Units
  public var sUnitTime;
  // ... device
  public var sUnitElevation;

  // Units conversion constants
  // ... device
  public var fUnitElevationConstant;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Settings
    self.setLocationAuto(self.DEFAULT_LOCATIONAUTO);
    self.setLocationHeight(self.DEFAULT_LOCATIONHEIGHT);
    self.setDateAuto(self.DEFAULT_DATEAUTO);
    self.setTimeUTC(self.DEFAULT_TIMEUTC);
    self.setBackgroundColor(self.DEFAULT_BACKGROUNDCOLOR);
    // ... device
    self.setUnitElevation();
  }

  function load() {
    var oApplication = App.getApp();

    // Settings
    self.setLocationAuto(oApplication.getProperty("userLocationAuto"));
    self.setLocationHeight(oApplication.getProperty("userLocationHeight"));
    self.setDateAuto(oApplication.getProperty("userDateAuto"));
    self.setTimeUTC(oApplication.getProperty("userTimeUTC"));
    self.setBackgroundColor(oApplication.getProperty("userBackgroundColor"));
    // ... device
    self.setUnitElevation();
  }

  function setLocationAuto(_bLocationAuto) {
    if(_bLocationAuto == null) {
      _bLocationAuto = self.DEFAULT_LOCATIONAUTO;
    }
    self.bLocationAuto = _bLocationAuto;
  }

  function setLocationHeight(_fLocationHeight) {
    if(_fLocationHeight == null) {
      _fLocationHeight = $.GSK_SETTINGS_LOCATIONHEIGHT;
    }
    else if(_fLocationHeight > 9999.0f) {
      _fLocationHeight = 9999.0f;
    }
    else if(_fLocationHeight < 0.0f) {
      _fLocationHeight = 0.0f;
    }
    self.fLocationHeight = _fLocationHeight;
  }

  function setDateAuto(_bDateAuto) {
    if(_bDateAuto == null) {
      _bDateAuto = self.DEFAULT_DATEAUTO;
    }
    self.bDateAuto = _bDateAuto;
  }

  function setTimeUTC(_bTimeUTC) {
    if(_bTimeUTC == null) {
      _bTimeUTC = self.DEFAULT_TIMEUTC;
    }
    if(_bTimeUTC) {
      self.bTimeUTC = true;
      self.sUnitTime = Ui.loadResource(Rez.Strings.unitTimeUTC);
    }
    else {
      self.bTimeUTC = false;
      self.sUnitTime = Ui.loadResource(Rez.Strings.unitTimeLT);
    }
  }

  function setBackgroundColor(_iBackgroundColor) {
    if(_iBackgroundColor == null) {
      _iBackgroundColor = self.DEFAULT_BACKGROUNDCOLOR;
    }
    self.iBackgroundColor = _iBackgroundColor;
  }

  function setUnitElevation() {
    var oDeviceSettings = Sys.getDeviceSettings();
    if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
      self.iUnitElevation = oDeviceSettings.elevationUnits;
    }
    else {
      self.iUnitElevation = Sys.UNIT_METRIC;
    }
    if(self.iUnitElevation == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = Ui.loadResource(Rez.Strings.unitElevationStatute);
      self.fUnitElevationConstant = 3.280839895f;  // ... m -> ft
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = Ui.loadResource(Rez.Strings.unitElevationMetric);
      self.fUnitElevationConstant = 1.0f;  // ... m -> m
    }
  }

}
