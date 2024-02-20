//
//  ProjectChoiceViewModel.swift
//  VKR
//
//  Created by r.a.gazizov on 15.02.2024.
//

import SwiftUI
import XcodeProj
import UniformTypeIdentifiers

final class ProjectChoiceViewModel: ObservableObject {
    
    // Properties
    @Published var projectPath: String? // = "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example.xcodeproj"
    @Published var includedFilesRegExp: String = ""
    @Published var excludedFilesRegExp: String = ""
    @Published var isAnalysisInProgress = false
    @Published var path = NavigationPath()
    
    // MARK: - Internal
    
    func showPanel() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        if let t = UTType(tag: "xcodeproj", tagClass: .filenameExtension, conformingTo: .compositeContent) {
            panel.allowedContentTypes = [t]
        }
        if panel.runModal() == .OK {
            projectPath = panel.url?.path
        }
    }
    
    func startAnalysis() {
        guard let projectPath, let xcodeproj = try? XcodeProj(pathString: projectPath) else { return }
        isAnalysisInProgress = true
        
//        guard let desiredGroupName = projectPath.split(separator: "/").last?.split(separator: ".").first,
//              let group = xcodeproj.pbxproj.groups.first(where: { $0.path == String(desiredGroupName) }) else { return }
        let filesAbsolutePaths = convertToFilesAbsolutePaths(buildFiles: xcodeproj.pbxproj.buildFiles,
                                                             projectPath: projectPath)
        let filteredFilesAbsolutePaths = filterFilesAbsolutePaths(filesAbsolutePaths)
        print(filteredFilesAbsolutePaths.joined(separator: "\n"))
        
        let manager = SwiftFilesManager(swiftFilesAbsolutePaths: filesAbsolutePaths)
        DispatchQueue.global(qos: .userInitiated).async {
            manager.startAnalysis()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                // Navigate to next screen
                self.path.append(String(describing: ChangesSuggestionView.self)) // TODO: изменить на добавление модели
                self.isAnalysisInProgress = false
            }
        }
    }
    
    // MARK: - Private
    
    private func convertToFilesAbsolutePaths(buildFiles: [PBXBuildFile], projectPath: String) -> [String] {
        let filesRelativePaths = buildFiles.compactMap { buildFile -> String? in
            let file = buildFile.file!
            guard var path = file.path, path.hasSuffix("swift"), !path.contains("Tests") else { return nil }
            
            var parent = file.parent
            while parent != nil && parent!.path != nil {
                path = parent!.path! + "/" + path
                parent = parent!.parent
            }
            return path
        }
        let absolutePrefix = "/" + projectPath.split(separator: "/").dropLast(1).joined(separator: "/") + "/"
        return filesRelativePaths.map { absolutePrefix + $0 }
    }
    
    private func filterFilesAbsolutePaths(_ filesAbsolutePaths: [String]) -> [String] {
        let includedRegExp = try? NSRegularExpression(pattern: includedFilesRegExp, options: .caseInsensitive)
        let excludedRegExp = try? NSRegularExpression(pattern: excludedFilesRegExp, options: .caseInsensitive)
        guard includedRegExp != nil || excludedRegExp != nil else { return filesAbsolutePaths }
        
        return filesAbsolutePaths.filter { path in
            if let includedRegExp, let excludedRegExp {
                return includedRegExp.wholeMatches(path) && !excludedRegExp.wholeMatches(path)
            } else if let includedRegExp {
                return includedRegExp.wholeMatches(path)
            } else if let excludedRegExp {
                return !excludedRegExp.wholeMatches(path)
            } else {
                return true
            }
        }
    }
}
