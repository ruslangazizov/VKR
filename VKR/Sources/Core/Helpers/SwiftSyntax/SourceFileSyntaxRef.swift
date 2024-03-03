//
//  SourceFileSyntaxRef.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax

final class SourceFileSyntaxRef {
    var value: SourceFileSyntax
    let absolutePath: String
    
    init(value: SourceFileSyntax, absolutePath: String) {
        self.value = value
        self.absolutePath = absolutePath
    }
    
    func writeOnDisk() {
        try? value.description.write(toFile: absolutePath, atomically: true, encoding: .utf8)
    }
    
    func addProtocolBeforeClass(_ protocolCodeBlockItem: CodeBlockItemSyntax, className: String) {
        var protocolStatementIndex = 0
        for (index, statement) in value.statements.enumerated() {
            if let classDecl = statement.item.as(ClassDeclSyntax.self),
               classDecl.name.text == className {
                protocolStatementIndex = index
                break
            }
        }
        let statements = value.statements.inserting(protocolCodeBlockItem, at: protocolStatementIndex)
        value = value.with(\.statements, statements)
    }
}
