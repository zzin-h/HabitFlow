//
//  HabitListView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.habits) { habit in
                    VStack(alignment: .leading) {
                        Text(habit.title)
                            .font(.headline)
                        Text(habit.category.displayName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.habits[$0] }.forEach(viewModel.delete)
                }
            }
            .navigationTitle("오늘의 습관")
            .toolbar {
                Button(action: { showingAddView = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddView) {
                HabitAddEditView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    HabitListView()
}
