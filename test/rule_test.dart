// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/src/services/lint.dart' as lint_service;
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/ast.dart';
import 'package:linter/src/formatter.dart';
import 'package:linter/src/rules.dart';
import 'package:linter/src/rules/implementation_imports.dart';
import 'package:linter/src/rules/package_prefixed_library_names.dart';
import 'package:linter/src/version.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'rules/experiments/experiments.dart';
import 'util/rule_test_utils.dart';
import 'util/test_utils.dart';

main() {
  defineSanityTests();
  defineRuleTests();
  defineRuleUnitTests();
}

final String ruleDir = p.join('test', 'rules');
final String testConfigDir = p.join('test', 'configs');

/// Rule tests
defineRuleTests() {
  group('rule', () {
    group('dart', () {
      // Rule tests run with default analysis options.
      testRules(ruleDir, analysisOptions: null);

      // Rule tests run against specific configurations.
      for (var entry in Directory(testConfigDir).listSync()) {
        if (entry is! Directory) continue;
        group('(config: ${p.basename(entry.path)})', () {
          var analysisOptionsFile =
              File(p.join(entry.path, 'analysis_options.yaml'));
          var analysisOptions = analysisOptionsFile.readAsStringSync();
          testRules(ruleDir, analysisOptions: analysisOptions);
        });
      }
    });
    group('experiments', () {
      registerLintRuleExperiments();

      for (var entry in Directory(p.join(ruleDir, 'experiments')).listSync()) {
        if (entry is! Directory) continue;
        var analysisOptionsFile =
            File(p.join(entry.path, 'analysis_options.yaml'));
        var analysisOptions = analysisOptionsFile.readAsStringSync();
        var ruleName = p.basename(entry.path);
        var testFile = File(p.join(entry.path, '$ruleName.dart'));
        testRule(p.basename(ruleName), testFile,
            analysisOptions: analysisOptions);
      }
    });

    group('pub', () {
      for (var entry in Directory(p.join(ruleDir, 'pub')).listSync()) {
        if (entry is Directory) {
          for (var child in entry.listSync()) {
            if (child is File && isPubspecFile(child)) {
              var ruleName = p.basename(entry.path);
              testRule(ruleName, child);
            }
          }
        }
      }
    });
    group('format', () {
      registerLintRules();
      for (LintRule rule in Registry.ruleRegistry.rules) {
        test('`${rule.name}` description', () {
          expect(rule.description.endsWith('.'), isTrue,
              reason:
                  "Rule description for ${rule.name} should end with a '.'");
        });
      }
    });
  });
}

defineRuleUnitTests() {
  group('uris', () {
    group('isPackage', () {
      [
        Uri.parse('package:foo/src/bar.dart'),
        Uri.parse('package:foo/src/baz/bar.dart')
      ]..forEach((uri) {
          test(uri.toString(), () {
            expect(isPackage(uri), isTrue);
          });
        });
      [
        Uri.parse('foo/bar.dart'),
        Uri.parse('src/bar.dart'),
        Uri.parse('dart:async')
      ]..forEach((uri) {
          test(uri.toString(), () {
            expect(isPackage(uri), isFalse);
          });
        });
    });

    group('samePackage', () {
      test('identity', () {
        expect(
            samePackage(Uri.parse('package:foo/src/bar.dart'),
                Uri.parse('package:foo/src/bar.dart')),
            isTrue);
      });
      test('foo/bar.dart', () {
        expect(
            samePackage(Uri.parse('package:foo/src/bar.dart'),
                Uri.parse('package:foo/bar.dart')),
            isTrue);
      });
    });

    group('implementation', () {
      [
        Uri.parse('package:foo/src/bar.dart'),
        Uri.parse('package:foo/src/baz/bar.dart')
      ]..forEach((uri) {
          test(uri.toString(), () {
            expect(isImplementation(uri), isTrue);
          });
        });
      [Uri.parse('package:foo/bar.dart'), Uri.parse('src/bar.dart')]
        ..forEach((uri) {
          test(uri.toString(), () {
            expect(isImplementation(uri), isFalse);
          });
        });
    });
  });

  group('names', () {
    group('keywords', () {
      var good = ['class', 'if', 'assert', 'catch', 'import'];
      testEach(good, isKeyWord, isTrue);
      var bad = ['_class', 'iff', 'assert_', 'Catch'];
      testEach(bad, isKeyWord, isFalse);
    });
    group('identifiers', () {
      var good = [
        'foo',
        '_if',
        '_',
        'f2',
        'fooBar',
        'foo_bar',
        '\$foo',
        'foo\$Bar',
        'foo\$'
      ];
      testEach(good, isValidDartIdentifier, isTrue);
      var bad = ['if', '42', '3', '2f'];
      testEach(bad, isValidDartIdentifier, isFalse);
    });
    group('libary_name_prefixes', () {
      testEach(
          Iterable<List<String>> values, dynamic f(List<String> s), Matcher m) {
        values.forEach((s) => test('${s[3]}', () => expect(f(s), m)));
      }

      bool isGoodPrefx(List<String> v) => matchesOrIsPrefixedBy(
          v[3],
          Analyzer.facade.createLibraryNamePrefix(
              libraryPath: v[0], projectRoot: v[1], packageName: v[2]));

      var good = [
        ['/u/b/c/lib/src/a.dart', '/u/b/c', 'acme', 'acme.src.a'],
        ['/u/b/c/lib/a.dart', '/u/b/c', 'acme', 'acme.a'],
        ['/u/b/c/test/a.dart', '/u/b/c', 'acme', 'acme.test.a'],
        ['/u/b/c/test/data/a.dart', '/u/b/c', 'acme', 'acme.test.data.a'],
        ['/u/b/c/lib/acme.dart', '/u/b/c', 'acme', 'acme']
      ];
      testEach(good, isGoodPrefx, isTrue);

      var bad = [
        ['/u/b/c/lib/src/a.dart', '/u/b/c', 'acme', 'acme.a'],
        ['/u/b/c/lib/a.dart', '/u/b/c', 'acme', 'wrk.acme.a'],
        ['/u/b/c/test/a.dart', '/u/b/c', 'acme', 'acme.a'],
        ['/u/b/c/test/data/a.dart', '/u/b/c', 'acme', 'acme.test.a']
      ];
      testEach(bad, isGoodPrefx, isFalse);
    });
  });
}

/// Test framework sanity
defineSanityTests() {
  group('test framework', () {
    group('annotation', () {
      test('extraction', () {
        expect(extractAnnotation('int x; // LINT [1:3]'), isNotNull);
        expect(extractAnnotation('int x; //LINT'), isNotNull);
        expect(extractAnnotation('int x; // OK'), isNull);
        expect(extractAnnotation('int x;'), isNull);
        expect(extractAnnotation('dynamic x; // LINT dynamic is bad').message,
            'dynamic is bad');
        expect(
            extractAnnotation('dynamic x; // LINT [1:3] dynamic is bad')
                .message,
            'dynamic is bad');
        expect(
            extractAnnotation('dynamic x; // LINT [1:3] dynamic is bad').column,
            1);
        expect(
            extractAnnotation('dynamic x; // LINT [1:3] dynamic is bad').length,
            3);
        expect(extractAnnotation('dynamic x; //LINT').message, isNull);
        expect(extractAnnotation('dynamic x; //LINT ').message, isNull);
        // Commented out lines shouldn't get linted.
        expect(extractAnnotation('// dynamic x; //LINT '), isNull);
      });
    });
    test('equality', () {
      expect(Annotation('Actual message (to be ignored)', ErrorType.LINT, 1),
          matchesAnnotation(null, ErrorType.LINT, 1));
      expect(Annotation('Message', ErrorType.LINT, 1),
          matchesAnnotation('Message', ErrorType.LINT, 1));
    });
    test('inequality', () {
      expect(
          () => expect(Annotation('Message', ErrorType.LINT, 1),
              matchesAnnotation('Message', ErrorType.HINT, 1)),
          throwsA(TypeMatcher<TestFailure>()));
      expect(
          () => expect(Annotation('Message', ErrorType.LINT, 1),
              matchesAnnotation('Message2', ErrorType.LINT, 1)),
          throwsA(TypeMatcher<TestFailure>()));
      expect(
          () => expect(Annotation('Message', ErrorType.LINT, 1),
              matchesAnnotation('Message', ErrorType.LINT, 2)),
          throwsA(TypeMatcher<TestFailure>()));
    });
  });

  group('reporting', () {
    //https://github.com/dart-lang/linter/issues/193
    group('ignore synthetic nodes', () {
      String path = p.join('test', '_data', 'synthetic', 'synthetic.dart');
      File file = File(path);
      testRule('non_constant_identifier_names', file);
    });
  });

  test('linter version caching', () {
    registerLintRules();
    expect(lint_service.linterVersion, version);
  });
}

/// Handy for debugging.
defineSoloRuleTest(String ruleToTest) {
  for (var entry in Directory(ruleDir).listSync()) {
    if (entry is! File || !isDartFile(entry)) continue;
    var ruleName = p.basenameWithoutExtension(entry.path);
    if (ruleName == ruleToTest) {
      testRule(ruleName, entry as File);
    }
  }
}

AnnotationMatcher matchesAnnotation(
        String message, ErrorType type, int lineNumber) =>
    AnnotationMatcher(Annotation(message, type, lineNumber));

testRules(String ruleDir, {String analysisOptions}) {
  for (var entry in Directory(ruleDir).listSync()) {
    if (entry is! File || !isDartFile(entry)) continue;
    var ruleName = p.basenameWithoutExtension(entry.path);
    if (ruleName == 'unnecessary_getters') {
<<<<<<< HEAD
      // Disabled pending fix: https://github.com/dart-lang/linter/issues/23
      continue;
    }
=======
      // Skip this test while this rule is not registered.
      // https://github.com/dart-lang/linter/issues/23
      continue;
    }

>>>>>>> Move some of rule_test into a util directory
    testRule(ruleName, entry as File,
        debug: true, analysisOptions: analysisOptions);
  }
}

testRule(String ruleName, File file,
    {bool debug = false, String analysisOptions}) {
  registerLintRules();

  test('$ruleName', () async {
    if (!file.existsSync()) {
      throw Exception('No rule found defined at: ${file.path}');
    }

    var expected = <AnnotationMatcher>[];

    int lineNumber = 1;
    for (var line in file.readAsLinesSync()) {
      var annotation = extractAnnotation(line);
      if (annotation != null) {
        annotation.lineNumber = lineNumber;
        expected.add(AnnotationMatcher(annotation));
      }
      ++lineNumber;
    }

    DartLinter driver =
        buildDriver(ruleName, file, analysisOptions: analysisOptions);

    Iterable<AnalysisErrorInfo> lints = await driver.lintFiles([file]);

    List<Annotation> actual = [];
    lints.forEach((AnalysisErrorInfo info) {
      info.errors.forEach((AnalysisError error) {
        if (error.errorCode.type == ErrorType.LINT) {
          actual.add(Annotation.forError(error, info.lineInfo));
        }
      });
    });
    actual.sort();
    try {
      expect(actual, unorderedMatches(expected));
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      if (debug) {
        // Dump results for debugging purposes.

        // AST.
        Spelunker(file.absolute.path).spelunk();
        print('');
        // Lints.
        ResultReporter(lints)..write();
      }

      // Rethrow and fail.
      rethrow;
    }
  });
}

/// A [LintFilter] that filters no lint.
class NoFilter implements LintFilter {
  @override
  bool filter(AnalysisError lint) => false;
}

/// A [DetailedReporter] that filters no lint.
class ResultReporter extends DetailedReporter {
  ResultReporter(Iterable<AnalysisErrorInfo> errors)
      : super(errors, NoFilter(), stdout);
}
