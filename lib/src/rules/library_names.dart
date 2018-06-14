// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/utils.dart';

const _desc =
    r'Name libraries and source files using `lowercase_with_underscores`.';

const _details = r'''

**DO** name libraries and source files using `lowercase_with_underscores`.

Some file systems are not case-sensitive, so many projects require filenames
to be all lowercase.  Using a separate character allows names to still be
readable in that form.  Using underscores as the separator ensures that the name
is still a valid Dart identifier, which may be helpful if the language later
supports symbolic imports.

**GOOD:**

* `slider_menu.dart`
* `file_system.dart`
* `library peg_parser;`

**BAD:**

* `SliderMenu.dart`
* `filesystem.dart`
* `library peg-parser;`

''';

class LibraryNames extends LintRule implements NodeLintRule {
  LibraryNames()
      : super(
            name: 'library_names',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addLibraryDirective(this, visitor);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitLibraryDirective(LibraryDirective node) {
    if (!isLowerCaseUnderScoreWithDots(node.name.toString())) {
      rule.reportLint(node.name);
    }
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (!isLowerCaseUnderScoreWithDots(node.element.source.shortName)) {
      rule.reportLint(node);
    }
  }
}
