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

    // MARK: - Published Properties
    @Published var records: [HabitRecordModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(
        fetchHabitRecordsByHabitIdUseCase: FetchHabitRecordsByHabitIdUseCase,
        addHabitRecordUseCase: AddHabitRecordUseCase,
        updateHabitRecordUseCase: UpdateHabitRecordUseCase,
        deleteHabitRecordUseCase: DeleteHabitRecordUseCase
    ) {
        self.fetchHabitRecordsByHabitIdUseCase = fetchHabitRecordsByHabitIdUseCase
        self.addHabitRecordUseCase = addHabitRecordUseCase
        self.updateHabitRecordUseCase = updateHabitRecordUseCase
        self.deleteHabitRecordUseCase = deleteHabitRecordUseCase
    }

    // MARK: - Actions
    func loadRecords(for habitId: UUID) {
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

    func addRecord(habitId: UUID, date: Date, duration: Int32) {
        addHabitRecordUseCase.execute(habitId: habitId, date: date, duration: Int(duration))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords(for: habitId)
            })
            .store(in: &cancellables)
    }

    func updateRecord(recordId: UUID, date: Date, duration: Int32, habitId: UUID) {
        updateHabitRecordUseCase.execute(recordId: recordId, newDate: date, newDuration: duration)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords(for: habitId)
            })
            .store(in: &cancellables)
    }

    func deleteRecord(recordId: UUID, habitId: UUID) {
        deleteHabitRecordUseCase.execute(recordId: recordId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords(for: habitId)
            })
            .store(in: &cancellables)
    }
}
