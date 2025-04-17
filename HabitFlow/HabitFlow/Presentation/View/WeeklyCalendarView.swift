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

    private var startOfWeek: Date {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
            return Date()
        }
        return startOfWeek
    }

    private var weekDates: [Date] {
        var dates = [Date]()
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(Weekdays.allCases, id: \.self) { day in
                    Text(day.koreanTitle)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .foregroundColor(.primary)
                        .font(.headline)
                }
            }
            .padding(.top)

            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack {
                        Text("\(calendar.component(.day, from: date))")
                            .padding(8)
                            .cornerRadius(10)
                            .background(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(calendar.isDate(selectedDate, inSameDayAs: date) ? .white : .primary)
                            .onTapGesture {
                                self.selectedDate = date
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

