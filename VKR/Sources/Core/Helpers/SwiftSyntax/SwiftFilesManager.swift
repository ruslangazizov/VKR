//
//  SwiftFilesManager.swift
//  VKR
//
//  Created by r.a.gazizov on 17.02.2024.
//

import SwiftGraph
import SwiftParser
import SwiftSyntax

typealias Graph = WeightedGraph<ClassDeclSyntaxRef, ImplicitClassUsagePlace>

enum ImplicitClassUsagePlace: Equatable {
    case storedPropertyInit(_ usedMembers: [String], propertyName: String)
    case funcBody(_ usedMembers: [String], propertyName: String)
    case initializerWithStoredProperty(_ usedMembers: [String])
    
    var usedMembers: [String] {
        switch self {
        case .storedPropertyInit(let usedMembers, _),
                .funcBody(let usedMembers, _),
                .initializerWithStoredProperty(let usedMembers):
            return usedMembers
        }
    }
}

final class SwiftFilesManager {
    
    // Properties
    private let swiftFilesAbsolutePaths: [String]
    
    // MARK: - Initialization
    
    init(swiftFilesAbsolutePaths: [String]) {
        self.swiftFilesAbsolutePaths = swiftFilesAbsolutePaths
    }
    
    // MARK: - Internal
    
    func createGraph() -> Graph? {
        let files = getFileRefsFromPaths()
        let classes = findClasses(in: files)
        guard !classes.isEmpty else { print("!!! не найдено ни одного класса"); return nil }
        
        let graph = makeGraph(from: classes)
        guard graph.edgeCount > 0 else { print("!!! алгоритм не нашел неявные зависимости"); return nil }
        
        return graph
    }
    
    func processIteration(_ iteration: Int, in graph: Graph) -> [SourceFileSyntaxRef]? {
        let vertexNumber = iteration
        guard let currentClassRef = graph.vertices[safe: vertexNumber] else { return nil }
        let currentClassName = currentClassRef.description
        let protocolName = "I\(currentClassName)"
        var protocolDesc = ProtocolDescription(name: protocolName)
        
        var usedMembers: Set<String> = []
        for neighbor in graph.neighborsForIndexWithWeights(vertexNumber) {
            usedMembers.formUnion(neighbor.1.usedMembers)
        }
        for classMember in usedMembers {
            for memberBlockItem in currentClassRef.value.memberBlock.members {
                if let varDecl = memberBlockItem.decl.as(VariableDeclSyntax.self),
                   let patternBindingSyntax = varDecl.bindings.first,
                   let varName = patternBindingSyntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                   varName == classMember {
                    if let idType = patternBindingSyntax.typeAnnotation?.type.as(IdentifierTypeSyntax.self) {
                        protocolDesc.properties.append(.init(name: varName, typeName: idType.name.text))
                        break
                    } else if let initializer = patternBindingSyntax.initializer,
                              let funcCallExpr = initializer.value.as(FunctionCallExprSyntax.self),
                              let declReferenceExpr = funcCallExpr.calledExpression.as(DeclReferenceExprSyntax.self) {
                        let typeName = declReferenceExpr.baseName.text
                        protocolDesc.properties.append(.init(name: varName, typeName: typeName))
                        break
                    }
                } else if let funcDecl = memberBlockItem.decl.as(FunctionDeclSyntax.self),
                          funcDecl.name.description == classMember {
                    let funcName = funcDecl.name.description
                    let returnTypeName = funcDecl.signature.returnClause?.type.description
                    var methodDesc = ProtocolDescription.MethodDescription(name: funcName,
                                                                           returnType: returnTypeName)
                    funcDecl.signature.parameterClause.parameters.forEach { funcParameter in
                        let argFirstName = funcParameter.firstName.description
                        let argSecondName = funcParameter.secondName?.description
                        let argType = funcParameter.type.description
                        methodDesc.args.append(.init(firstName: argFirstName,
                                                     secondName: argSecondName,
                                                     typeName: argType))
                    }
                    protocolDesc.methods.append(methodDesc)
                }
            }
        }
        
        guard !protocolDesc.properties.isEmpty || !protocolDesc.methods.isEmpty else { return [] }
        
        let protocolCodeBlock = protocolDesc.toProtocolCodeBlockItem()
        currentClassRef.file.addProtocolAfterClass(protocolCodeBlock, className: currentClassName)
        currentClassRef.addConformanceToProtocol(name: protocolName)
        currentClassRef.updateFile()
        
        var modifiedClassesRefs = [currentClassRef]
        for (referringClassRef, implicitUsagePlace) in graph.neighborsForIndexWithWeights(vertexNumber) {
            switch implicitUsagePlace {
            case .storedPropertyInit(_, let propertyName):
                for (memberIndex, var memberBlockItem) in referringClassRef.value.memberBlock.members.enumerated() {
                    if var varDecl = memberBlockItem.decl.as(VariableDeclSyntax.self),
                       var patternBindingSyntax = varDecl.bindings.first,
                       let varName = patternBindingSyntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                       varName == propertyName {
                        // Update stored property
                        patternBindingSyntax.typeAnnotation = SyntaxBuilder.buildTypeAnnotationWithLeadingSpace(protocolName)
                        patternBindingSyntax.initializer = nil
                        patternBindingSyntax.pattern.trailingTrivia = []
                        varDecl.bindings = varDecl.bindings.replacing(childAt: 0, with: patternBindingSyntax)
                        memberBlockItem.decl = DeclSyntax(varDecl)
                        referringClassRef.value.memberBlock.members = referringClassRef.value.memberBlock.members
                            .replacing(childAt: memberIndex, with: memberBlockItem)
                        break
                    }
                }
                // Update initializer or create a new one
                referringClassRef.addParameterToInitializer(paramName: propertyName, typeName: protocolName)
            
            case .funcBody(_, let propertyName):
                // Remove line with class initialization from function body
                for (memberIndex, var memberBlockItem) in referringClassRef.value.memberBlock.members.enumerated() {
                    if var funcDecl = memberBlockItem.decl.as(FunctionDeclSyntax.self),
                       var codeBlock = funcDecl.body {
                        for (index, codeBlockItem) in codeBlock.statements.enumerated() {
                            if case .decl(let decl) = codeBlockItem.item,
                               let varDecl = decl.as(VariableDeclSyntax.self),
                               let patternBinding = varDecl.bindings.first,
                               let funcCallExpr = patternBinding.initializer?.value.as(FunctionCallExprSyntax.self),
                               let declReferenceExpr = funcCallExpr.calledExpression.as(DeclReferenceExprSyntax.self) {
                                let typeName = declReferenceExpr.baseName.text
                                if typeName == currentClassName {
                                    codeBlock.statements = codeBlock.statements.removing(childAt: index)
                                    funcDecl.body = codeBlock
                                    memberBlockItem.decl = DeclSyntax(funcDecl)
                                    referringClassRef.value.memberBlock.members = referringClassRef.value.memberBlock.members
                                        .replacing(childAt: memberIndex, with: memberBlockItem)
                                    break
                                }
                            }
                        }
                    }
                }
                // Add private property
                let varMember = MemberBlockItemSyntax(decl: VariableDeclSyntax(
                    leadingTrivia: .newline + .indent,
                    modifiers: [DeclModifierSyntax(name: .keyword(.private))],
                    bindingSpecifier: .keyword(.let, leadingTrivia: .space, trailingTrivia: .space),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier(propertyName)),
                        typeAnnotation: SyntaxBuilder.buildTypeAnnotationWithLeadingSpace(protocolName)
                    )],
                    trailingTrivia: .newline
                ))
                let members = referringClassRef.value.memberBlock.members
                referringClassRef.value.memberBlock.members = [varMember] + members
                // Update initializer or create a new one
                referringClassRef.addParameterToInitializer(paramName: propertyName, typeName: protocolName)
            
            case .initializerWithStoredProperty:
                // Change concrete class type in initializer parameters and properties to protocol
                let newDesc = referringClassRef.value.description.replacing(currentClassName, with: protocolName)
                let sourceFileSyntax = Parser.parse(source: newDesc)
                guard let firstStatement = sourceFileSyntax.statements.first,
                      case .decl(let decl) = firstStatement.item,
                      let newClassDecl = decl.as(ClassDeclSyntax.self) else {
                    print("!!! не получилось распарсить класс с измененными типами")
                    continue
                }
                referringClassRef.value = newClassDecl
            }
            
            referringClassRef.updateFile()
            modifiedClassesRefs.append(referringClassRef)
        }
        
        var modifiedFilesRefs: [SourceFileSyntaxRef] = []
        var visitedFiles: Set<String> = []
        modifiedClassesRefs.forEach { classRef in
            let file = classRef.file
            if visitedFiles.insert(file.absolutePath).inserted {
                modifiedFilesRefs.append(file)
            }
        }
        return modifiedFilesRefs
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
            file.value.statements.forEach { codeBlockItem in
                if case .decl(let decl) = codeBlockItem.item,
                   let classDecl = decl.as(ClassDeclSyntax.self) {
                    let classRef = ClassDeclSyntaxRef(file: file, value: classDecl)
                    classes.append(classRef)
                    file.classes.append(classRef)
                }
            }
        }
        return classes
    }
    
    private func makeGraph(from classes: [ClassDeclSyntaxRef]) -> Graph {
        let graph = Graph(vertices: classes)
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
                                              weight: .funcBody(finder.usedMembers, propertyName: varName),
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
}
