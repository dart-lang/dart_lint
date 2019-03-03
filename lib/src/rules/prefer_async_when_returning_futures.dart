// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Declare methods that return Futures as async.';

const _details = r'''

**DO** declare methods that return Futures as async.

If a method returns a `Future` callers will expect that it will report failures
through `Future`'s `onError` rather than by throwing an exception.

Exceptions thrown in an `async` function will be translated into a `Future`
error automatically so declaring all functions that return `Future`s as async
will guarantee this behavior.

**BAD:**
```
Future<String> getValue(Map<String, String> values, String key) {
  if (values.containsKey(key)) {
    return Future.value(values[key]);
  } else {
    return Future.value(null);
  }
}
```

**GOOD:**
```
Future<String> getValue(Map<String, String> values, String key) async {
  if (values.containsKey(key)) {
    return values[key];
  } else {
    return null;
  }
}
```

''';

class PreferAsyncWhenReturningFutures extends LintRule implements NodeLintRule {
  PreferAsyncWhenReturningFutures()
      : super(
            name: 'prefer_async_when_returning_futures',
            description: _desc,
            details: _details,
            group: Group.errors,
            maturity: Maturity.experimental);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.returnType != null &&
        node.returnType.type.isDartAsyncFuture &&
        !node.functionExpression.body.isAsynchronous) {
      rule.reportLint(node.name);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.body.length == 1 &&
        node.body.beginToken.type == TokenType.SEMICOLON) {
      // This is an abstract declaration.
      return;
    }

    if (node.returnType != null &&
        node.returnType.type.isDartAsyncFuture &&
        !node.body.isAsynchronous) {
      rule.reportLint(node.name);
    }
  }
}
