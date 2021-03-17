// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.6

import 'weak_mode_unnecessary_null_checks/opted_in.dart';

main() {
  // from opted-out
  v1a?.substring(0); // LINT
  v1b?.substring(0); // OK
  v1a?.length; // LINT
  v1b?.length; // OK
  v1a.length; // OK
  v1a != null; // LINT
  v1b != null; // OK
  v1a == null; // LINT
  v1b == null; // OK
  null != v1a; // LINT
  null != v1b; // OK
  null == v1a; // LINT
  null == v1b; // OK
  v1a != ''; // OK
  v1a == ''; // OK

  // from opted-out
  v2?.substring(0); // OK
  v2?.length; // OK
  v2.length; // OK
  v2 != null; // OK
  v2 == null; // OK
  null != v2; // OK
  null == v2; // OK
  v2 != ''; // OK
  v2 == ''; // OK

  f1a()?.length; // LINT
  f1b()?.length; // OK
  f2()?.length; // OK

  C1().p1a?.length; // LINT
  C1().p1b?.length; // OK
  C2().p2?.length; // OK

  C1().m1a()?.length; // LINT
  C1().m1b()?.length; // OK
  C2().m2()?.length; // OK

  dynA?.length; // OK
  dynB?.length; // OK
}

String v2 = '';

String f2() => '';

class C2 {
  String p2 = '';
  String m2() => '';
}
