//
//  HabitRecordRepositoryImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

final class HabitRecordRepositoryImpl: HabitRecordRepository {
    private let storage: HabitRecordCoreDataStorage

    init(storage: HabitRecordCoreDataStorage) {
        self.storage = storage
    }

    func addRecord(habitId: UUID, date: Date, duration: Int32) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }

            do {
                try self.storage.addRecord(habitId: habitId, date: date, duration: duration)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteRecord(by id: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }

            do {
                try self.storage.deleteRecord(by: id)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateRecord(id: UUID, date: Date, duration: Int32) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }

            do {
                try self.storage.updateRecord(recordId: id, newDate: date, newDuration: duration)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchRecords(for habitId: UUID) -> AnyPublisher<[HabitRecordModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }

            do {
                let entities = try self.storage.fetchRecords(for: habitId)
                let models = entities.map { HabitRecordModel(entity: $0) }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchAllRecords() -> AnyPublisher<[HabitRecordModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }

            do {
                let entities = try self.storage.fetchAllRecords()
                let models = entities.map { HabitRecordModel(entity: $0) }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
