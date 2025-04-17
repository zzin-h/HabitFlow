//
//  HabitRecordDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

final class HabitRecordDIContainer {

    // MARK: - CoreData Storage
    private let storage: HabitRecordCoreDataStorage

    // MARK: - Repository
    private let repository: HabitRecordRepository

    // MARK: - UseCases
    private let addHabitRecordUseCase: AddHabitRecordUseCase
    private let deleteHabitRecordUseCase: DeleteHabitRecordUseCase
    private let updateHabitRecordUseCase: UpdateHabitRecordUseCase
    private let fetchHabitRecordsByHabitIdUseCase: FetchHabitRecordsByHabitIdUseCase

    // MARK: - Init
    init() {
        self.storage = HabitRecordCoreDataStorage()
        self.repository = HabitRecordRepositoryImpl(storage: storage)

        self.addHabitRecordUseCase = DefaultAddHabitRecordUseCase(repository: repository)
        self.deleteHabitRecordUseCase = DefaultDeleteHabitRecordUseCase(repository: repository)
        self.updateHabitRecordUseCase = DefaultUpdateHabitRecordUseCase(repository: repository)
        self.fetchHabitRecordsByHabitIdUseCase = DefaultFetchHabitRecordsByHabitIdUseCase(repository: repository)
    }

    // MARK: - ViewModel Factory
    func makeHabitRecordViewModel(habitId: UUID) -> HabitRecordViewModel {
        return HabitRecordViewModel(
            habitId: habitId,
            fetchHabitRecordsByHabitIdUseCase: fetchHabitRecordsByHabitIdUseCase,
            addHabitRecordUseCase: addHabitRecordUseCase,
            updateHabitRecordUseCase: updateHabitRecordUseCase,
            deleteHabitRecordUseCase: deleteHabitRecordUseCase
        )
    }
}
