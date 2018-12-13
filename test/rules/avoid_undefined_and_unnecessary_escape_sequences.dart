// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_undefined_and_unnecessary_escape_sequences`

// ignore_for_file: unused_local_variable, prefer_single_quotes
main() {
  const okLiteral = 'Jurassic'; // OK
  const okEscapeSequences =
      'Some escapes sequences \n \r \f \b \t \v \x01 \u0776 \\ \$, quotes covered later'; // OK

  const okSingleQuoteEscape = '\''; // OK
  const okDoubleQuote = "\""; // OK

  const badEscapeSequence = '\z'; // LINT
  const badAdjacentStrings = '\z' 'z'; // LINT
  const badInterpolationString = '\z $okLiteral'; // LINT

  const unnecessarySingleQuoteEscape = "\'"; // LINT
  const unnecessaryDoubleQuoteEscape = '\"'; // LINT

  const rawStringsAreIgnored = r'\z'; // OK
  const multilineLiteralsAreConsidered = '''\z'''; // LINT

  const handleEmptyInterpolationString =
      '$okLiteral'; // OK, this caused a bug earlier
  const interpolationWithinString = 'Welcome to $okLiteral World'; // OK
}
