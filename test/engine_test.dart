// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart' show AstNode, AstVisitor;
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/lint/analysis.dart';
import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer/src/lint/linter.dart' hide CamelCaseString;
import 'package:analyzer/src/lint/pub.dart';
import 'package:analyzer/src/string_source.dart' show StringSource;
import 'package:cli_util/cli_util.dart' show getSdkPath;
import 'package:linter/src/utils.dart';
import 'package:test/test.dart';

import '../bin/linter.dart' as dartlint;
import 'mocks.dart';
import 'rule_test.dart' show ruleDir;

main() {
  defineLinterEngineTests();
}

/// Linter engine tests
void defineLinterEngineTests() {
  group('engine', () {
    group('reporter', () {
      _test(String label, String expected, report(PrintingReporter r)) {
        test(label, () {
          String msg;
          final reporter = PrintingReporter((m) => msg = m);
          report(reporter);
          expect(msg, expected);
        });
      }

      _test('exception', 'EXCEPTION: LinterException: foo',
          (r) => r.exception(const LinterException('foo')));
      _test('logError', 'ERROR: foo', (r) => r.logError('foo'));
      _test('logInformation', 'INFO: foo', (r) => r.logInformation('foo'));
      _test('warn', 'WARN: foo', (r) => r.warn('foo'));
    });

    group('exceptions', () {
      test('message', () {
        expect(const LinterException('foo').message, 'foo');
      });
      test('toString', () {
        expect(const LinterException().toString(), 'LinterException');
        expect(const LinterException('foo').toString(), 'LinterException: foo');
      });
    });

    group('analysis logger', () {
      final currentErr = errorSink;
      final currentOut = outSink;
      final errCollector = CollectingSink();
      final outCollector = CollectingSink();
      final logger = StdLogger();
      setUp(() {
        errorSink = errCollector;
        outSink = outCollector;
      });
      tearDown(() {
        errorSink = currentErr;
        outSink = currentOut;
        errCollector.buffer.clear();
        outCollector.buffer.clear();
      });
      test('logError', () {
        logger.logError('logError');
        expect(errCollector.trim(), 'logError');
      });
      test('logInformation', () {
        logger.logInformation('logInformation');
        expect(outCollector.trim(), 'logInformation');
      });
    });

    group('camel case', () {
      test('humanize', () {
        expect(CamelCaseString('FooBar').humanized, 'Foo Bar');
        expect(CamelCaseString('Foo').humanized, 'Foo');
      });
      test('validation', () {
        expect(() => CamelCaseString('foo'),
            throwsA(const TypeMatcher<ArgumentError>()));
      });
      test('toString', () {
        expect(CamelCaseString('FooBar').toString(), 'FooBar');
      });
    });

    group('groups', () {
      test('factory', () {
        expect(Group('style').custom, isFalse);
        expect(Group('pub').custom, isFalse);
        expect(Group('errors').custom, isFalse);
        expect(Group('Kustom').custom, isTrue);
      });
      test('builtins', () {
        expect(Group.builtin.contains(Group.style), isTrue);
        expect(Group.builtin.contains(Group.errors), isTrue);
        expect(Group.builtin.contains(Group.pub), isTrue);
      });
    });

    group('lint driver', () {
      test('pubspec', () {
        bool visited;
        final options = LinterOptions([MockLinter((n) => visited = true)])
          ..previewDart2 = true;
        SourceLinter(options).lintPubspecSource(contents: 'name: foo_bar');
        expect(visited, isTrue);
      });
      test('error collecting', () {
        final error = AnalysisError(StringSource('foo', ''), 0, 0,
            const LintCode('MockLint', 'This is a test...'));
        final linter = SourceLinter(LinterOptions([]))..onError(error);
        expect(linter.errors.contains(error), isTrue);
      });
      test('pubspec visitor error handling', () {
        final visitor = MockPubVisitor();
        final rule = MockRule()..pubspecVisitor = visitor;

        final reporter = MockReporter();
        SourceLinter(LinterOptions([rule]), reporter: reporter)
          ..lintPubspecSource(contents: 'author: foo');
        expect(reporter.exceptions, hasLength(1));
      });
    });

    group('main', () {
      setUp(() {
        exitCode = 0;
        errorSink = MockIOSink();
      });
      tearDown(() {
        exitCode = 0;
        errorSink = stderr;
      });
      test('smoke', () async {
        final firstRuleTest =
            Directory(ruleDir).listSync().firstWhere(isDartFile);
        await dartlint.main([firstRuleTest.path]);
        expect(dartlint.isLinterErrorCode(exitCode), isFalse);
      });
      test('no args', () async {
        await dartlint.main([]);
        expect(exitCode, dartlint.unableToProcessExitCode);
      });
      test('help', () async {
        await dartlint.main(['-h']);
        // Help shouldn't generate an error code
        expect(dartlint.isLinterErrorCode(exitCode), isFalse);
      });
      test('unknown arg', () async {
        await dartlint.main(['-XXXXX']);
        expect(exitCode, dartlint.unableToProcessExitCode);
      });
      test('custom sdk path', () async {
        // Smoke test to ensure a custom sdk path doesn't sink the ship
        final firstRuleTest =
            Directory(ruleDir).listSync().firstWhere(isDartFile);
        final sdk = getSdkPath();
        await dartlint.main(['--dart-sdk', sdk, firstRuleTest.path]);
        expect(dartlint.isLinterErrorCode(exitCode), isFalse);
      });
      test('custom package root', () async {
        // Smoke test to ensure a custom package root doesn't sink the ship
        final firstRuleTest =
            Directory(ruleDir).listSync().firstWhere(isDartFile);
        final packageDir = Directory('.').path;
        await dartlint.main(['--package-root', packageDir, firstRuleTest.path]);
        expect(dartlint.isLinterErrorCode(exitCode), isFalse);
      });
    });

    group('dtos', () {
      group('hyperlink', () {
        test('html', () {
          const link = Hyperlink('dart', 'http://dartlang.org');
          expect(link.html, '<a href="http://dartlang.org">dart</a>');
        });
        test('html - strong', () {
          const link = Hyperlink('dart', 'http://dartlang.org', bold: true);
          expect(link.html,
              '<a href="http://dartlang.org"><strong>dart</strong></a>');
        });
      });

      group('rule', () {
        test('comparing', () {
          final r1 = MockLintRule('Bar', Group('acme'));
          final r2 = MockLintRule('Foo', Group('acme'));
          expect(r1.compareTo(r2), -1);
          final r3 = MockLintRule('Bar', Group('acme'));
          final r4 = MockLintRule('Bar', Group('woody'));
          expect(r3.compareTo(r4), -1);
        });
      });
      group('maturity', () {
        test('comparing', () {
          // Custom
          final m1 = Maturity('foo', ordinal: 0);
          final m2 = Maturity('bar', ordinal: 1);
          expect(m1.compareTo(m2), -1);
          // Builtin
          expect(Maturity.stable.compareTo(Maturity.experimental), -1);
        });
      });
    });
  });
}

typedef NodeVisitor(node);

typedef dynamic /* AstVisitor, PubSpecVisitor*/ VisitorCallback();

class MockLinter extends LintRule {
  VisitorCallback visitorCallback;

  MockLinter([NodeVisitor v])
      : super(
            name: 'MockLint',
            group: Group.style,
            description: 'Desc',
            details: 'And so on...') {
    visitorCallback = () => MockVisitor(v);
  }

  @override
  PubspecVisitor getPubspecVisitor() => visitorCallback();

  @override
  AstVisitor getVisitor() => visitorCallback();
}

class MockLintRule extends LintRule {
  MockLintRule(String name, Group group) : super(name: name, group: group);

  @override
  AstVisitor getVisitor() => MockVisitor(null);
}

class MockVisitor extends GeneralizingAstVisitor with PubspecVisitor {
  final nodeVisitor;

  MockVisitor(this.nodeVisitor);

  @override
  visitNode(AstNode node) {
    if (nodeVisitor != null) {
      nodeVisitor(node);
    }
  }

  @override
  visitPackageName(PSEntry node) {
    if (nodeVisitor != null) {
      nodeVisitor(node);
    }
  }
}
