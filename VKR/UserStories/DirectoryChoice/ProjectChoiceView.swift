//
//  ProjectChoiceView.swift
//  VKR
//
//  Created by Руслан on 08.01.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ProjectChoiceView: View {

    // Properties
    @State private var projectURL: URL? = URL(string: "/Users/ruslan/Desktop/VKR_old/VKR.xcodeproj")

    // MARK: - View

    var body: some View {
        VStack {
            Button("Выберите xcodeproj проект") {
                NSApp.keyWindow?.makeFirstResponder(nil)
                showPanel()
            }

            if let projectURL {
                Spacer().frame(height: 50)

                Text("Выбранный проект: \(projectURL.path)")
                    .font(.title)

                Spacer().frame(height: 20)

                Button {
                    print(">>> начат анализ")
                } label: {
                    Text("Начать анализ")
                        .padding(.all, 8)
                        .font(.title)
                        .background(.blue)
                        .cornerRadius(10)
                        .bold()
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private

    private func showPanel() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        if let t = UTType(tag: "xcodeproj", tagClass: .filenameExtension, conformingTo: .compositeContent) {
            panel.allowedContentTypes = [t]
        }
        if panel.runModal() == .OK {
            projectURL = panel.url
        }
    }
}

// MARK: - Preview

//struct ProjectChoiceView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ProjectChoiceView()
//    }
//}
