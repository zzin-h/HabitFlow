//
//  HabitListDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation

struct HabitListDIContainer {
    
    // MARK: - Repository
    private let repository = HabitRepository()
    private let recordRepository = HabitRecordRepository()
    private let notificationRepository = HabitNotificationRepository()
    
    // MARK: - UseCase
    private var useCase: HabitUseCase {
        return HabitUseCaseImpl(repository: repository, recordRepository: recordRepository)
    }
    
    private var notificationUseCase: HabitNotificationUseCase {
        return HabitNotificationUseCaseImpl(
            repository: notificationRepository,
            context: CoreDataManager.shared.context
        )
    }
    
    // MARK: - ViewModel
    func makeHabitListViewModel() -> HabitListViewModel {
        return HabitListViewModel(
            useCase: useCase,
            notificationUseCase: notificationUseCase
        )
    }
}
