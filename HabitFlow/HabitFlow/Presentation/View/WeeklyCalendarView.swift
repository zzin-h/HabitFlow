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
    private let totalDays = 35
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
                .font(.headline)
                .padding(.horizontal)
            
            ScrollViewReader { scrollProxy in
                GeometryReader { geometry in
                    let itemWidth = geometry.size.width / 10
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(dateRange.enumerated()), id: \.1) { index, date in
                                VStack {
                                    Text(date.weekdayShortSymbol())
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(calendar.component(.day, from: date))")
                                        .fontWeight(.semibold)
                                        .frame(width: 36, height: 36)
                                        .background(
                                            calendar.isDate(selectedDate, inSameDayAs: date)
                                            ? Color.accentColor
                                            : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            calendar.isDate(selectedDate, inSameDayAs: date)
                                            ? .white
                                            : .primary
                                        )
                                        .clipShape(Circle())
                                }
                                .frame(width: itemWidth)
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
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return formatter.string(from: Date())
    }
}
