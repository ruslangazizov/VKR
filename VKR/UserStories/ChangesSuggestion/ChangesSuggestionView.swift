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

    // Properties
    let changesDescription: AttributedString
    let fileChangesModels: [FileChangesModel]

    // MARK: - View

    var body: some View {
        VStack(spacing: .zero) {
            Text(changesDescription)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.black)
            HStack {
                Spacer()
                Button(action: { print(">>> did tap red button") }) {
                    Label("Отклонить", systemImage: "xmark.circle")
                }
                .background(Color.red.opacity(0.6))
                .cornerRadius(5)
                Spacer()
                Button(action: { print(">>> did tap green button") }) {
                    Label("Принять", systemImage: "checkmark.circle")
                }
                .background(Color.green.opacity(0.6))
                .cornerRadius(5)
                Spacer()
            }
            .frame(height: 30)
            .background(Color.black)
            ForEach(0..<fileChangesModels.count, id: \.self) { index in
                let model = fileChangesModels[index]
                VStack {
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

    // MARK: - Private

    private func linesCount(for fileChangesModel: FileChangesModel) -> Int {
        max(fileChangesModel.leftLines.count, fileChangesModel.rightLines.count)
    }

    private func makeLine(_ line: LineModel) -> some View {
        let color = lineColor(for: line.status)
        return Group {
            Rectangle()
                .frame(width: 6)
                .foregroundColor(color)
            Text(line.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(color)
        }
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

//struct ChangesSuggestionView_Previews: PreviewProvider {
//
//    static let presenter = ChangesSuggestionPresenter()
//
//    static var previews: some View {
//        ChangesSuggestionView(changesDescription: presenter.changesDescription,
//                              fileChangesModels: presenter.fileChangesModels)
//    }
//}
