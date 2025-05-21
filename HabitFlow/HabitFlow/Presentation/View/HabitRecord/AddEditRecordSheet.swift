//
//  AddEditRecordSheet.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct AddEditRecordSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: HabitRecordViewModel
    
    let habit: HabitModel
    let existingRecord: HabitRecordModel?

    init(
        viewModel: HabitRecordViewModel,
        habit: HabitModel,
        existingRecord: HabitRecordModel? = nil
    ) {
        self.viewModel = viewModel
        self.habit = habit
        self.existingRecord = existingRecord

        if let record = existingRecord {
            _selectedDate = State(initialValue: record.date)
            _durationMinutes = State(initialValue: String(record.duration))
        } else {
            _selectedDate = State(initialValue: Date())
            _durationMinutes = State(initialValue: "")
        }
    }
    
    @State private var selectedDate: Date
    @State private var durationMinutes: String

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(NSLocalizedString("completed_record", comment: "completed_record"))) {
                    DatePicker(
                        String(localized: "completed_date"),
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .padding(.vertical, 2)
                    .background(Color.cardBg)
                    
                    DatePicker(
                        String(localized: "completed_time"),
                        selection: $selectedDate,
                        displayedComponents: .hourAndMinute
                    )
                }

                if habit.goalMinutes! > 0 {
                    Section(header: Text(NSLocalizedString("completed_duration", comment: "completed_duration"))) {
                        TextField(String(localized: "completed_duration_notice"), text: $durationMinutes)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle(existingRecord != nil ? String(localized: "edit_record_nav_title") : String(localized: "new_record_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .hideKeyboardOnTap()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel_btn")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(existingRecord != nil ? String(localized: "edit_btn") : String(localized: "new_btn")) {
                        saveRecord()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        if habit.goalMinutes ?? 0 > 0 {
            return Int(durationMinutes) != nil
        }
        return true
    }

    private func saveRecord() {
        let finalDate = selectedDateHasTime(selectedDate) ? selectedDate : endOfDay(for: selectedDate)
        let duration = Int32(Int(durationMinutes) ?? 0)

        if let record = existingRecord {
            viewModel.updateRecord(
                recordId: record.id,
                date: finalDate,
                duration: duration
            )
        } else {
            viewModel.addRecord(
                date: finalDate,
                duration: duration
            )
        }
        
        dismiss()
    }

    private func selectedDateHasTime(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour != 0 || minute != 0
    }

    private func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 23
        components.minute = 59
        return calendar.date(from: components) ?? date
    }
}
