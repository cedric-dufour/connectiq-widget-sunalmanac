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
var SA_oSettings = null;

// (Last) position location
var SA_oPositionLocation = null;

// Almanac data
var SA_oAlmanac_today = null;
var SA_oAlmanac_yesterday = null;

// Current view
var SA_oCurrentView = null;


//
// CONSTANTS
//

// Storage slots
const SA_STORAGE_SLOTS = 100;


//
// CLASS
//

class SA_App extends App.AppBase {

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
    $.SA_oSettings = new SA_Settings();

    // Almanac data
    $.SA_oAlmanac_today = new SA_Almanac();
    $.SA_oAlmanac_yesterday = new SA_Almanac();

    // UI update time
    self.oUpdateTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: SA_App.onStart()");

    // Upgrade
    self.upgradeSdk();

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
    //Sys.println("DEBUG: SA_App.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: SA_App.getInitialView()");

    return [new SA_View(), new SA_ViewDelegate()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: SA_App.onSettingsChanged()");
    self.updateApp();
  }


  //
  // FUNCTIONS: self
  //

  function upgradeSdk() {
    //Sys.println("DEBUG: SA_App.upgradeSdk()");

    // Migrate data from Object Store to Application.Storage (SDK >= 2.4.0)
    // TODO: Delete after December 1st, 2018

    // ... location
    if(AppBase.getProperty("storLocPreset") != null) {
      // ... preset
      Sys.println("DEBUG[upgrade]: Migrating 'storLocPreset'");
      App.Storage.setValue("storLocPreset", AppBase.getProperty("storLocPreset"));
      AppBase.deleteProperty("storLocPreset");
      // ... storage slots
      for(var n=0; n<$.SA_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        var dictLocation = AppBase.getProperty("storLoc"+s);
        if(dictLocation != null) {
          Sys.println("DEBUG[upgrade]: Migrating 'storLoc"+s+"'");
          App.Storage.setValue("storLoc"+s, dictLocation);
          AppBase.deleteProperty("storLoc"+s);
        }
      }
    }

    // ... date
    if(AppBase.getProperty("storDatePreset") != null) {
      // ... preset
      Sys.println("DEBUG[upgrade]: Migrating 'storDatePreset'");
      App.Storage.setValue("storDatePreset", AppBase.getProperty("storDatePreset"));
      AppBase.deleteProperty("storDatePreset");
    }
  }

  function updateApp() {
    //Sys.println("DEBUG: SA_App.updateApp()");

    // Load settings
    self.loadSettings();

    // Use GPS position
    if($.SA_oSettings.bLocationAuto) {
      Pos.enableLocationEvents(Pos.LOCATION_ONE_SHOT, method(:onLocationEvent));
    }
    else {
      var dictLocation = App.Storage.getValue("storLocPreset");
      var fLocationHeight = App.Properties.getValue("userLocationHeight");
      var iEpochDate = $.SA_oSettings.bDateAuto ? Time.today().value() : App.Storage.getValue("storDatePreset");
      var iEpochTime = $.SA_oSettings.bDateAuto ? Time.now().value() : null;
      self.computeAlmanac(dictLocation["name"], dictLocation["latitude"], dictLocation["longitude"], fLocationHeight, iEpochDate, iEpochTime);
    }

    // Update UI
    self.updateUi();
  }

  function loadSettings() {
    //Sys.println("DEBUG: SA_App.loadSettings()");

    // Load settings
    $.SA_oSettings.load();

    // ... location
    var dictLocation = App.Storage.getValue("storLocPreset");
    if(dictLocation == null) {
      // Sun Almanac was born in Switzerland; use "Old" Bern Observatory coordinates ;-)
      dictLocation = { "name" => "CH/Bern", "latitude" => 46.9524055555556d, "longitude" => 7.43958333333333d };
      App.Storage.setValue("storLocPreset", dictLocation);
    }

    // ... date
    var iEpochDate = App.Storage.getValue("storDatePreset");
    if(iEpochDate == null) {
      iEpochDate = Time.today().value();
      App.Storage.setValue("storDatePreset", iEpochDate);
    }
  }

  function computeAlmanac(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight, _iEpochDate, _iEpochTime) {
    //Sys.println("DEBUG: SA_App.computeAlmanac()");

    // Compute almanac data
    // ... today
    $.SA_oAlmanac_today.setLocation(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight);
    $.SA_oAlmanac_today.compute(_iEpochDate, _iEpochTime, true);
    // ... yesterday
    $.SA_oAlmanac_yesterday.setLocation(_sLocationName, _fLocationLatitude, _fLocationLongitude, _fLocationHeight);
    $.SA_oAlmanac_yesterday.compute(_iEpochDate-86400, _iEpochTime != null ? _iEpochTime-86400 : null, false);
  }

  function onLocationEvent(_oInfo) {
    //Sys.println("DEBUG: SA_App.onLocationEvent()");
    if(!$.SA_oSettings.bLocationAuto) {
      return;  // should one have changed his mind while waiting for GPS fix
    }
    if(!(_oInfo has :position)) {
      return;
    }

    // Save position
    $.SA_oPositionLocation = _oInfo.position;

    // Update almanac data
    var adLocation = _oInfo.position.toDegrees();
    var fLocationHeight = App.Properties.getValue("userLocationHeight");
    var iEpochDate = $.SA_oSettings.bDateAuto ? Time.today().value() : App.Storage.getValue("storDatePreset");
    var iEpochTime = $.SA_oSettings.bDateAuto ? Time.now().value() : null;
    self.computeAlmanac(Ui.loadResource(Rez.Strings.valueLocationGPS), adLocation[0], adLocation[1], fLocationHeight, iEpochDate, iEpochTime);

    // Update UI
    self.updateUi();
  }

  function onUpdateTimer_init() {
    //Sys.println("DEBUG: SA_App.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 60000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: SA_App.onUpdateTimer()");
    self.updateUi();
  }

  function updateUi() {
    //Sys.println("DEBUG: SA_App.updateUi()");

    // Update UI
    if($.SA_oCurrentView != null) {
      $.SA_oCurrentView.updateUi();
    }
  }

}
