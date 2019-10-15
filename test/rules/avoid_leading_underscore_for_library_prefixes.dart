// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_leading_underscore_for_library_prefixes`

import 'dart:async' as _async; // LINT
import 'dart:convert' as _convert; // LINT
import 'dart:core' as dart_core; // OK
import 'dart:math' as dart_math; // OK
