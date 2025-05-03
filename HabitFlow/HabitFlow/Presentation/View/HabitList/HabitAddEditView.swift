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
    
    var editingHabit: HabitModel?
    
    @State private var title: String = ""
    @State private var selectedCategory: HabitCategory = .healthyIt
    @State private var isEmptyTitle: Bool = false
    @State private var routineType: RoutineType = .daily
    @State private var selectedDays: Set<Weekdays> = []
    @State private var intervalDays: String = ""
    @State private var isEmptyRoutine: Bool = false
    @State private var goalMinutes: String = ""
    @State private var hasGoal: Bool = true
    @State private var isEmptyGoal: Bool = false
    
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("제목을 입력해주세요.").foregroundStyle(isEmptyTitle ? Color.primaryColor : .clear)) {
                    TextField("제목", text: $title)
                }
                
                Section() {
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                }
                
                Section(footer: Text("반복 주기를 입력해주세요").foregroundStyle(isEmptyRoutine ? Color.primaryColor : .clear)) {
                    Picker("반복", selection: $routineType) {
                        ForEach(RoutineType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    
                    if routineType == .interval {
                        HStack {
                            Text("매")
                            TextField("3", text: $intervalDays)
                                .keyboardType(.numberPad)
                                .frame(width: 30)
                                .multilineTextAlignment(.center)
                            Text("일마다")
                        }
                    }
                }
                
                if routineType == .weekly {
                    MultipleDayPicker(selectedDays: $selectedDays)
                }
                
                Section(footer: Text("목표 시간을 입력해주세요").foregroundStyle(isEmptyRoutine ? Color.primaryColor : .clear)) {
                    Toggle("목표 시간", isOn: $hasGoal)
                    if hasGoal {
                        HStack {
                            TextField("10", text: $goalMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 30)
                                .multilineTextAlignment(.leading)
                            Text("분")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingHabit != nil ? "수정" : "추가") {
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
                
                ToolbarItem(placement: .principal) {
                    Text(editingHabit != nil ? "습관" : "새로운 습관")
                        .bold()
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
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
                        Text(day.koreanTitle + "요일")
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
