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
                // TODO: удалить после завершения разработки
                .onAppear {
//                    let manager = SwiftFilesManager(swiftFilesAbsolutePaths: [
//                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/TestClasses.swift",
//                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/Services/NetworkService.swift",
//                        "/Users/r.a.gazizov/Desktop/VKR/VKR_Example/VKR_Example/Services/NestedGroup/DatabaseService.swift"
//                    ])
//                    let graph = manager.createGraph()
                }
        }
    }
}
