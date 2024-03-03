//
//  ClassDeclSyntaxRef.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax

final class ClassDeclSyntaxRef: Equatable, CustomStringConvertible {
    let file: SourceFileSyntaxRef
    let fileStatementNumber: Int
    var value: ClassDeclSyntax
    
    init(file: SourceFileSyntaxRef, fileStatementNumber: Int, value: ClassDeclSyntax) {
        self.file = file
        self.fileStatementNumber = fileStatementNumber
        self.value = value
    }
    
    static func == (lhs: ClassDeclSyntaxRef, rhs: ClassDeclSyntaxRef) -> Bool {
        return lhs.value.name.text == rhs.value.name.text
    }
    
    var description: String {
        value.name.text
    }
}
