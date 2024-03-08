//
//  ArraysDiffFinder.swift
//  VKR
//
//  Created by Руслан on 05.01.2024.
//

import IGListDiffKit

final class ArraysDiffFinder {

    func findDiff(_ lhsArray: [String], _ rhsArray: [String]) -> (lhsArray: [LineModel], rhsArray: [LineModel]) {
        let result = ListDiff(oldArray: lhsArray.map { $0.toClass() },
                              newArray: rhsArray.map { $0.toClass() },
                              option: .equality)
        print("inserts", result.inserts.map { $0 })
        print("deletes", result.deletes.map { $0 })
        print("moves", result.moves)

        let moves = result.moves.filter { $0.from != $0.to }
        let finalInserts = result.inserts + moves.map { $0.to }
        let finalDeletes = result.deletes + moves.map { $0.from }
        print("final inserts", finalInserts.sorted()) // эти строки нужно подсветить зеленым в новой версии файла
        print("final deletes", finalDeletes.sorted()) // эти строки нужно подсветить красным в старой версии файла
        
        var resultLhsArray: [LineModel] = []
        var resultRhsArray: [LineModel] = []
        let lhsArrayCount = lhsArray.count
        let rhsArrayCount = rhsArray.count
        for i in 0..<max(lhsArrayCount, rhsArrayCount) {
            var isLineChanged = false
            if i < lhsArrayCount && finalDeletes.contains(i) {
                resultLhsArray.append(LineModel(text: lhsArray[i], status: .removed))
                isLineChanged = true
            }
            if i < rhsArrayCount && finalInserts.contains(i) {
                resultRhsArray.append(LineModel(text: rhsArray[i], status: .added))
                isLineChanged = true
            }
            if !isLineChanged {
                equalizeElementsCount(&resultLhsArray, &resultRhsArray)
                resultLhsArray.append(LineModel(text: lhsArray[i], status: .unchanged))
                resultRhsArray.append(LineModel(text: rhsArray[i], status: .unchanged))
            }
        }
        equalizeElementsCount(&resultLhsArray, &resultRhsArray)
        return (resultLhsArray, resultRhsArray)
    }
    
    // MARK: - Private
    
    private func equalizeElementsCount(_ resultLhsArray: inout [LineModel],
                                       _ resultRhsArray: inout [LineModel]) {
        let resultLhsArrayCount = resultLhsArray.count
        let resultRhsArrayCount = resultRhsArray.count
        if resultLhsArrayCount < resultRhsArrayCount {
            for _ in 0..<resultRhsArrayCount - resultLhsArrayCount {
                resultLhsArray.append(LineModel(text: "", status: .empty))
            }
        } else if resultRhsArrayCount < resultLhsArrayCount {
            for _ in 0..<resultLhsArrayCount - resultRhsArrayCount {
                resultRhsArray.append(LineModel(text: "", status: .empty))
            }
        }
    }
}
