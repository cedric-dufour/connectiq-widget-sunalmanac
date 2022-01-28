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

class PickerLocationEditName extends Ui.TextPicker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var dictLocation = App.Storage.getValue("storLocPreset") as Dictionary?;

    // Initialize picker
    TextPicker.initialize(dictLocation != null ? dictLocation["name"] as String : "");
  }

}

class PickerLocationEditNameDelegate extends Ui.TextPickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    TextPickerDelegate.initialize();
  }

  function onTextEntered(_sText, _bChanged) {
    // Update/create location (dictionary)
    var dictLocation = App.Storage.getValue("storLocPreset") as Dictionary?;
    if(dictLocation != null) {
      dictLocation["name"] = _sText;
    }
    else {
      dictLocation = {"name" => _sText, "latitude" => 0.0d, "longitude" => 0.0d};
    }

    // Set property and exit
    App.Storage.setValue("storLocPreset", dictLocation as App.PropertyValueType);
    return true;
  }

  function onCancel() {
    // Exit
    return true;
  }

}
