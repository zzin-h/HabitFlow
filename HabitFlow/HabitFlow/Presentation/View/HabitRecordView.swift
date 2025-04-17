//
//  HabitRecordView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct HabitRecordView: View {
    @ObservedObject var viewModel: HabitRecordViewModel

    @State private var showingAddRecordSheet = false

    var body: some View {
        VStack {
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
                            Text(record.date, style: .date)
                            Spacer()
                            Text("\(record.duration)분")
                                .foregroundColor(.accentColor)
                        }
                    }
//                    .onDelete(perform: deleteRecord)
                }
            }
        }
        .navigationTitle("습관 기록")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddRecordSheet = true
                } label: {
                    Label("기록 추가", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRecordSheet) {
//            AddRecordSheet(viewModel: viewModel)
        }
    }

//    private func deleteRecord(at offsets: IndexSet) {
//        offsets.map { viewModel.records[$0].id }
//            .forEach { viewModel.deleteRecord(id: $0) }
//    }
}
