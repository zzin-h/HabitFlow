//
//  BestHabitChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import SwiftUI
import Charts

struct BestHabitChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    
    private let categories = HabitCategory.allCases
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Picker("카테고리", selection: $viewModel.selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if viewModel.filteredHabits.isEmpty {
                Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 32)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
            } else {
                BestHabitGraphView(viewModel: viewModel)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .padding(.horizontal)
            }
            Divider()
            
            BestHabit3Summary(viewModel: viewModel)
        }
        .navigationTitle(String(localized: "best_habit"))
        .onAppear {
            viewModel.loadAllBestHabits()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    let currentIndex = categories.firstIndex(of: viewModel.selectedCategory) ?? 0
                    if value.translation.width < -threshold {
                        let nextIndex = min(currentIndex + 1, categories.count - 1)
                        viewModel.selectedCategory = categories[nextIndex]
                    } else if value.translation.width > threshold {
                        let prevIndex = max(currentIndex - 1, 0)
                        viewModel.selectedCategory = categories[prevIndex]
                    }
                }
        )
    }
}

private struct BestHabitGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var barHeight: CGFloat {
        if viewModel.filteredHabits.count < 5 {
            return 120
        } else if viewModel.filteredHabits.count < 7 {
            return 100
        } else if viewModel.filteredHabits.count < 9 {
            return 180
        } else if viewModel.filteredHabits.count < 11 {
            return 60
        } else {
            return 40
        }
    }
    
    var body: some View {
        ScrollView {
            Chart(viewModel.filteredHabits.sorted(by: { $0.count > $1.count })) { habit in
                BarMark(
                    x: .value("횟수", habit.count),
                    y: .value("습관", habit.title)
                )
                .foregroundStyle(habit.category.color)
                .annotation(position: .trailing) {
                    Text("\(habit.count)" + NSLocalizedString("times", comment: "times"))
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: CGFloat(viewModel.filteredHabits.count) * barHeight)
            
            Spacer()
        }
    }
}

private struct BestHabit3Summary: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var top1: BestHabitStat? {
        viewModel.top3Habits.indices.contains(0) ? viewModel.top3Habits[0] : nil
    }
    private var top2: BestHabitStat? {
        viewModel.top3Habits.indices.contains(1) ? viewModel.top3Habits[1] : nil
    }
    private var top3: BestHabitStat? {
        viewModel.top3Habits.indices.contains(2) ? viewModel.top3Habits[2] : nil
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("best_3", comment: "best_3"))
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.textPrimary)
                        .padding(.bottom, 16)
                    
                    Spacer()
                }
                
                if let top1 {
                    Top3Card(title: top1.title,
                             count: top1.count,
                             category: top1.category.title,
                             crownColor: .yellow,
                             font: .title3
                    )
                }
                
                HStack(spacing: 8) {
                    if let top2 {
                        Top3Card(title: top2.title,
                                 count: top2.count,
                                 category: top2.category.title,
                                 crownColor: .gray,
                                 font: .headline
                        )
                    }
                    
                    if let top3 {
                        Top3Card(title: top3.title,
                                 count: top3.count,
                                 category: top3.category.title,
                                 crownColor: Color(red: 205/255, green: 127/255, blue: 50/255),
                                 font: .headline
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct Top3Card: View {
    let title: String
    let count: Int
    let category: String
    let crownColor: Color
    let font: Font
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                
                Image(systemName: "crown.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(crownColor)
                
                Text(title)
                    .bold()
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.top, 8)
            .lineLimit(1)
            .truncationMode(.tail)
            
            HStack {
                Spacer()
                
                Text("\(count)" + NSLocalizedString("times", comment: "times"))
                
                Spacer()
                
                Text(category)
                
                Spacer()
            }
            .foregroundStyle(Color.textSecondary)
            .fontWeight(.regular)
            .padding(.bottom, 8)
        }
        .font(font)
        .background(Color.cardBg)
        .cornerRadius(8)
    }
}
