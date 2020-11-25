# Writing lints
- [Writing lints](#writing-lints)
  - [Introduction](#introduction)
    - [Lint criteria](#lint-criteria)
    - [Lint properties](#lint-properties)
  - [Writing](#writing)
    - [Environment setup](#environment-setup)
    - [Mechanics](#mechanics)
    - [Abstract syntax tree](#abstract-syntax-tree)
    - [Example lints](#example-lints)
    - [Performance](#performance)
    - [Analyzer APIs](#analyzer-apis)
    - [Dart language specification](#dart-language-specification)
  - [Testing](#testing)
    - [Utilities](#utilities)
    - [Writing automated tests](#writing-automated-tests)
      - [Code that triggers the lint](#code-that-triggers-the-lint)
      - [Code that passes the lint](#code-that-passes-the-lint)
      - [Advanced testing markup](#advanced-testing-markup)
      - [Caveat: depending on Dart SDK details](#caveat-depending-on-dart-sdk-details)
    - [Running automated tests](#running-automated-tests)
    - [Manually testing against a codebase](#manually-testing-against-a-codebase)
    - [Benchmarking](#benchmarking)
  - [Feedback is welcome!](#feedback-is-welcome)

## Introduction

### Lint criteria

Borrowing heavily from the criteria for [adding new checks to
errorprone](https://github.com/google/error-prone/wiki/Criteria-for-new-checks),
lints should have the following properties.

Dart lints:

* should be easy to understand. The problem should be obvious once the linter
  points it out.
* should have a correspondingly easy fix. For example, "Remove this type
  annotation", or "Delete these braces", not "Introduce a new subclass and
  override methods A, B, and C."
* should have *few* false positives.

### Lint properties

Every lint has a:

**Name.** A short name using Dart package naming conventions.  Naming is *hard*
but strive to be concise and consistent.  Where possible, use existing rules for
inspiration and observe the rules of [parallel
construction](https://en.wikipedia.org/wiki/Parallelism_(grammar)).

**Description.** A short description of the lint, suitable for printing in
console output.  For example:

```
[lint] DO name types using UpperCamelCase.
```

**Kind.** The first word in the description should identify the *kind* of lint
where kinds are derived from the [style
guide](https://dart.dev/guides/language/effective-dart/style/). In summary:

* ***DO*** guidelines describe practices that should always be followed. There
  will almost never be a valid reason to stray from them.

* ***DON'T*** guidelines are the converse: things that are almost never a good
  idea. You'll note there are few of these here. Guidelines like these in other
  languages help to avoid the pitfalls that appear over time. Dart is new enough
  that we can just fix those pitfalls directly instead of putting up ropes
  around them.

* ***PREFER*** guidelines are practices that you should follow. However, there
  may be circumstances where it makes sense to do otherwise. Just make sure you
  understand the full implications of ignoring the guideline when you do.

* ***AVOID*** guidelines are the dual to "prefer": stuff you shouldn't do but
  where there may be good reasons to on rare occasions.

* ***CONSIDER*** guidelines are practices that you might or might not want to
  follow, depending on circumstances, precedents, and your own preference.

**Detailed description.** In addition to the short description, a lint rule
should have more detailed rationale with code examples, ideally *good* and
*bad*. The [style guide](https://dart.dev/guides/language/effective-dart/style/)
is a great source for inspiration.  Many style recommendations have been
directly translated to lints as enumerated
[here](https://dart-lang.github.io/linter/lints/).

**Group.**  A grouping. For example, *Style Guide* aggregates style guide
derived lints.

**Maturity.** Rules can be further distinguished by maturity. Unqualified rules
are considered stable, while others may be marked *EXPERIMENTAL* or *PROPOSED*
to indicate that they are under review.

## Writing

### Environment setup

- Install the [Dart SDK](https://dart.dev/get-dart).
- Install one of the [supported
  editors](https://dart.dev/tools#ides-and-editors) and associated Dart plugin.
- Fork and clone this repo, as described in the [contributing
  guidelines](../CONTRIBUTING.md#mechanics).

### Mechanics

Lints live in the [lib/src/rules](../lib/src/rules) directory. Corresponding
tests live in [test/rules](../test/rules). 

Rule stubs can be generated with the [rule.dart](../tool/rule.dart) helper
script, and documentation gets generated with [doc.dart](../tool/doc.dart).
Helper scripts can be invoked via `dart` or grinder
(`pub run grinder docs --dir=doc_location` and
`pub run grinder rule --name=my_new_rule` respectively).
Using grinder, for example

    $ pub run grinder rule --name=my_new_lint
    
generates lint and test stubs in `lib/src/rules` and `test/rules`.

### Abstract syntax tree

Lint rules traverse an AST (abstract syntax tree) representing the syntactic
structure of the Dart program being analyzed to determine if (and where)
warnings should be reported.

The Dart analyzer package contains documentation for understanding Dart's
[AST](https://github.com/dart-lang/sdk/blob/master/pkg/analyzer/doc/tutorial/ast.md)
and associated [element
model](https://github.com/dart-lang/sdk/blob/master/pkg/analyzer/doc/tutorial/element.md).
*These documents are an excellent place to start!*

Further understanding can be gained by studying [existing
rules](../lib/src/rules/), the [analyzer
documentation](https://pub.dev/documentation/analyzer/latest/), and the [Dart
language specification](#dart-language-specification).

### Example lints

Take a look at the [existing rules](../lib/src/rules/) for examples of how to
write lints. Finding an existing rule that tackles similar problems to your
desired rule is a great way to get started writing a lint.

### Performance

For performance reasons rules should prefer implementing `NodeLintRule` and
registering interest in specific AST node types using `registry.addXYZ(this,
visitor)`. Avoid overriding `visitCompilationUnit()` and performing your own
full `CompilationUnit` visits.

### Analyzer APIs

The linter has a close relationship with the `analyzer` package and at times
reaches into non-public APIs. For the most part, we have isolated these
references in an [analyzer.dart utility library](../lib/src/analyzer.dart).
*Wherever possible please use this library to access analyzer internals.*  

  * If `analyzer.dart` is missing something please consider either opening an
    issue where we can discuss how best to add it. 
  * If you find yourself tempted to make references to analyzer [implementation
    classes](https://dart-lang.github.io/linter/lints/implementation_imports.html)
    also consider opening an issue so that we can see how best to manage the new
    dependency.

Thanks!

### Dart language specification

When writing lints, it can be useful to have the [Dart language
specification](https://dart.dev/guides/language/spec) handy.  If you're working
to support bleeding edge language features, you'll want the [latest
draft](https://spec.dart.dev/DartLangSpecDraft.pdf). 

## Testing

It is very important to exhaustively test your lint, as false positives reported
by your rule may lead to people not using it all.

### Utilities

You'll notice when authoring a new rule that failures cause the AST of the test
case to be displayed to `stdout`.  If you simply want to dump the AST of a given
compilation unit, you can use the `spelunk` helper directly.  For example:

    $ dart tool/spelunk.dart lib/src/rules.dart
    
would dump the AST of `rules.dart`.

More utilities can be found under the `tool/` directory, but most of them are
more useful for maintaining overall project health rather than authoring lints.

### Writing automated tests

Generating a rule stub with `rule.dart` will also create a corresponding test
stub under `test/rules/`. This test file should contain contrasting examples of
Dart code that both _should_ and should _not_ trigger the lint.

Take a look at the other test cases under [`test/rules/`](../test/rules) for
examples.

See [Running automated tests](#running-automated-tests) for how to execute them.

#### Code that triggers the lint

Code that _should_ trigger the rule is marked as such with `// LINT` at the end
of the offending line.

Example **triggering** [test cases](../test/rules/avoid_print.dart) from the
[`avoid_print` rule](../lib/src/rules/avoid_print.dart):

```dart
void main() {
  print('ha'); // LINT
  [1,2,3].forEach(print); // LINT
  Future.value('hello').then(print); // LINT
}
```

The test runner will perform a set-wise comparison of the reported lint warnings
vs. the expected locations annotated by `// LINT`, and report errors for any
differences.

#### Code that passes the lint

In contrast with `// LINT`, code that should _not_ trigger the rule is marked
by `// OK` at the end of the line. These `// OK` comments by themselves have no
mechanical impact on the lint testing process, but are the conventional way of
notating situations where your rule should not report failures.

Example **passing** [test cases](../test/rules/avoid_print.dart) from the
[`avoid_print` rule](../lib/src/rules/avoid_print.dart):

```dart
var x = print; // OK

void f() {
  x('ha'); // OK?
  [1,2,3].forEach(x); // OK
  Future.value('hello').then(x); // OK
}

class A {
  print() {
  }
}

void g() {
  A().print(); // OK
}
```

#### Advanced testing markup

**Optional parameters for `// LINT`**

The `// LINT` comment markup supports optional parameters that describe
which line is expected to report the lint warning, and exactly which part of the
line of code should elicit the warning (specified by character column and
length).

```dart
// LINT [lineOffset,column:length] message
```

1. `lineOffset`: the relative line offset of the expected error from the
   comment. Can be prefixed with either a `+` or `-` to specify offset
   directionality.
2. `column`: the horizontal position on the line where the warning highlight is
   expected to begin.
3. `length`: the expected length of the warning highlight. The end position of
   the highlight is `column + length`.
4. `message`: the warning message expected to be reported here, must exactly
   match what the lint rule reports for the test to pass.

Notes:

- Some parameters may be specified while omiting the others. Often appending
  just `// LINT` on its own will suffice.
- The format is sensitive to whitespace and punctuation, take a look at this
  [regex
  pattern](https://github.com/dart-lang/linter/blob/fd23864bb9faa5a75e449786983631284397bef8/lib/src/test_utilities/annotation.dart#L10)
  for specifics.

The rule `always_specify_types` should highlight `final` below with a warning.
Specifying `[1:5]` ensures that it does so.
```dart
final x = 1; // LINT [1:5]
```

The rule `leading_newlines_in_multiline_strings` should highlight the line
containing `f('''this` in the example below. Appending `// LINT` to the end of
the offending line would make it part of the string, rather than a comment.
Specifying `[+1]` allows the `// LINT` comment to be placed on the previous
line.
```dart
// LINT [+1]
f('''this
 is a multiline string''');
```

**Lints that operate on comments**

If a lint rule should report warnings for text contained in comments or doc
comments, there is the option of appending `# LINT` to the end of the offending
comment lines in your test cases instead of placing `// LINT [+1]` on the line
before. The alternative `# LINT` syntax accepts the same optional parameters
discussed above.

For example, this is useful for the
[comment_references](../lib/src/rules/comment_references.dart) lint rule
[tests](../test/rules/comment_references.dart):

```dart
/// [this] # LINT
```

**Ignoring other lints in a test case**

The test runner will only check each test case file against its associated lint
rule, so violating a different lint rule in your test case will not report an
error when running the test. However, violating other lint rules will still
cause tools like your IDE to show the expected warnings. These can optionally be
ignored with the standard `// ignore: xyz` syntax, just like anywhere else.

**Complicated lints that require integration tests**

For any tests that cannot be achieved by writing test cases under `test/rules/`
as described thusfar, there is the option of writing an [integration
test](../test/integration_test.dart) instead.  

#### Caveat: depending on Dart SDK details

**Important:** when writing tests that use standard `dart:` libraries, it's
important to keep in mind that linter tests use a mocked SDK that has only a
small subset of the real one.  We do this for performance reasons as it's FAR
faster to load a mock SDK into memory than read the real one from disk.  If you
are writing tests that depend on something in the Dart SDK (for example, an
interface such as `Iterable`), you may need to update SDK mock content located
in the `package:analyzer` [test utilities
`mock_sdk.dart`](https://github.com/dart-lang/sdk/blob/master/pkg/analyzer/lib/src/test_utilities/mock_sdk.dart).

### Running automated tests

The test suite run during the linter's CI can be run locally:

    $ dart test/all.dart

Alternatively, tests can be run using `pub`:

    $ pub run test
    
Running a single test can be done using the `rule_debug` helper:

    $ dart test/util/rule_debug.dart always_declare_return_types
    
would only test `always_declare_return_types`. **(This can be very handy if you
want to run tests in the VM debugger).**

If you simply want to verify a test, you can run it solo in `pub`:

    $ pub run test -N always_declare_return_types

### Manually testing against a codebase

Testing lints against real-world codebases can be great way for finding
false-positives.

The `bin/linter.dart` tool serves as a wrapper around the `linter` CLI, and can
be used to run lints that are still in development.

**Specific lints**

For testing just a few specific lints against a Dart codebase, use the `--rules`
flag followed by a comma-separated list of rules:

    $ dart bin/linter.dart --rules lint_one,lint_two path/to/codebase

Example: test the `avoid_as` rule against the codebase of the linter itself.

    $ dart bin/linter.dart --rules avoid_as .

**Batches of lints**

For testing a larger batch of lints, use the `-c` flag followed the path to an
`analysis-options.yaml` file:

    $ dart bin/linter.dart -c path/to/analysis-options.yaml path/to/codebase

Example: test all lint rules against the codebase of the linter itself:

    $ dart bin/linter.dart -c example/all.yaml .

**Filtering output**

Running the linter will also output Dart language warnings and errors, such as
`[static type warning]` and `[compile time error]`. When testing a lint rule, it
can be helpful to filter the output for only lines that contain `[lint]`.

For platforms that support it, piping to `grep` can work well for this:

    $ dart bin/linter.dart --rules avoid_as . | grep ' \[lint\] '

**Collecting statistics**

Passing `-s` to the `bin/linter.dart` tool will output two tables of statistics,
in addition to the individual lint warnings. If you're just interested in the
statistics, pass `-q` as well to quiet the individual warnings.

Example: run all lint rules against this linter repo:

    $ dart bin/linter.dart -s -q -c example/all.yaml .

The first table shows the count of how many instances of each lint were detected
(including language warnings and errors at the top):

```
------------------------------------------------------------
Counts
------------------------------------------------------------
ARGUMENT_TYPE_NOT_ASSIGNABLE                               2
CAST_TO_NON_TYPE                                          73
CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE                 10
...
use_to_and_as_if_applicable                                8
valid_regexps                                              1
void_checks                                               12
------------------------------------------------------------
```

The second table shows how long it took to run each lint rule*:

```
------------------------------------------------------
Timings                                             ms
------------------------------------------------------
invariant_booleans                                 115
prefer_final_locals                                 96
prefer_double_quotes                                69
...
avoid_bool_literals_in_conditional_expressions       0
empty_statements                                     0
empty_catches                                        0
------------------------------------------------------
Total                                             1306
------------------------------------------------------
```

*Note that the time taken to run a lint can vary greatly, and the `--benchmark`
parameter should be used instead when [benchmarking](#benchmarking).

**Ideas for where to test lints**

- Your own projects.
- Official Dart projects, such as this `linter` repo.
- Flutter repos such as the [framework](https://github.com/flutter/flutter) and
  [plugins](https://github.com/flutter/plugins) repo.
- Popular packages on [pub.dev](https://pub.dev/).

### Benchmarking

Benchmarking lints is very similar to [manually testing against a
codebase](#manually-testing-against-a-codebase), and uses the same
`bin/linter.dart` tool.

The `--benchmark` flag for `bin/linter.dart` will run each provided lint rule
`10` times (as defined by `benchmarkRuns` in
[lib/src/formatter.dart](../lib/src/formatter.dart)), and report the best result
for each lint. This helps reduce noise between runs, but some variation is still
likely.

**Specific lints**

For benchmarking just a few specific lints against a Dart codebase, use the
`--rules` flag followed by a comma-separated list of rules:

    $ dart bin/linter.dart --benchmark -q --rules lint_one,lint_two path/to/codebase

The `-q` parameter will suppress individual lint errors from being shown.

Example: benchmark the `avoid_as` rule against the codebase of the linter
itself.

    $ dart bin/linter.dart --benchmark -q --rules avoid_as .

**Batches of lints**

For benchmarking a larger batch of lints defined by an `analysis-options.yaml`
file, pass `-c path/to/analysis-options.yaml` instead of `--rules`:

    $ dart bin/linter.dart --benchmark -q -c path/to/analysis-options.yaml path/to/codebase

Example: benchmark all lint rules against the codebase of the linter itself:

    $ dart bin/linter.dart --benchmark -q -c example/all.yaml .

## Feedback is welcome!

Details are under active development. Feedback is most
[welcome](https://github.com/dart-lang/linter/issues)!
