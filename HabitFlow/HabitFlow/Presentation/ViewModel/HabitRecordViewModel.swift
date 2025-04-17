//
//  HabitRecordViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

final class HabitRecordViewModel: ObservableObject {
    // MARK: - Dependencies
    private let fetchHabitRecordsByHabitIdUseCase: FetchHabitRecordsByHabitIdUseCase
    private let addHabitRecordUseCase: AddHabitRecordUseCase
    private let updateHabitRecordUseCase: UpdateHabitRecordUseCase
    private let deleteHabitRecordUseCase: DeleteHabitRecordUseCase

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State
    private let habitId: UUID

    // MARK: - Published
    @Published var records: [HabitRecordModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(
        habitId: UUID,
        fetchHabitRecordsByHabitIdUseCase: FetchHabitRecordsByHabitIdUseCase,
        addHabitRecordUseCase: AddHabitRecordUseCase,
        updateHabitRecordUseCase: UpdateHabitRecordUseCase,
        deleteHabitRecordUseCase: DeleteHabitRecordUseCase
    ) {
        self.habitId = habitId
        self.fetchHabitRecordsByHabitIdUseCase = fetchHabitRecordsByHabitIdUseCase
        self.addHabitRecordUseCase = addHabitRecordUseCase
        self.updateHabitRecordUseCase = updateHabitRecordUseCase
        self.deleteHabitRecordUseCase = deleteHabitRecordUseCase
        
        loadRecords()
    }

    // MARK: - Actions
    func loadRecords() {
        isLoading = true
        errorMessage = nil

        fetchHabitRecordsByHabitIdUseCase.execute(habitId: habitId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] records in
                self?.records = records
            }
            .store(in: &cancellables)
    }

    func addRecord(date: Date, duration: Int32) {
        addHabitRecordUseCase.execute(habitId: habitId, date: date, duration: Int(duration))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }

    func updateRecord(recordId: UUID, date: Date, duration: Int32) {
        updateHabitRecordUseCase.execute(recordId: recordId, newDate: date, newDuration: duration)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }

    func deleteRecord(recordId: UUID) {
        deleteHabitRecordUseCase.execute(recordId: recordId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }
}
