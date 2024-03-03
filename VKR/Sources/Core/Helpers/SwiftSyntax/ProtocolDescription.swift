//
//  ProtocolDescription.swift
//  VKR
//
//  Created by r.a.gazizov on 27.02.2024.
//

import SwiftSyntax
import SwiftParser

struct ProtocolDescription {
    struct PropertyDescription: Comparable {
        let name: String
        let typeName: String
        
        var description: String {
            "var \(name): \(typeName) { get }"
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.name < rhs.name
        }
    }
    
    struct MethodDescription: Comparable {
        struct Argument {
            let firstName: String
            let secondName: String?
            let typeName: String
            
            var description: String {
                var line = firstName
                if let secondName = secondName {
                    line += " " + secondName
                }
                line += ": " + typeName
                return line
            }
        }
        
        let name: String
        var args: [Argument] = []
        let returnType: String?
        
        var description: String {
            let argsLine = args.map(\.description).joined(separator: ", ")
            var line = "func \(name)(\(argsLine))"
            if let returnType = returnType {
                line += " -> " + returnType
            }
            return line
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.name < rhs.name
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
        }
    }
    
    let name: String
    var properties: [PropertyDescription] = []
    var methods: [MethodDescription] = []
    
    func toProtocolCodeBlockItem() -> CodeBlockItemSyntax {
        var lines: [String] = ["", "", "protocol \(name) {"]
        let indent = "    "
        if !properties.isEmpty {
            let propertiesLines = ["// Properties"] + properties.sorted().map(\.description)
            lines += propertiesLines.map { indent + $0 }
        }
        if !methods.isEmpty {
            let methodsLines = ["// Methods"] + methods.sorted().map(\.description)
            lines += methodsLines.map { indent + $0 }
        }
        lines.append("}")
        let source = lines.joined(separator: "\n")
        let sourceFileSyntax = Parser.parse(source: source)
        return sourceFileSyntax.statements.first!
    }
}
