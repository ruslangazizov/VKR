//
//  PropertyUsagesFinder.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax

final class PropertyUsagesFinder: SyntaxVisitor {
    let propertyName: String
    var usedMembers: [String] = []
    
    init(propertyName: String) {
        self.propertyName = propertyName
        super.init(viewMode: .sourceAccurate)
    }
    
    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        if let declReferenceExpr = node.base?.as(DeclReferenceExprSyntax.self) {
            if declReferenceExpr.baseName.text == propertyName {
                usedMembers.append(node.declName.baseName.text)
                return .skipChildren
            }
        }
        return .visitChildren
    }
}
