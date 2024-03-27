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
        }
    }
}
