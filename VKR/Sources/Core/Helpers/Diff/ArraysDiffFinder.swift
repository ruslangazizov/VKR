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
        var inserts = result.inserts
        var deletes = result.deletes
        for move in result.moves.filter({ $0.from >= $0.to }) {
            inserts.insert(move.to)
            deletes.insert(move.from)
        }
        
        var resultLhsArray: [LineModel] = []
        var resultRhsArray: [LineModel] = []
        let lhsArrayCount = lhsArray.count
        let rhsArrayCount = rhsArray.count
        
        var leftI = 0, rightI = 0
        while leftI < lhsArrayCount && rightI < rhsArrayCount {
            let isRemoved = deletes.contains(leftI)
            if isRemoved {
                resultLhsArray.append(LineModel(text: lhsArray[leftI], status: .removed))
                leftI += 1
            }
            let isAdded = inserts.contains(rightI)
            if isAdded {
                resultRhsArray.append(LineModel(text: rhsArray[rightI], status: .added))
                rightI += 1
            }
            if isRemoved && isAdded && lhsArray[leftI - 1] == rhsArray[rightI - 1] {
                resultLhsArray[resultLhsArray.count - 1].status = .unchanged
                resultRhsArray[resultRhsArray.count - 1].status = .unchanged
            }
            if !isRemoved && !isAdded {
                equalizeElementsCount(&resultLhsArray, &resultRhsArray)
                resultLhsArray.append(LineModel(text: lhsArray[leftI], status: .unchanged))
                leftI += 1
                resultRhsArray.append(LineModel(text: rhsArray[rightI], status: .unchanged))
                rightI += 1
            }
        }
        equalizeElementsCount(&resultLhsArray, &resultRhsArray)
        while leftI < lhsArrayCount {
            if deletes.contains(leftI) {
                resultLhsArray.append(LineModel(text: lhsArray[leftI], status: .removed))
            } else {
                resultLhsArray.append(LineModel(text: lhsArray[leftI], status: .unchanged))
            }
            leftI += 1
        }
        while rightI < rhsArrayCount {
            if inserts.contains(rightI) {
                resultRhsArray.append(LineModel(text: rhsArray[rightI], status: .added))
            } else {
                resultRhsArray.append(LineModel(text: rhsArray[rightI], status: .unchanged))
            }
            rightI += 1
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
