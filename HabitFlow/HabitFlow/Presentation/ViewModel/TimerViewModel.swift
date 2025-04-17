//
//  TimerViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation
import Combine

final class TimerViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var isRunning: Bool = false
    
    private let totalTime: Int
    private var timer: Timer?
    private var onFinish: (() -> Void)?

    init(goalMinutes: Int, onFinish: (() -> Void)? = nil) {
        self.totalTime = goalMinutes * 60
        self.remainingTime = self.totalTime
        self.onFinish = onFinish
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.completeTimer()
            }
        }
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        pause()
        remainingTime = totalTime
    }

    func completeTimer() {
        pause()
        onFinish?()
    }

    deinit {
        timer?.invalidate()
    }
}
