//
//  WeeklyCalendarView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @ObservedObject var viewModel: TodayHabitViewModel
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let totalDays = 21
    private var centerIndex: Int { totalDays / 2 }
    
    private var dateRange: [Date] {
        guard let start = calendar.date(byAdding: .day, value: -centerIndex, to: Date()) else {
            return []
        }
        return (0..<totalDays).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(formattedToday)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.textPrimary)
                .padding(.horizontal)
                .padding(.bottom, 6)
            
            ScrollViewReader { scrollProxy in
                GeometryReader { geometry in
                    let itemWidth = geometry.size.width / 10
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(dateRange.enumerated()), id: \.1) { index, date in
                                VStack {
                                    Text(date.weekdayShortSymbol())
                                        .font(.caption)
                                        .foregroundColor(
                                            calendar.isDate(selectedDate, inSameDayAs: date)
                                            ? .white
                                            : .textPrimary
                                        )
                                    
                                    Text("\(calendar.component(.day, from: date))")
                                        .fontWeight(.semibold)
                                        .frame(width: 40, height: 24)
                                        .foregroundColor(
                                            calendar.isDate(selectedDate, inSameDayAs: date)
                                            ? .white
                                            : .textPrimary
                                        )
                                }
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            calendar.isDate(selectedDate, inSameDayAs: date)
                                            ? Color.primaryColor
                                            : Color.gray.opacity(0.2)
                                        )
                                        .frame(width: itemWidth)
                                )
                                .onTapGesture {
                                    selectedDate = date
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .onAppear {
                        scrollProxy.scrollTo(centerIndex, anchor: .center)
                    }
                }
                .frame(height: 60)
            }
        }
    }
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return formatter.string(from: Date())
    }
}
