// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/error/listener.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r"Don't use more than one case with same value.";

const _details = r'''

**DON'T** use more than one case with same value.

This is usually a typo or changed value of constant.

**GOOD:**
```
const int A = 1;
switch (v) {
  case A:
  case 2:
}
```

**BAD:**
```
const int A = 1;
switch (v) {
  case 1:
  case 2:
  case A:
  case 2:
}
```

''';

String message(String value1, String value2) =>
    'Do not use more than one case with same value ($value1 and $value2)';

class NoDuplicateCaseValues extends LintRule implements NodeLintRule {
  NoDuplicateCaseValues()
      : super(
            name: 'no_duplicate_case_values',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = _Visitor(this);
    registry.addSwitchStatement(this, visitor);
  }

  void reportLintWithDescription(AstNode node, String description) {
    if (node != null) {
      reporter.reportErrorForNode(_LintCode(name, description), node, []);
    }
  }
}

class _LintCode extends LintCode {
  static final registry = <String, LintCode>{};

  factory _LintCode(String name, String message) =>
      registry.putIfAbsent(name + message, () => _LintCode._(name, message));

  _LintCode._(String name, String message) : super(name, message);
}

class _Visitor extends SimpleAstVisitor<void> {
  final NoDuplicateCaseValues rule;

  _Visitor(this.rule);

  @override
  void visitSwitchStatement(SwitchStatement node) {
    final context = node?.expression == null
        ? null
        : resolutionMap
            .bestTypeForExpression(node.expression)
            ?.element
            ?.context;
    if (context == null) {
      return;
    }
    final typeProvider = context.typeProvider;
    final typeSystem = context.typeSystem;
    final declaredVariables = context.declaredVariables;

    final values = HashMap<DartObjectImpl, Expression>(equals: (key1, key2) {
      final equals = key1.isIdentical(typeProvider, key2);
      return equals.isBool && equals.toBoolValue();
    });

    final constantVisitor = ConstantVisitor(
        ConstantEvaluationEngine(typeProvider, declaredVariables,
            typeSystem: typeSystem),
        ErrorReporter(
            AnalysisErrorListener.NULL_LISTENER, rule.reporter.source));

    for (final member in node.members) {
      if (member is SwitchCase) {
        final expression = member.expression;

        final result = expression.accept(constantVisitor);

        if (result == null) {
          continue;
        }

        final duplicateValue = values[result];
        if (duplicateValue != null) {
          rule.reportLintWithDescription(member,
              message(duplicateValue.toString(), expression.toString()));
        } else {
          values[result] = expression;
        }
      }
    }
  }
}
