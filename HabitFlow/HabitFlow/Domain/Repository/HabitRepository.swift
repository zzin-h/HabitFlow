//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

public protocol HabitRepository {
    func add(_ habit: HabitModel) throws
    func fetchAll() throws -> [HabitModel]
    func update(_ habit: HabitModel) throws
    func delete(_ habit: HabitModel) throws
}
