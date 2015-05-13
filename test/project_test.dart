// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.test.project;

import 'dart:io';

import 'package:linter/src/project.dart';
import 'package:test/test.dart';

void main() {
  group('cwd', () {
    var project = new DartProject(null, null);
    test('name', () {
      expect(project.name, equals('linter'));
    });
    test('spec', () {
      expect(project.pubspec, isNotNull);
    });
    test('root', () {
      expect(project.root.path, equals(Directory.current.path));
    });
  });
  group('p1', () {
    var project =
        new DartProject(null, null, dir: new Directory('test/_data/p1'));
    test('name', () {
      expect(project.name, equals('p1'));
    });
    test('spec', () {
      expect(project.pubspec, isNotNull);
      expect(project.pubspec.name.value.text, equals('p1'));
    });
    test('root', () {
      expect(project.root.path, equals('test/_data/p1'));
    });
  });
  group('no pubspec', () {
    var project =
        new DartProject(null, null, dir: new Directory('test/_data/p1/src'));
    test('name', () {
      expect(project.name, equals('src'));
    });
    test('spec', () {
      expect(project.pubspec, isNull);
    });
    test('root', () {
      expect(project.root.path, equals('test/_data/p1/src'));
    });
  });
}
