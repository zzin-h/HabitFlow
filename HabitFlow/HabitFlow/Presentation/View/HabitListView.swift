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
        NavigationView {
            List {
                ForEach(viewModel.habits) { habit in
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

                        Button {
                            selectedHabitToEdit = habit
                        } label: {
                            Label("수정", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("My Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddView = true
                    }) {
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
//                HabitRecordView(viewModel: recordViewModel)
            }
        }
    }
}

private struct HabitRowView: View {
    let habit: HabitModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(habit.title)
                    .font(.headline)
                Spacer()
                Text(habit.category.title)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            HStack {
                Text(routineDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let goal = habit.goalMinutes {
                    if goal > 0 {
                        Text("\(goal)분")
                            .font(.footnote)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var routineDescription: String {
        switch habit.routineType {
        case .daily:
            return "매일"
        case .weekly:
            let days = habit.selectedDays?.compactMap { Weekdays(rawValue: $0) }.sorted().map { $0.koreanTitle }.joined(separator: " ") ?? "요일 없음"
            return "\(days) 주기"
        case .interval:
            let interval = habit.intervalDays ?? 0
            return "\(interval)일 주기"
        }
    }
}

#Preview {
    HabitListView()
}
