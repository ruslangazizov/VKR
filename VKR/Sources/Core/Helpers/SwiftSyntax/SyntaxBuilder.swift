//
//  SyntaxBuilder.swift
//  VKR
//
//  Created by r.a.gazizov on 05.03.2024.
//

import SwiftSyntax

final class SyntaxBuilder {
    
    static func buildFunctionParameter(paramName: String, typeName: String) -> FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: .identifier(paramName),
            type: IdentifierTypeSyntax(leadingTrivia: .space, name: .identifier(typeName))
        )
    }
    
    static func buildInitBodyLine(propertyName: String) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(
            leadingTrivia: .newline + .indent(2),
            item: .expr(ExprSyntax(InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("self")),
                                                    name: .identifier(propertyName)),
                operator: AssignmentExprSyntax(leadingTrivia: .space, trailingTrivia: .space),
                rightOperand: DeclReferenceExprSyntax(baseName: .identifier(propertyName))
            )))
        )
    }
    
    static func buildTypeAnnotationWithLeadingSpace(_ typeName: String) -> TypeAnnotationSyntax {
        TypeAnnotationSyntax(type: IdentifierTypeSyntax(
            leadingTrivia: .space,
            name: .identifier(typeName)
        ))
    }
}
