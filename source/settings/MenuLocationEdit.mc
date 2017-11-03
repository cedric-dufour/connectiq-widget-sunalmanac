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

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuLocationEdit extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.menuLocationEdit));
    Menu.addItem(Ui.loadResource(Rez.Strings.menuLocationName), :menuLocationName);
    Menu.addItem(Ui.loadResource(Rez.Strings.menuLocationLatitude), :menuLocationLatitude);
    Menu.addItem(Ui.loadResource(Rez.Strings.menuLocationLongitude), :menuLocationLongitude);
    if($.SA_PositionLocation != null) {
      Menu.addItem(Ui.loadResource(Rez.Strings.menuLocationFromGPS), :menuLocationFromGPS);
    }
  }
}

class MenuDelegateLocationEdit extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuLocationName) {
      //Sys.println("DEBUG: MenuDelegateLocationEdit.onMenuItem(:menuLocationName)");
      Ui.pushView(new PickerLocationEditName(), new PickerDelegateLocationEditName(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationLatitude) {
      //Sys.println("DEBUG: MenuDelegateLocationEdit.onMenuItem(:menuLocationLatitude)");
      Ui.pushView(new PickerLocationEditLatitude(), new PickerDelegateLocationEditLatitude(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationLongitude) {
      //Sys.println("DEBUG: MenuDelegateLocationEdit.onMenuItem(:menuLocationLongitude)");
      Ui.pushView(new PickerLocationEditLongitude(), new PickerDelegateLocationEditLongitude(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationFromGPS) {
      //Sys.println("DEBUG: MenuDelegateLocationEdit.onMenuItem(:menuLocationFromGPS)");
      Ui.pushView(new MenuLocationEditFromGPS(), new MenuDelegateLocationEditFromGPS(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
