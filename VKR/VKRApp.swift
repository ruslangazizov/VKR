//
//  VKRApp.swift
//  VKR
//
//  Created by Руслан on 06.01.2024.
//

import SwiftUI

@main
struct VKRApp: App {

    private let presenter = ChangesSuggestionPresenter()

    var body: some Scene {
        WindowGroup(Constants.appName) {
            ChangesSuggestionView(changesDescription: presenter.changesDescription,
                                  fileChangesModels: presenter.fileChangesModels)
        }
    }
}
