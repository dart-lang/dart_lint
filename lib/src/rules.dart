// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/rules/always_declare_return_types.dart';
import 'package:linter/src/rules/always_put_control_body_on_new_line.dart';
import 'package:linter/src/rules/always_put_required_named_parameters_first.dart';
import 'package:linter/src/rules/always_require_non_null_named_parameters.dart';
import 'package:linter/src/rules/always_specify_types.dart';
import 'package:linter/src/rules/annotate_overrides.dart';
import 'package:linter/src/rules/avoid_annotating_with_dynamic.dart';
import 'package:linter/src/rules/avoid_as.dart';
import 'package:linter/src/rules/avoid_bool_literals_in_conditional_expressions.dart';
import 'package:linter/src/rules/avoid_catches_without_on_clauses.dart';
import 'package:linter/src/rules/avoid_catching_errors.dart';
import 'package:linter/src/rules/avoid_classes_with_only_static_members.dart';
import 'package:linter/src/rules/avoid_double_and_int_checks.dart';
import 'package:linter/src/rules/avoid_empty_else.dart';
import 'package:linter/src/rules/avoid_field_initializers_in_const_classes.dart';
import 'package:linter/src/rules/avoid_function_literals_in_foreach_calls.dart';
import 'package:linter/src/rules/avoid_init_to_null.dart';
import 'package:linter/src/rules/avoid_js_rounded_ints.dart';
import 'package:linter/src/rules/avoid_null_checks_in_equality_operators.dart';
import 'package:linter/src/rules/avoid_positional_boolean_parameters.dart';
import 'package:linter/src/rules/avoid_private_typedef_functions.dart';
import 'package:linter/src/rules/avoid_relative_lib_imports.dart';
import 'package:linter/src/rules/avoid_renaming_method_parameters.dart';
import 'package:linter/src/rules/avoid_return_types_on_setters.dart';
import 'package:linter/src/rules/avoid_returning_null.dart';
import 'package:linter/src/rules/avoid_returning_this.dart';
import 'package:linter/src/rules/avoid_setters_without_getters.dart';
import 'package:linter/src/rules/avoid_single_cascade_in_expression_statements.dart';
import 'package:linter/src/rules/avoid_slow_async_io.dart';
import 'package:linter/src/rules/avoid_types_as_parameter_names.dart';
import 'package:linter/src/rules/avoid_types_on_closure_parameters.dart';
import 'package:linter/src/rules/avoid_unused_constructor_parameters.dart';
import 'package:linter/src/rules/await_only_futures.dart';
import 'package:linter/src/rules/camel_case_types.dart';
import 'package:linter/src/rules/cancel_subscriptions.dart';
import 'package:linter/src/rules/cascade_invocations.dart';
import 'package:linter/src/rules/close_sinks.dart';
import 'package:linter/src/rules/comment_references.dart';
import 'package:linter/src/rules/constant_identifier_names.dart';
import 'package:linter/src/rules/control_flow_in_finally.dart';
import 'package:linter/src/rules/curly_braces_in_flow_control_structures.dart';
import 'package:linter/src/rules/directives_ordering.dart';
import 'package:linter/src/rules/empty_catches.dart';
import 'package:linter/src/rules/empty_constructor_bodies.dart';
import 'package:linter/src/rules/empty_statements.dart';
import 'package:linter/src/rules/file_names.dart';
import 'package:linter/src/rules/hash_and_equals.dart';
import 'package:linter/src/rules/implementation_imports.dart';
import 'package:linter/src/rules/invariant_booleans.dart';
import 'package:linter/src/rules/iterable_contains_unrelated_type.dart';
import 'package:linter/src/rules/join_return_with_assignment.dart';
import 'package:linter/src/rules/library_names.dart';
import 'package:linter/src/rules/library_prefixes.dart';
import 'package:linter/src/rules/lines_longer_than_80_chars.dart';
import 'package:linter/src/rules/list_remove_unrelated_type.dart';
import 'package:linter/src/rules/literal_only_boolean_expressions.dart';
import 'package:linter/src/rules/no_adjacent_strings_in_list.dart';
import 'package:linter/src/rules/no_duplicate_case_values.dart';
import 'package:linter/src/rules/non_constant_identifier_names.dart';
import 'package:linter/src/rules/null_closures.dart';
import 'package:linter/src/rules/omit_local_variable_types.dart';
import 'package:linter/src/rules/one_member_abstracts.dart';
import 'package:linter/src/rules/only_throw_errors.dart';
import 'package:linter/src/rules/overridden_fields.dart';
import 'package:linter/src/rules/package_api_docs.dart';
import 'package:linter/src/rules/package_prefixed_library_names.dart';
import 'package:linter/src/rules/parameter_assignments.dart';
import 'package:linter/src/rules/prefer_adjacent_string_concatenation.dart';
import 'package:linter/src/rules/prefer_asserts_in_initializer_lists.dart';
import 'package:linter/src/rules/prefer_bool_in_asserts.dart';
import 'package:linter/src/rules/prefer_collection_literals.dart';
import 'package:linter/src/rules/prefer_conditional_assignment.dart';
import 'package:linter/src/rules/prefer_const_constructors.dart';
import 'package:linter/src/rules/prefer_const_constructors_in_immutables.dart';
import 'package:linter/src/rules/prefer_const_declarations.dart';
import 'package:linter/src/rules/prefer_const_literals_to_create_immutables.dart';
import 'package:linter/src/rules/prefer_constructors_over_static_methods.dart';
import 'package:linter/src/rules/prefer_contains.dart';
import 'package:linter/src/rules/prefer_equal_for_default_values.dart';
import 'package:linter/src/rules/prefer_expression_function_bodies.dart';
import 'package:linter/src/rules/prefer_final_fields.dart';
import 'package:linter/src/rules/prefer_final_locals.dart';
import 'package:linter/src/rules/prefer_foreach.dart';
import 'package:linter/src/rules/prefer_function_declarations_over_variables.dart';
import 'package:linter/src/rules/prefer_generic_function_type_aliases.dart';
import 'package:linter/src/rules/prefer_initializing_formals.dart';
import 'package:linter/src/rules/prefer_interpolation_to_compose_strings.dart';
import 'package:linter/src/rules/prefer_is_empty.dart';
import 'package:linter/src/rules/prefer_is_not_empty.dart';
import 'package:linter/src/rules/prefer_iterable_whereType.dart';
import 'package:linter/src/rules/prefer_single_quotes.dart';
import 'package:linter/src/rules/prefer_typing_uninitialized_variables.dart';
import 'package:linter/src/rules/pub/package_names.dart';
import 'package:linter/src/rules/public_member_api_docs.dart';
import 'package:linter/src/rules/recursive_getters.dart';
import 'package:linter/src/rules/slash_for_doc_comments.dart';
import 'package:linter/src/rules/sort_constructors_first.dart';
import 'package:linter/src/rules/sort_unnamed_constructors_first.dart';
import 'package:linter/src/rules/super_goes_last.dart';
import 'package:linter/src/rules/test_types_in_equals.dart';
import 'package:linter/src/rules/throw_in_finally.dart';
import 'package:linter/src/rules/type_annotate_public_apis.dart';
import 'package:linter/src/rules/type_init_formals.dart';
import 'package:linter/src/rules/unawaited_futures.dart';
import 'package:linter/src/rules/unnecessary_brace_in_string_interps.dart';
import 'package:linter/src/rules/unnecessary_const.dart';
import 'package:linter/src/rules/unnecessary_getters_setters.dart';
import 'package:linter/src/rules/unnecessary_lambdas.dart';
import 'package:linter/src/rules/unnecessary_new.dart';
import 'package:linter/src/rules/unnecessary_null_aware_assignments.dart';
import 'package:linter/src/rules/unnecessary_null_in_if_null_operators.dart';
import 'package:linter/src/rules/unnecessary_overrides.dart';
import 'package:linter/src/rules/unnecessary_parenthesis.dart';
import 'package:linter/src/rules/unnecessary_statements.dart';
import 'package:linter/src/rules/unnecessary_this.dart';
import 'package:linter/src/rules/unrelated_type_equality_checks.dart';
import 'package:linter/src/rules/use_rethrow_when_possible.dart';
import 'package:linter/src/rules/use_setters_to_change_properties.dart';
import 'package:linter/src/rules/use_string_buffers.dart';
import 'package:linter/src/rules/use_to_and_as_if_applicable.dart';
import 'package:linter/src/rules/valid_regexps.dart';
import 'package:linter/src/rules/void_checks.dart';

void registerLintRules() {
  Analyzer.facade
    ..register(AlwaysDeclareReturnTypes())
    ..register(AlwaysPutControlBodyOnNewLine())
    ..register(AlwaysPutRequiredNamedParametersFirst())
    ..register(AlwaysRequireNonNullNamedParameters())
    ..register(AlwaysSpecifyTypes())
    ..register(AnnotateOverrides())
    ..register(AvoidAnnotatingWithDynamic())
    ..register(AvoidBoolLiteralsInConditionalExpressions())
    ..register(AvoidTypesOnClosureParameters())
    ..register(AvoidAs())
    ..register(AvoidCatchingErrors())
    ..register(AvoidCatchesWithoutOnClauses())
    ..register(AvoidClassesWithOnlyStaticMembers())
    ..register(AvoidDoubleAndIntChecks())
    ..register(AvoidEmptyElse())
    ..register(AvoidFieldInitializersInConstClasses())
    ..register(AvoidFunctionLiteralInForeachMethod())
    ..register(AvoidInitToNull())
    ..register(AvoidJsRoundedInts())
    ..register(AvoidNullChecksInEqualityOperators())
    ..register(AvoidPositionalBooleanParameters())
    ..register(AvoidPrivateTypedefFunctions())
    ..register(AvoidRelativeLibImports())
    ..register(AvoidRenamingMethodParameters())
    ..register(AvoidReturningNull())
    ..register(AvoidReturnTypesOnSetters())
    ..register(AvoidReturningThis())
    ..register(AvoidSettersWithoutGetters())
    ..register(AvoidSingleCascadeInExpressionStatements())
    ..register(AvoidSlowAsyncIo())
    ..register(AvoidTypesAsParameterNames())
    ..register(AvoidUnusedConstructorParameters())
    ..register(AwaitOnlyFutures())
    ..registerDefault(CamelCaseTypes())
    ..register(CancelSubscriptions())
    ..register(CascadeInvocations())
    ..register(CloseSinks())
    ..register(CommentReferences())
    ..register(ControlFlowInFinally())
    ..registerDefault(ConstantIdentifierNames())
    ..register(CurlyBracesInFlowControlStructures())
    ..register(DirectivesOrdering())
    ..register(EmptyCatches())
    ..registerDefault(EmptyConstructorBodies())
    ..register(EmptyStatements())
    ..register(FileNames())
    ..register(HashAndEquals())
    ..register(ImplementationImports())
    ..register(InvariantBooleans())
    ..register(IterableContainsUnrelatedType())
    ..register(JoinReturnWithAssignment())
    ..registerDefault(LibraryNames())
    ..registerDefault(LibraryPrefixes())
    ..register(LinesLongerThan80Chars())
    ..register(ListRemoveUnrelatedType())
    ..register(LiteralOnlyBooleanExpressions())
    ..register(NoAdjacentStringsInList())
    ..register(NoDuplicateCaseValues())
    ..registerDefault(NonConstantIdentifierNames())
    ..register(NullClosures())
    ..registerDefault(OneMemberAbstracts())
    ..register(OmitLocalVariableTypes())
    ..register(OnlyThrowErrors())
    ..register(OverriddenFields())
    ..register(PackageApiDocs())
    ..register(PackagePrefixedLibraryNames())
    ..register(ParameterAssignments())
    ..register(PreferAdjacentStringConcatenation())
    ..register(PreferBoolInAsserts())
    ..register(PreferCollectionLiterals())
    ..register(PreferConditionalAssignment())
    ..register(PreferConstConstructors())
    ..register(PreferConstConstructorsInImmutables())
    ..register(PreferConstDeclarations())
    ..register(PreferConstLiteralsToCreateImmutables())
    ..register(PreferAssertsInInitializerLists())
    ..register(PreferConstructorsInsteadOfStaticMethods())
    ..register(PreferContainsOverIndexOf())
    ..register(PreferEqualForDefaultValues())
    ..register(PreferExpressionFunctionBodies())
    ..register(PreferFinalFields())
    ..register(PreferFinalLocals())
    ..register(PreferForeach())
    ..register(PreferFunctionDeclarationsOverVariables())
    ..register(PreferGenericFunctionTypeAliases())
    ..register(PreferInitializingFormals())
    ..register(PreferInterpolationToComposeStrings())
    ..register(PreferIterableWhereType())
    ..register(PreferIsEmpty())
    ..register(PreferIsNotEmpty())
    ..register(PublicMemberApiDocs())
    ..register(PreferSingleQuotes())
    ..register(PreferTypingUninitializedVariables())
    ..register(PubPackageNames())
    ..register(RecursiveGetters())
    ..registerDefault(SlashForDocComments())
    ..register(SortConstructorsFirst())
    ..register(SortUnnamedConstructorsFirst())
    ..registerDefault(SuperGoesLast())
    ..register(TestTypesInEquals())
    ..register(ThrowInFinally())
    ..register(TypeAnnotatePublicApis())
    ..registerDefault(TypeInitFormals())
    ..register(UnawaitedFutures())
    ..registerDefault(UnnecessaryBraceInStringInterps())
    ..register(UnnecessaryConst())
    ..register(UnnecessaryNew())
    ..registerDefault(UnnecessaryNullAwareAssignments())
    ..registerDefault(UnnecessaryNullInIfNullOperators())
    // Disabled pending fix: https://github.com/dart-lang/linter/issues/35
    //..register(UnnecessaryGetters())
    ..register(UnnecessaryGettersSetters())
    ..register(UnnecessaryLambdas())
    ..register(UnnecessaryOverrides())
    ..register(UnnecessaryParenthesis())
    ..register(UnnecessaryStatements())
    ..register(UnnecessaryThis())
    ..register(UnrelatedTypeEqualityChecks())
    ..register(UseRethrowWhenPossible())
    ..register(UseSettersToChangeAProperty())
    ..register(UseStringBuffers())
    ..register(UseToAndAsIfApplicable())
    ..register(ValidRegExps())
    ..register(VoidChecks());
}
