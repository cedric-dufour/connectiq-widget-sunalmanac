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

// Menu: resources/menus/menuSettingsLocation.xml

class MenuDelegateSettingsLocation extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuLocationAuto) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationAuto(), new PickerDelegateLocationAuto(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationLoad) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuLocationLoad)");
      Ui.pushView(new PickerLocationLoad(), new PickerDelegateLocationLoad(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationEdit) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuLocationEdit)");
      Ui.pushView(new MenuLocationEdit(), new MenuDelegateLocationEdit(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationSave) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuLocationSave)");
      Ui.pushView(new PickerLocationSave(), new PickerDelegateLocationSave(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationDelete) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuLocationDelete)");
      Ui.pushView(new PickerLocationDelete(), new PickerDelegateLocationDelete(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationHeight) {
      //Sys.println("DEBUG: MenuDelegateSettingsLocation.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationHeight(), new PickerDelegateLocationHeight(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
