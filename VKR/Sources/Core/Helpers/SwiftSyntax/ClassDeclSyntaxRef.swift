//
//  ClassDeclSyntaxRef.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax

final class ClassDeclSyntaxRef: Equatable, CustomStringConvertible {
    
    // Properties
    let file: SourceFileSyntaxRef
    var value: ClassDeclSyntax
    
    // Computed properties
    var description: String {
        value.name.text
    }
    
    // MARK: - Initialization
    
    init(file: SourceFileSyntaxRef, value: ClassDeclSyntax) {
        self.file = file
        self.value = value
    }
    
    // MARK: - Equatable
    
    static func == (lhs: ClassDeclSyntaxRef, rhs: ClassDeclSyntaxRef) -> Bool {
        return lhs.value.name.text == rhs.value.name.text
    }
    
    // MARK: - Internal
    
    /// Update file based on modified class
    func updateFile() {
        let fileStatementNumber = file.value.statements.firstIndex { codeBlockItem in
            if case .decl(let decl) = codeBlockItem.item,
               let classDecl = decl.as(ClassDeclSyntax.self),
               classDecl.name.text == value.name.text {
                return true
            }
            return false
        }
        guard let fileStatementNumber else { return }
        
        let statements = file.value.statements.with(\.[fileStatementNumber],
                                                     CodeBlockItemSyntax(item: .decl(.init(value))))
        file.value = file.value.with(\.statements, statements)
    }
    
    func restoreStateFromFile() {
        for codeBlockItem in file.value.statements {
            if case .decl(let decl) = codeBlockItem.item,
               let classDecl = decl.as(ClassDeclSyntax.self),
               classDecl.name.text == value.name.text {
                value = classDecl
                return
            }
        }
    }
    
    func addConformanceToProtocol(name: String) {
        let inheritedType = InheritedTypeSyntax(leadingTrivia: .space,
                                                type: IdentifierTypeSyntax(name: .identifier(name)),
                                                trailingTrivia: .space)
        if var inheritanceClause = value.inheritanceClause, var lastType = inheritanceClause.inheritedTypes.last {
            lastType.type.trailingTrivia = []
            lastType = lastType.with(\.trailingComma, .commaToken())
            inheritanceClause.inheritedTypes = inheritanceClause.inheritedTypes
                .replacing(childAt: inheritanceClause.inheritedTypes.count - 1, with: lastType)
            inheritanceClause.inheritedTypes.append(inheritedType)
            value.inheritanceClause = inheritanceClause
        } else {
            value.name.trailingTrivia = []
            let inheritanceClause = InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax([inheritedType]))
            value.inheritanceClause = inheritanceClause
        }
    }
    
    /// Adds new parameter to existing initializer or creates a new one with one parameter
    func addParameterToInitializer(paramName: String, typeName: String) {
        var didUpdateInitBlock = false
        for (memberIndex, var memberBlockItem) in value.memberBlock.members.enumerated() {
            let members = value.memberBlock.members
            if var initDecl = memberBlockItem.decl.as(InitializerDeclSyntax.self),
                      var body = initDecl.body {
                // Update parameters
                var parameters = initDecl.signature.parameterClause.parameters
                if var lastParam = parameters.last {
                    lastParam.trailingComma = .commaToken(trailingTrivia: .space)
                    parameters = parameters.replacing(childAt: parameters.count - 1, with: lastParam)
                }
                parameters.append(SyntaxBuilder.buildFunctionParameter(paramName: paramName, typeName: typeName))
                initDecl.signature.parameterClause.parameters = parameters
                
                // Update initializer body
                body.statements.append(SyntaxBuilder.buildInitBodyLine(propertyName: paramName))
                initDecl.body = body
                
                memberBlockItem.decl = DeclSyntax(initDecl)
                value.memberBlock.members = members.replacing(childAt: memberIndex, with: memberBlockItem)
                didUpdateInitBlock = true
            }
        }
        
        if !didUpdateInitBlock {
            // Create new initializer for class since it does not have one
            let memberBlockItem = MemberBlockItemSyntax(decl: InitializerDeclSyntax(
                leadingTrivia: .newline + .newline + .indent,
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: [SyntaxBuilder.buildFunctionParameter(paramName: paramName, typeName: typeName)]
                    ),
                    trailingTrivia: .space
                ),
                body: CodeBlockSyntax(
                    statements: [SyntaxBuilder.buildInitBodyLine(propertyName: paramName)],
                    rightBrace: .rightBraceToken(leadingTrivia: .newline + .indent)
                ),
                trailingTrivia: .newline
            ))
            let members = value.memberBlock.members
            value.memberBlock.members = [memberBlockItem] + members
        }
    }
}
