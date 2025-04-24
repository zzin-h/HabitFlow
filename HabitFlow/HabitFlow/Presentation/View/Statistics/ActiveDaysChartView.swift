//
//  ActiveDaysChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import SwiftUI

struct ActiveDaysChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ActiveDaysCalendarView(viewModel: viewModel)
            StatisticsSummaryView(viewModel: viewModel, completedDates: viewModel.completedDates)
        }
        .onAppear {
            viewModel.loadActiveDaysStat()
        }
    }
}

struct ActiveDaysCalendarView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text("\(viewModel.currentMonth.year.description)년 \(viewModel.currentMonth.month)월")
                    .font(.headline)
                
                Button(action: {
                    viewModel.nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            HStack {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.days) { dayCell in
                    VStack {
                        let day = Calendar.current.component(.day, from: dayCell.date)
                        
                        Text("\(day)")
                            .fontWeight(Calendar.current.isDateInToday(dayCell.date) ? .bold : .regular)
                            .foregroundColor(
                                Calendar.current.isDateInToday(dayCell.date) ? .blue :
                                    (dayCell.isInCurrentMonth ? .primary : .gray)
                            )
                        
                        if dayCell.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Spacer().frame(height: 24)
                        }
                    }
                    .frame(height: 50)
                }
            }
        }
        .onAppear {
            viewModel.fetchAndGenerateDays()
        }
    }
}

struct StatisticsSummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    let completedDates: [Date]
    
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let year = viewModel.currentMonth.year
        let month = viewModel.currentMonth.month
        
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return AnyView(EmptyView())
        }
        
        guard let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return AnyView(EmptyView())
        }
        
        if monthStart > today {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text("📅 통계 요약")
                        .font(.headline)
                    Text("미래의 날짜로 왔어요.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            )
        }
        
        let rangeEnd = min(today, monthEnd)
        
        let monthCompletedDates = completedDates.filter { $0 >= monthStart && $0 <= rangeEnd }
        let totalDays = calendar.dateComponents([.day], from: monthStart, to: rangeEnd).day! + 1
        let completionRate = Int(Double(monthCompletedDates.count) / Double(totalDays) * 100)
        
        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                Text("📅 통계 요약")
                    .font(.headline)
                
                if let stat = viewModel.activeDaysStat {
                    HStack {
                        Text("✅ 총 완료 일수")
                        Spacer()
                        Text("\(stat.totalDays)일")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("📈 연속 기록 일수")
                        Spacer()
                        Text("\(stat.streakDays)일")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("🗓️ \(month)월 달성률")
                        Spacer()
                        Text("\(completionRate)%")
                            .foregroundColor(.purple)
                            .fontWeight(.bold)
                    }
                    
                    Text("\(formatDate(monthStart)) ~ \(formatDate(rangeEnd))일 간의 달성 기록이에요.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    if let breakGap = viewModel.longestBreakGap(from: monthCompletedDates) {
                        let adjustedStart = calendar.date(byAdding: .day, value: 1, to: breakGap.start)
                        let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: breakGap.end)
                        
                        HStack {
                            Text("😴 가장 오래 쉰 구간")
                            Spacer()
                            Text("\(formatDate(adjustedStart!)) ~ \(formatDate(adjustedEnd!)) (\(breakGap.days)일)")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                        }
                    } else {
                        HStack {
                            Text("😴 가장 오래 쉰 구간")
                            Spacer()
                            Text("충분한 데이터 없음")
                                .foregroundColor(.gray)
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)")
                } else {
                    ProgressView()
                }
            }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
