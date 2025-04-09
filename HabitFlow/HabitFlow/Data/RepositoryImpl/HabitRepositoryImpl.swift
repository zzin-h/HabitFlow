//
//  HabitRepositoryImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

final class HabitRepositoryImpl: HabitRepository {
    private let storage: HabitCoreDataStorage

    init(storage: HabitCoreDataStorage = HabitCoreDataStorage()) {
        self.storage = storage
    }

    func addHabit(_ habit: HabitModel) throws {
        try storage.add(habit)
    }

    func fetchHabits() throws -> [HabitModel] {
        try storage.fetchAll()
    }

    func updateHabit(_ habit: HabitModel) throws {
        try storage.update(habit)
    }

    func deleteHabit(_ habit: HabitModel) throws {
        try storage.delete(habit)
    }
}
