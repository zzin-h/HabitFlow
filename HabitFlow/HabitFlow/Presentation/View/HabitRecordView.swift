//
//  HabitRecordView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct HabitRecordView: View {
    let habit: HabitModel

    @StateObject private var viewModel: HabitRecordViewModel
    @State private var showingAddRecordSheet = false
    @State private var editingRecord: HabitRecordModel? = nil

    init(habit: HabitModel) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: HabitRecordDIContainer().makeHabitRecordViewModel(habitId: habit.id))
    }

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Text("\(habit.title) (\(viewModel.records.count))")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddRecordSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding()

            if viewModel.records.isEmpty {
                Spacer()
                Text("아직 기록이 없어요 🕊️")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.records.sorted(by: { $0.date > $1.date })) { record in
                        HStack {
                            Text(record.date.description(with: .current))
                            Spacer()
                            if record.duration > 0 {
                                Text("\(record.duration)분")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteRecord(recordId: record.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }

                            Button {
                                editingRecord = record
                            } label: {
                                Label("수정", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("습관 기록")
        .onAppear {
            viewModel.loadRecords()
        }
        .sheet(isPresented: $showingAddRecordSheet) {
            AddEditRecordSheet(viewModel: viewModel, habit: habit)
        }
        .sheet(item: $editingRecord) { record in
            AddEditRecordSheet(viewModel: viewModel, habit: habit, existingRecord: record)
        }
    }
}
