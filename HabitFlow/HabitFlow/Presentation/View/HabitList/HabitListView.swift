//
//  HabitListView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    
    init(viewModel: HabitListViewModel = HabitListDIContainer().makeHabitListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var showingAddView = false
    @State private var selectedHabitToEdit: HabitModel? = nil
    @State private var selectedHabitForStats: HabitModel? = nil
    
    var body: some View {
        VStack {
            if viewModel.habits.isEmpty {
                HStack {
                    Spacer()
                    
                    Text("아직 습관이 없어요")
                    
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
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                    .tint(Color.primaryColor)
                                    
                                    Button {
                                        selectedHabitToEdit = habit
                                    } label: {
                                        Label("수정", systemImage: "pencil")
                                    }
                                    .tint(Color.secondaryColor)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("습관 목록")
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
            HabitAddEditView(viewModel: viewModel)
        }
        .sheet(item: $selectedHabitToEdit) { habit in
            HabitAddEditView(viewModel: viewModel, editingHabit: habit)
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
                            Text("|  \(goal)분")
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
            return "매일"
        case .weekly:
            let days = habit.selectedDays?.compactMap { Weekdays(rawValue: $0) }.sorted().map { $0.koreanTitle }.joined(separator: " ") ?? ""
            return "\(days) 주기"
        case .interval:
            let interval = habit.intervalDays ?? 0
            return "\(interval)일 주기"
        }
    }
}
