//
//  HabitViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation
import Combine

final class HabitViewModel: ObservableObject {
    @Published var habits: [HabitModel] = []
    
    private let useCase: HabitUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: HabitUseCase) {
        self.useCase = useCase
        fetchHabits()
    }

    func fetchHabits() {
        useCase.fetchHabits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Fetch Error: \(error)")
                }
            }, receiveValue: { [weak self] habits in
                self?.habits = habits
            })
            .store(in: &cancellables)
    }

    func addHabit(title: String, category: HabitCategory) {
        let newHabit = HabitModel(
            id: UUID(),
            title: title,
            category: category,
            createdAt: Date()
        )
        useCase.createHabit(habit: newHabit)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.fetchHabits()
            }, receiveValue: { })
            .store(in: &cancellables)
    }

    func deleteHabit(id: UUID) {
        useCase.deleteHabit(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.fetchHabits()
            }, receiveValue: { })
            .store(in: &cancellables)
    }
}
