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
    private let useCase: HabitRecordUseCase

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
        useCase: HabitRecordUseCase
    ) {
        self.habitId = habitId
        self.useCase = useCase
        
        loadRecords()
    }

    // MARK: - Actions
    func loadRecords() {
        isLoading = true
        errorMessage = nil

        useCase.fetchRecords(for: habitId)
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
        useCase.addRecord(habitId: habitId, date: date, duration: duration)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }

    func updateRecord(recordId: UUID, date: Date, duration: Int32) {
        useCase.updateRecord(id: recordId, date: date, duration: duration)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }

    func deleteRecord(recordId: UUID) {
        useCase.deleteRecord(by: recordId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.loadRecords()
            })
            .store(in: &cancellables)
    }
}
