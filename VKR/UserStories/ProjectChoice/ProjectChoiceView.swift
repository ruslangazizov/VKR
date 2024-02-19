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
                        .navigationDestination(for: String.self) { _ in
                            ChangesSuggestionView()
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .blur(radius: viewModel.isAnalysisInProgress ? 5 : 0)
            .onTapGesture {
                makeFirstResponderNil()
            }
            .overlay(loadingOverlayView)
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
    
    @ViewBuilder private var loadingOverlayView: some View {
        if viewModel.isAnalysisInProgress {
            ZStack {
                Color(white: 0, opacity: 0.5)
                
                ProgressView("Выполняется анализ проекта...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .font(.title)
                    .padding()
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(16)
            }
        }
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
