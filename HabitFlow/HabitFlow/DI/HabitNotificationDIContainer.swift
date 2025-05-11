//
//  HabitNotificationDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import Foundation
import CoreData

struct HabitNotificationDIContainer {
    
    // MARK: - Repository
    private let repository = HabitNotificationRepository()
    
    // MARK: - UseCase
    private var useCase: HabitNotificationUseCase {
        return HabitNotificationUseCaseImpl(
            repository: repository,
            context: CoreDataManager.shared.context
        )
    }
    
    // MARK: - ViewModel
    func makeHabitNotificationViewModel() -> HabitNotificationViewModel {
        return HabitNotificationViewModel(useCase: useCase)
    }
}
