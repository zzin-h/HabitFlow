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
            
            Spacer()
            
            ActiveDaysSummaryView(viewModel: viewModel, completedDates: viewModel.completedDates)
                .padding(.bottom, 48)
        }
        .navigationTitle("함께한 일수")
        .onAppear {
            viewModel.loadActiveDaysStat()
        }
    }
}

private struct ActiveDaysCalendarView: View {
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
                        
                        if viewModel.days.count > 35 {
                            Text("1")
                                .foregroundStyle(.clear)
                                .frame(height: 50)
                        }
                        
                        if dayCell.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26)
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Text("\(day)")
                                .fontWeight(Calendar.current.isDateInToday(dayCell.date) ? .bold : .regular)
                                .foregroundColor(
                                    Calendar.current.isDateInToday(dayCell.date) ? Color.accentColor :
                                        (dayCell.isInCurrentMonth ? Color.textPrimary : Color.textSecondary)
                                )
                        }
                    }
                    .frame(height: 50)
                }
            }
            .frame(height: 300)
        }
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .onAppear {
            viewModel.fetchAndGenerateDays()
        }
    }
}

private struct ActiveDaysSummaryView: View {
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
        
        let rangeEnd = min(today, monthEnd)
        
        let monthCompletedDates = completedDates.filter { $0 >= monthStart && $0 <= rangeEnd }
        let totalDays = calendar.dateComponents([.day], from: monthStart, to: rangeEnd).day! + 1
        let completionRate = Int(Double(monthCompletedDates.count) / Double(totalDays) * 100)
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                if monthStart > today {
                    HStack {
                        Spacer()
                        
                        Text("미래의 날짜로 왔습니다")
                            .foregroundColor(.gray)
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                    }
                }
                
                if let stat = viewModel.activeDaysStat {
                    HStack {
                        Text("총 완료 일수")
                        
                        Spacer()
                        
                        Text("\(stat.totalDays)일")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("연속 수행 일수")
                        
                        Spacer()
                        
                        Text("\(stat.streakDays)일")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("\(month)월 수행률")
                        
                        Spacer()
                        
                        Text("\(completionRate)%")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondaryColor)
                    }
                    
                    if monthStart <= today {
                        Text("\(formatDate(monthStart)) ~ \(formatDate(rangeEnd))일 간의 달성 기록이에요.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    if let breakGap = viewModel.longestBreakGap(from: monthCompletedDates) {
                        let adjustedStart = calendar.date(byAdding: .day, value: 1, to: breakGap.start)
                        let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: breakGap.end)
                        
                        if breakGap.days != 0 {
                            HStack {
                                Text("휴식 기간")
                                
                                Spacer()
                                
                                Text("\(formatDate(adjustedStart!)) ~ \(formatDate(adjustedEnd!)) (\(breakGap.days)일)")
                                    .foregroundColor(Color.primaryColor)
                                    .fontWeight(.bold)
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            
                            Text("충분한 기록이 없습니다")
                                .foregroundColor(.gray)
                                .font(.headline)
                        }
                    }
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
