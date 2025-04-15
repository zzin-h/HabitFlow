//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

//public protocol HabitRepository {
//    func add(_ habit: HabitModel) throws
//    func fetchAll() throws -> [HabitModel]
//    func update(_ habit: HabitModel) throws
//    func delete(_ habit: HabitModel) throws
//}

import Foundation
import Combine

protocol HabitRepository {
    func fetchHabits() -> AnyPublisher<[HabitModel], Error>
    func saveHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error>
    func deleteHabit(_ id: UUID) -> AnyPublisher<Void, Error>
}
