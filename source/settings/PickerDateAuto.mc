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

class PickerDateAuto extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var bDateAuto = App.getApp().getProperty("userDateAuto");

    // Initialize picker
    var oFactory = new PickerFactoryDictionary([true, false], [Ui.loadResource(Rez.Strings.valueAuto), Ui.loadResource(Rez.Strings.valuePreset)], null);
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleDateAuto), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory ],
      :defaults => [ oFactory.indexOfKey(bDateAuto) ]
    });
  }

}

class PickerDelegateDateAuto extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Set property and exit
    App.getApp().setProperty("userDateAuto", _amValues[0]);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
