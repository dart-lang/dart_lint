// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N function_expression_with_incorrect_types`

f(void Function(int a) p) {}
f1(Function p) {}
f2(dynamic p) {}
f3(void Function([int a]) p) {}
f4(void Function({int a}) p) {}
f5(void Function({bool a, bool b, Uri c}) p) {}
f6(void Function(dynamic a) p) {}
f7(void Function(Object? a) p) {}

class MyMap<K, V> {
  void f(void Function(int a) p) {}
  void ff(void Function(K a) p) {}
}

Function(int a)? p;

g1(int a) {}
g2(int? a) {}
g3(num a) {}

m() {
  f((a) {}); // OK
  f((int? a) {}); // LINT
  f((num a) {}); // LINT
  f(g1); // OK
  f(g2); // OK
  f(g3); // OK

  p = (a) {}; // OK
  p = (int? a) {}; // LINT
  p = (num a) {}; // LINT
  p = g1; // OK
  p = g2; // OK
  p = g3; // OK

  f1((int? a) {}); // OK
  f2((int? a) {}); // OK

  // mutation of param
  f((int? a) { a = null; }); // OK
  f((int? a) { () {a = null;}(); }); // OK

  // optional params
  f3(([int? a]) {}); // OK
  f3(([int a = 1]) {}); // OK
  f4(({int? a}) {}); // OK
  f4(({int a = 1}) {}); // OK
  f4(({num? a}) {}); // LINT
  f4(({num a = 1}) {}); // LINT

  // different name
  f((num b) {}); // LINT

  // inversed names
  f5(({bool b, bool a, Uri c}) {}); // OK

  // Object? vs. dynamic
  f6((Object? a) {}); // OK
  f7((dynamic a) {}); // OK
  MyMap().f((int? a) {}); // LINT
  MyMap().ff((Object? a) {}); // LINT
  MyMap<int, String>().ff((int? a) {}); // LINT
}
