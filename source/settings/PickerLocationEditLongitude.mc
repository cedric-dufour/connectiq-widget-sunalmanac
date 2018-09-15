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
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerLocationEditLongitude extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var dictLocation = App.Storage.getValue("storLocPreset");
    var fLongitude = dictLocation != null ? dictLocation["longitude"] : 0.0f;

    // Split components
    var iLongitude_qua = fLongitude < 0.0f ? -1 : 1;
    fLongitude = fLongitude.abs();
    var iLongitude_deg = fLongitude.toNumber();
    fLongitude = (fLongitude - iLongitude_deg) * 60.0f;
    var iLongitude_min = fLongitude.toNumber();
    fLongitude = (fLongitude - iLongitude_min) * 60.0f + 0.5f;
    var iLongitude_sec = fLongitude.toNumber();
    if(iLongitude_sec >= 60) {
      iLongitude_sec = 59;
    }

    // Initialize picker
    var oFactory_qua = new PickerFactoryDictionary([1, -1], ["E", "W"], null);
    var oText_qua = new Ui.Text({ :text => "E/W", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_deg = new Ui.Text({ :text => "deg", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_min = new Ui.Text({ :text => "min", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_sec = new Ui.Text({ :text => "sec", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleLocationLongitude), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory_qua, oText_qua,
                    new PickerFactoryNumber(0, 179, null), oText_deg,
                    new PickerFactoryNumber(0, 59, { :format => "%02d" }), oText_min,
                    new PickerFactoryNumber(0, 59, { :format => "%02d" }), oText_sec ],
      :defaults => [ oFactory_qua.indexOfKey(iLongitude_qua), 0, iLongitude_deg, 0, iLongitude_min, 0, iLongitude_sec, 0 ]
    });
  }

}

class PickerDelegateLocationEditLongitude extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var fLongitude = _amValues[0] * (_amValues[2] + _amValues[4]/60.0f + _amValues[6]/3600.0f);

    // Update/create location (dictionary)
    var dictLocation = App.Storage.getValue("storLocPreset");
    if(dictLocation != null) {
      dictLocation["longitude"] = fLongitude;
    }
    else {
      dictLocation = { "name" => "----", "latitude" => 0.0f, "longitude" => fLongitude };
    }

    // Set property and exit
    App.Storage.setValue("storLocPreset", dictLocation);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
