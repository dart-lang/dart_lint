import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Static checks on "dart:ffi".';

const _details = r'''
Applies static rules of the "dart:ffi" package.
See the "dart:ffi" API documentation for details.
''';

class Ffi extends LintRule implements NodeLintRule {
  Ffi()
      : super(
            name: 'ffi',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const LintCode invalidSuperclass = LintCode(
      'ffi', //
      '{0} may not be extended.',
      correction: 'Considering extending dart:ffi.Struct instead.');

  static const LintCode invalidSupertype = LintCode(
      'ffi', //
      '{0} may not be implemented.',
      correction: 'Considering extending dart:ffi.Struct instead.');

  static const LintCode genericStruct = LintCode(
      'ffi', //
      'Subclasses of Struct may not be generic.');

  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  bool _isFfiCoreClass(TypeName cls) {
    final Element target = cls.name.staticElement;
    if (target is ClassElement) {
      return target.library.name == 'dart.ffi';
    }
    return false;
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    bool isStruct = false;

    // Only the Struct class may be extended.
    if (node.extendsClause != null) {
      final TypeName superclass = node.extendsClause.superclass;
      if (_isFfiCoreClass(superclass) && !isStruct) {
        if (superclass.name.staticElement.name == 'Struct') {
          isStruct = true;
        } else {
          rule.reportLint(superclass.name,
              errorCode: invalidSuperclass, arguments: [superclass.name]);
        }
      }
    }

    // No classes from the FFI may be explicitly implemented.
    void checkSupertype(TypeName typename) {
      if (_isFfiCoreClass(typename)) {
        rule.reportLint(typename.name,
            errorCode: invalidSupertype, arguments: [typename.name]);
      }
    }

    node.implementsClause?.interfaces?.forEach(checkSupertype);
    node.withClause?.mixinTypes?.forEach(checkSupertype);

    if (isStruct && node.declaredElement.typeParameters?.isNotEmpty == true) {
      rule.reportLint(node.name, errorCode: genericStruct);
    }
  }
}
