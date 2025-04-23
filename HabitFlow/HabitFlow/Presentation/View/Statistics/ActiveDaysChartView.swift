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
            if let stat = viewModel.activeDaysStat {
                Text("총 달성일: \(stat.totalDays)일")
                Text("연속 달성일: \(stat.streakDays)일")
            } else if let error = viewModel.errorMessage {
                Text("오류: \(error)")
            } else {
                ProgressView()
            }
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
            // 월 변경 헤더
            HStack {
                Button(action: {
                    $viewModel.previousMonth
                }) {
                    Image(systemName: "chevron.left")
                }

                Text(viewModel.monthTitle)
                    .font(.headline)

                Button(action: {
                    viewModel.nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // 요일 헤더
            HStack {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // 날짜 셀
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.days) { dayCell in
                    VStack {
                        if Calendar.current.isDateInToday(dayCell.date) {
                            Text("\(Calendar.current.component(.day, from: dayCell.date))")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        } else {
                            Text("\(Calendar.current.component(.day, from: dayCell.date))")
                        }

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
    }
}
