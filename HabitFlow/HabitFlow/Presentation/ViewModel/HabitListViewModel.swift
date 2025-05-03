//
//  HabitListViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation
import Combine

final class HabitListViewModel: ObservableObject {
    // MARK: - Input
    @Published var habits: [HabitModel] = []
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let fetchHabitUseCase: FetchHabitUseCase
    private let addHabitUseCase: AddHabitUseCase
    private let deleteHabitUseCase: DeleteHabitUseCase
    private let updateHabitUseCase: UpdateHabitUseCase

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        fetchHabitUseCase: FetchHabitUseCase,
        addHabitUseCase: AddHabitUseCase,
        deleteHabitUseCase: DeleteHabitUseCase,
        updateHabitUseCase: UpdateHabitUseCase
    ) {
        self.fetchHabitUseCase = fetchHabitUseCase
        self.addHabitUseCase = addHabitUseCase
        self.deleteHabitUseCase = deleteHabitUseCase
        self.updateHabitUseCase = updateHabitUseCase
        
        fetchHabits()
    }

    // MARK: - Public Methods
    func fetchHabits() {
        fetchHabitUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] habits in
                self?.habits = habits
            }
            .store(in: &cancellables)
    }

    func addHabit(_ habit: HabitModel) {
        addHabitUseCase.execute(habit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func deleteHabit(id: UUID) {
        deleteHabitUseCase.execute(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func updateHabit(_ habit: HabitModel) {
        updateHabitUseCase.execute(habit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    var groupedHabitsByRoutine: [RoutineType: [HabitModel]] {
        Dictionary(grouping: habits, by: { $0.routineType })
    }
}
