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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class PickerLocationHeight extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var fHeight = App.Properties.getValue("userLocationHeight");

    // Use settings-specified elevation unit (NB: always use metric units internally)
    fHeight = fHeight * $.SA_oSettings.fUnitElevationConstant;  // ... from meters

    // Split components
    fHeight += 0.5f;
    var iHeight_10e0 = fHeight.toNumber() % 10;
    fHeight = fHeight / 10.0f;
    var iHeight_10e1 = fHeight.toNumber() % 10;
    fHeight = fHeight / 10.0f;
    var iHeight_10e2 = fHeight.toNumber() % 10;
    fHeight = fHeight / 10.0f;
    var iHeight_10e3 = fHeight.toNumber();
    if($.SA_oSettings.iUnitElevation == Sys.UNIT_STATUTE) {
      if(iHeight_10e3 > 29 ) { iHeight_10e3 = 29; }
    }
    else {
      if(iHeight_10e3 > 9 ) { iHeight_10e3 = 9; }
    }

    // Initialize picker
    var oText_10e3 = new Ui.Text({ :text => "x1000", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e2 = new Ui.Text({ :text => "x100", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e1 = new Ui.Text({ :text => "x10", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e0 = new Ui.Text({ :text => "x1", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    Picker.initialize({
      :title => new Ui.Text({ :text => Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.titleLocationHeight), $.SA_oSettings.sUnitElevation]), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryNumber(0, $.SA_oSettings.iUnitElevation == Sys.UNIT_STATUTE ? 29 : 9, null), oText_10e3,
                    new PickerFactoryNumber(0, 9, null), oText_10e2,
                    new PickerFactoryNumber(0, 9, null), oText_10e1,
                    new PickerFactoryNumber(0, 9, null), oText_10e0 ],
      :defaults => [ iHeight_10e3, 0, iHeight_10e2, 0, iHeight_10e1, 0, iHeight_10e0 ]
    });
  }

}

class PickerDelegateLocationHeight extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var fHeight = _amValues[0]*1000.0f + _amValues[2]*100.0f + _amValues[4]*10.0f + _amValues[6];

    // Use settings-specified elevation unit (NB: always use metric units internally)
    fHeight = fHeight / $.SA_oSettings.fUnitElevationConstant;  // ... to meters

    // Set property and exit
    App.Properties.setValue("userLocationHeight", fHeight);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
