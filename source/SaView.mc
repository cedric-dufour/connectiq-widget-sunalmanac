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
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//
// CONSTANTS
//

const SA_NOVALUE_BLANK = "";
const SA_NOVALUE_LEN3 = "---";


//
// GLOBALS
//

// Current view index
var SA_ViewIndex = 0;


//
// CLASS
//

class ViewSa extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;

  // Resources (to be loaded on onShow() and freed on onHide())
  // ... drawable
  private var oRezDrawableGlobal;
  // ... header
  private var oRezValueDate;
  // ... label
  private var oRezLabelTop;
  // ... fields (2x2)
  private var oRezValueTopLeft;
  private var oRezValueTopRight;
  private var oRezValueBottomLeft;
  private var oRezValueBottomRight;
  // ... fields (4x1)
  private var oRezValueTopHigh;
  private var oRezValueTopLow;
  private var oRezValueBottomHigh;
  private var oRezValueBottomLow;
  // ... label
  private var oRezLabelBottom;
  // ... footer
  private var oRezValueTime;
  // ... strings
  private var sLabelSunriseSunset;
  private var sLabelDayLength;
  private var sLabelZenith;
  private var sLabelAzimuth;
  private var sLabelCivilDawnDusk;
  private var sLabelNauticalDawnDusk;
  private var sLabelAstronomicalDawnDusk;
  private var sLabelEcliptic;
  private var sLabelLocation;
  private var sLabelHeight;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode (internal)
    self.bShow = false;
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.LayoutGlobal(_oDC));
    return true;
  }

  function onShow() {
    //Sys.println("DEBUG: ViewSa.onShow()");

    // Load resources
    // ... drawable
    self.oRezDrawableGlobal = View.findDrawableById("DrawableGlobal");
    // ... header
    self.oRezValueDate = View.findDrawableById("valueDate");
    // ... label
    self.oRezLabelTop = View.findDrawableById("labelTop");
    // ... fields (2x2)
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft");
    self.oRezValueTopRight = View.findDrawableById("valueTopRight");
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft");
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight");
    // ... fields (4x1)
    self.oRezValueTopHigh = View.findDrawableById("valueTopHigh");
    self.oRezValueTopLow = View.findDrawableById("valueTopLow");
    self.oRezValueBottomHigh = View.findDrawableById("valueBottomHigh");
    self.oRezValueBottomLow = View.findDrawableById("valueBottomLow");
    // ... label
    self.oRezLabelBottom = View.findDrawableById("labelBottom");
    // ... footer
    self.oRezValueTime = View.findDrawableById("valueTime");
    // ... strings
    self.sLabelSunriseSunset = Ui.loadResource(Rez.Strings.labelSunriseSunset);
    self.sLabelDayLength = Ui.loadResource(Rez.Strings.labelDayLength);
    self.sLabelZenith = Ui.loadResource(Rez.Strings.labelZenith);
    self.sLabelAzimuth = Ui.loadResource(Rez.Strings.labelAzimuth);
    self.sLabelCivilDawnDusk = Ui.loadResource(Rez.Strings.labelCivilDawnDusk);
    self.sLabelNauticalDawnDusk = Ui.loadResource(Rez.Strings.labelNauticalDawnDusk);
    self.sLabelAstronomicalDawnDusk = Ui.loadResource(Rez.Strings.labelAstronomicalDawnDusk);
    self.sLabelEcliptic = Ui.loadResource(Rez.Strings.labelEcliptic);
    self.sLabelLocation = Ui.loadResource(Rez.Strings.labelLocation);
    self.sLabelHeight = Ui.loadResource(Rez.Strings.labelHeight);

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors
    var iColorText = $.SA_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableGlobal.setColorBackground($.SA_Settings.iBackgroundColor);
    // ... date
    // -> depends on settings
    // ... fields (2x2)
    self.oRezValueTopLeft.setColor(iColorText);
    self.oRezValueTopRight.setColor(iColorText);
    self.oRezValueBottomLeft.setColor(iColorText);
    self.oRezValueBottomRight.setColor(iColorText);
    // ... fields (4x1)
    self.oRezValueTopHigh.setColor(iColorText);
    self.oRezValueTopLow.setColor(iColorText);
    self.oRezValueBottomHigh.setColor(iColorText);
    self.oRezValueBottomLow.setColor(iColorText);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Done
    self.bShow = true;
    $.SA_CurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: ViewSa.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: ViewSa.onHide()");
    $.SA_CurrentView = null;
    self.bShow = false;

    // Free resources
    // ... drawable
    self.oRezDrawableGlobal = null;
    // ... header
    self.oRezValueDate = null;
    // ... label
    self.oRezLabelTop = null;
    // ... fields (2x2)
    self.oRezValueTopLeft = null;
    self.oRezValueTopRight = null;
    self.oRezValueBottomLeft = null;
    self.oRezValueBottomRight = null;
    // ... fields (4x1)
    self.oRezValueTopHigh = null;
    self.oRezValueTopLow = null;
    self.oRezValueBottomHigh = null;
    self.oRezValueBottomLow = null;
    // ... label
    self.oRezLabelBottom = null;
    // ... footer
    self.oRezValueTime = null;
    // ... strings
    self.sLabelSunriseSunset = null;
    self.sLabelDayLength = null;
    self.sLabelZenith = null;
    self.sLabelAzimuth = null;
    self.sLabelCivilDawnDusk = null;
    self.sLabelNauticalDawnDusk = null;
    self.sLabelAstronomicalDawnDusk = null;
    self.sLabelEcliptic = null;
    self.sLabelLocation = null;
    self.sLabelHeight = null;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() {
    //Sys.println("DEBUG: ViewSa.reloadSettings()");

    // Update application state
    App.getApp().updateApp();
  }

  function updateUi() {
    //Sys.println("DEBUG: ViewSa.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() {
    //Sys.println("DEBUG: ViewSa.updateLayout()");

    // Set header/footer values
    var iColorText = $.SA_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    var sValue;

    // ... date
    self.oRezValueDate.setColor($.SA_Settings.bDateAuto ? iColorText : Gfx.COLOR_LT_GRAY);
    if($.SA_Almanac_today.iEpochDate != null) {
      var oDate = new Time.Moment($.SA_Almanac_today.iEpochDate);
      var oDateInfo = Gregorian.info(oDate, Time.FORMAT_MEDIUM);
      self.oRezValueDate.setText(Lang.format("$1$ $2$", [oDateInfo.month, oDateInfo.day.format("%d")]));
    }
    else {
      self.oRezValueDate.setText($.SA_NOVALUE_LEN3);
    }

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.SA_Settings.bTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$:$2$ $3$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d"), $.SA_Settings.sUnitTime]));

    // Set field values
    switch($.SA_ViewIndex) {

    case 0:
      self.oRezDrawableGlobal.setDividers($.SA_DRAW_DIVIDER_HORIZONTAL | $.SA_DRAW_DIVIDER_VERTICAL_TOP | $.SA_DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... sunrise/sunset
      self.oRezLabelTop.setText(self.sLabelSunriseSunset);
      if($.SA_Almanac_today.iEpochSunrise != null and $.SA_Almanac_today.iEpochSunset != null) {
        self.oRezValueTopLeft.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochSunrise));
        self.oRezValueTopRight.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochSunset));
      }
      else {
        self.oRezValueTopLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueTopRight.setText($.SA_NOVALUE_LEN3);
      }
      // ... day length
      self.oRezLabelBottom.setText(self.sLabelDayLength);
      if($.SA_Almanac_today.iEpochSunrise != null and $.SA_Almanac_today.iEpochSunset != null) {
        self.oRezValueBottomLeft.setText($.SA_Almanac_today.stringTimeDiff_hm($.SA_Almanac_today.iEpochSunset - $.SA_Almanac_today.iEpochSunrise));
        if($.SA_Almanac_yesterday.iEpochSunrise != null and $.SA_Almanac_yesterday.iEpochSunset != null) {
          self.oRezValueBottomRight.setText($.SA_Almanac_today.stringTimeDiff_ms($.SA_Almanac_today.iEpochSunset - $.SA_Almanac_today.iEpochSunrise - $.SA_Almanac_yesterday.iEpochSunset + $.SA_Almanac_yesterday.iEpochSunrise));
        }
        else {
          self.oRezValueBottomRight.setText($.SA_Almanac_today.stringTimeDiff_ms($.SA_Almanac_today.iEpochSunset - $.SA_Almanac_today.iEpochSunrise));
        }
      }
      else if($.SA_Almanac_today.fAltitudeZenith != null and $.SA_Almanac_today.fAltitudeZenith >= 0.0d) {
        self.oRezValueBottomLeft.setText("24h");
        if($.SA_Almanac_yesterday.iEpochSunrise != null and $.SA_Almanac_yesterday.iEpochSunset != null) {
          self.oRezValueBottomRight.setText($.SA_Almanac_today.stringTimeDiff_ms(86400 - $.SA_Almanac_yesterday.iEpochSunset + $.SA_Almanac_yesterday.iEpochSunrise));
        }
        else {
          self.oRezValueBottomRight.setText($.SA_NOVALUE_LEN3);
        }
      }
      else {
        self.oRezValueBottomLeft.setText($.SA_NOVALUE_LEN3);
        if($.SA_Almanac_yesterday.iEpochSunrise != null and $.SA_Almanac_yesterday.iEpochSunset != null) {
          self.oRezValueBottomRight.setText($.SA_Almanac_today.stringTimeDiff_ms($.SA_Almanac_yesterday.iEpochSunrise - $.SA_Almanac_yesterday.iEpochSunset));
        }
        else {
          self.oRezValueBottomRight.setText($.SA_NOVALUE_LEN3);
        }
      }
      // ... clear previous view fields
      self.oRezValueTopHigh.setText($.SA_NOVALUE_BLANK);
      self.oRezValueTopLow.setText($.SA_NOVALUE_BLANK);
      self.oRezValueBottomHigh.setText($.SA_NOVALUE_BLANK);
      self.oRezValueBottomLow.setText($.SA_NOVALUE_BLANK);
      break;

    case 1:
      // ... zenith
      self.oRezLabelTop.setText(self.sLabelZenith);
      if($.SA_Almanac_today.iEpochZenith != null and $.SA_Almanac_today.fAltitudeZenith != null) {
        self.oRezValueTopLeft.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochZenith));
        self.oRezValueTopRight.setText($.SA_Almanac_today.stringDegree($.SA_Almanac_today.fAltitudeZenith));
      }
      else {
        self.oRezValueTopLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueTopRight.setText($.SA_NOVALUE_LEN3);
      }
      // ... azimuth
      self.oRezLabelBottom.setText(self.sLabelAzimuth);
      if($.SA_Almanac_today.fAzimuthSunrise != null and $.SA_Almanac_today.fAzimuthSunset != null) {
        self.oRezValueBottomLeft.setText($.SA_Almanac_today.stringDegree($.SA_Almanac_today.fAzimuthSunrise));
        self.oRezValueBottomRight.setText($.SA_Almanac_today.stringDegree($.SA_Almanac_today.fAzimuthSunset));
      }
      else {
        self.oRezValueBottomLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueBottomRight.setText($.SA_NOVALUE_LEN3);
      }
      break;

    case 2:
      self.oRezDrawableGlobal.setDividers($.SA_DRAW_DIVIDER_HORIZONTAL | $.SA_DRAW_DIVIDER_VERTICAL_TOP | $.SA_DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... civil dawn/dusk
      self.oRezLabelTop.setText(self.sLabelCivilDawnDusk);
      if($.SA_Almanac_today.iEpochCivilDawn != null and $.SA_Almanac_today.iEpochCivilDusk != null) {
        self.oRezValueTopLeft.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochCivilDawn));
        self.oRezValueTopRight.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochCivilDusk));
      }
      else {
        self.oRezValueTopLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueTopRight.setText($.SA_NOVALUE_LEN3);
      }
      // ... nautical dawn/dusk
      self.oRezLabelBottom.setText(self.sLabelNauticalDawnDusk);
      if($.SA_Almanac_today.iEpochNauticalDawn != null and $.SA_Almanac_today.iEpochNauticalDusk != null) {
        self.oRezValueBottomLeft.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochNauticalDawn));
        self.oRezValueBottomRight.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochNauticalDusk));
      }
      else {
        self.oRezValueBottomLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueBottomRight.setText($.SA_NOVALUE_LEN3);
      }
      break;

    case 3:
      self.oRezDrawableGlobal.setDividers($.SA_DRAW_DIVIDER_HORIZONTAL | $.SA_DRAW_DIVIDER_VERTICAL_TOP | $.SA_DRAW_DIVIDER_VERTICAL_BOTTOM);
      // ... astronomical dawn/dusk
      self.oRezLabelTop.setText(self.sLabelAstronomicalDawnDusk);
      if($.SA_Almanac_today.iEpochAstronomicalDawn != null and $.SA_Almanac_today.iEpochAstronomicalDusk != null) {
        self.oRezValueTopLeft.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochAstronomicalDawn));
        self.oRezValueTopRight.setText($.SA_Almanac_today.stringTime($.SA_Almanac_today.iEpochAstronomicalDusk));
      }
      else {
        self.oRezValueTopLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueTopRight.setText($.SA_NOVALUE_LEN3);
      }
      // ... ecliptic longitude / declination
      self.oRezLabelBottom.setText(self.sLabelEcliptic);
      if($.SA_Almanac_today.fEclipticLongitude != null and $.SA_Almanac_today.fDeclination != null) {
        self.oRezValueBottomLeft.setText($.SA_Almanac_today.stringDegree($.SA_Almanac_today.fEclipticLongitude));
        self.oRezValueBottomRight.setText($.SA_Almanac_today.stringDegree($.SA_Almanac_today.fDeclination));
      }
      else {
        self.oRezValueBottomLeft.setText($.SA_NOVALUE_LEN3);
        self.oRezValueBottomRight.setText($.SA_NOVALUE_LEN3);
      }
      break;

    case 4:
      self.oRezDrawableGlobal.setDividers(0);
      // ... location
      self.oRezLabelTop.setText(self.sLabelLocation);
      if($.SA_Almanac_today.sLocationName != null) {
        self.oRezValueTopHigh.setText($.SA_Almanac_today.sLocationName);
      }
      else {
        self.oRezValueTopHigh.setText($.SA_NOVALUE_LEN3);
      }
      if($.SA_Almanac_today.dLocationLatitude != null and $.SA_Almanac_today.dLocationLongitude != null) {
        self.oRezValueTopLow.setText($.SA_Almanac_today.stringLatitude($.SA_Almanac_today.dLocationLatitude));
        self.oRezValueBottomHigh.setText($.SA_Almanac_today.stringLongitude($.SA_Almanac_today.dLocationLongitude));
      }
      else {
        self.oRezValueTopLow.setText($.SA_NOVALUE_BLANK);
        self.oRezValueBottomHigh.setText($.SA_NOVALUE_BLANK);
      }
      if($.SA_Almanac_today.fLocationHeight != null) {
        self.oRezValueBottomLow.setText($.SA_Almanac_today.stringHeight($.SA_Almanac_today.fLocationHeight));
      }
      else {
        self.oRezValueBottomLow.setText($.SA_NOVALUE_LEN3);
      }
      self.oRezLabelBottom.setText(self.sLabelHeight);
      // ... clear previous view fields
      self.oRezValueTopLeft.setText($.SA_NOVALUE_BLANK);
      self.oRezValueTopRight.setText($.SA_NOVALUE_BLANK);
      self.oRezValueBottomLeft.setText($.SA_NOVALUE_BLANK);
      self.oRezValueBottomRight.setText($.SA_NOVALUE_BLANK);
      break;

    }
  }

}

class ViewDelegateSa extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: ViewDelegateSa.onMenu()");
    Ui.pushView(new Rez.Menus.menuSettings(), new MenuDelegateSettings(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: ViewDelegateSa.onSelect()");
    $.SA_ViewIndex = ( $.SA_ViewIndex + 1 ) % 5;
    Ui.requestUpdate();
    return true;
  }

}
