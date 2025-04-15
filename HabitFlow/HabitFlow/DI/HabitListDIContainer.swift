//
//  HabitListDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation

struct HabitListDIContainer {
    
    // MARK: - CoreData Storage
    private let storage = HabitCoreDataStorage()

    // MARK: - Repository
    private var repository: HabitRepository {
        return HabitRepositoryImpl(storage: storage)
    }

    // MARK: - UseCases
    private var fetchHabitUseCase: FetchHabitUseCase {
        return DefaultFetchHabitUseCase(repository: repository)
    }

    private var addHabitUseCase: AddHabitUseCase {
        return DefaultAddHabitUseCase(repository: repository)
    }

    private var deleteHabitUseCase: DeleteHabitUseCase {
        return DefaultDeleteHabitUseCase(repository: repository)
    }
    
    private var updateHabitUseCase: UpdateHabitUseCase {
        return DefaultUpdateHabitUseCase(repository: repository)
    }

    // MARK: - ViewModel
    func makeHabitListViewModel() -> HabitListViewModel {
        return HabitListViewModel(
            fetchHabitUseCase: fetchHabitUseCase,
            addHabitUseCase: addHabitUseCase,
            deleteHabitUseCase: deleteHabitUseCase,
            updateHabitUseCase: updateHabitUseCase
        )
    }
}
