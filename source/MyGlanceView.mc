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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;


//
// CLASS
//

(:glance)
class MyGlanceView extends Ui.GlanceView {

  //
  // CONSTANTS
  //

  private const NOVALUE_TIME = "--:--";
  private const NOVALUE_DEGREE = "---°";


  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow as Boolean = false;

  // Layout
  private var iXCenter as Number = 0;
  private var iXLeft as Number = 0;
  private var iYLine2 as Number = 0;
  private var iYLine3 as Number = 0;


  //
  // FUNCTIONS: Ui.GlanceView (override/implement)
  //

  function initialize() {
    GlanceView.initialize();
  }


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function onLayout(_oDC) {
    // Layout
    self.iXCenter = (0.50*_oDC.getWidth()).toNumber();
    self.iXLeft = _oDC.getWidth();
    self.iYLine2 = (0.25*_oDC.getHeight()).toNumber();
    self.iYLine3 = (0.67*_oDC.getHeight()).toNumber();
  }

  function onShow() {
    //Sys.println("DEBUG: MyGlanceView.onShow()");

    // Update application state
    (App.getApp() as MyApp).updateApp();

    // Done
    self.bShow = true;
    $.oMyGlanceView = self;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyGlanceView.onUpdate()");
    GlanceView.onUpdate(_oDC);

    // Label
    _oDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(0, 0, Gfx.FONT_GLANCE, "SUN ALMANAC", Gfx.TEXT_JUSTIFY_LEFT);

    // ... location
    _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iXLeft, 0, Gfx.FONT_GLANCE, $.oMyAlmanac_today.sLocationName, Gfx.TEXT_JUSTIFY_RIGHT);

    // Values (line 2)
    var fValue, sValue;
    _oDC.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    // ... sunrise/sunset
    if($.oMyAlmanac_today.iEpochSunrise >= 0 and $.oMyAlmanac_today.iEpochSunset >= 0) {
      sValue = format("$1$ - $2$ $3$", [self.stringTime($.oMyAlmanac_today.iEpochSunrise), self.stringTime($.oMyAlmanac_today.iEpochSunset), $.oMySettings.sUnitTime]);
    }
    else {
      sValue = format("$1$ - $2$ $3$", [self.NOVALUE_TIME, self.NOVALUE_TIME, $.oMySettings.sUnitTime]);
    }
    _oDC.drawText(self.iXCenter, self.iYLine2, Gfx.FONT_SYSTEM_SMALL, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Values (secondary, line 3)
    _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

    // ... sunrise/sunset: azimuth
    if(LangUtils.notNaN($.oMyAlmanac_today.fAzimuthSunrise) and LangUtils.notNaN($.oMyAlmanac_today.fAzimuthSunset)) {
      sValue = format("$1$/$2$", [self.stringDegree($.oMyAlmanac_today.fAzimuthSunrise), self.stringDegree($.oMyAlmanac_today.fAzimuthSunset)]);
    }
    else {
      sValue = format("$1$/$2$", [self.NOVALUE_DEGREE, self.NOVALUE_DEGREE]);
    }
    _oDC.drawText(0, self.iYLine3, Gfx.FONT_SYSTEM_XTINY, sValue, Gfx.TEXT_JUSTIFY_LEFT);

    // ... noon: time/elevation
    if($.oMyAlmanac_today.iEpochTransit >= 0 and LangUtils.notNaN($.oMyAlmanac_today.fElevationTransit)) {
      sValue = format("$1$/$2$", [self.stringTime($.oMyAlmanac_today.iEpochTransit), self.stringDegree($.oMyAlmanac_today.fElevationTransit)]);
    }
    else {
      sValue = format("$1$/$2$", [self.NOVALUE_TIME, self.NOVALUE_DEGREE]);
    }
    _oDC.drawText(self.iXCenter, self.iYLine3, Gfx.FONT_SYSTEM_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... current: azimuth/elevation
    if(LangUtils.notNaN($.oMyAlmanac_today.fAzimuthCurrent) and LangUtils.notNaN($.oMyAlmanac_today.fElevationCurrent)) {
      sValue = format("$1$/$2$", [self.stringDegree($.oMyAlmanac_today.fAzimuthCurrent), self.stringDegree($.oMyAlmanac_today.fElevationCurrent)]);
    }
    else {
      sValue = format("$1$/$2$", [self.NOVALUE_DEGREE, self.NOVALUE_DEGREE]);
    }
    _oDC.drawText(self.iXLeft, self.iYLine3, Gfx.FONT_SYSTEM_XTINY, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  }

  function onHide() {
    //Sys.println("DEBUG: MyGlanceView.onHide()");
    $.oMyGlanceView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function updateUi() as Void {
    //Sys.println("DEBUG: MyGlanceView.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function stringTime(_iEpochTimestamp as Number) as String {
    // Components
    var oTime = new Time.Moment(_iEpochTimestamp);
    var oTimeInfo;
    if($.oMySettings.bTimeUTC) {
      oTimeInfo = Gregorian.utcInfo(oTime, Time.FORMAT_SHORT);
    }
    else {
      oTimeInfo = Gregorian.info(oTime, Time.FORMAT_SHORT);
    }
    var iTime_hour = oTimeInfo.hour;
    var iTime_min = oTimeInfo.min;
    // ... round minutes up
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
    return format("$1$:$2$", [iTime_hour.format("%d"), iTime_min.format("%02d")]);
  }

  function stringDegree(_fDegree as Float) as String {
    return format("$1$°", [_fDegree.format("%.0f")]);
  }

}
