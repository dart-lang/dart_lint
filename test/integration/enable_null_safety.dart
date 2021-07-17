// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_constants.dart';

void main() {
  group('enable_null_safety', () {
    var currentOut = outSink;
    var collectingOut = CollectingSink();
    setUp(() => outSink = collectingOut);
    tearDown(() {
      collectingOut.buffer.clear();
      outSink = currentOut;
    });
    test('enable null safety', () async {
      await cli.runLinter([
        '$integrationTestDir/enable_null_safety',
        '--rules=enable_null_safety',
      ], LinterOptions());
      expect(
          collectingOut.trim(), contains('3 files analyzed, 2 issues found'));
      expect(collectingOut.trim(), contains('Do use sound null safety'));
    });
  });
}
