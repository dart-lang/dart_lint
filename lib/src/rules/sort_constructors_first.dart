// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Sort constructor declarations before method declarations.';

const _details = r'''

**DO** sort constructor declarations before method declarations.

**GOOD:**
```
abstract class Animation<T> {
  const Animation();
  void addListener(VoidCallback listener);
}
```

**BAD:**
```
abstract class Visitor {
  visitSomething(Something s);
  Visitor();
}
```

''';

class SortConstructorsFirst extends LintRule implements NodeLintRule {
  SortConstructorsFirst()
      : super(
            name: 'sort_constructors_first',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Sort members by offset.
    final members = node.members.toList()
      ..sort((m1, m2) => m1.offset - m2.offset);

    var seenMethod = false;
    for (final member in members) {
      if (member is ConstructorDeclaration) {
        if (seenMethod) {
          rule.reportLint(member.returnType);
        }
      }
      if (member is MethodDeclaration) {
        seenMethod = true;
      }
    }
  }
}
