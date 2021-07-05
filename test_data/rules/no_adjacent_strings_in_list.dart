// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N no_adjacent_strings_in_list`

void bad() {
  var list = [
    'a' // LINT
    'b',
    'c',
  ];

  var list2 = [
    'a' // LINT
    'b'
    'c'
  ];

  var list3 = [
    if (1 == 2) 'a' // LINT
    'b'
  ];

  var list4 = [
    for (var v in []) 'a' // LINT
    'b'
  ];
}

void good() {
  var list = [
    'a' + // OK
    'b',
    'c',
  ];
}
