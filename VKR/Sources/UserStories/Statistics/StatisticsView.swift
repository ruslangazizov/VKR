//
//  StatisticsView.swift
//  VKR
//
//  Created by Руслан on 25.03.2024.
//

import SwiftUI

struct StatisticsView<ViewModel>: View where ViewModel: IStatisticsViewModel {
    
    // Dependencies
    @ObservedObject var viewModel: ViewModel
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Text("Метрики тестируемости")
                .font(.title)
                .bold()
                .padding(.top, 16)
            
            VStack {
                makeTable(for: viewModel.model.metrics)
            }
            
            Text("Формулы индекса тестируемости")
                .font(.title)
                .bold()
            
            makeTable(for: viewModel.model.formulas)
        }
    }
    
    // MARK: - Private
    
    private func makeTable(for rows: [StatisticsModel.Row]) -> some View {
        return Table(rows) {
            TableColumn("Название", value: \.name)
            TableColumn("Старое значение") { row in
                Text(truncatedDouble(row.previousValue))
            }
            TableColumn("Новое значение") { row in
                Text(truncatedDouble(row.newValue))
                    .foregroundColor(newValueColor(row: row))
            }
        }
    }
    
    private func truncatedDouble(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    private func newValueColor(row: StatisticsModel.Row) -> Color? {
        guard let improvementOrder = row.improvementOrder else {
            return nil
        }
        
        let positiveComparator: (Double, Double) -> Bool
        let negativeComparator: (Double, Double) -> Bool
        switch improvementOrder {
        case .moreIsBetter:
            positiveComparator = (>)
            negativeComparator = (<)
        case .lessIsBetter:
            positiveComparator = (<)
            negativeComparator = (>)
        }
        
        if positiveComparator(row.newValue, row.previousValue) {
            return .green
        } else if negativeComparator(row.newValue, row.previousValue) {
            return .red
        } else {
            return nil
        }
    }
}

// MARK: - Preview

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StatisticsView(viewModel: StatisticsViewModelMock())
        }
    }
}
