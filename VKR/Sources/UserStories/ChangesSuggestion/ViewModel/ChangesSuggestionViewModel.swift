//
//  ChangesSuggestionViewModel.swift
//  VKR
//
//  Created by r.a.gazizov on 05.03.2024.
//

import SwiftUI

protocol NavigationDelegate: AnyObject {
    func removeLastPathComponent()
}

final class ChangesSuggestionViewModel: IChangesSuggestionViewModel {
    
    // Dependencies
    private let manager: SwiftFilesManager
    private weak var navigationDelegate: NavigationDelegate?
    private let diffFinder = ArraysDiffFinder()
    
    // Properties
    @Published private(set) var model: ChangesSuggestionModel?
    private var graph: Graph?
    private var modifiedFilesRefs: [SourceFileSyntaxRef] = []
    private var currentIteration = -1
    
    // MARK: - Initialization
    
    init(manager: SwiftFilesManager, navigationDelegate: NavigationDelegate?) {
        self.manager = manager
        self.navigationDelegate = navigationDelegate
    }
    
    // MARK: - IChangesSuggestionViewModel
    
    func viewDidAppear() {
        guard let graph = manager.createGraph() else {
            goToPreviousScreenWithDelay()
            return
        }
        
        self.graph = graph
        makeIteration()
    }
    
    func didTapDiscardButton() {
        model = nil
        DispatchQueue.main.async { [self] in
            modifiedFilesRefs.forEach { fileRef in
                fileRef.restoreDiskState()
            }
            makeIteration()
        }
    }
    
    func didTapAcceptButton() {
        model = nil
        DispatchQueue.main.async { [self] in
            modifiedFilesRefs.forEach { fileRef in
                fileRef.writeOnDisk()
            }
            makeIteration()
        }
    }
    
    // MARK: - Private
    
    private func makeIteration() {
        guard let graph else { goToPreviousScreenWithDelay(); return }
        
        var fileChangesModels: [FileChangesModel] = []
        modifiedFilesRefs = []
        while modifiedFilesRefs.isEmpty {
            currentIteration += 1
            guard let refs = manager.processIteration(currentIteration, in: graph) else {
                print(">>> работа окончена, можно переходить на финальный экран")
                return
            }
            
            modifiedFilesRefs = refs
            fileChangesModels = modifiedFilesRefs.compactMap { convertFileRefToFileChangesModel($0) }
        }
        model = ChangesSuggestionModel(fileChangesModels: fileChangesModels)
    }
    
    private func goToPreviousScreenWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.navigationDelegate?.removeLastPathComponent()
        }
    }
    
    private func convertFileRefToFileChangesModel(_ fileRef: SourceFileSyntaxRef) -> FileChangesModel? {
        guard let originalFile = try? String(contentsOfFile: fileRef.absolutePath).splitByNewLineChar() else {
            return nil
        }
        
        let modifiedFile = fileRef.value.description.splitByNewLineChar()
        let (leftLines, rightLines) = diffFinder.findDiff(originalFile, modifiedFile)
        return FileChangesModel(fileName: fileRef.absolutePath, leftLines: leftLines, rightLines: rightLines)
    }
}
