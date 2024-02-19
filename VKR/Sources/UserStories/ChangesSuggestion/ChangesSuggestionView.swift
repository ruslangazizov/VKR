//
//  ChangesSuggestionView.swift
//  VKR
//
//  Created by Руслан on 06.01.2024.
//

import SwiftUI

private extension Color {
    static let fileNameBackground = Color(.displayP3, red: 0.173, green: 0.192, blue: 0.212)
    static let fileVersionsSeparator = Color(red: 0.188, green: 0.212, blue: 0.235)
    static let addedLine = Color(.displayP3, red: 0.114, green: 0.224, blue: 0.118)
    static let removedLine = Color(.displayP3, red: 0.247, green: 0.067, blue: 0.067)
    static let unchangedLine = Color(.displayP3, red: 0.145, green: 0.161, blue: 0.180)
    static let emptyLine = Color(.displayP3, red: 0.137, green: 0.149, blue: 0.169)
}

struct ChangesSuggestionView: View {

    // Dependencies
    private let viewModel = ChangesSuggestionMockViewModel()

    // MARK: - View

    var body: some View {
        VStack(spacing: .zero) {
            Text(viewModel.changesDescription)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding(.all, 8)
            
            HStack {
                Spacer()
                
                makeActionButton(action: { print(">>> did tap red button") },
                                 title: "Отклонить",
                                 systemImage: "xmark.circle",
                                 color: .red)
                
                Spacer()
                
                makeActionButton(action: { print(">>> did tap green button") },
                                 title: "Принять",
                                 systemImage: "checkmark.circle",
                                 color: .green)
                
                Spacer()
            }
            .frame(height: 35)
            
            ForEach(0..<viewModel.fileChangesModels.count, id: \.self) { index in
                let model = viewModel.fileChangesModels[index]
                VStack(spacing: 0) {
                    Text(model.fileName)
                        .font(.title2)
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.fileNameBackground)
                    
                    ScrollView {
                        VStack(spacing: .zero) {
                            ForEach(0..<linesCount(for: model), id: \.self) { index in
                                HStack(spacing: .zero) {
                                    makeLine(model.leftLines[index])
                                    
                                    Rectangle()
                                        .frame(width: 2)
                                        .foregroundColor(.fileVersionsSeparator)
                                    
                                    makeLine(model.rightLines[index])
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Custom Views
    
    private func makeActionButton(action: @escaping () -> Void,
                                  title: String,
                                  systemImage: String,
                                  color: Color) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.title3)
                .bold()
        }
        .background(color.opacity(0.6))
        .cornerRadius(5)
    }

    private func makeLine(_ line: LineModel) -> some View {
        let color = lineColor(for: line.status)
        return Group {
            Rectangle()
                .frame(width: 6)
                .foregroundColor(color)
            Text(line.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .background(color)
        }
    }
    
    // MARK: - Private Methods
    
    private func linesCount(for fileChangesModel: FileChangesModel) -> Int {
        max(fileChangesModel.leftLines.count, fileChangesModel.rightLines.count)
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
        ChangesSuggestionView()
    }
}
