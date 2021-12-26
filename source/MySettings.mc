// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Sun Almanac (SunAlmanac)
// Copyright (C) 2017-2021 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

(:glance)
class MySettings {

  //
  // VARIABLES
  //

  // Settings
  public var bLocationAuto as Boolean = false;
  public var fLocationHeight as Float = 0.0f;
  public var bDateAuto as Boolean = true;
  public var bTimeUTC as Boolean = false;
  public var iBackgroundColor as Number = Gfx.COLOR_BLACK;
  // ... device
  public var iUnitElevation as Number = -1;

  // Units
  public var sUnitTime as String = "LT";
  // ... device
  public var sUnitElevation as String = "m";

  // Units conversion constants
  // ... device
  public var fUnitElevationConstant as Float = 1.0f;


  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    self.setLocationAuto(App.Properties.getValue("userLocationAuto") as Boolean?);
    self.setLocationHeight(App.Properties.getValue("userLocationHeight") as Float?);
    self.setDateAuto(App.Properties.getValue("userDateAuto") as Boolean?);
    self.setTimeUTC(App.Properties.getValue("userTimeUTC") as Boolean?);
    self.setBackgroundColor(App.Properties.getValue("userBackgroundColor") as Number?);
    // ... device
    self.setUnitElevation();
  }

  function setLocationAuto(_bValue as Boolean?) as Void {
    var bValue = _bValue != null ? _bValue : false;
    self.bLocationAuto = bValue;
  }

  function setLocationHeight(_fValue as Float?) as Void {
    var fValue = _fValue != null ? _fValue : 0.0f;
    if(fValue > 9999.0f) {
      fValue = 9999.0f;
    }
    else if(fValue < 0.0f) {
      fValue = 0.0f;
    }
    self.fLocationHeight = fValue;
  }

  function setDateAuto(_bValue as Boolean?) as Void {
    var bValue = _bValue != null ? _bValue : true;
    self.bDateAuto = bValue;
  }

  function setTimeUTC(_bValue as Boolean?) as Void {
    var bValue = _bValue != null ? _bValue : false;
    if(bValue) {
      self.bTimeUTC = true;
      self.sUnitTime = "Z";
    }
    else {
      self.bTimeUTC = false;
      self.sUnitTime = "LT";
    }
  }

  function setBackgroundColor(_iValue as Number?) as Void {
    var iValue = _iValue != null ? _iValue : Gfx.COLOR_BLACK;
    self.iBackgroundColor = iValue;
  }

  function setUnitElevation() as Void {
    var oDeviceSettings = Sys.getDeviceSettings();
    if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
      self.iUnitElevation = oDeviceSettings.elevationUnits as Number;
    }
    else {
      self.iUnitElevation = Sys.UNIT_METRIC;
    }
    if(self.iUnitElevation == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = "ft";
      self.fUnitElevationConstant = 3.280839895f;  // ... m -> ft
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationConstant = 1.0f;  // ... m -> m
    }
  }

}
