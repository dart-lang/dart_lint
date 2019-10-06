// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/utils.dart';

const _desc = r'Avoid leading underscore for identifiers that aren’t private.';

const _details = r'''

**DON’T** use a leading underscore for identifiers that aren’t private.

Dart uses a leading underscore in an identifier to mark members and top-level declarations as private. This trains users to associate a leading underscore with one of those kinds of declarations. They see “_” and think “private”.

There is no concept of “private” for local variables, parameters, or library prefixes. When one of those has a name that starts with an underscore, it sends a confusing signal to the reader. To avoid that, don’t use leading underscores in those names.

**Exception**: An unused parameter can be named _, __, ___, etc. This happens in things like callbacks where you are passed a value but you don’t need to use it. Giving it a name that consists solely of underscores is the idiomatic way to indicate the value isn’t used.

**BAD**
```
print(string _name) {
  int _size = _name.length;
}
```

**GOOD:**
```
print(string name) {
  int size = name.length;
}
```

''';

class AvoidLeadingUnderscoreForNonPrivateIdentifiers extends LintRule
    implements NodeLintRule {
  AvoidLeadingUnderscoreForNonPrivateIdentifiers()
      : super(
            name: 'avoid_leading_underscore_for_non_private_identifiers',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);
    registry.addFormalParameterList(this, visitor);
    registry.addVariableDeclarationStatement(this, visitor);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  checkIdentifier(SimpleIdentifier id, {bool isJustUnderscoresOK = false}) {
    if (id == null) {
      return;
    }

    if (isJustUnderscoresOK && isJustUnderscores(id.name)) {
      return;
    }

    if (hasLeadingUnderscores(id.name)) {
      rule.reportLint(id);
    }
  }

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.prefix != null) {
      checkIdentifier(node.prefix);
    }
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    node.variables.variables.forEach((v) => {checkIdentifier(v.name)});
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    node.parameters.forEach((FormalParameter p) {
      if (p is! FieldFormalParameter) {
        checkIdentifier(p.identifier, isJustUnderscoresOK: true);
      }
    });
  }
}
