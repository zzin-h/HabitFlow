//
//  TodayHabitView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct TodayHabitView: View {
    @StateObject private var viewModel: TodayHabitViewModel

    init(viewModel: TodayHabitViewModel = TodayHabitDIContainer().makeTodayHabitViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            WeeklyCalendarView(selectedDate: $selectedDate)

            List {
                Section(header: Text("📋 해야 할 습관")) {
                    ForEach(viewModel.todos) { habit in
                        Button {
                            viewModel.markHabitCompleted(habit)
                        } label: {
                            HStack {
                                Text(habit.title)
                                Spacer()
                                if let goal = habit.goalMinutes {
                                    Text("\(goal)분")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("✅ 완료한 습관")) {
                    ForEach(viewModel.completed) { habit in
                        HStack {
                            Text(habit.title)
                            Spacer()
                            if let goal = habit.goalMinutes {
                                Text("\(goal)분")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .opacity(0.5)
                        .contentShape(Rectangle()) // 탭 무효화
                        .disabled(true)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .onAppear {
            viewModel.loadHabits(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.loadHabits(for: newDate)
        }
    }
}
