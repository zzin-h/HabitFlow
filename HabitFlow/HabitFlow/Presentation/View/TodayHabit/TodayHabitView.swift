//
//  TodayHabitView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct TodayHabitView: View {
    @StateObject private var viewModel: TodayHabitViewModel
    @StateObject private var habitListViewModel: HabitListViewModel
    
    init(viewModel: TodayHabitViewModel = TodayHabitDIContainer().makeTodayHabitViewModel(),
         habitListViewModel: HabitListViewModel = HabitListDIContainer().makeHabitListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _habitListViewModel = StateObject(wrappedValue: habitListViewModel)
    }
    
    @State private var selectedDate: Date = Date()
    @State private var showingTimer = false
    @State private var selectedHabit: HabitModel?
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    NavigationIconView()
                    
                    WeeklyCalendarView(viewModel: viewModel, selectedDate: $selectedDate)
                    
                    List {
                        Section(header: Text("📋 해야 할 습관")) {
                            ForEach(viewModel.todos) { habit in
                                if let goal = habit.goalMinutes {
                                    
                                    Button {
                                        if goal != 0 {
                                            selectedHabit = habit
                                            showingTimer = true
                                        } else {
                                            viewModel.markHabitCompleted(habit)
                                        }
                                    } label: {
                                        HStack {
                                            Text(habit.title)
                                            Spacer()
                                            if goal != 0 {
                                                Text("\(goal)분 ⏰")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("✅ 완료한 습관")) {
                            ForEach(viewModel.completed) { habit in
                                if let goal = habit.goalMinutes {
                                    HStack {
                                        Text(habit.title)
                                        Spacer()
                                        if goal != 0 {
                                            Text("\(goal)분 ⏰")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .opacity(0.5)
                                    .contentShape(Rectangle())
                                    .disabled(true)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.blue)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            }
                    }
                }
                .onAppear {
                    habitListViewModel.fetchHabits()
                    viewModel.loadHabits(for: selectedDate)
                }
                .onChange(of: selectedDate) { newDate in
                    viewModel.loadHabits(for: newDate)
                    habitListViewModel.fetchHabits()
                }
                .sheet(isPresented: $isSheetPresented) {
                    HabitAddEditView(
                        viewModel: habitListViewModel,
                        onSave: {
                            isSheetPresented = false
                            viewModel.loadHabits(for: selectedDate)
                        }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showingTimer)
            .fullScreenCover(isPresented: $showingTimer) {
                if let habit = selectedHabit {
                    TimerView(
                        viewModel: TimerViewModel(
                            goalMinutes: habit.goalMinutes ?? 0,
                            onComplete: {
                                viewModel.markHabitCompleted(habit)
                                showingTimer = false
                                selectedHabit = nil
                            }
                        ),
                        showingTimer: $showingTimer,
                        habitTitle: habit.title
                    )
                }
            }
        }
    }
}
