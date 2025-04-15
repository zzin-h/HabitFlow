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

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Habit Title"), footer: Text("Please fill in the habit title.").foregroundStyle(isEmptyTitle ? .red : .clear)) {
                    TextField("ex. drinking water in the morning", text: $title)
                }

                Section(header: Text("Category")) {
                    Picker("Pick a category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
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
                }
            }
        }
    }

    private func addHabit() {
        let newHabit = HabitModel(
            id: UUID(),
            title: title,
            category: selectedCategory,
            createdAt: Date()
        )
        viewModel.addHabit(newHabit)
    }

    private func updateHabit(_ habit: HabitModel) {
        let updated = HabitModel(
            id: habit.id,
            title: title,
            category: selectedCategory,
            createdAt: habit.createdAt
        )
        viewModel.updateHabit(updated)
    }
}
