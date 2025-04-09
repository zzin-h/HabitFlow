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

    func add(_ habit: HabitModel) throws {
        try storage.add(habit)
    }

    func fetchAll() throws -> [HabitModel] {
        try storage.fetchAll()
    }

    func update(_ habit: HabitModel) throws {
        try storage.update(habit)
    }

    func delete(_ habit: HabitModel) throws {
        try storage.delete(habit)
    }
}
