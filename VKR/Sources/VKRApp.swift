//
//  VKRApp.swift
//  VKR
//
//  Created by Руслан on 06.01.2024.
//

import SwiftUI

@main
struct VKRApp: App {

    var body: some Scene {
        WindowGroup(Constants.appName) {
            ProjectChoiceView()
                .onAppear {
                    let manager = SwiftFilesManager(swiftFilesAbsolutePaths: [
                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/UserStories/Screen1Presenter.swift",
                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/Services/NetworkService.swift",
                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/Services/NestedGroup/DatabaseService.swift"
                    ])
                    manager.startAnalysis()
                }
        }
    }
}
