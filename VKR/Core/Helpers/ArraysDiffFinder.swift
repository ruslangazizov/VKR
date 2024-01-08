//
//  ArraysDiffFinder.swift
//  VKR
//
//  Created by Руслан on 05.01.2024.
//

import IGListDiffKit

final class ArraysDiffFinder {

    func findDiff(_ lhsArray: [StringClass], _ rhsArray: [StringClass]) -> (inserts: [Int], deletes: [Int]) {
        let result = ListDiff(oldArray: lhsArray, newArray: rhsArray, option: .equality)
        print("inserts", result.inserts.map { $0 })
        print("deletes", result.deletes.map { $0 })
        print("updates", result.updates.map { $0 }) // думаю тут всегда будет пусто из-за текущей реализации StringClass
        print("moves", result.moves) // передвижения можно воспринимать как удаление строк на позициях from и добавление на позициях to

        let moves = result.moves.filter { $0.from != $0.to }
        let finalInserts = result.inserts + moves.map { $0.to }
        let finalDeletes = result.deletes + moves.map { $0.from }
        print("final inserts", finalInserts.sorted()) // эти строки нужно подсветить зеленым в новой версии файла
        print("final deletes", finalDeletes.sorted()) // эти строки нужно подсветить красным в старой версии файла
        return (finalInserts.sorted(), finalDeletes.sorted())
    }
}
