// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N end_doc_paragraphs_with_punctuation`


// BAD

// LINT [+1]
/// This sentence doesn't have any terminating punctuation at the end
void a() => null;

// LINT [+1]
/// This is a long documentation comment composed of multiple paragraphs.
/// 
/// It looks like we forgot to terminate this middle one, which is bad
/// 
/// But the end one is fine.
void b() => null;

// LINT [+2]
// ignore: slash_for_doc_comments
/**
 * We also flag Java-style documentation comments, such as this long one we have
 * spread across multiple lines here
 */
void c() => null;


// GOOD

// OK (lines +2 and +4)
/// This is a longer paragraph spread across multiple lines of a documentation
/// comment, but it still ends with terminating punctuation!
/// 
/// And so does this other paragraph.
void d() => null;

// OK (lines +3, +5, +7, and +9)
// ignore: slash_for_doc_comments
/** 
 * Other endings work too:
 * 
 * Would you like to see an interrobang‽
 * 
 * (Even other styles of ordering punctuation.)
 * 
 * This also works: "false negatives are okay"
 */
void e() => null;

// OK (lines +1, +3, +7, +9, +13, +15, +17, +19, +21, +22, +23)
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
void f() => null;
