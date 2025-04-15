//
//  HabitRepositoryImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation
import Combine

final class HabitRepositoryImpl: HabitRepository {
    private let storage: HabitCoreDataStorage

    init(storage: HabitCoreDataStorage) {
        self.storage = storage
    }

    func fetchHabits() -> AnyPublisher<[HabitModel], Error> {
        return Future { promise in
            do {
                let habits = try self.storage.fetchAllHabits()
                promise(.success(habits))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func saveHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.storage.saveHabit(habit)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteHabit(_ id: UUID) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.storage.deleteHabit(by: id)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
