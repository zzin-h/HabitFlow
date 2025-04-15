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
            .navigationTitle("습관 추가")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if title.isEmpty {
                            isEmptyTitle = true
                        } else {
                            addHabit()
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
        }
    }
    
    private func addHabit() {
        let addHabit = HabitModel(
            id: UUID(),
            title: title,
            category: selectedCategory,
            createdAt: Date()
        )
        viewModel.addHabit(addHabit)
    }
}
