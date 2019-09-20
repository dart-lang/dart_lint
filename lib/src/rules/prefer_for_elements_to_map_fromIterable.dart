// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Prefer for elements when building maps from iterables.';

const _details = r'''
When building maps from iterables, it is preferable to use for elements.

**BAD:**
```
Map<String, WidgetBuilder>.fromIterable(
  kAllGalleryDemos,
  key: (demo) => '${demo.routeName}',
  value: (demo) => demo.buildRoute,
);

```

**GOOD:**
```
return {
  for (var demo in kAllGalleryDemos)
    '${demo.routeName}': demo.buildRoute,
};
```
''';

class PreferForElementsToMapFromIterable extends LintRule
    implements NodeLintRule {
  PreferForElementsToMapFromIterable()
      : super(
            name: 'prefer_for_elements_to_map_fromIterable',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression creation) {
    ConstructorElement element = creation.staticElement;
    if (element?.name != 'fromIterable' ||
        element.enclosingElement != context.typeProvider.mapElement) {
      return;
    }

    //
    // Ensure that the arguments have the right form.
    //
    NodeList<Expression> arguments = creation.argumentList.arguments;
    if (arguments.length != 3) {
      return;
    }

    Expression secondArg = arguments[1];
    Expression thirdArg = arguments[2];

    Expression extractBody(FunctionExpression expression) {
      FunctionBody body = expression.body;
      if (body is ExpressionFunctionBody) {
        return body.expression;
      } else if (body is BlockFunctionBody) {
        NodeList<Statement> statements = body.block.statements;
        if (statements.length == 1) {
          Statement statement = statements[0];
          if (statement is ReturnStatement) {
            return statement.expression;
          }
        }
      }
      return null;
    }

    FunctionExpression extractClosure(String name, Expression argument) {
      if (argument is NamedExpression && argument.name.label.name == name) {
        Expression expression = argument.expression.unParenthesized;
        if (expression is FunctionExpression) {
          NodeList<FormalParameter> parameters =
              expression.parameters.parameters;
          if (parameters.length == 1 && parameters[0].isRequired) {
            if (extractBody(expression) != null) {
              return expression;
            }
          }
        }
      }
      return null;
    }

    FunctionExpression keyClosure =
        extractClosure('key', secondArg) ?? extractClosure('key', thirdArg);
    FunctionExpression valueClosure =
        extractClosure('value', thirdArg) ?? extractClosure('value', secondArg);
    if (keyClosure == null || valueClosure == null) {
      return;
    }

    rule.reportLint(creation);
  }
}
