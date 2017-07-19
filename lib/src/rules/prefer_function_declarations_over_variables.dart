// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Use a function declaration to bind a function to a name.';

const _details = r'''

**DO** use a function declaration to bind a function to a name.

**BAD:**
```
void main() {
  var localFunction = () {
    ...
  };
}
```

**GOOD:**
```
void main() {
  localFunction() {
    ...
  }
}
```

''';

class PreferFunctionDeclarationsOverVariables extends LintRule {
  _Visitor _visitor;
  PreferFunctionDeclarationsOverVariables()
      : super(
            name: 'prefer_function_declarations_over_variables',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    if (node.initializer != null && node.initializer is FunctionExpression) {
      rule.reportLint(node);
    }
  }
}
