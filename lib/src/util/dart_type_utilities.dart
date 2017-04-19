// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.util.dart_type_utilities;

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

typedef bool AstNodePredicate(AstNode node);

class DartTypeUtilities {
  static bool extendsClass(DartType type, String className, String library) =>
      isClass(type, className, library) ||
      (type is InterfaceType &&
          extendsClass(type.superclass, className, library));

  static Element getCanonicalElement(Element element) =>
      element is PropertyAccessorElement ? element.variable : element;

  static Element getCanonicalElementFromIdentifier(AstNode rawNode) {
    if (rawNode is Expression) {
      final node = rawNode.unParenthesized;
      if (node is Identifier) {
        return getCanonicalElement(node.bestElement);
      } else if (node is PropertyAccess) {
        return getCanonicalElement(node.propertyName.bestElement);
      }
    }
    return null;
  }

  static Statement getLastStatementInBlock(Block node) {
    if (node.statements.isEmpty) {
      return null;
    }
    final lastStatement = node.statements.last;
    if (lastStatement is Block) {
      return getLastStatementInBlock(lastStatement);
    }
    return lastStatement;
  }

  static bool hasInheritedMethod(MethodDeclaration node) =>
      lookUpInheritedMethod(node) != null;

  static bool implementsAnyInterface(
      DartType type, Iterable<InterfaceTypeDefinition> definitions) {
    if (type is! InterfaceType) {
      return false;
    }
    bool predicate(InterfaceType i) => definitions
        .any((d) => i.name == d.name && i.element.library.name == d.library);
    ClassElement element = type.element;
    return predicate(type) ||
        !element.isSynthetic &&
            type is InterfaceType &&
            element.allSupertypes.any(predicate);
  }

  static bool implementsInterface(
      DartType type, String interface, String library) {
    if (type is! InterfaceType) {
      return false;
    }
    bool predicate(InterfaceType i) =>
        i.name == interface && i.element.library.name == library;
    ClassElement element = type.element;
    return predicate(type) ||
        !element.isSynthetic &&
            type is InterfaceType &&
            element.allSupertypes.any(predicate);
  }

  static bool isClass(DartType type, String className, String library) =>
      type != null &&
      type.name == className &&
      type.element?.library?.name == library;

  static bool isNullLiteral(Expression expression) =>
      expression?.unParenthesized is NullLiteral;

  static PropertyAccessorElement lookUpGetter(MethodDeclaration node) =>
      (node.parent as ClassDeclaration)
          .element
          .lookUpGetter(node.name.name, node.element.library);

  static PropertyAccessorElement lookUpInheritedConcreteGetter(
          MethodDeclaration node) =>
      (node.parent as ClassDeclaration)
          .element
          .lookUpInheritedConcreteGetter(node.name.name, node.element.library);

  static PropertyAccessorElement lookUpInheritedConcreteSetter(
          MethodDeclaration node) =>
      (node.parent as ClassDeclaration)
          .element
          .lookUpInheritedConcreteSetter(node.name.name, node.element.library);

  static MethodElement lookUpInheritedMethod(MethodDeclaration node) =>
      (node.parent as ClassDeclaration)
          .element
          .lookUpInheritedMethod(node.name.name, node.element.library);

  static PropertyAccessorElement lookUpSetter(MethodDeclaration node) =>
      (node.parent as ClassDeclaration)
          .element
          .lookUpSetter(node.name.name, node.element.library);

  /// Builds the list resulting from traversing the node in DFS and does not
  /// include the node itself, it excludes the nodes for which the exclusion
  /// predicate returns true, if not provided, all is included.
  static Iterable<AstNode> traverseNodesInDFS(AstNode node,
      {AstNodePredicate excludeCriteria}) {
    final nodes = new LinkedHashSet<AstNode>();
    void recursiveCall(node) {
      if (node is AstNode &&
          (excludeCriteria == null || !excludeCriteria(node))) {
        nodes.add(node);
        node.childEntities.forEach(recursiveCall);
      }
    }

    node.childEntities.forEach(recursiveCall);
    return nodes;
  }

  static bool unrelatedTypes(DartType leftType, DartType rightType) {
    if (leftType == null ||
        leftType.isBottom ||
        leftType.isDynamic ||
        rightType == null ||
        rightType.isBottom ||
        rightType.isDynamic) {
      return false;
    }
    if (leftType == rightType ||
        leftType.isMoreSpecificThan(rightType) ||
        rightType.isMoreSpecificThan(leftType)) {
      return false;
    }
    final leftElement = leftType.element;
    final rightElement = rightType.element;
    if (leftElement is ClassElement && rightElement is ClassElement) {
      return leftElement.supertype.isObject ||
          leftElement.supertype != rightElement.supertype;
    }
    return false;
  }
}

class InterfaceTypeDefinition {
  final String name;
  final String library;

  InterfaceTypeDefinition(this.name, this.library);

  @override
  int get hashCode => name.hashCode ^ library.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is InterfaceTypeDefinition &&
        name == other.name &&
        library == other.library;
  }
}
