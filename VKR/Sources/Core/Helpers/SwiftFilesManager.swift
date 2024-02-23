//
//  SwiftFilesManager.swift
//  VKR
//
//  Created by r.a.gazizov on 17.02.2024.
//

import SwiftGraph
import SwiftParser
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
}

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

enum ImplicitClassUsagePlace: Equatable {
    case storedPropertyInit(_ usedMembers: [String], propertyName: String)
    case funcBody(_ usedMembers: [String])
    case initializerWithStoredProperty(_ usedMembers: [String])
}

final class SwiftFilesManager {
    
    // Properties
    private let swiftFilesAbsolutePaths: [String]
    // classes for which user discarded the suggested changes
    var discardedClasses: [String] = []
    
    // MARK: - Initialization
    
    init(swiftFilesAbsolutePaths: [String]) {
        self.swiftFilesAbsolutePaths = swiftFilesAbsolutePaths
    }
    
    // MARK: - Internal
    
    func startAnalysis() {
        let files = getFileRefsFromPaths()
        let classes: [ClassDeclSyntaxRef] = findClasses(in: files)
        guard !classes.isEmpty else { print("!!! не найдено ни одного класса"); return }
        
        let graph = makeGraph(from: classes)
        guard !graph.isEmpty else { print("!!! алгоритм не нашел неявные зависимости"); return }
        
        print(graph)
        for vertexNumber in 0..<graph.vertices.count {
            let currentClassRef = graph.vertices[vertexNumber]
            let currentClassProtocolName = "I\(currentClassRef.value.name.text)"
            for neighbor in graph.neighborsForIndexWithWeights(vertexNumber) {
                let referringNeighborClassRef = neighbor.0
                switch neighbor.1 {
                case .storedPropertyInit(let classMemberTypes, let name): break
                case .funcBody(let classMemberTypes): break
                case .initializerWithStoredProperty(let classMemberTypes): break
                }
            }
        }
        
//        updateFiles(in: classes)
//        files.forEach { fileRef in
//            print(fileRef.value.description, terminator: "----------------------------\n")
//        }
    }
    
    // MARK: - Private
    
    private func getFileRefsFromPaths() -> [SourceFileSyntaxRef] {
        return swiftFilesAbsolutePaths.compactMap { path in
            guard let file = try? String(contentsOfFile: path) else { return nil }
            return SourceFileSyntaxRef(value: Parser.parse(source: file), absolutePath: path)
        }
    }
    
    private func findClasses(in files: [SourceFileSyntaxRef]) -> [ClassDeclSyntaxRef] {
        var classes: [ClassDeclSyntaxRef] = []
        files.forEach { file in
            file.value.statements.enumerated().forEach { offset, codeBlockItem in
                if case .decl(let decl) = codeBlockItem.item {
                    if let classDecl = decl.as(ClassDeclSyntax.self),
                       !discardedClasses.contains(where: { $0 == classDecl.name.text}) {
                        classes.append(ClassDeclSyntaxRef(file: file,
                                                fileStatementNumber: offset,
                                                value: classDecl))
                    }
                }
            }
        }
        return classes
    }
    
    private func makeGraph(from classes: [ClassDeclSyntaxRef]) -> WeightedGraph<ClassDeclSyntaxRef, ImplicitClassUsagePlace> {
        let graph = WeightedGraph<ClassDeclSyntaxRef, ImplicitClassUsagePlace>(vertices: classes)
        let classesNames = classes.names
        for classRef in classes {
            classRef.value.memberBlock.members.forEach { memberBlockItem in
                if let varDecl = memberBlockItem.decl.as(VariableDeclSyntax.self) {
                    let patternBindingSyntax = varDecl.bindings.first!
                    if let varName = patternBindingSyntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                       let initializer = patternBindingSyntax.initializer, // check if property has default value
                       let funcCallExpr = initializer.value.as(FunctionCallExprSyntax.self),
                       let declReferenceExpr = funcCallExpr.calledExpression.as(DeclReferenceExprSyntax.self) {
                        let typeName = declReferenceExpr.baseName.text
                        if let toClassRef = classes.first(className: typeName) {
                            let finder = PropertyUsagesFinder(propertyName: varName)
                            finder.walk(classRef.value.memberBlock.members)
                            graph.addEdge(from: toClassRef,
                                          to: classRef,
                                          weight: .storedPropertyInit(finder.usedMembers, propertyName: varName),
                                          directed: true)
                        }
                    }
                } else if let funcDecl = memberBlockItem.decl.as(FunctionDeclSyntax.self),
                          let codeBlock = funcDecl.body {
                    codeBlock.statements.forEach { codeBlockItem in
                        if case .decl(let decl) = codeBlockItem.item,
                           let varDecl = decl.as(VariableDeclSyntax.self),
                           let patternBinding = varDecl.bindings.first,
                           let varName = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                           let funcCallExpr = patternBinding.initializer?.value.as(FunctionCallExprSyntax.self),
                           let declReferenceExpr = funcCallExpr.calledExpression.as(DeclReferenceExprSyntax.self) {
                            let typeName = declReferenceExpr.baseName.text
                            if let toClassRef = classes.first(className: typeName) {
                                let finder = PropertyUsagesFinder(propertyName: varName)
                                finder.walk(codeBlock)
                                graph.addEdge(from: toClassRef,
                                              to: classRef,
                                              weight: .funcBody(finder.usedMembers),
                                              directed: true)
                            }
                        }
                    }
                } else if let initDecl = memberBlockItem.decl.as(InitializerDeclSyntax.self) {
                    initDecl.signature.parameterClause.parameters.forEach { functionParameter in
                        let varName = functionParameter.firstName.text
                        let typeName = functionParameter.type.description
                        if let toClassRef = classes.first(className: typeName) {
                            let finder = PropertyUsagesFinder(propertyName: varName)
                            finder.walk(classRef.value.memberBlock.members)
                            graph.addEdge(from: toClassRef,
                                          to: classRef,
                                          weight: .initializerWithStoredProperty(finder.usedMembers),
                                          directed: true)
                        }
                    }
                }
            }
        }
        return graph
    }
    
    // Update files based on modified classes
    private func updateFiles(in classes: [ClassDeclSyntaxRef]) {
        classes.forEach { classRef in
            let statements = classRef.file.value.statements.replacing(
                childAt: classRef.fileStatementNumber,
                with: CodeBlockItemSyntax(item: .decl(.init(classRef.value)))
            )
            classRef.file.value = classRef.file.value.with(\.statements, statements)
        }
    }
}

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
