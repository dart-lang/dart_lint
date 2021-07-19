// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Use trailing commas for all function calls and declarations.';

const _details = r'''

**DO** use trailing commas for all function calls and declarations unless the
function call or definition, from the start of the function name up to the
closing parenthesis, fits in a single line.

**GOOD:**
```dart
void run() {
  method(
    'does not fit on one line',
    'test test test test test test test test test test test',
  );
}
```

**BAD:**
```dart
void run() {
  method('does not fit on one line',
      'test test test test test test test test test test test');
}
```

**Exception:** If a parameter/argument is either a function literal
implemented using curly braces, a literal map, a literal set or a literal array
then any line break will be ignore and the expression will be treated as a
single line expression.

**Note:** This lint rule assumes `dartfmt` has been run over the code and may
produce false positives until that has happened.

''';

class RequireTrailingCommas extends LintRule implements NodeLintRule {
  RequireTrailingCommas()
      : super(
          name: 'require_trailing_commas',
          description: _desc,
          details: _details,
          group: Group.style,
          maturity: Maturity.experimental,
        );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    var visitor = _Visitor(this);
    registry
      ..addArgumentList(this, visitor)
      ..addAssertInitializer(this, visitor)
      ..addAssertStatement(this, visitor)
      ..addCompilationUnit(this, visitor)
      ..addFormalParameterList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const _trailingCommaCode = LintCode(
    'require_trailing_commas',
    'Missing a required trailing comma.',
  );

  final LintRule rule;

  LineInfo? _lineInfo;

  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) => _lineInfo = node.lineInfo;

  @override
  void visitArgumentList(ArgumentList node) {
    super.visitArgumentList(node);
    if (node.arguments.isEmpty) return;
    _checkTrailingComma(
      node.leftParenthesis,
      node.rightParenthesis,
      node.arguments,
    );
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    super.visitFormalParameterList(node);
    if (node.parameters.isEmpty) return;
    _checkTrailingComma(
      node.leftParenthesis,
      node.rightParenthesis,
      node.parameters,
    );
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    super.visitAssertStatement(node);
    _checkTrailingComma(
      node.leftParenthesis,
      node.rightParenthesis,
      [
        node.condition,
        if (node.message != null) node.message!,
      ],
    );
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    super.visitAssertInitializer(node);
    _checkTrailingComma(
      node.leftParenthesis,
      node.rightParenthesis,
      [
        node.condition,
        if (node.message != null) node.message!,
      ],
    );
  }

  void _checkTrailingComma(
    Token leftParenthesis,
    Token rightParenthesis,
    List<AstNode> nodes,
  ) {
    // Early exit if trailing comma is present.
    if (nodes.last.endToken.next?.type == TokenType.COMMA) return;

    // No trailing comma is needed if the function call or declaration, up to
    // the closing parenthesis, fits on a single line. Ensuring the left and
    // right parenthesis are on the same line is sufficient since dartfmt places
    // the left parenthesis right after the identifier (on the same line).
    if (_isSameLine(leftParenthesis, rightParenthesis)) return;

    // look for unallowed line split
    if (_hasUnallowedLineSplit(leftParenthesis, nodes)) {
      rule.reportLintForOffset(nodes.last.end, 0,
          errorCode: _trailingCommaCode);
    }
  }

  // The function allow split with brackets (block of functions, list, map...)
  // For instance, if an argument is a callback with a body, the body is ignored
  // as it is collapsed on a single line.
  bool _hasUnallowedLineSplit(Token leftParenthesis, List<AstNode> nodes) {
    var argVisitor = _ArgVisitor(_lineOf, _lineOf(leftParenthesis.end));
    for (var node in nodes) {
      if (argVisitor.currentLine != _lineOf(node.offset)) {
        return true;
      }
      node.accept(argVisitor);
      if (argVisitor.hasUnallowedSplit) {
        return true;
      }
    }
    return false;
  }

  int _lineOf(int offset) => _lineInfo!.getLocation(offset).lineNumber;

  bool _isSameLine(Token token1, Token token2) =>
      _lineOf(token1.offset) == _lineOf(token2.offset);
}

class _ArgVisitor extends GeneralizingAstVisitor<void> {
  _ArgVisitor(this.lineOf, this.currentLine);
  final int Function(int offset) lineOf;

  int currentLine;
  bool hasUnallowedSplit = false;

  @override
  void visitNode(AstNode node) {
    if (currentLine != lineOf(node.offset)) {
      hasUnallowedSplit = true;
    } else {
      super.visitNode(node);
      if (currentLine != lineOf(node.end)) {
        hasUnallowedSplit = true;
      }
    }
  }

  @override
  void visitArgumentList(ArgumentList node) {
    if (node.arguments.isNotEmpty &&
        node.arguments.last.endToken.next?.type == TokenType.COMMA) {
      currentLine = lineOf(node.end);
      return;
    }
    super.visitArgumentList(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    if (currentLine == lineOf(node.leftBracket.offset) &&
        node.elements.isNotEmpty) {
      currentLine = lineOf(node.end);
      return;
    }
    currentLine = lineOf(node.leftBracket.offset);
    super.visitListLiteral(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (currentLine == lineOf(node.leftBracket.offset) &&
        node.elements.isNotEmpty) {
      currentLine = lineOf(node.end);
      return;
    }
    currentLine = lineOf(node.leftBracket.offset);
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitBlock(Block node) {
    currentLine = lineOf(node.end);
  }

  @override
  void visitStringLiteral(StringLiteral node) {
    if (node is SingleStringLiteral && node.parent is! AdjacentStrings) {
      currentLine = lineOf(node.end);
      return;
    }
    super.visitStringLiteral(node);
  }
}
