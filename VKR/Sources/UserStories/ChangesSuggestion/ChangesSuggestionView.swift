//
//  ChangesSuggestionView.swift
//  VKR
//
//  Created by Руслан on 06.01.2024.
//

import SwiftUI

private extension Color {
    static let fileVersionsSeparator = Color(red: 0.188, green: 0.212, blue: 0.235)
    static let addedLine = Color(.displayP3, red: 0.114, green: 0.224, blue: 0.118)
    static let removedLine = Color(.displayP3, red: 0.247, green: 0.067, blue: 0.067)
    static let unchangedLine = Color(.displayP3, red: 0.145, green: 0.161, blue: 0.180)
    static let emptyLine = Color(.displayP3, red: 0.137, green: 0.149, blue: 0.169)
}

struct ChangesSuggestionView<ViewModel>: View where ViewModel: IChangesSuggestionViewModel {

    // Dependencies
    @ObservedObject var viewModel: ViewModel

    // MARK: - View

    var body: some View {
        ZStack {
            if let model = viewModel.model {
                VStack(spacing: .zero) {
                    ScrollView {
                        ForEach(0..<model.fileChangesModels.count, id: \.self) { index in
                            let model = model.fileChangesModels[index]
                            VStack(spacing: 0) {
                                Text(model.fileName)
                                    .font(.title2)
                                    .padding(6)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: .zero) {
                                    ForEach(0..<linesCount(for: model), id: \.self) { index in
                                        HStack(spacing: .zero) {
                                            makeLine(model.leftLines[index], isNumberBefore: false)
                                            
                                            Rectangle()
                                                .frame(width: 2)
                                                .foregroundColor(.fileVersionsSeparator)
                                            
                                            makeLine(model.rightLines[index], isNumberBefore: true)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            makeActionButton(action: { viewModel.didTapDiscardButton() },
                                             title: "Отклонить",
                                             systemImage: "xmark.circle",
                                             color: .red)
                            
                            makeActionButton(action: { viewModel.didTapAcceptButton() },
                                             title: "Принять",
                                             systemImage: "checkmark.circle",
                                             color: .green)
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    ProgressView("Выполняется анализ проекта...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .font(.title)
                        .padding()
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(16)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Custom Views
    
    private func makeActionButton(action: @escaping () -> Void,
                                  title: String,
                                  systemImage: String,
                                  color: Color) -> some View {
        Label(title, systemImage: systemImage)
            .padding(6)
            .font(.title3.bold())
            .background(color.opacity(0.6))
            .cornerRadius(5)
            .onTapGesture(perform: action)
    }

    private func makeLine(_ line: LineModel, isNumberBefore: Bool) -> some View {
        func makeLineNumber(_ line: LineModel, color: Color) -> some View {
            Text(line.line.map { "\($0)" } ?? "")
                .font(.system(size: 12))
                .fontDesign(.monospaced)
                .frame(minWidth: 20, maxHeight: .infinity, alignment: .topTrailing)
                .foregroundColor(.white)
                .background(color.opacity(0.5))
        }
        
        let color = lineColor(for: line.status)
        return Group {
            if isNumberBefore {
                makeLineNumber(line, color: color)
            }
            
            Rectangle()
                .frame(width: 6)
                .foregroundColor(color)
            
            Text(line.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .foregroundColor(.white)
                .background(color)
            
            if !isNumberBefore {
                makeLineNumber(line, color: color)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func linesCount(for fileChangesModel: FileChangesModel) -> Int {
        min(fileChangesModel.leftLines.count, fileChangesModel.rightLines.count)
    }

    private func lineColor(for lineStatus: LineModel.Status) -> Color {
        switch lineStatus {
        case .added:
            return Color.addedLine
        case .removed:
            return Color.removedLine
        case .unchanged:
            return Color.unchangedLine
        case .empty:
            return Color.emptyLine
        }
    }
}

// MARK: - Preview

struct ChangesSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        ChangesSuggestionView(viewModel: ChangesSuggestionViewModelMock())
    }
}
