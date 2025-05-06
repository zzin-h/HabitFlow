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
            if viewModel.categoryStatList.isEmpty {
                VStack {
                    Spacer()
                    
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 90)
                        .shadow(radius: 10)
                    
                    Spacer()
                    
                    Text("충분한 데이터가 없습니다")
                        .foregroundColor(.gray)
                        .font(.headline)
                    
                    Spacer()
                    Spacer()
                }
                .frame(width: 200)
                
            } else {
                let slices = viewModel.makePieSlices()
                let maxSlice = slices.max(by: { $0.percentage < $1.percentage })
                
                Spacer()
                
                CategoryPieGraphView(slices: slices, maxSliceId: maxSlice?.id)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                
                Spacer()
                
                CategorySummaryView(viewModel: viewModel, maxTitle: maxSlice?.title)
                    .frame(height: UIScreen.main.bounds.height * 0.55)
                
                Spacer()
                
            }
        }
        .navigationTitle("관심 카테고리")
        .onAppear {
            viewModel.loadAllCategoryStats()
        }
    }
}

private struct CategoryPieGraphView: View {
    @State private var selectedSliceId: UUID?
    
    var slices: [PieSlice]
    var maxSliceId: UUID?
    
    var body: some View {
        ZStack {
            ForEach(slices) { slice in
                Circle()
                    .trim(from: slice.startAngle.degrees / 360, to: slice.endAngle.degrees / 360)
                    .stroke(slice.color, lineWidth: 90)
                    .opacity(slice.id == selectedSliceId ? 1 : 0.6)
                    .shadow(radius: 10)
                    .onTapGesture {
                        selectedSliceId = slice.id
                    }
                    .overlay(
                        VStack {
                            if let selectedSlice = slices.first(where: { $0.id == selectedSliceId }) {
                                VStack {
                                    Text(selectedSlice.title)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.black)
                                        .opacity(0.7)
                                    
                                    Text("\(Int(selectedSlice.percentage * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .opacity(0.7)
                                }
                            }
                        }
                    )
            }
        }
        .frame(width: 200, height: 200)
        .offset(y: 48)
    }
}

private struct CategorySummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    var maxTitle: String?
    
    private var totalCount: Int {
        viewModel.categoryStatList.map(\.totalCount).reduce(0, +)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.categoryStatList.sorted(by: { $0.totalCount > $1.totalCount })) { stat in
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
                                .foregroundColor(Color.textSecondary)
                                .fontWeight(stat.title == maxTitle ? .bold : .medium)
                                .frame(width: 56, alignment: .trailing)
                        }
                    }
                    .foregroundStyle(Color.textPrimary)
                    .padding(.vertical, 4)
                    
                    Divider()
                }
            }
            .padding()
            .background(Color.cardBg)
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(.top, 32)
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
