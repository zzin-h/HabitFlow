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

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.habits) { habit in
                    Button {
                        selectedHabitToEdit = habit
                    } label: {
                        HStack {
                            Text(habit.title)
                            Spacer()
                            Text(habit.category.title)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteHabit)
            }
            .navigationTitle("Today's Habits")
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
        }
    }

    private func deleteHabit(at offsets: IndexSet) {
        offsets.forEach { index in
            let habit = viewModel.habits[index]
            viewModel.deleteHabit(id: habit.id)
        }
    }
}


#Preview {
    HabitListView()
}
