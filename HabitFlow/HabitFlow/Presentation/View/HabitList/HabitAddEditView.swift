//
//  HabitAddEditView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitAddEditView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: HabitListViewModel
    
    @State private var title: String = ""
    @State private var selectedCategory: HabitCategory = .healthyIt
    @State private var isEmptyTitle: Bool = false
    @State private var routineType: RoutineType = .daily
    @State private var selectedDays: Set<Weekdays> = []
    @State private var intervalDays: String = ""
    @State private var isEmptyRoutine: Bool = false
    @State private var goalMinutes: String = ""
    @State private var hasGoal: Bool = true
    
    var editingHabit: HabitModel?
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text(NSLocalizedString("title_notice", comment: "title_notice")).foregroundStyle(isEmptyTitle ? Color.primaryColor : .clear)) {
                    TextField(String(localized: "title"), text: $title)
                }
                
                Section() {
                    Picker(String(localized: "category"), selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                }
                
                Section(footer: Text(NSLocalizedString("repeat_notice", comment: "repeat_notice")).foregroundStyle(isEmptyRoutine ? Color.primaryColor : .clear)) {
                    Picker(String(localized: "repeat"), selection: $routineType) {
                        ForEach(RoutineType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    
                    if routineType == .interval {
                        HStack {
                            Text(NSLocalizedString("every", comment: "every"))
                            TextField("3", text: $intervalDays)
                                .keyboardType(.numberPad)
                                .frame(width: 30)
                                .multilineTextAlignment(.center)
                            Text(NSLocalizedString("repeat_days", comment: "repeat_days"))
                        }
                    }
                }
                
                if routineType == .weekly {
                    MultipleDayPicker(selectedDays: $selectedDays)
                }
                
                Section(footer: Text(NSLocalizedString("goal_time_notice", comment: "goal_time_notice")).foregroundStyle(hasGoal == true && goalMinutes.isEmpty ? Color.primaryColor : .clear)) {
                    Toggle(String(localized: "goal_time"), isOn: $hasGoal)
                    if hasGoal {
                        HStack {
                            TextField("10", text: $goalMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 30)
                                .multilineTextAlignment(.leading)
                            Text(NSLocalizedString("min", comment: "min"))
                        }
                    }
                }
            }
            .navigationTitle(editingHabit != nil ? String(localized: "edit_nav_title") : String(localized: "new_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel_btn")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingHabit != nil ? String(localized: "edit_btn") : String(localized: "new_btn")) {
                        if validateInputs() {
                            if let habit = editingHabit {
                                updateHabit(habit)
                            } else {
                                addHabit()
                                onSave?()
                            }
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if let habit = editingHabit {
                    title = habit.title
                    selectedCategory = habit.category
                    routineType = habit.routineType
                    selectedDays = Set(habit.selectedDays?.compactMap { Weekdays(rawValue: $0) } ?? [])
                    intervalDays = habit.intervalDays.map { String($0) } ?? ""
                    if let minutes = habit.goalMinutes {
                        hasGoal = true
                        goalMinutes = String(minutes)
                    } else {
                        hasGoal = false
                    }
                }
            }
        }
    }
    
    private func addHabit() {
        let newHabit = HabitModel(
            id: UUID(),
            title: title,
            category: selectedCategory,
            createdAt: Date(),
            routineType: routineType,
            selectedDays: routineType == .weekly ? selectedDays.map { $0.rawValue } : nil,
            intervalDays: routineType == .interval ? Int(intervalDays) ?? 1 : nil,
            goalMinutes: hasGoal ? Int(goalMinutes) ?? 0 : nil
        )
        viewModel.addHabit(newHabit)
    }
    
    private func updateHabit(_ habit: HabitModel) {
        let updated = HabitModel(
            id: habit.id,
            title: title,
            category: selectedCategory,
            createdAt: habit.createdAt,
            routineType: routineType,
            selectedDays: routineType == .weekly ? selectedDays.map { $0.rawValue } : nil,
            intervalDays: routineType == .interval ? Int(intervalDays) ?? 1 : nil,
            goalMinutes: hasGoal ? Int(goalMinutes) ?? 0 : nil
        )
        viewModel.updateHabit(updated)
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        
        if title.isEmpty {
            isEmptyTitle = true
            isValid = false
        } else {
            isEmptyTitle = false
        }
        
        if (routineType == .weekly && selectedDays.isEmpty) ||
            (routineType == .interval && intervalDays.isEmpty) {
            isEmptyRoutine = true
            isValid = false
        } else {
            isEmptyRoutine = false
        }
        
        return isValid
    }
}

private struct MultipleDayPicker: View {
    @Binding var selectedDays: Set<Weekdays>
    
    var body: some View {
        Section {
            ForEach(Weekdays.allCases, id: \.self) { day in
                Button(action: {
                    toggleSelection(for: day)
                }) {
                    HStack {
                        Text(day.fullTitle)
                            .foregroundStyle(Color.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .bold()
                            .foregroundStyle(selectedDays.contains(day) ? Color.accentColor : .clear)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleSelection(for day: Weekdays) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}
