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
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

//
// CLASS
//

class MyDrawable extends Ui.Drawable {

  //
  // CONSTANTS
  //

  public const DRAW_DIVIDER_HORIZONTAL = 1;
  public const DRAW_DIVIDER_VERTICAL_TOP = 2;
  public const DRAW_DIVIDER_VERTICAL_BOTTOM = 4;


  //
  // VARIABLES
  //

  // Resources
  private var oRezDividerHorizontal as Ui.Drawable;
  private var oRezDividerVerticalTop as Ui.Drawable;
  private var oRezDividerVerticalBottom as Ui.Drawable;

  // Background color
  private var iColorBackground as Number = Gfx.COLOR_BLACK;

  // Dividers
  private var iDividers as Number = 0;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawable"});

    // Resources
    oRezDividerHorizontal = new Rez.Drawables.drawDividerHorizontal();
    oRezDividerVerticalTop = new Rez.Drawables.drawDividerVerticalTop();
    oRezDividerVerticalBottom = new Rez.Drawables.drawDividerVerticalBottom();
  }

  function draw(_oDC) {
    // Draw

    // ... background
    _oDC.setColor(self.iColorBackground, self.iColorBackground);
    _oDC.clear();

    // ... dividers
    if(self.iDividers & self.DRAW_DIVIDER_HORIZONTAL) {
      self.oRezDividerHorizontal.draw(_oDC);
    }
    if(self.iDividers & self.DRAW_DIVIDER_VERTICAL_TOP) {
      self.oRezDividerVerticalTop.draw(_oDC);
    }
    if(self.iDividers & self.DRAW_DIVIDER_VERTICAL_BOTTOM) {
      self.oRezDividerVerticalBottom.draw(_oDC);
    }
  }


  //
  // FUNCTIONS: self
  //

  function setColorBackground(_iColorBackground as Number) as Void {
    self.iColorBackground = _iColorBackground;
  }

  function setDividers(_iDividers as Number) as Void {
    self.iDividers = _iDividers;
  }

}
