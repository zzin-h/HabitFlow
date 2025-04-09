//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

public protocol HabitRepository {
    func addHabit(_ habit: HabitModel) throws
    func fetchHabits() throws -> [HabitModel]
    func updateHabit(_ habit: HabitModel) throws
    func deleteHabit(_ habit: HabitModel) throws
}
