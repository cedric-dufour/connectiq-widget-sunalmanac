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
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Application settings
var oMySettings as MySettings = new MySettings();

// (Last) position location
var oMyPositionLocation as Pos.Location?;

// Almanac data
var oMyAlmanac_today as MyAlmanac = new MyAlmanac();
var oMyAlmanac_yesterday as MyAlmanac = new MyAlmanac();

// Current view
var oMyView as MyView?;


//
// CONSTANTS
//

// Storage slots
const MY_STORAGE_SLOTS = 100;


//
// CLASS
//

(:glance)
class MyApp extends App.AppBase {

  //
  // VARIABLES
  //

  // UI update time
  private var oUpdateTimer as Timer.Timer?;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    //Sys.println("DEBUG: MyApp.onStart()");

    // Start UI update timer (every multiple of 60 seconds)
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%60;
    if(iUpdateTimerDelay > 0) {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 60000, true);
    }
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [new MyView(), new MyViewDelegate()] as Array<Ui.Views or Ui.InputDelegates>;
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: MyApp.onSettingsChanged()");
    self.updateApp();
  }


  //
  // FUNCTIONS: self
  //


  function updateApp() as Void {
    //Sys.println("DEBUG: MyApp.updateApp()");

    // Load settings
    self.loadSettings();

    // Use GPS position
    if($.oMySettings.bLocationAuto) {
      Pos.enableLocationEvents(Pos.LOCATION_ONE_SHOT, method(:onLocationEvent));
    }
    else {
      var dictLocation = App.Storage.getValue("storLocPreset") as Dictionary?;
      var fLocationHeight = App.Properties.getValue("userLocationHeight") as Float?;
      var iEpochToday = Time.today().value();
      var iEpochDate = $.oMySettings.bDateAuto ? iEpochToday : App.Storage.getValue("storDatePreset") as Number?;
      var iEpochTime = $.oMySettings.bDateAuto ? Time.now().value() : null;
      if(dictLocation != null) {
        self.computeAlmanac(dictLocation["name"] as String,
                            dictLocation["latitude"] as Double,
                            dictLocation["longitude"] as Double,
                            fLocationHeight != null ? fLocationHeight : 0.0f,
                            iEpochDate != null ? iEpochDate : iEpochToday,
                            iEpochTime);
      }
    }

    // Update UI
    self.updateUi();
  }

  function loadSettings() as Void {
    //Sys.println("DEBUG: MyApp.loadSettings()");

    // Load settings
    $.oMySettings.load();

    // ... location
    var dictLocation = App.Storage.getValue("storLocPreset");
    if(dictLocation == null) {
      // Sun Almanac was born in Switzerland; use "Old" Bern Observatory coordinates ;-)
      dictLocation = {"name" => "CH/Bern", "latitude" => 46.9524055555556d, "longitude" => 7.43958333333333d};
      App.Storage.setValue("storLocPreset", dictLocation as App.PropertyValueType);
    }

    // ... date
    var iEpochDate = App.Storage.getValue("storDatePreset");
    if(iEpochDate == null) {
      iEpochDate = Time.today().value();
      App.Storage.setValue("storDatePreset", iEpochDate as App.PropertyValueType);
    }
  }

  function computeAlmanac(_sLocationName as String,
                          _dLocationLatitude as Double, _dLocationLongitude as Double, _fLocationHeight as Float,
                          _iEpochDate as Number, _iEpochTime as Number?) as Void {
    //Sys.println("DEBUG: MyApp.computeAlmanac()");

    // Compute almanac data
    // ... today
    $.oMyAlmanac_today.setLocation(_sLocationName, _dLocationLatitude, _dLocationLongitude, _fLocationHeight);
    $.oMyAlmanac_today.compute(_iEpochDate, _iEpochTime, true);
    // ... yesterday
    $.oMyAlmanac_yesterday.setLocation(_sLocationName, _dLocationLatitude, _dLocationLongitude, _fLocationHeight);
    $.oMyAlmanac_yesterday.compute(_iEpochDate-86400, _iEpochTime != null ? _iEpochTime-86400 : null, false);
  }

  function onLocationEvent(_oInfo as Pos.Info) as Void {
    //Sys.println("DEBUG: MyApp.onLocationEvent()");
    if(!$.oMySettings.bLocationAuto) {
      return;  // should one have changed his mind while waiting for GPS fix
    }
    if(!(_oInfo has :position) or _oInfo.position == null) {
      return;
    }

    // Save position
    $.oMyPositionLocation = _oInfo.position as Pos.Location;

    // Update almanac data
    var adLocation = (_oInfo.position as Pos.Location).toDegrees();
    var fLocationHeight = App.Properties.getValue("userLocationHeight") as Float?;
    var iEpochToday = Time.today().value();
    var iEpochDate = $.oMySettings.bDateAuto ? iEpochToday : App.Storage.getValue("storDatePreset") as Number?;
    var iEpochTime = $.oMySettings.bDateAuto ? Time.now().value() : null;
    self.computeAlmanac(Ui.loadResource(Rez.Strings.valueLocationGPS) as String,
                        adLocation[0], adLocation[1],
                        fLocationHeight != null ? fLocationHeight : 0.0f,
                        iEpochDate != null ? iEpochDate : iEpochToday,
                        iEpochTime);

    // Update UI
    self.updateUi();
  }

  function onUpdateTimer_init() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 60000, true);
  }

  function onUpdateTimer() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimer()");
    self.updateUi();
  }

  function updateUi() as Void {
    //Sys.println("DEBUG: MyApp.updateUi()");

    // Update UI
    if($.oMyView != null) {
      ($.oMyView as MyView).updateUi();
    }
  }

}
