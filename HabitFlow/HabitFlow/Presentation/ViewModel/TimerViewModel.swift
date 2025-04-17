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
    
    let totalTime: Int
    private var timer: Timer?
    
    init(totalTime: Int) {
        self.totalTime = totalTime
        self.remainingTime = totalTime
    }
    
    var onComplete: (() -> Void)?
    
    init(goalMinutes: Int, onComplete: (() -> Void)? = nil) {
        self.totalTime = goalMinutes * 60
        self.remainingTime = self.totalTime
        self.onComplete = onComplete
    }
    
    var progress: CGFloat {
        guard totalTime > 0 else { return 0 }
        return CGFloat(remainingTime) / CGFloat(totalTime)
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.pause()
                self.onComplete?()
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
    
    deinit {
        timer?.invalidate()
    }
}
