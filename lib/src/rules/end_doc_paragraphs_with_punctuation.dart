// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dartdoc/src/utils.dart'; // TODO: how to properly rely on these helper functions?
import 'package:markdown/markdown.dart';

import '../analyzer.dart';

const Set<String> _allowedEndings = {
  '.',
  '?',
  '!',
  ':',
  '‽',
  '\'',
  '"',
  '}',
  ']',
  ')',
  '>'
};
const String _suggestedEndings = '".", "?", "!", or ":"';

const _desc =
    'DO end all paragraphs in documentation comments with terminating punctuation: $_suggestedEndings.';

const _details = '''

**DO** end all paragraphs in documentation comments with one of the following: $_suggestedEndings

**BAD:**
```
/// This sentence doesn't have any terminating punctuation at the end
void a() => null;

/// This is a long documentation comment composed of multiple paragraphs.
/// 
/// It looks like we forgot to terminate this middle one, which is bad
/// 
/// But the end one is fine.
void b() => null;
```

**GOOD:**
```
/// This is a longer paragraph spread across multiple lines of a documentation
/// comment, but it still ends with terminating punctuation!
/// 
/// And so does this other paragraph.
void c() => null;

/// Other endings work too:
/// 
/// Would you like to see an interrobang‽
/// 
/// (Even other styles of ordering punctuation.)
/// 
/// This also works: "false negatives are okay"
void d() => null;

/// Markdown is also supported, so `thisWorksToo();`
/// 
/// As does a table:
/// 
/// |   |  2 |  3 |
/// | 5 | 10 | 15 |
/// | 7 | 14 | 21 |
/// 
/// Same with a code snippet:
/// 
/// ```dart
/// new Foo();
/// ```
/// 
/// Etcetera:
/// 
/// [README.md]: https://google.com
/// 
/// https://abc.xyz/
/// 
/// * http://dart.dev
/// * http://flutter.dev
/// * http://pub.dev
void e() => null;
```

''';

class EndDocParagraphsWithPunctuation extends LintRule implements NodeLintRule {
  EndDocParagraphsWithPunctuation()
      : super(
            name: 'end_doc_paragraphs_with_punctuation',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addComment(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  final Document document = Document(
    blockSyntaxes: [
      // This is the only extension that was needed to fix false positives
      // when testing against the Flutter framework on 2020-08-01. Consider
      // expanding the extension set used if more false positives arise.
      const TableSyntax(),
    ],
  );

  _Visitor(this.rule);

  @override
  void visitComment(Comment commentNode) {
    final commentBuffer = StringBuffer();
    for (var token in commentNode.tokens) {
      commentBuffer.writeln(token.lexeme);
    }
    final rawComment = commentBuffer.toString().replaceAll('\r\n', '\n').trim();
    final rawText = stripComments(rawComment);

    final lines = rawText.split('\n');
    final mdNodes = document.parseLines(lines);
    for (final mdNode in mdNodes) {
      if (mdNode is Element) {
        final pText = mdNode.textContent.trim();
        if (mdNode.tag == 'p' && pText.isNotEmpty) {
          // Ending with an anchor (link), inline code, etc. is valid.
          if (mdNode.children != null && mdNode.children.isNotEmpty) {
            final lastChild = mdNode.children.last;
            if (lastChild is Element && lastChild.tag != 'p') {
              return;
            }
          }

          final endChar = pText[pText.length - 1];
          if (!_allowedEndings.contains(endChar)) {
            if (!_endsWithHyperlink(pText)) {
              rule.reportLint(commentNode);
            }
          }
        }
      }
    }
  }

  // Using _endsWithHyperlink instead of AutolinkExtensionSyntax improved
  // performance by 20% (2251 vs. 2806 ms) when testing on Flutter framework,
  // without any visible loss in accuracy.
  bool _endsWithHyperlink(String text) {
    // TODO: is there a more succinct way to declaring this?
    const validChars = {
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
      'p',
      'q',
      'r',
      's',
      't',
      'u',
      'v',
      'w',
      'x',
      'y',
      'z',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '-',
      '.',
      '_',
      '~',
      ':',
      '/',
      '?',
      '#',
      '[',
      ']',
      '@',
      '!',
      '\$',
      '&',
      '\'',
      '(',
      ')',
      '*',
      '+',
      ',',
      ';',
      '='
    };
    const targetPrefixes = [
      'http://',
      'https://',
      'b/',
      'go/',
    ];

    if (text == null || text.isEmpty) {
      return false;
    }

    String potentialLink;
    // Skip the end character because we start the substring at i+1
    for (var i = text.length - 2; i >= 0; i--) {
      if (!validChars.contains(text[i])) {
        potentialLink = text.substring(i + 1, text.length);
        break;
      }
    }
    potentialLink ??= text;

    for (final prefix in targetPrefixes) {
      if (potentialLink.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }
}
