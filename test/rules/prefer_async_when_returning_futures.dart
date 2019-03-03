// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_async_when_returning_futures`

import 'dart:async';

Future<int> f1() { // LINT
  return new Future<int>.value(42);
}

Future<int> f2() async { // OK
  return 42;
}

f3() { // OK
  return 42;
}

f4() { // OK
  return Future<int>.value(42);
}

abstract class C {
  Future<int> m1() { // LINT
    return new Future<int>.value(42);
  }

  Future<int> m2() async { // OK
    return 42;
  }

  Future<int> m3(); // OK

  m4(); // OK

  m5() { // OK
    return Future<int>.value(42);
  }

  Future<int> get g1 { // LINT
    return Future<int>.value(42);
  }
  
  Future<int> get g2 async { // OK
    return 42;
  }
}

void main() {
  Future<int> c1() => Future.value(42); // LINT
  Future<int> c2() async => 42; // OK
}