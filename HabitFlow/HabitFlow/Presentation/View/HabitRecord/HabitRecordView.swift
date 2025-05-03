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
        let groupedRecords = Dictionary(grouping: viewModel.records, by: { yearMonthString(from: $0.date) })
        let durationSums = groupedRecords.mapValues { records in records.reduce(0) { $0 + $1.duration }}
        let totalDuration = viewModel.records.reduce(0) { $0 + $1.duration }
        
        VStack {
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .foregroundStyle(.clear)
                    
                    Spacer()
                    
                    Text(habit.title)
                        .font(.headline.bold())
                    
                    Spacer()
                    
                    Button {
                        showingAddRecordSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                HStack(alignment: .center) {
                    Text("총 \(viewModel.records.count)회")
                    
                    if totalDuration > 0 {
                        Text("\(totalDuration / 60)시간 \(totalDuration % 60)분")
                    }
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color.textSecondary)
                .padding(.vertical, 4)
                
                Text("세부 기록을 추가, 수정, 삭제할 수 있습니다")
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray2))
            }
            .padding()

            if viewModel.records.isEmpty {
                Spacer()
                
                Text("아직 기록이 없어요")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Spacer()
            } else {
                List {
                    ForEach(groupedRecords.sorted(by: { $0.key > $1.key }), id: \.key) { (month, records) in
                        Section(header: HStack{
                            Text(month)
                                .font(.headline)
                            
                            Text("\(records.count)회")
                                .font(.subheadline.bold())
                            
                            if durationSums[month] ?? 0 > 0 {
                                Text("\(durationSums[month] ?? 0)분")
                                    .font(.subheadline.bold())
                            }
                        }) {
                            ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                                HStack {
                                    Text(formattedDate(record.date))
                                    
                                    Spacer()
                                    
                                    if record.duration > 0 {
                                        Text("\(record.duration)분")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color.textPrimary)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteRecord(recordId: record.id)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                    .tint(Color.primaryColor)

                                    Button {
                                        editingRecord = record
                                    } label: {
                                        Label("수정", systemImage: "pencil")
                                    }
                                    .tint(Color.secondaryColor)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
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
    
    private func yearMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE HH:mm"
        return formatter.string(from: date)
    }
}
