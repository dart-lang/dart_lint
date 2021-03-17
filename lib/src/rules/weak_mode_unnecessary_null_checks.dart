// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Unnecessary null check for non-nullable value.';

const _details = r'''

Unnecessary null check for non-nullable value in a opted-out library.

**BAD:**
```
nonNullable?.property;
if (nonNullable != null) {}
```

**GOOD:**
```
nonNullable.property;
```

''';

class WeakModeUnnecessaryNullChecks extends LintRule implements NodeLintRule {
  WeakModeUnnecessaryNullChecks()
      : super(
            name: 'weak_mode_unnecessary_null_checks',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    if (context.isEnabled(Feature.non_nullable)) {
      return;
    }

    final visitor = _Visitor(this, context);
    registry.addPropertyAccess(this, visitor);
    registry.addMethodInvocation(this, visitor);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.operator.type == TokenType.QUESTION_PERIOD &&
        isNonNullable(node.target)) {
      rule.reportLintForToken(node.operator);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.operator?.type == TokenType.QUESTION_PERIOD &&
        isNonNullable(node.target)) {
      rule.reportLintForToken(node.operator);
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operands = [
      node.leftOperand,
      node.rightOperand,
    ].map((e) => e.unParenthesized).toList();
    if ((node.operator.type == TokenType.EQ_EQ ||
            node.operator.type == TokenType.BANG_EQ) &&
        operands.where((e) => e.staticType.isDartCoreNull).length == 1) {
      final operand = operands.firstWhere((e) => !e.staticType.isDartCoreNull);
      if (isNonNullable(operand)) {
        rule.reportLint(node);
      }
    }
  }

  bool isNonNullable(Expression expression) {
    if (expression.staticType.isDynamic) {
      return false;
    }
    Element element;
    if (expression is SimpleIdentifier) {
      element = expression.staticElement;
    } else if (expression is MethodInvocation) {
      element = expression.methodName.staticElement;
    } else if (expression is PropertyAccess) {
      element = expression.propertyName.staticElement;
    }
    if (element == null ||
        !element.library.featureSet.isEnabled(Feature.non_nullable)) {
      return false;
    }
    if (element is PropertyAccessorElement && element.isSynthetic) {
      element = (element as PropertyAccessorElement).variable;
    }
    final node = getNode(element);
    TypeAnnotation type;
    if (node is FunctionDeclaration) {
      type = node.returnType;
    } else if (node is MethodDeclaration) {
      type = node.returnType;
    } else if (node is VariableDeclaration) {
      type = (node.parent as VariableDeclarationList).type;
    }

    return type != null && type.question == null;
  }

  AstNode getNode(Element element) => element.session
      .getParsedLibraryByElement(element.library)
      .getElementDeclaration(element)
      ?.node;
}
