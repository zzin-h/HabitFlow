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
    @State private var intervalDays: String = "1"
    @State private var goalMinutes: String = "10"
    @State private var hasGoal: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("습관 제목"), footer: Text("습관 제목을 입력해주세요.").foregroundStyle(isEmptyTitle ? .red : .clear)) {
                    TextField("ex. 아침에 물 마시기", text: $title)
                }

                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                }

                Section(header: Text("루틴 설정")) {
                    Picker("반복 주기", selection: $routineType) {
                        ForEach(RoutineType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }

                    if routineType == .weekly {
                        MultipleDayPicker(selectedDays: $selectedDays)
                    }

                    if routineType == .interval {
                        HStack {
                            Text("매")
                            TextField("0", text: $intervalDays)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.center)
                            Text("일마다")
                        }
                    }
                }

                Section(header: Text("하루 목표 시간")) {
                    Toggle("목표 시간 설정", isOn: $hasGoal)
                    if hasGoal {
                        HStack {
                            TextField("10", text: $goalMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .multilineTextAlignment(.leading)
                            Text("분")
                        }
                    }
                }
            }
            .navigationTitle(editingHabit != nil ? "습관 수정" : "습관 추가")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if title.isEmpty {
                            isEmptyTitle = true
                        } else {
                            if let habit = editingHabit {
                                updateHabit(habit)
                            } else {
                                addHabit()
                            }
                            dismiss()
                        }
                    }
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
                    intervalDays = habit.intervalDays.map { String($0) } ?? "1"
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
            goalMinutes: hasGoal ? Int(goalMinutes) ?? 10 : nil
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
            goalMinutes: hasGoal ? Int(goalMinutes) ?? 10 : nil
        )
        viewModel.updateHabit(updated)
    }
}

private struct MultipleDayPicker: View {
    @Binding var selectedDays: Set<Weekdays>

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        VStack(alignment: .leading) {
            Text("요일 선택")
                .font(.subheadline)
                .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Weekdays.allCases, id: \.self) { day in
                    Text(day.koreanTitle)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(selectedDays.contains(day) ? Color.accentColor : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(for: day)
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
