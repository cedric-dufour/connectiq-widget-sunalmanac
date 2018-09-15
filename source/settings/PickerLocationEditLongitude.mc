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

class PickerLocationEditLongitude extends PickerGenericLongitude {

  //
  // FUNCTIONS: PickerGenericLongitude (override/implement)
  //

  function initialize() {
    // Get property
    var dictLocation = App.Storage.getValue("storLocPreset");
    var fLongitude = dictLocation != null ? dictLocation["longitude"] : 0.0f;
    PickerGenericLongitude.initialize(Ui.loadResource(Rez.Strings.titleLocationLongitude), fLongitude);
  }

}

class PickerDelegateLocationEditLongitude extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var fLongitude = PickerGenericLongitude.getValue(_amValues);

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
