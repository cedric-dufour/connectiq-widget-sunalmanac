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
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class MenuLocationEditFromGPS extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.menuConfirm));
    Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.menuLocationFromGPS)]), :confirm);
  }

}

class MenuDelegateLocationEditFromGPS extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :confirm and $.SA_PositionLocation != null) {
      // Update location (dictionary) with current location
      var adLocation = $.SA_PositionLocation.toDegrees();
      var dictLocation = App.getApp().getProperty("storLocPreset");
      if(dictLocation == null) {
        dictLocation = { "name" => "----", "latitude" => 0.0f, "longitude" => 0.0f };
      }
      dictLocation["name"] = Ui.loadResource(Rez.Strings.valueLocationGPS);
      dictLocation["latitude"] = adLocation[0];
      dictLocation["longitude"] = adLocation[1];
      App.getApp().setProperty("storLocPreset", dictLocation);
    }
  }

}
