//
//  TodayHabitDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

final class TodayHabitDIContainer {

    // MARK: - Storage
    private let habitStorage: HabitCoreDataStorage
    private let habitRecordStorage: HabitRecordCoreDataStorage

    // MARK: - Repository
    private let habitRepository: HabitRepository
    private let habitRecordRepository: HabitRecordRepository

    // MARK: - Init
    init() {
        self.habitStorage = HabitCoreDataStorage()
        self.habitRecordStorage = HabitRecordCoreDataStorage()

        self.habitRepository = HabitRepositoryImpl(
            storage: habitStorage,
            recordStorage: habitRecordStorage
        )
        
        self.habitRecordRepository = HabitRecordRepositoryImpl(
            storage: habitRecordStorage
        )
    }

    // MARK: - ViewModel Factory
    func makeTodayHabitViewModel() -> TodayHabitViewModel {
        return TodayHabitViewModel(
            habitRepository: habitRepository,
            habitRecordRepository: habitRecordRepository
        )
    }
}
