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
        .navigationTitle(String(localized: "active_days"))
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
                    viewModel.fetchAndGenerateDays()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text("\(formatDate(viewModel.currentMonth))")
                    .font(.headline)
                
                Button(action: {
                    viewModel.nextMonth()
                    viewModel.fetchAndGenerateDays()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            HStack {
                ForEach(Weekdays.allCases, id: \.self) { day in
                    Text(day.shortTitle)
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
                                .opacity(dayCell.isInCurrentMonth ? 1 : 0.6)
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
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    viewModel.nextMonth()
                                    viewModel.fetchAndGenerateDays()
                                } else if value.translation.width > 50 {
                                    viewModel.previousMonth()
                                    viewModel.fetchAndGenerateDays()
                                }
                            }
                    )
                }
            }
            .frame(height: 300)
        }
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .onAppear {
            viewModel.fetchAndGenerateDays()
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("YYYYMMM")
        return formatter.string(from: date)
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
                        
                        Text(NSLocalizedString("future_date_notice", comment: "future_date_notice"))
                            .foregroundColor(.gray)
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                    }
                }
                
                if let stat = viewModel.activeDaysStat {
                    HStack {
                        Text(NSLocalizedString("total_completed_days", comment: ""))
                        
                        Spacer()
                        
                        Text("\(stat.totalDays)" + NSLocalizedString("days", comment: "days"))
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text(NSLocalizedString("consecutive_active_days", comment: ""))
                        
                        Spacer()
                        
                        Text("\(stat.streakDays)" + NSLocalizedString("days", comment: "days"))
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text(String(format: NSLocalizedString("monthly_completion_rate", comment: ""), formatMonth(viewModel.currentMonth)))
                        
                        Spacer()
                        
                        Text("\(completionRate)%")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondaryColor)
                    }
                    
                    if monthStart <= today {
                        Text(String(format: NSLocalizedString("period_achievement", comment: ""), formatDate(monthStart), formatDate(rangeEnd)))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    if let breakGap = viewModel.longestBreakGap(from: monthCompletedDates) {
                        let adjustedStart = calendar.date(byAdding: .day, value: 1, to: breakGap.start)
                        let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: breakGap.end)
                        
                        if breakGap.days != 0 {
                            HStack {
                                Text(NSLocalizedString("longest_rest_period", comment: ""))
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("\(formatDate(adjustedStart!)) - \(formatDate(adjustedEnd!))")
                                    Text(" (\(breakGap.days) " + NSLocalizedString("days", comment: "days") + ")")
                                }
                                .foregroundColor(Color.primaryColor)
                                .fontWeight(.bold)
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            
                            Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
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
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}
