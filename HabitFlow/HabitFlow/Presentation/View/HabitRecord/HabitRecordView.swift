//
//  HabitRecordView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct HabitRecordView: View {
    let habit: HabitModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: HabitRecordViewModel
    @StateObject private var notifyViewModel: HabitNotificationViewModel
    
    init(habit: HabitModel) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: HabitRecordDIContainer().makeHabitRecordViewModel(habitId: habit.id))
        _notifyViewModel = StateObject(wrappedValue: HabitNotificationDIContainer().makeHabitNotificationViewModel())
    }
    
    @State private var showingAddRecordSheet = false
    @State private var editingRecord: HabitRecordModel? = nil
    
    var body: some View {
        let groupedRecords = Dictionary(grouping: viewModel.records, by: { yearMonthString(from: $0.date) })
        let durationSums = groupedRecords.mapValues { records in records.reduce(0) { $0 + $1.duration }}
        let totalDuration = viewModel.records.reduce(0) { $0 + $1.duration }
        
        VStack {
            VStack {
                HStack(alignment: .center) {
                    Button(String(localized: "cancel_btn")) {
                        dismiss()
                    }
                    Image(systemName: "plus")
                        .foregroundStyle(.clear)
                    
                    Spacer()
                    
                    Text(habit.title)
                        .font(.headline.bold())
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(NSLocalizedString("cancel_btn", comment: "cancel_btn"))
                        .foregroundStyle(.clear)
                    Button {
                        showingAddRecordSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                HStack(alignment: .center) {
                    HStack(spacing: 0) {
                        Text(NSLocalizedString("total", comment: "total"))
                        Text(" \(viewModel.records.count)")
                        Text(NSLocalizedString("times", comment: "times"))
                    }
                    
                    if totalDuration > 0 {
                        HStack(spacing: 0) {
                            Text("\(totalDuration / 60)")
                            Text(NSLocalizedString("hour", comment: "hour"))
                            Text(" \(totalDuration % 60)")
                            Text(NSLocalizedString("min", comment: "min"))
                        }
                    }
                    
                    HabitNotificationView(viewModel: notifyViewModel, habitId: habit.id)
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color.textSecondary)
                .padding(.vertical, 4)
                
                Text(NSLocalizedString("records_notice", comment: "records_notice"))
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray2))
            }
            .padding()
            
            if viewModel.records.isEmpty {
                Spacer()
                
                Text(NSLocalizedString("none_records_notice", comment: "none_records_notice"))
                    .font(.body)
                    .foregroundColor(.gray)
                
                Spacer()
            } else {
                List {
                    ForEach(groupedRecords.sorted(by: { $0.key > $1.key }), id: \.key) { (month, records) in
                        Section(header: HStack{
                            Text(month)
                                .font(.headline)
                            
                            HStack(spacing: 0) {
                                Text("\(records.count)")
                                Text(NSLocalizedString("times", comment: "times"))
                            }
                            .font(.subheadline.bold())
                            
                            if durationSums[month] ?? 0 > 0 {
                                HStack(spacing: 0) {
                                    Text("\(durationSums[month] ?? 0)")
                                    Text(NSLocalizedString("min", comment: "min"))
                                }
                                .font(.subheadline.bold())
                            }
                        }) {
                            ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                                HStack {
                                    Text(formattedDate(record.date))
                                    
                                    Spacer()
                                    
                                    if record.duration > 0 {
                                        HStack(spacing: 0) {
                                            Text("\(record.duration)")
                                            Text(NSLocalizedString("min", comment: "min"))
                                        }
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
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMMdEEEEHm")
        return formatter.string(from: date)
    }
}
