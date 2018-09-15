// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Lang;

module LangUtils {

  // Deep-copy the given object
  function copy(_oObject) {
    var oCopy = null;
    if(_oObject instanceof Lang.Array) {
      var iSize = _oObject.size();
      oCopy = new [iSize];
      for(var i=0; i<iSize; i++) {
        oCopy[i] = LangUtils.copy(_oObject[i]);
      }
    }
    else if(_oObject instanceof Lang.Dictionary) {
      var amKeys = _oObject.keys();
      var iSize = amKeys.size();
      oCopy = {};
      for(var i=0; i<iSize; i++) {
        var mKey = amKeys[i];
        oCopy.put(mKey, LangUtils.copy(_oObject.get(mKey)));
      }
    }
    else if(_oObject instanceof Lang.Exception) {
      throw new Lang.UnexpectedTypeException();
    }
    else if(_oObject instanceof Lang.Method) {
      throw new Lang.UnexpectedTypeException();
    }
    else {
      oCopy = _oObject;
    }
    return oCopy;
  }

}
