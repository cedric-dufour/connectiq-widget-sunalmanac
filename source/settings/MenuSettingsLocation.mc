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

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuSettingsLocation extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  (:memory_large)
  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsLocation));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationAuto), :menuLocationAuto);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationLoad), :menuLocationLoad);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationEdit), :menuLocationEdit);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationSave), :menuLocationSave);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationDelete), :menuLocationDelete);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationHeight), :menuLocationHeight);
  }

  (:memory_small)
  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsLocation));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationAuto), :menuLocationAuto);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationEdit), :menuLocationEdit);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleLocationHeight), :menuLocationHeight);
  }

}

class MenuSettingsLocationDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  (:memory_large)
  function onMenuItem(item) {
    if (item == :menuLocationAuto) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationAuto(), new PickerLocationAutoDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationLoad) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuLocationLoad)");
      Ui.pushView(new PickerLocationLoad(), new PickerLocationLoadDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationEdit) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuLocationEdit)");
      Ui.pushView(new MenuLocationEdit(), new MenuLocationEditDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationSave) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuLocationSave)");
      Ui.pushView(new PickerLocationSave(), new PickerLocationSaveDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationDelete) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuLocationDelete)");
      Ui.pushView(new PickerLocationDelete(), new PickerLocationDeleteDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationHeight) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationHeight(), new PickerLocationHeightDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

  (:memory_small)
  function onMenuItem(item) {
    if (item == :menuLocationAuto) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationAuto(), new PickerLocationAutoDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationEdit) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuLocationEdit)");
      Ui.pushView(new MenuLocationEdit(), new MenuLocationEditDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLocationHeight) {
      //Sys.println("DEBUG: MenuSettingsLocationDelegate.onMenuItem(:menuSettingsLocation)");
      Ui.pushView(new PickerLocationHeight(), new PickerLocationHeightDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
