// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Prefer using a boolean as the assert condition.';

const _details = r'''

**DO** use a boolean for assert conditions.

Not using booleans in assert conditions can lead to code where it isn't clear
what the intention of the assert statement is.

**BAD:**
```
assert(() {
  f();
  return true;
});
```

**GOOD:**
```
assert(() {
  f();
  return true;
}());
```

''';

class PreferBoolInAsserts extends LintRule implements NodeLintRule {
  PreferBoolInAsserts()
      : super(
            name: 'prefer_bool_in_asserts',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addCompilationUnit(this, visitor);
    registry.addAssertStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  DartType boolType;
  @override
  void visitAssertStatement(AssertStatement node) {
    if (!_unbound(node.condition.bestType).isAssignableTo(boolType)) {
      rule.reportLint(node.condition);
    }
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    boolType = node.element.context.typeProvider.boolType;
  }

  DartType _unbound(DartType type) {
    DartType t = type;
    while (t is TypeParameterType) t = (t as TypeParameterType).bound;
    return t;
  }
}
