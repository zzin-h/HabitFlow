//
//  RoutineSummaryView.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/1/25.
//

import SwiftUI

struct RoutineSummaryView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    @State private var period: Period = .weekly(Date())
    
    let lastweek: String
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel(),
         lastweek: String) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.lastweek = lastweek
    }
    
    var body: some View {
        VStack {
            if let summary = viewModel.routineSummary {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(Color.primaryColor)
                            .rotationEffect(.degrees(320))
                        
                        Text(NSLocalizedString("weekly_report_title", comment: "weekly_report_title"))
                        
                        Spacer()
                        
                        Text(lastweek)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .font(.headline.bold())
                    .foregroundStyle(Color.textPrimary)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if summary.routineCount > 0 {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text(String(format: NSLocalizedString("weekly_report_summary", comment: ""), summary.routineCount, summary.totalCount))
                            }
                            
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text(NSLocalizedString("weekly_report_top_habit", comment: "weekly_report_top_habit"))
                            }
                        } else {
                            Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                                .foregroundStyle(Color.textSecondary)
                        }
                        
                        let titles = summary.topRoutineName
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(titles.count, 2), id: \.self) { index in
                                HStack {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .foregroundStyle(Color.accentColor)
                                    Text(titles[index])
                                }
                            }
                        }
                        .padding(.leading, 24)
                        .padding(.vertical, 6)
                        
                        if let weekday = summary.topWeekday, let time = summary.topTimeSlot {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text(String(format: NSLocalizedString("weekly_report_time_day", comment: ""), weekday.fullTitle, time.title))
                            }
                        }
                        
                        if formatHour(summary.totalDuration) > 59 {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text(String(format: NSLocalizedString("weekly_report_total_time", comment: ""), formatHour(summary.totalDuration), formatMin(summary.totalDuration)))
                            }
                        } else if formatHour(summary.totalDuration) > 0 {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text(String(format: NSLocalizedString("weekly_report_total_time_mins", comment: ""), formatMin(summary.totalDuration)))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBg)
                .cornerRadius(16)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text(NSLocalizedString("weekly_report_update_notice", comment: "weekly_report_update_notice"))
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray2))
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                
            } else {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                        .bold()
                        .foregroundStyle(Color.textSecondary)
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGroupedBackground))
        .onAppear{
            viewModel.loadSummary(for: period)
        }
    }
    
    private func formatHour(_ time: Int) -> Int {
        let hour = Int(time) / 60
        return hour
    }
    
    private func formatMin(_ time: Int) -> Int {
        let min = Int(time) % 60
        return min
    }
}
