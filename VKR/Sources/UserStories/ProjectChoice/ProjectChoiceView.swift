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
        NavigationStack(path: $viewModel.path) {
            VStack {
                Button("Выберите xcodeproj проект") {
                    viewModel.didTapSelectProjectButton()
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
                    
                    VStack(spacing: 20) {
                        Text("Выбранный проект: \(projectPath)")
                            .font(.title)
                            .bold()
                            .textSelection(.enabled)
                        
                        makeSwiftFileRegExpInputView(title: "Файлы для включения в анализ:",
                                                     text: $viewModel.includedFilesRegExp)
                        
                        makeSwiftFileRegExpInputView(title: "Файлы для исключения из анализа:",
                                                     text: $viewModel.excludedFilesRegExp)
                        
                        Button("Начать анализ") {
                            makeFirstResponderNil()
                            viewModel.didTapStartAnalysisButton()
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
            .navigationDestination(for: NavigationPathScreen.self) { screen in
                switch screen {
                case .changesSuggestion(let paths):
                    viewModel.createChangesSuggestionView(swiftFilesAbsolutePaths: paths)
                case .statistics:
                    viewModel.createStatisticsView()
                }
            }
        }
    }
    
    // MARK: - Custom Views
    
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
    
    // MARK: - Private Methods
    
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
