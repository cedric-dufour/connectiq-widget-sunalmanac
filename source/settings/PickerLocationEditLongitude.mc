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
using Toybox.WatchUi as Ui;

class PickerLocationEditLongitude extends PickerGenericLongitude {

  //
  // FUNCTIONS: PickerGenericLongitude (override/implement)
  //

  function initialize() {
    var dictLocation = App.Storage.getValue("storLocPreset") as Dictionary?;
    var dLongitude = dictLocation != null ? dictLocation["longitude"] as Double : 0.0d;
    PickerGenericLongitude.initialize(Ui.loadResource(Rez.Strings.titleLocationLongitude) as String, dLongitude);
  }

}

class PickerLocationEditLongitudeDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var dLongitude = PickerGenericLongitude.getValue(_amValues);

    // Update/create location (dictionary)
    var dictLocation = App.Storage.getValue("storLocPreset") as Dictionary?;
    if(dictLocation != null) {
      dictLocation["longitude"] = dLongitude;
    }
    else {
      dictLocation = {"name" => "----", "latitude" => 0.0d, "longitude" => dLongitude};
    }

    // Set property and exit
    App.Storage.setValue("storLocPreset", dictLocation as App.PropertyValueType);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
