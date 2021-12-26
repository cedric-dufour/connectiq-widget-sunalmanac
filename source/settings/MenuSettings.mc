// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Sun Almanac (SunAlmanac)
// Copyright (C) 2017-2021 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuSettings extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettings) as String);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsLocation) as String, :menuSettingsLocation);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsDateTime) as String, :menuSettingsDateTime);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleBackgroundColor) as String, :menuBackgroundColor);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAbout) as String, :menuSettingsAbout);
  }

}

class MenuSettingsDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSettingsLocation) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new MenuSettingsLocation(),
                  new MenuSettingsLocationDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsDateTime) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsDateTime)");
      Ui.pushView(new MenuSettingsDateTime(),
                  new MenuSettingsDateTimeDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuBackgroundColor) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuBackgroundColor)");
      Ui.pushView(new PickerBackgroundColor(),
                  new PickerBackgroundColorDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsAbout) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsAbout)");
      Ui.pushView(new MenuSettingsAbout(),
                  new MenuSettingsAboutDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
  }

}
