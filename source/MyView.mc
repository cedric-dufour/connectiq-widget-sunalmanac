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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Current view index
var iMyViewIndex as Number = 0;


//
// CLASS
//

class MyView extends Ui.View {

  //
  // CONSTANTS
  //

  private const NOVALUE_BLANK = "";
  private const NOVALUE_LEN3 = "---";


  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow as Boolean = false;

  // Resources
  // ... drawable
  private var oRezDrawable as MyDrawable?;
  // ... header
  private var oRezValueDate as Ui.Text?;
  // ... label
  private var oRezLabelTop as Ui.Text?;
  // ... fields (2x2)
  private var oRezValueTopLeft as Ui.Text?;
  private var oRezValueTopRight as Ui.Text?;
  private var oRezValueBottomLeft as Ui.Text?;
  private var oRezValueBottomRight as Ui.Text?;
  // ... fields (4x1)
  private var oRezValueTopHigh as Ui.Text?;
  private var oRezValueTopLow as Ui.Text?;
  private var oRezValueBottomHigh as Ui.Text?;
  private var oRezValueBottomLow as Ui.Text?;
  // ... label
  private var oRezLabelBottom as Ui.Text?;
  // ... footer
  private var oRezValueTime as Ui.Text?;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.MyLayout(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawable = View.findDrawableById("MyDrawable") as MyDrawable?;
    // ... header
    self.oRezValueDate = View.findDrawableById("valueDate") as Ui.Text?;
    // ... label
    self.oRezLabelTop = View.findDrawableById("labelTop") as Ui.Text?;
    // ... fields (2x2)
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft") as Ui.Text?;
    self.oRezValueTopRight = View.findDrawableById("valueTopRight") as Ui.Text?;
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft") as Ui.Text?;
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight") as Ui.Text?;
    // ... fields (4x1)
    self.oRezValueTopHigh = View.findDrawableById("valueTopHigh") as Ui.Text?;
    self.oRezValueTopLow = View.findDrawableById("valueTopLow") as Ui.Text?;
    self.oRezValueBottomHigh = View.findDrawableById("valueBottomHigh") as Ui.Text?;
    self.oRezValueBottomLow = View.findDrawableById("valueBottomLow") as Ui.Text?;
    // ... label
    self.oRezLabelBottom = View.findDrawableById("labelBottom") as Ui.Text?;
    // ... footer
    self.oRezValueTime = View.findDrawableById("valueTime") as Ui.Text?;
  }

  function onShow() {
    //Sys.println("DEBUG: MyView.onShow()");

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors
    var iColorText = $.oMySettings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    if(self.oRezDrawable != null) {
      (self.oRezDrawable as MyDrawable).setColorBackground($.oMySettings.iBackgroundColor);
    }
    // ... date
    // -> depends on settings
    // ... fields (2x2)
    if(self.oRezValueTopLeft != null) {
      (self.oRezValueTopLeft as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueTopRight != null) {
      (self.oRezValueTopRight as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueBottomLeft != null) {
      (self.oRezValueBottomLeft as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueBottomRight != null) {
      (self.oRezValueBottomRight as Ui.Text).setColor(iColorText);
    }
    // ... fields (4x1)
    if(self.oRezValueTopHigh != null) {
      (self.oRezValueTopHigh as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueTopLow != null) {
      (self.oRezValueTopLow as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueBottomHigh != null) {
      (self.oRezValueBottomHigh as Ui.Text).setColor(iColorText);
    }
    if(self.oRezValueBottomLow != null) {
      (self.oRezValueBottomLow as Ui.Text).setColor(iColorText);
    }
    // ... time
    if(self.oRezValueTime != null) {
      (self.oRezValueTime as Ui.Text).setColor(iColorText);
    }

    // Done
    self.bShow = true;
    $.oMyView = self;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyView.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);
  }

  function onHide() {
    //Sys.println("DEBUG: MyView.onHide()");
    $.oMyView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() as Void {
    //Sys.println("DEBUG: MyView.reloadSettings()");

    // Update application state
    (App.getApp() as MyApp).updateApp();
  }

  function updateUi() as Void {
    //Sys.println("DEBUG: MyView.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() as Void {
    //Sys.println("DEBUG: MyView.updateLayout()");
    if(self.oRezDrawable == null) {
      return;
    }

    // Set header/footer values
    var iColorText = $.oMySettings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;

    // ... date
    if(self.oRezValueDate != null) {
      (self.oRezValueDate as Ui.Text).setColor($.oMySettings.bDateAuto ? iColorText : Gfx.COLOR_LT_GRAY);
      if($.oMyAlmanac_today.iEpochCurrent >= 0) {
        var oDate = new Time.Moment($.oMyAlmanac_today.iEpochCurrent);
        var oDateInfo = $.oMySettings.bTimeUTC ? Gregorian.utcInfo(oDate, Time.FORMAT_MEDIUM) : Gregorian.info(oDate, Time.FORMAT_MEDIUM);
        (self.oRezValueDate as Ui.Text).setText(format("$1$ $2$", [oDateInfo.month, oDateInfo.day.format("%d")]));
      }
      else if($.oMyAlmanac_today.iEpochDate >= 0) {
        var oDateInfo = Gregorian.utcInfo(new Time.Moment($.oMyAlmanac_today.iEpochDate), Time.FORMAT_MEDIUM);
        (self.oRezValueDate as Ui.Text).setText(format("$1$ $2$", [oDateInfo.month, oDateInfo.day.format("%d")]));
      }
      else {
        (self.oRezValueDate as Ui.Text).setText(self.NOVALUE_LEN3);
      }
    }

    // ... time
    if(self.oRezValueTime != null) {
      var oTimeNow = Time.now();
      var oTimeInfo = $.oMySettings.bTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
      (self.oRezValueTime as Ui.Text).setText(format("$1$:$2$ $3$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]));
    }

    // Set field values
    if(self.oRezLabelTop == null
       or self.oRezValueTopLeft == null or self.oRezValueTopRight == null
       or self.oRezValueTopHigh == null or self.oRezValueTopLow == null
       or self.oRezLabelBottom == null
       or self.oRezValueBottomLeft == null or self.oRezValueBottomRight == null
       or self.oRezValueBottomHigh == null or self.oRezValueBottomLow == null
       ) {
      return;
    }
    if($.iMyViewIndex == 0) {

      (self.oRezDrawable as MyDrawable).setDividers(MyDrawable.DRAW_DIVIDER_HORIZONTAL
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_TOP
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... sunrise/sunset
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelSunriseSunset) as String);
      if($.oMyAlmanac_today.iEpochSunrise >= 0 and $.oMyAlmanac_today.iEpochSunset >= 0) {
        (self.oRezValueTopLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochSunrise, true));
        (self.oRezValueTopRight as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochSunset, true));
      }
      else {
        (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      // ... day length
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDayLength) as String);
      if($.oMyAlmanac_today.iEpochSunrise >= 0 and $.oMyAlmanac_today.iEpochSunset >= 0) {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.stringTimeDiff_daylength($.oMyAlmanac_today.iEpochSunset
                                                                                    - $.oMyAlmanac_today.iEpochSunrise));
        if($.oMyAlmanac_yesterday.iEpochSunrise >= 0 and $.oMyAlmanac_yesterday.iEpochSunset >= 0) {
          (self.oRezValueBottomRight as Ui.Text).setText(self.stringTimeDiff_daydelta($.oMyAlmanac_today.iEpochSunset
                                                                                      - $.oMyAlmanac_today.iEpochSunrise
                                                                                      - $.oMyAlmanac_yesterday.iEpochSunset
                                                                                      + $.oMyAlmanac_yesterday.iEpochSunrise));
        }
        else {
          (self.oRezValueBottomRight as Ui.Text).setText(self.stringTimeDiff_daydelta($.oMyAlmanac_today.iEpochSunset
                                                                                      - $.oMyAlmanac_today.iEpochSunrise));
        }
      }
      else if($.oMyAlmanac_today.fElevationTransit >= 0.0d) {
        (self.oRezValueBottomLeft as Ui.Text).setText("24h");
        if($.oMyAlmanac_yesterday.iEpochSunrise >= 0 and $.oMyAlmanac_yesterday.iEpochSunset >= 0) {
          (self.oRezValueBottomRight as Ui.Text).setText(self.stringTimeDiff_daydelta(86400
                                                                                      - $.oMyAlmanac_yesterday.iEpochSunset
                                                                                      + $.oMyAlmanac_yesterday.iEpochSunrise));
        }
        else {
          (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
        }
      }
      else {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        if($.oMyAlmanac_yesterday.iEpochSunrise >= 0 and $.oMyAlmanac_yesterday.iEpochSunset >= 0) {
          (self.oRezValueBottomRight as Ui.Text).setText(self.stringTimeDiff_daydelta($.oMyAlmanac_yesterday.iEpochSunrise
                                                                                      - $.oMyAlmanac_yesterday.iEpochSunset));
        }
        else {
          (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
        }
      }
      // ... clear previous view fields
      (self.oRezValueTopHigh as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueTopLow as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueBottomHigh as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueBottomLow as Ui.Text).setText(self.NOVALUE_BLANK);

    }
    else if($.iMyViewIndex == 1) {

      (self.oRezDrawable as MyDrawable).setDividers(MyDrawable.DRAW_DIVIDER_HORIZONTAL
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_TOP
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... zenith
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelTransit) as String);
      if($.oMyAlmanac_today.iEpochTransit >= 0 and LangUtils.notNaN($.oMyAlmanac_today.fElevationTransit)) {
        (self.oRezValueTopLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochTransit, true));
        (self.oRezValueTopRight as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fElevationTransit));
      }
      else {
        (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      // ... azimuth
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAzimuth) as String);
      if(LangUtils.notNaN($.oMyAlmanac_today.fAzimuthSunrise) and LangUtils.notNaN($.oMyAlmanac_today.fAzimuthSunset)) {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fAzimuthSunrise));
        (self.oRezValueBottomRight as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fAzimuthSunset));
      }
      else {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }

    }
    else if($.iMyViewIndex == 2) {

      (self.oRezDrawable as MyDrawable).setDividers(MyDrawable.DRAW_DIVIDER_HORIZONTAL
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_TOP
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... civil dawn/dusk
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelCivilDawnDusk) as String);
      if($.oMyAlmanac_today.iEpochCivilDawn >= 0 and $.oMyAlmanac_today.iEpochCivilDusk >= 0) {
        (self.oRezValueTopLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochCivilDawn, true));
        (self.oRezValueTopRight as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochCivilDusk, true));
      }
      else {
        (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      // ... nautical dawn/dusk
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelNauticalDawnDusk) as String);
      if($.oMyAlmanac_today.iEpochNauticalDawn >= 0 and $.oMyAlmanac_today.iEpochNauticalDusk >= 0) {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochNauticalDawn, true));
        (self.oRezValueBottomRight as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochNauticalDusk, true));
      }
      else {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }

    }
    else if($.iMyViewIndex == 3) {

      (self.oRezDrawable as MyDrawable).setDividers(MyDrawable.DRAW_DIVIDER_HORIZONTAL
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_TOP
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... astronomical dawn/dusk
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAstronomicalDawnDusk) as String);
      if($.oMyAlmanac_today.iEpochAstronomicalDawn >= 0 and $.oMyAlmanac_today.iEpochAstronomicalDusk >= 0) {
        (self.oRezValueTopLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochAstronomicalDawn, true));
        (self.oRezValueTopRight as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochAstronomicalDusk, true));
      }
      else {
        (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      // ... ecliptic longitude / declination
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelEcliptic) as String);
      if(LangUtils.notNaN($.oMyAlmanac_today.fEclipticLongitude) and LangUtils.notNaN($.oMyAlmanac_today.fDeclination)) {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fEclipticLongitude));
        (self.oRezValueBottomRight as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fDeclination));
      }
      else {
        (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }

    }
    else if($.iMyViewIndex == 4) {

      (self.oRezDrawable as MyDrawable).setDividers(MyDrawable.DRAW_DIVIDER_HORIZONTAL
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_TOP
                                                    | MyDrawable.DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... current
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelCurrentTop) as String);
      if($.oMyAlmanac_today.iEpochCurrent >= 0 and LangUtils.notNaN($.oMyAlmanac_today.fElevationCurrent) and LangUtils.notNaN($.oMyAlmanac_today.fAzimuthCurrent)) {
        (self.oRezValueTopLeft as Ui.Text).setText(self.stringTime($.oMyAlmanac_today.iEpochCurrent, false));
        if($.oMyAlmanac_today.fElevationCurrent > $.oMyAlmanac_today.ANGLE_RISESET) {
          (self.oRezValueTopRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.valuePhaseDay) as String);
        }
        else if($.oMyAlmanac_today.fElevationCurrent > $.oMyAlmanac_today.ANGLE_CIVIL) {
          (self.oRezValueTopRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.valuePhaseCivil) as String);
        }
        else if($.oMyAlmanac_today.fElevationCurrent > $.oMyAlmanac_today.ANGLE_NAUTICAL) {
          (self.oRezValueTopRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.valuePhaseNautical) as String);
        }
        else if($.oMyAlmanac_today.fElevationCurrent > $.oMyAlmanac_today.ANGLE_ASTRONOMICAL) {
          (self.oRezValueTopRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.valuePhaseAstronomical) as String);
        }
        else {
          (self.oRezValueTopRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.valuePhaseNight) as String);
        }
        (self.oRezValueBottomLeft as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fAzimuthCurrent));
        (self.oRezValueBottomRight as Ui.Text).setText(self.stringDegree($.oMyAlmanac_today.fElevationCurrent));
      }
      else {
        (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_LEN3);
        (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelCurrentBottom) as String);

    }
    else if($.iMyViewIndex == 5) {

      (self.oRezDrawable as MyDrawable).setDividers(0);
      // ... location
      (self.oRezLabelTop as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelLocation) as String);
      if($.oMyAlmanac_today.sLocationName.length() > 0) {
        (self.oRezValueTopHigh as Ui.Text).setText($.oMyAlmanac_today.sLocationName as String);
      }
      else {
        (self.oRezValueTopHigh as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      if(LangUtils.notNaN($.oMyAlmanac_today.dLocationLatitude) and LangUtils.notNaN($.oMyAlmanac_today.dLocationLongitude)) {
        (self.oRezValueTopLow as Ui.Text).setText(self.stringLatitude($.oMyAlmanac_today.dLocationLatitude));
        (self.oRezValueBottomHigh as Ui.Text).setText(self.stringLongitude($.oMyAlmanac_today.dLocationLongitude));
      }
      else {
        (self.oRezValueTopLow as Ui.Text).setText(self.NOVALUE_BLANK);
        (self.oRezValueBottomHigh as Ui.Text).setText(self.NOVALUE_BLANK);
      }
      if(LangUtils.notNaN($.oMyAlmanac_today.fLocationHeight)) {
        (self.oRezValueBottomLow as Ui.Text).setText(self.stringHeight($.oMyAlmanac_today.fLocationHeight));
      }
      else {
        (self.oRezValueBottomLow as Ui.Text).setText(self.NOVALUE_LEN3);
      }
      (self.oRezLabelBottom as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeight) as String);
      // ... clear previous view fields
      (self.oRezValueTopLeft as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueTopRight as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueBottomLeft as Ui.Text).setText(self.NOVALUE_BLANK);
      (self.oRezValueBottomRight as Ui.Text).setText(self.NOVALUE_BLANK);

    }
  }

  function stringTime(_iEpochTimestamp as Number, _bRoundUp as Boolean) as String {
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
    if(_bRoundUp and oTimeInfo.sec >= 30) {
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

  function stringTimeDiff_daylength(_iDuration as Number) as String {
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

    // String
    return format("$1$h$2$", [iDuration_hour.format("%d"), iDuration_min.format("%02d")]);
  }

  function stringTimeDiff_daydelta(_iDuration as Number) as String {
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

    // String
    return format("$1$$2$m$3$", [iDuration_sign < 0 ? "-" : "+", iDuration_min.format("%d"), iDuration_sec.format("%02d")]);
  }

  function stringDegree(_fDegree as Float) as String {
    return format("$1$°", [_fDegree.format("%.1f")]);
  }

  function stringLatitude(_dLatitude as Decimal) as String {
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
    return format("$1$°$2$'$3$\" $4$", [iLatitude_deg.format("%d"), iLatitude_min.format("%02d"), iLatitude_sec.format("%02d"), iLatitude_qua < 0 ? "S" : "N"]);
  }

  function stringLongitude(_dLongitude as Decimal) as String {
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
    return format("$1$°$2$'$3$\" $4$", [iLongitude_deg.format("%d"), iLongitude_min.format("%02d"), iLongitude_sec.format("%02d"), iLongitude_qua < 0 ? "W" : "E"]);
  }

  function stringHeight(_fHeight as Float) as String {
    var fValue = _fHeight * $.oMySettings.fUnitElevationConstant;
    return format("$1$ $2$", [fValue.format("%.0f"), $.oMySettings.sUnitElevation]);
  }

}

class MyViewDelegate extends Ui.BehaviorDelegate {

  //
  // FUNCTIONS: Ui.BehaviorDelegate (override/implement)
  //

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewDelegate.onMenu()");
    Ui.pushView(new MenuSettings(),
                new MenuSettingsDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewDelegate.onSelect()");
    $.iMyViewIndex = ( $.iMyViewIndex + 1 ) % 6;
    Ui.requestUpdate();
    return true;
  }

}
