// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'`Future` results in `sync` function bodies must be '
    'avoided or marked `unawaited` using `package:pedantic`.';

const _details = r'''

**DO** avoid functions that return a `Future` inside of an sync function body.
Convert function to async or mark function call with unawaited.

When you really _do_ want to start a fire-and-forget `Future`, the recommended
way is to use `unawaited` from `package:pedantic`. The `// ignore` and
`// ignore_for_file` comments also work.

**GOOD:**
```
Future doSomething() => ...;

void main() async {
  await doSomething();

  unawaited(doSomething()); // Explicitly-ignored fire-and-forget.
}
```

**BAD:**
```
void main() {
  doSomething(); // Likely a bug.
}
```

''';

class AvoidAsyncFromSync extends LintRule implements NodeLintRule {
  AvoidAsyncFromSync()
      : super(
            name: 'avoid_async_from_sync',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);
    registry.addExpressionStatement(this, visitor);
    registry.addCascadeExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitCascadeExpression(CascadeExpression node) {
    for (final expr in node.cascadeSections) {
      if (expr.staticType?.isDartAsyncFuture == true &&
          _isEnclosedInSyncFunctionBody(expr) &&
          expr is! AssignmentExpression) {
        rule.reportLint(expr);
      }
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    var expr = node?.expression;
    if (expr is AssignmentExpression) return;

    var type = expr?.staticType;
    if (type?.isDartAsyncFuture == true) {
      // Ignore a couple of special known cases.
      if (_isFutureDelayedInstanceCreationWithComputation(expr) ||
          _isMapPutIfAbsentInvocation(expr)) {
        return;
      }

      if (_isEnclosedInSyncFunctionBody(node)) {
        // Future expression statement that isn't awaited in an sync function:
        // while this is legal, it's a very frequent sign of an error.
        rule.reportLint(node);
      }
    }
  }

  bool _isEnclosedInSyncFunctionBody(AstNode node) {
    final enclosingFunctionBody = node.thisOrAncestorOfType<FunctionBody>();
    return enclosingFunctionBody?.isSynchronous == true;
  }

  /// Detects `new Future.delayed(duration, [computation])` creations with a
  /// computation.
  bool _isFutureDelayedInstanceCreationWithComputation(Expression expr) =>
      expr is InstanceCreationExpression &&
      expr.staticType?.isDartAsyncFuture == true &&
      expr.constructorName?.name?.name == 'delayed' &&
      expr.argumentList.arguments.length == 2;

  bool _isMapClass(Element e) =>
      e is ClassElement && e.name == 'Map' && e.library?.name == 'dart.core';

  /// Detects Map.putIfAbsent invocations.
  bool _isMapPutIfAbsentInvocation(Expression expr) =>
      expr is MethodInvocation &&
      expr.methodName.name == 'putIfAbsent' &&
      _isMapClass(expr.methodName.staticElement?.enclosingElement);
}
