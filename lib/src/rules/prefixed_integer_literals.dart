// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Prefer a lowercase prefix and an uppercase value.';

const _details = r'''

Prefer a lowercase prefix and an uppercase value when using an integer literal
that contains a prefix indicating the base.

**BAD:**
```dart
int a = 0xffffffff;
int b = 0XFFFFFFFF;
```

**GOOD:**
```dart
int a = 0xFFFFFFFF;
int b = 0x12345678;
```

''';

class PrefixedIntegerLiterals extends LintRule implements NodeLintRule {
  PrefixedIntegerLiterals()
      : super(
            name: 'prefixed_integer_literals',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addIntegerLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitIntegerLiteral(IntegerLiteral node) {
    var lexeme = node.literal.lexeme;
    if (lexeme.startsWith(RegExp('0[a-zA-Z]'))) {
      var prefix = lexeme.substring(0, 2);
      var value = lexeme.substring(3);
      if (prefix != prefix.toLowerCase() || value != value.toUpperCase()) {
        rule.reportLint(node);
      }
    }
  }
}
