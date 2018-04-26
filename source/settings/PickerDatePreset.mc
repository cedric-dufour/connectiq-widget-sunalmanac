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
using Toybox.WatchUi as Ui;

class PickerDatePreset extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var iEpochDate = App.Storage.getValue("storDatePreset");

    // Slipt components
    var oDate = new Time.Moment(iEpochDate);
    var oDateInfo = Gregorian.info(oDate, Time.FORMAT_SHORT);

    // Initialize picker
    var oFactory_year = new PickerFactoryNumber(1970, 2037, null);
    var oFactory_month = new PickerFactoryNumber(1, 12, null);
    var oFactory_day = new PickerFactoryNumber(1, 31, null);
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleDatePreset), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory_year, oFactory_month, oFactory_day ],
      :defaults => [ oFactory_year.indexOf(oDateInfo.year), oFactory_month.indexOf(oDateInfo.month), oFactory_day.indexOf(oDateInfo.day) ]
    });
  }

}

class PickerDelegateDatePreset extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var iDay = _amValues[2];
    if(_amValues[1] == 2 and iDay > 28) {
      // Yes. I know. I wish the "Invalid Value" spawned by invalid Gregorian.moment() could be catched as a exception but it can't. So let's keep this simple...
      iDay = 28;
    }
    else if((_amValues[1] == 4 or _amValues[1] == 6 or _amValues[1] == 9 or _amValues[1] == 11) and iDay > 30) {
      iDay = 30;
    }
    var iEpochDate = Gregorian.moment({ :year => _amValues[0], :month => _amValues[1], :day => iDay, :hour => 0, :min => 0, :sec => 0 }).value();

    // Set property and exit
    App.Storage.setValue("storDatePreset", iEpochDate);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
