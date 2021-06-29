// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Missing whitespace between adjacent strings.';

const _details = r'''

Add a trailing whitespace to prevent missing whitespace between adjacent
strings.

With long text split accross adjacent strings it's easy to forget a whitespace
between strings.

**BAD:**
```dart
var s =
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed'
  'do eiusmod tempor incididunt ut labore et dolore magna';
```

**GOOD:**
```dart
var s =
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed '
  'do eiusmod tempor incididunt ut labore et dolore magna';
```

''';

class MissingWhitespaceBetweenAdjacentStrings extends LintRule
    implements NodeLintRule {
  MissingWhitespaceBetweenAdjacentStrings()
      : super(
            name: 'missing_whitespace_between_adjacent_strings',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    // Skip strings passed to `RegExp()` or any method named `matches`.
    var parent = node.parent;
    if (parent is ArgumentList) {
      var parentParent = parent.parent;
      if (_isRegExpInstanceCreation(parentParent) ||
          parentParent is MethodInvocation &&
              parentParent.realTarget == null &&
              const ['RegExp', 'matches']
                  .contains(parentParent.methodName.name)) {
        return;
      }
    }

    for (var i = 0; i < node.strings.length - 1; i++) {
      var current = node.strings[i];
      var next = node.strings[i + 1];
      if (current.endsWithWhitespace || next.startsWithWhitespace) {
        continue;
      }
      if (!current.hasWhitespace) {
        continue;
      }
      rule.reportLint(current);
    }

    return super.visitAdjacentStrings(node);
  }

  static bool _isRegExpInstanceCreation(AstNode? node) {
    if (node is InstanceCreationExpression) {
      var constructorElement = node.constructorName.staticElement;
      return constructorElement?.enclosingElement.name == 'RegExp';
    }
    return false;
  }
}

extension on StringLiteral {
  /// Returns whether this ends with whitespace, where any
  /// [InterpolationExpression] counts as whitespace.
  bool get endsWithWhitespace {
    if (this is SimpleStringLiteral) {
      return (this as SimpleStringLiteral).value.endsWithWhitespace;
    } else if (this is StringInterpolation) {
      var last = (this as StringInterpolation).elements.last;
      if (last is InterpolationExpression) {
        // Treat an interpolation expression as containing whitespace so as to
        // avoid over-reporting strings that end with an interpolation
        // expression.
        return true;
      } else if (last is InterpolationString) {
        return last.value.endsWithWhitespace;
      }
    }
    throw ArgumentError(
        'Expected SimpleStringLiteral or StringInterpolation, got $runtimeType');
  }

  /// Returns whether this starts with whitespace, where any
  /// [InterpolationExpression] counts as whitespace.
  bool get startsWithWhitespace {
    if (this is SimpleStringLiteral) {
      return (this as SimpleStringLiteral).value.startsWithWhitespace;
    } else if (this is StringInterpolation) {
      var first = (this as StringInterpolation).elements.first;
      if (first is InterpolationExpression) {
        // Treat an interpolation expression as containing whitespace so as to
        // avoid over-reporting strings that start with an interpolation
        // expression.
        return true;
      } else if (first is InterpolationString) {
        return first.value.endsWithWhitespace;
      }
    }
    throw ArgumentError(
        'Expected SimpleStringLiteral or StringInterpolation, got $runtimeType');
  }

  /// Returns whether this contains whitespace, where any
  /// [InterpolationExpression] does not count as whitespace.
  bool get hasWhitespace {
    if (this is SimpleStringLiteral) {
      return (this as SimpleStringLiteral).value.hasWhitespace;
    } else if (this is StringInterpolation) {
      return (this as StringInterpolation)
          .elements
          .any((e) => e is InterpolationString && e.value.hasWhitespace);
    }
    return false;
  }
}

extension on String {
  bool get hasWhitespace => whitespaces.any(contains);
  bool get endsWithWhitespace => whitespaces.any(endsWith);
  bool get startsWithWhitespace => whitespaces.any(startsWith);

  static const whitespaces = [' ', '\n', '\r', '\t'];
}
