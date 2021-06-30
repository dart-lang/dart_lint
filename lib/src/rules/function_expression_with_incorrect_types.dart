// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

import '../analyzer.dart';

const _desc =
    r'Use the parameter types expected by the target in function expression.';

const _details = r'''

Use the parameter types expected by the target in function expression.

**BAD:**
```
f(void Function(int a) p) {}

f((int? a) {});
f((num a) {});
```

**GOOD:**
```
f(void Function(int a) p) {}

f((a) {});
f((int a) {});
```

''';

class FunctionExpressionWithIncorrectTypes extends LintRule
    implements NodeLintRule {
  FunctionExpressionWithIncorrectTypes()
      : super(
            name: 'function_expression_with_incorrect_types',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addFunctionExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitFunctionExpression(FunctionExpression node) {
    var currentType = node.staticType;
    if (currentType is! FunctionType) return;

    var parameterElement = node
        .thisOrAncestorMatching<Expression>(
            (e) => e.parent is! ParenthesizedExpression)
        ?.staticParameterElement;
    if (parameterElement == null) return;

    var expectedType = parameterElement.type;
    if (expectedType is! FunctionType) return;

    // too hard to check cross nullability
    var currentNullability = context.isEnabled(Feature.non_nullable);
    var expectedNullability =
        (parameterElement.library ?? parameterElement.declaration.library)
            ?.featureSet
            .isEnabled(Feature.non_nullable);
    if (expectedNullability == null ||
        currentNullability ^ expectedNullability) {
      return;
    }

    // check type of each parameters
    var currentParams = currentType.parameters;
    var expectedParams = expectedType.parameters;
    for (var i = 0; i < currentParams.length; i++) {
      var currentParam = currentParams[i];
      // if param is mutated, no lint
      if (node.body.isPotentiallyMutatedInScope(currentParam) ||
          node.body.isPotentiallyMutatedInClosure(currentParam)) {
        continue;
      }

      // if param is not found on target, no lint
      var expectedParam = currentParam.isPositional
          ? expectedParams[i]
          : expectedParams
              .where((e) => e.name == currentParam.name)
              .firstOrNull;
      if (expectedParam == null) {
        continue;
      }

      var typeSystem = context.typeSystem;
      var currentType = currentParam.type;
      var expectedType = expectedParam.type;
      // if type are not consistent, lint!
      if (currentParam.isRequiredPositional && currentType != expectedType ||
          currentParam.isOptional &&
              (currentNullability &&
                      (typeSystem.isNonNullable(expectedType) &&
                              expectedType !=
                                  typeSystem.promoteToNonNull(currentType) ||
                          typeSystem.isNullable(expectedType) &&
                              expectedType != currentType) ||
                  !currentNullability && expectedType != currentType)) {
        rule.reportLint(node.parameters!.parameters
            .firstWhere((e) => e.declaredElement == currentParam));
      }
    }
  }
}
