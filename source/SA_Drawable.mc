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

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

//
// CLASS
//

class SA_Drawable extends Ui.Drawable {

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
  private var oRezDividerHorizontal;
  private var oRezDividerVerticalTop;
  private var oRezDividerVerticalBottom;

  // Background color
  private var iColorBackground;

  // Dividers
  private var iDividers;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({ :identifier => "SA_Drawable" });

    // Resources
    self.oRezDividerHorizontal = new Rez.Drawables.drawDividerHorizontal();
    self.oRezDividerVerticalTop = new Rez.Drawables.drawDividerVerticalTop();
    self.oRezDividerVerticalBottom = new Rez.Drawables.drawDividerVerticalBottom();

    // Background color
    self.iColorBackground = Gfx.COLOR_BLACK;

    // Dividers
    self.iDividers = 0;
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

  function setColorBackground(_iColorBackground) {
    self.iColorBackground = _iColorBackground;
  }

  function setDividers(_iDividers) {
    self.iDividers = _iDividers;
  }

}
