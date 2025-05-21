//
//  HabitListView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    @StateObject private var notifyViewModel: HabitNotificationViewModel
    
    init(viewModel: HabitListViewModel = HabitListDIContainer().makeHabitListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _notifyViewModel = StateObject(wrappedValue: HabitNotificationDIContainer().makeHabitNotificationViewModel())
    }
    
    @State private var showingAddView = false
    @State private var selectedHabitToEdit: HabitModel? = nil
    @State private var selectedHabitForStats: HabitModel? = nil
    
    var body: some View {
        VStack {
            if viewModel.habits.isEmpty {
                HStack {
                    Spacer()
                    
                    Text(NSLocalizedString("any_habits_yet", comment: "any_habits_yet"))
                    
                    Spacer()
                }
                .padding(.top, 48)
                .font(.title3.bold())
                .foregroundStyle(Color(.systemGray4))
            }
            
            List {
                ForEach(RoutineType.allCases, id: \.self) { routineType in
                    if let habits = viewModel.groupedHabitsByRoutine[routineType], !habits.isEmpty {
                        Section(header: Text(routineType.title)) {
                            ForEach(habits) { habit in
                                Button {
                                    selectedHabitForStats = habit
                                } label: {
                                    HabitRowView(habit: habit)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteHabit(id: habit.id)
                                        notifyViewModel.deleteNotification(habitId: habit.id)
                                    } label: {
                                        Label("", systemImage: "trash")
                                    }
                                    .tint(Color.primaryColor)
                                    
                                    Button {
                                        selectedHabitToEdit = habit
                                    } label: {
                                        Label("", systemImage: "pencil")
                                    }
                                    .tint(Color.secondaryColor)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "habit_list_nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            viewModel.fetchHabits()
        }
        .sheet(isPresented: $showingAddView) {
            HabitAddEditView(viewModel: viewModel, notifyViewModel: notifyViewModel)
        }
        .sheet(item: $selectedHabitToEdit) { habit in
            HabitAddEditView(viewModel: viewModel, notifyViewModel: notifyViewModel, editingHabit: habit)
        }
        .sheet(item: $selectedHabitForStats) { habit in
            HabitRecordView(habit: habit)
        }
    }
}

private struct HabitRowView: View {
    let habit: HabitModel
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.callout.bold())
                    .foregroundStyle(Color.textPrimary)
                
                HStack(alignment: .center) {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(habit.category.color)
                    
                    Text(habit.category.title + "  |")
                        .padding(-4)
                    
                    Text(routineDescription)
                        .padding(.leading, 3)
                    
                    if let goal = habit.goalMinutes {
                        if goal > 0 {
                            HStack(spacing: 0) {
                                Text("|  \(goal)")
                                Text(NSLocalizedString("min", comment: "min"))
                            }
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            if let goal = habit.goalMinutes {
                if goal > 0 {
                    Image(systemName: "clock.fill")
                        .font(.callout)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var routineDescription: String {
        switch habit.routineType {
        case .daily:
            return String(localized: "every_days")
        case .weekly:
            let days = habit.selectedDays?.compactMap { Weekdays(rawValue: $0) }.sorted().map { $0.shortTitle }.joined(separator: " ") ?? ""
            return String(format: NSLocalizedString("every_weekdays", comment: ""), days)
        case .interval:
            let interval = habit.intervalDays ?? 0
            return String(format: NSLocalizedString("every_interval_days", comment: ""), interval)
        }
    }
}
