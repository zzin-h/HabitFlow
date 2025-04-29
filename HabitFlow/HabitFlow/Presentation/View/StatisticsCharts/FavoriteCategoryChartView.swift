//
//  FavoriteCategoryChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/28/25.
//

import SwiftUI

struct FavoriteCategoryChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if !viewModel.categoryStatList.isEmpty {
                let slices = viewModel.makePieSlices()
                let maxSlice = slices.max(by: { $0.percentage < $1.percentage })
                
                Spacer()
                
                CategoryPieGraphView(slices: slices, maxSliceId: maxSlice?.id)
                
                Spacer()
                
                CategorySummaryView(viewModel: viewModel, maxTitle: maxSlice?.title)
                
                Spacer()
                
            } else {
                Text("데이터를 불러오는 중...")
            }
        }
        .onAppear {
            viewModel.loadAllCategoryStats()
        }
    }
}

private struct CategoryPieGraphView: View {
    var slices: [PieSlice]
    var maxSliceId: UUID?
    
    var body: some View {
        ZStack {
            ForEach(slices) { slice in
                Circle()
                    .trim(from: slice.startAngle.degrees / 360, to: slice.endAngle.degrees / 360)
                    .stroke(slice.color, lineWidth: 90)
                    .shadow(radius: 10)
                    .overlay(
                        VStack {
                            Text(slice.title)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(slice.id == maxSliceId ? .black : .clear)
                                .opacity(0.7)
                            Text("\(Int(slice.percentage * 100))%")
                                .font(.caption)
                                .foregroundColor(slice.id == maxSliceId ? .gray : .clear)
                                .opacity(0.7)
                        }
                    )
            }
        }
        .frame(width: 200, height: 200)
    }
}

private struct CategorySummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    var maxTitle: String?
    
    private var totalCount: Int {
        viewModel.categoryStatList.map(\.totalCount).reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("관심 카테고리")
                .font(.headline)
            
            ForEach(viewModel.categoryStatList) { stat in
                HStack {
                    Circle()
                        .fill(stat.color)
                        .frame(width: 12, height: 12)
                    
                    Text(stat.title)
                        .font(stat.title == maxTitle ? .headline : .subheadline)
                    
                    Spacer()
                    
                    Text("\(stat.totalCount)회")
                        .font(stat.title == maxTitle ? .headline : .subheadline)
                    
                    if totalCount > 0 {
                        let percentage = (Double(stat.totalCount) / Double(totalCount)) * 100
                        Text(String(format: "%.1f%%", percentage))
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .fontWeight(stat.title == maxTitle ? .bold : .medium)
                            .frame(width: 45, alignment: .trailing)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}
