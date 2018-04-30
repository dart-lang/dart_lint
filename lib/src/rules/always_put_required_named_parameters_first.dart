// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Put @required named parameters first.';

const _details = r'''

**DO** specify `@required` on named parameter before other named parameters.

**GOOD:**
```
m({@required a, b, c}) ;
```

**BAD:**
```
m({b, c, @required a}) ;
```

''';

/// The name of `meta` library, used to define analysis annotations.
String _META_LIB_NAME = 'meta';

/// The name of the top-level variable used to mark a required named parameter.
String _REQUIRED_VAR_NAME = 'required';

bool _isRequired(Element element) =>
    element is PropertyAccessorElement &&
    element.name == _REQUIRED_VAR_NAME &&
    element.library?.name == _META_LIB_NAME;

class AlwaysPutRequiredNamedParametersFirst extends LintRule
    implements NodeLintRule {
  AlwaysPutRequiredNamedParametersFirst()
      : super(
            name: 'always_put_required_named_parameters_first',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addFormalParameterList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFormalParameterList(FormalParameterList node) {
    bool nonRequiredSeen = false;
    for (DefaultFormalParameter param
        in node.parameters.where((p) => p.isNamed)) {
      if (param.metadata.any((a) => _isRequired(a.element))) {
        if (nonRequiredSeen) {
          rule.reportLintForToken(param.identifier.token);
        }
      } else {
        nonRequiredSeen = true;
      }
    }
  }
}
