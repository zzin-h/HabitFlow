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
    private let recordStorage: HabitRecordCoreDataStorage
    
    init(storage: HabitCoreDataStorage, recordStorage: HabitRecordCoreDataStorage) {
        self.storage = storage
        self.recordStorage = recordStorage
    }
    
    func fetchHabits() -> AnyPublisher<[HabitModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            do {
                let habits = try self.storage.fetchAllHabits()
                promise(.success(habits))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            do {
                try self.storage.addHabit(habit)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteHabit(_ id: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            do {
                try self.storage.deleteHabit(by: id)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            do {
                try self.storage.updateHabit(habit)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateHabitStatus(_ habitId: UUID, completedAt: Date) {
        do {
            try storage.updateHabitStatus(habitId: habitId, completedAt: completedAt)
        } catch {
            print("Error updating habit status: \(error)")
        }
    }
    
    func addHabitRecord(_ record: HabitRecordModel) {
        do {
            try recordStorage.addRecord(
                habitId: record.habit.id,
                date: record.date,
                duration: Int32(record.duration)
            )
        } catch {
            print("Error adding habit record: \(error)")
        }
    }
}
