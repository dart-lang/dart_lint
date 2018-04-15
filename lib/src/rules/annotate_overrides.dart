// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Annotate overridden members.';

const _details = r'''

**DO** annotate overridden methods and fields.

This practice improves code readability and helps protect against
unintentionally overriding superclass members.

**GOOD:**
```
abstract class Dog {
  String get breed;
  void bark() {}
}

class Husky extends Dog {
  @override
  final String breed = 'Husky';
  @override
  void bark() {}
}
```

**BAD:**
```
class Cat {
  int get lives => 9;
}

class Lucky extends Cat {
  final int lives = 14;
}
```

''';

class AnnotateOverrides extends LintRule {
  AnnotateOverrides()
      : super(
            name: 'annotate_overrides',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  InheritanceManager manager;

  final LintRule rule;
  Visitor(this.rule);

  ExecutableElement getOverriddenMember(Element member) {
    if (member == null || manager == null) {
      return null;
    }

    ClassElement classElement =
        member.getAncestor((element) => element is ClassElement);
    if (classElement == null) {
      return null;
    }
    return manager.lookupInheritance(classElement, member.name);
  }

  @override
  visitCompilationUnit(CompilationUnit node) {
    LibraryElement library = node == null
        ? null
        : resolutionMap.elementDeclaredByCompilationUnit(node)?.library;
    manager = library == null ? null : new InheritanceManager(library);
  }

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    for (VariableDeclaration field in node.fields.variables) {
      if (field?.element != null &&
          !resolutionMap
              .elementDeclaredByVariableDeclaration(field)
              .hasOverride) {
        ExecutableElement member = getOverriddenMember(field.element);
        if (member != null) {
          rule.reportLint(field);
        }
      }
    }
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    if (node?.element != null &&
        !resolutionMap.elementDeclaredByMethodDeclaration(node).hasOverride) {
      ExecutableElement member = getOverriddenMember(node.element);
      if (member != null) {
        rule.reportLint(node.name);
      }
    }
  }
}
