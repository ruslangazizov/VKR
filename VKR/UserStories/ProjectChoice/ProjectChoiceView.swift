//
//  ProjectChoiceView.swift
//  VKR
//
//  Created by Руслан on 08.01.2024.
//

import SwiftUI

struct ProjectChoiceView: View {
    
    // Dependencies
    @ObservedObject private var viewModel = ProjectChoiceViewModel()
    
    // MARK: - View

    var body: some View {
        VStack {
            Button("Выберите xcodeproj проект") {
                viewModel.showPanel()
            }
            .buttonStyle(PlainButtonStyle())
            .font(.title2)
            .foregroundColor(.white)
            .padding(.all, 6)
            .background(Color.gray)
            .cornerRadius(8)
            .onAppear {
                makeFirstResponderNil()
            }

            if let projectPath = viewModel.projectPath {
                Spacer().frame(height: 30)

                VStack {
                    Text("Выбранный проект: \(projectPath)")
                        .font(.title)
                        .bold()
                    
                    makeSwiftFileRegExpInputView(title: "Файлы для включения в анализ:",
                                                 text: $viewModel.includedFilesRegExp)
                    
                    makeSwiftFileRegExpInputView(title: "Файлы для исключения из анализа:",
                                                 text: $viewModel.excludedFilesRegExp)
                    
                    Button("Начать анализ") {
                        viewModel.startAnalysis()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.all, 8)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            makeFirstResponderNil()
        }
    }
    
    // MARK: - Private
    
    private func makeSwiftFileRegExpInputView(title: String, text: Binding<String>) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .padding(.trailing, 8)
            
            TextField("", text: text, prompt: Text("Регулярное выражение"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text(".swift")
        }
        .font(.title3)
    }
    
    private func makeFirstResponderNil() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
}

// MARK: - Preview

struct ProjectChoiceView_Previews: PreviewProvider {

    static var previews: some View {
        ProjectChoiceView()
    }
}
