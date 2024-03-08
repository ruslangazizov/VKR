//
//  SourceFileSyntaxRef.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax
import SwiftParser

final class SourceFileSyntaxRef {
    
    // Properties
    var value: SourceFileSyntax
    let absolutePath: String
    var classes: [ClassDeclSyntaxRef] = []
    
    // MARK: - Initialization
    
    init(value: SourceFileSyntax, absolutePath: String) {
        self.value = value
        self.absolutePath = absolutePath
    }
    
    // MARK: - Internal
    
    func writeOnDisk() {
        try? value.description.write(toFile: absolutePath, atomically: true, encoding: .utf8)
    }
    
    func restoreDiskState() {
        guard let file = try? String(contentsOfFile: absolutePath) else { return }
        value = Parser.parse(source: file)
        classes.forEach { classRef in
            classRef.restoreStateFromFile()
        }
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
