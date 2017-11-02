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
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Application settings
var SA_Settings = null;

// (Last) position location
var SA_PositionLocation = null;

// Almanac data
var SA_Almanac_today = null;
var SA_Almanac_yesterday = null;

// Current view
var SA_CurrentView = null;


//
// CLASS
//

class SaApp extends App.AppBase {

  //
  // VARIABLES
  //

  // UI update time
  private var oUpdateTimer;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // Application settings
    $.SA_Settings = new SaSettings();

    // UI update time
    self.oUpdateTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: SaApp.onStart()");

    // Load settings
    self.loadSettings();

    // Compute almanac data
    var dictLocation = AppBase.getProperty("storLocPreset");
    var fLocationHeight = AppBase.getProperty("userLocationHeight");
    var iEpochDate = $.SA_Settings.bDateAuto ? Time.today().value() : AppBase.getProperty("storDatePreset");
    self.computeAlmanac(dictLocation["name"], dictLocation["latitude"], dictLocation["longitude"], fLocationHeight, iEpochDate);

    // Start UI update timer (every multiple of 60 seconds)
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%60;
    if(iUpdateTimerDelay > 0) {
      self.oUpdateTimer.start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      self.oUpdateTimer.start(method(:onUpdateTimer), 60000, true);
    }
  }

  function onStop(state) {
    //Sys.println("DEBUG: SaApp.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: SaApp.getInitialView()");

    return [new ViewSa(), new ViewDelegateSa()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: SaApp.onSettingsChanged()");
    self.updateApp();
  }


  //
  // FUNCTIONS: self
  //

  function updateApp() {
    //Sys.println("DEBUG: SaApp.updateApp()");

    // Load settings
    self.loadSettings();

    // Use GPS position
    if($.SA_Settings.bLocationAuto) {
      Pos.enableLocationEvents(Pos.LOCATION_ONE_SHOT, method(:onLocationEvent));
    }
    else {
      var dictLocation = AppBase.getProperty("storLocPreset");
      var fLocationHeight = AppBase.getProperty("userLocationHeight");
      var iEpochDate = $.SA_Settings.bDateAuto ? Time.today().value() : AppBase.getProperty("storDatePreset");
      self.computeAlmanac(dictLocation["name"], dictLocation["latitude"], dictLocation["longitude"], fLocationHeight, iEpochDate);
    }

    // Update UI
    self.updateUi();
  }

  function loadSettings() {
    //Sys.println("DEBUG: SaApp.loadSettings()");

    // Load settings
    $.SA_Settings.load();

    // ... location
    var dictLocation = AppBase.getProperty("storLocPreset");
    if(dictLocation == null) {
      // Sun Almanac was born in Switzerland; use "Old" Bern Observatory coordinates ;-)
      dictLocation = { "name" => "CH/Bern", "latitude" => 46.9524055555556d, "longitude" => 7.43958333333333d };
      AppBase.setProperty("storLocPreset", dictLocation);
    }

    // ... date
    var iEpochDate = AppBase.getProperty("storDatePreset");
    if(iEpochDate == null) {
      iEpochDate = Time.today().value();
      AppBase.setProperty("storDatePreset", iEpochDate);
    }
  }

  function computeAlmanac(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight, _iEpochDate) {
    //Sys.println("DEBUG: SaApp.computeAlmanac()");

    // Compute almanac data
    // ... today
    $.SA_Almanac_today = new SaAlmanac();
    $.SA_Almanac_today.setLocation(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight);
    $.SA_Almanac_today.compute(_iEpochDate);
    // ... yesterday
    $.SA_Almanac_yesterday = new SaAlmanac();
    $.SA_Almanac_yesterday.setLocation(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight);
    $.SA_Almanac_yesterday.compute(_iEpochDate-86400);
  }

  function onLocationEvent(_oInfo) {
    Sys.println("DEBUG: SaApp.onLocationEvent()");
    if(!$.SA_Settings.bLocationAuto) {
      return;  // should one have changed his mind while waiting for GPS fix
    }
    if(!(_oInfo has :position)) {
      return;
    }

    // Save position
    $.SA_PositionLocation = _oInfo.position;

    // Update almanac data
    var adLocation = _oInfo.position.toDegrees();
    var fLocationHeight = AppBase.getProperty("userLocationHeight");
    var iEpochDate = $.SA_Settings.bDateAuto ? Time.today().value() : AppBase.getProperty("storDatePreset");
    self.computeAlmanac(Ui.loadResource(Rez.Strings.valueLocationGPS), adLocation[0], adLocation[1], fLocationHeight, iEpochDate);

    // Update UI
    self.updateUi();
  }

  function onUpdateTimer_init() {
    //Sys.println("DEBUG: SaApp.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 60000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: SaApp.onUpdateTimer()");
    self.updateUi();
  }

  function updateUi() {
    //Sys.println("DEBUG: SaApp.updateUi()");

    // Update UI
    if($.SA_CurrentView != null) {
      $.SA_CurrentView.updateUi();
    }
  }

}
