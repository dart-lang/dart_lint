// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r'Use @required.';

const _details = r'''

**DO** specify `@required` on named parameters without a default value on which 
an `assert(param != null)` is done.

**GOOD:**
```
m1({@required a}) {
  assert(a != null);
}

m2({a: 1}) {
  assert(a != null);
}
```

**BAD:**
```
m1({a}) {
  assert(a != null);
}
```

NOTE: Only asserts at the start of the bodies will be taken into account.

''';

class AlwaysRequireNonNullNamedParameters extends LintRule
    implements NodeLintRule {
  AlwaysRequireNonNullNamedParameters()
      : super(
            name: 'always_require_non_null_named_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);
    registry.addFormalParameterList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  void checkLiteral(TypedLiteral literal) {
    if (literal.typeArguments == null) {
      rule.reportLintForToken(literal.beginToken);
    }
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    List<DefaultFormalParameter> getParams() {
      final params = <DefaultFormalParameter>[];
      for (final p in node.parameters) {
        // Only named parameters
        if (p.isNamed) {
          DefaultFormalParameter parameter = p as DefaultFormalParameter;
          // Without a default value or marked @required
          if (parameter.defaultValue == null &&
              !parameter.declaredElement.hasRequired) {
            params.add(parameter);
          }
        }
      }
      return params;
    }

    final parent = node.parent;
    if (parent is FunctionExpression) {
      _checkParams(getParams(), parent.body);
    } else if (parent is ConstructorDeclaration) {
      _checkInitializerList(getParams(), parent.initializers);
      _checkParams(getParams(), parent.body);
    } else if (parent is MethodDeclaration) {
      _checkParams(getParams(), parent.body);
    }
  }

  void _checkAsserts(
      List<Expression> asserts, List<DefaultFormalParameter> params) {
    for (final expression in asserts) {
      for (final param in params) {
        if (_hasAssertNotNull(expression, param.identifier.name)) {
          rule.reportLintForToken(param.identifier.beginToken);
        }
      }
    }
  }

  void _checkInitializerList(List<DefaultFormalParameter> params,
      NodeList<ConstructorInitializer> initializers) {
    final asserts = <Expression>[];
    for (final initializer in initializers) {
      if (initializer is AssertInitializer) {
        asserts.add(initializer.condition);
      }
    }
    _checkAsserts(asserts, params);
  }

  void _checkParams(List<DefaultFormalParameter> params, FunctionBody body) {
    if (body is BlockFunctionBody) {
      final asserts = <Expression>[];
      for (final statement in body.block.statements) {
        if (statement is AssertStatement) {
          asserts.add(statement.condition);
        }
      }
      _checkAsserts(asserts, params);
    }
  }

  bool _hasAssertNotNull(Expression node, String name) {
    bool _hasSameName(Expression rawExpression) {
      final expression = rawExpression.unParenthesized;
      return expression is SimpleIdentifier && expression.name == name;
    }

    final expression = node.unParenthesized;
    if (expression is BinaryExpression) {
      if (expression.operator.type == TokenType.AMPERSAND_AMPERSAND) {
        return _hasAssertNotNull(expression.leftOperand, name) ||
            _hasAssertNotNull(expression.rightOperand, name);
      }
      if (expression.operator.type == TokenType.BANG_EQ) {
        final operands = [expression.leftOperand, expression.rightOperand];
        return operands.any(DartTypeUtilities.isNullLiteral) &&
            operands.any(_hasSameName);
      }
    }
    return false;
  }
}
