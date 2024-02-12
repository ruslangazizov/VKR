//
//  DirectoryChoiceView.swift
//  VKR
//
//  Created by Руслан on 08.01.2024.
//

import SwiftUI

struct DirectoryChoiceView: View {
    @State private var directoryURL: URL?

    var body: some View {
        VStack {
            Text("Selected directory: \(directoryURL?.path ?? "None")")
            Button("Choose directory") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                if panel.runModal() == .OK {
                    directoryURL = panel.url
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

//struct DirectoryChoiceView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        DirectoryChoiceView()
//    }
//}
