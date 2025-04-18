//
//  StatisticsOverviewView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct StatisticsOverviewView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var navigationSelection: StatisticsDetailType? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.overviewItems) { item in
                        NavigationLink(destination: TotalCompletedChartView(viewModel: viewModel)) {
//                            Button {
//                                navigationSelection = item.type
//                            } label: {
                                StatisticsCardView(item: item)
//                            }
//                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("전체 통계")
            .navigationDestination(for: StatisticsDetailType.self) { type in
                StatisticsDetailRouter.view(for: type, viewModel: viewModel)
            }
        }
    }
}
