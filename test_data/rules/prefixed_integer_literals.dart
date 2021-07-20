// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N prefixed_integer_literals`

var a = 0xFFFFFF00; // OK
var b = 0x00000000; // OK
var c = 0xffffffff; // LINT
var d = 0xABCDEf01; // LINT
var e = 0Xffffffff; // LINT
var f = 0XFFFFFFFF; // LINT
