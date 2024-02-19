//
//  StringClass.swift
//  VKR
//
//  Created by Руслан on 05.01.2024.
//

import IGListDiffKit

extension String {

    func toClass() -> StringClass {
        StringClass(self)
    }
}

final class StringClass: ListDiffable, ExpressibleByStringLiteral {

    // Properties
    let value: String

    // MARK: - Init

    init(_ value: String) {
        self.value = value
    }

    init(stringLiteral value: String) {
        self.value = value
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return value as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? StringClass else { return false }
        return value == object.value
    }
}
