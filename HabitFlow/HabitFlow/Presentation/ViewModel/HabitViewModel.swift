//
//  HabitViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [HabitModel] = []

    private let repository: HabitRepository

    init(repository: HabitRepository = HabitRepositoryImpl()) {
        self.repository = repository
        loadHabits()
    }

    func loadHabits() {
        do {
            habits = try repository.fetchAll()
        } catch {
            print("불러오기 실패: \(error)")
        }
    }

    func add(title: String, category: HabitCategory) {
        let habit = HabitModel(title: title, category: category)
        do {
            try repository.add(habit)
            loadHabits()
        } catch {
            print("추가 실패: \(error)")
        }
    }

    func update(_ habit: HabitModel) {
        do {
            try repository.update(habit)
            loadHabits()
        } catch {
            print("수정 실패: \(error)")
        }
    }

    func delete(_ habit: HabitModel) {
        do {
            try repository.delete(habit)
            loadHabits()
        } catch {
            print("삭제 실패: \(error)")
        }
    }
}
