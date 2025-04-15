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

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.habits) { habit in
                    HStack {
                        Text(habit.title)
                        Spacer()
                        Text(habit.category.title)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteHabit)
            }
            .navigationTitle("My Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addDummyHabit) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchHabits()
            }
        }
    }

    private func deleteHabit(at offsets: IndexSet) {
        offsets.forEach { index in
            let habit = viewModel.habits[index]
            viewModel.deleteHabit(id: habit.id)
        }
    }

    // 임시 더미 데이터 추가용
    private func addDummyHabit() {
        let dummyHabit = HabitModel(
            id: UUID(),
            title: "Read a book",
            category: .healthyIt,
            createdAt: Date()
        )
        viewModel.addHabit(dummyHabit)
    }
}

#Preview {
    HabitListView()
}
