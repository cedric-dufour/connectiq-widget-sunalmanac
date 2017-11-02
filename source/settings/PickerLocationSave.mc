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
using Toybox.WatchUi as Ui;

class PickerLocationSave extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Location memory
    var iMemorySize = 10;
    var aiMemoryKeys = new [iMemorySize];
    var asMemoryValues = new [iMemorySize];
    for(var n=0; n<iMemorySize; n++) {
      aiMemoryKeys[n] = n;
      var s = n.format("%02d");
      var dictLocation = App.getApp().getProperty("storLoc"+s);
      if(dictLocation != null) {
        asMemoryValues[n] = Lang.format("[$1$]\n$2$", [s, dictLocation["name"]]);
      }
      else {
        asMemoryValues[n] = Lang.format("[$1$]\n----", [s]);
      }
    }

    // Initialize picker
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.menuLocationSave), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryDictionary(aiMemoryKeys, asMemoryValues, { :font => Gfx.FONT_TINY }) ]
    });
  }

}

class PickerDelegateLocationSave extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Save location
    var dictLocation = App.getApp().getProperty("storLocPreset");
    if(dictLocation != null) {
      // Set property (location memory)
      // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
      var s = _amValues[0].format("%02d");
      App.getApp().setProperty("storLoc"+s, SaUtils.copy(dictLocation));
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
