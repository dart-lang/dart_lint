// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_async_from_sync`

import 'dart:async';

Future fut() => null;

foo1() {
  fut(); //LINT
}

foo2() async {
  fut();

  // ignore: unawaited_futures
  fut();
}

foo3() async {
  await fut();
}

foo4() async {
  var x = fut();
}

foo5() async {
  new Future.delayed(d);
  new Future.delayed(d, bar);
}

foo6() async {
  var map = <String, Future>{};
  map.putIfAbsent('foo', fut());
}

foo7() async {
  _Foo()
    ..doAsync()
    ..doSync();
}

foo8() {
  _Foo()
    ..doAsync() //LINT
    ..doSync();
}

foo9() async {
  _Foo()..futureField = fut();
}

foo10() async {
  _Foo()..futureListField[0] = fut();
}

foo11() async {
  _Foo()..bar.futureField = fut();
}

foo12() async {
  final x = [fut()];
  x..[0] = fut();
}

foo13() {
  _Foo foo = _Foo();
  var x = foo.asyncProperty;
}

class _Bar {
  Future<void> futureField;
}

class _Foo {
  Future<void> futureField;
  List<Future<void>> futureListField;
  _Bar bar;
  Future<void> doAsync() async {}
  void doSync() => null;
  Future<void> get asyncProperty => doAsync();
  List<Future<void>> get futures => [doAsync()];
}
