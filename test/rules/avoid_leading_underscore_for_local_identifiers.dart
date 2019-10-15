// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_leading_underscore_for_local_identifiers`

var _foo = 0; // OK
const _foo1 = 1; // OK
final _foo2 = 2; // OK

fn() {
  var _foo = 0; // LINT
  const _foo1 = 1; // LINT
  final _foo2 = 2; // LINT
  var foo_value = 0; // OK
  var foo__value = 0; // OK
  var foo__value_ = 0; // OK
}

fn2(_param1) => null; // LINT

fn3(param) => null; // OK

fn4(_) => null; // OK

fn5(param_value) => null; // OK

class TestClass {
  var _foo = 0; // OK
  static const _foo1 = 1; // OK
  final _foo2 = 2; // OK

  foo() {
    var _foo = 0; // LINT
    const _foo1 = 1; // LINT
    final _foo2 = 2; // LINT
    var foo_value = 0; // OK
    var foo__value = 0; // OK
    var foo__value_ = 0; // OK

    for(var _x in [1,2,3]) {} // LINT
    for(var x in [1,2,3]) {} // OK

    [1,2,3].forEach((_x) => fn()); // LINT
    [1,2,3].forEach((x) => fn()); // OK
    [1,2,3].forEach((_) => fn()); // OK

    try {}
    catch(_error) {} // LINT

    try {}
    catch(error) { // OK
    }

    try {}
    catch(error, _stackTrace) {} // LINT

    try {}
    catch(error, stackTrace) { // OK
    }
  }

  foo1(_param) => null; // LINT

  foo2(param) => null; // OK

  foo3(_) => null; // OK

  foo4(param_value) => null; // OK

  foo5(param, [_positional]) => null; // LINT

  foo6(param, [positional]) => null; // OK

  foo7(param, {_named}) => null; // OK
}
