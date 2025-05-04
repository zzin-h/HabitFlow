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
                            .font(.title3)
                            .foregroundStyle(Color.primaryColor)
                            .rotationEffect(.degrees(320))
                        
                        Text("지난주 리포트")
                        
                        Spacer()
                        
                        Text(lastweek)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .font(.title2.bold())
                    .foregroundStyle(Color.textPrimary)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Text("매주 월요일마다 리포트가 갱신됩니다")
                            .font(.caption)
                            .foregroundStyle(Color(.systemGray2))
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "lightbulb.max.fill")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryColor)
                                .padding(.trailing, 8)
                            
                            Text("한 주간 ")
                            Text("\(summary.routineCount)개")
                                .bold()
                            Text("의 습관을 ")
                            Text("\(summary.totalCount)회 ")
                                .bold()
                            Text("실천했어요.")
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "lightbulb.max.fill")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryColor)
                                .padding(.trailing, 8)
                            
                            Text("가장 많이 실천한 습관은")
                        }
                        
                        let titles = summary.topRoutineName
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(titles.count, 2), id: \.self) { index in
                                HStack {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .foregroundStyle(Color.accentColor)
                                    Text(titles[index])
                                        .bold()
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
                                
                                Text("주로 ")
                                Text("\(weekday.koreanTitle)요일, \(time.title)")
                                    .bold()
                                Text("에 수행했어요.")
                            }
                        }
                        
                        if formatHour(summary.totalDuration) > 0 {
                            HStack(alignment: .center, spacing: 0) {
                                Image(systemName: "lightbulb.max.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryColor)
                                    .padding(.trailing, 8)
                                
                                Text("총 ")
                                Text("\(formatHour(summary.totalDuration))시간 \(formatMin(summary.totalDuration))분")
                                    .bold()
                                Text(" 동안 나를 위한 시간을 가졌어요.")
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBg)
                .cornerRadius(16)
            } else {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("충분한 데이터가 없습니다")
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
