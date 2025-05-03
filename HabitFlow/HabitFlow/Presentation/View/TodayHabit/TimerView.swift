//
//  TimerView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    @State private var showAlert = false
    @Binding var showingTimer: Bool
    
    let habitTitle: String
    let category: HabitCategory
    
    var body: some View {
        VStack {
            Text(habitTitle)
                .font(.title.bold())
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 32)
            
            Text("집중해서 완료해봐요!")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 16)
            
            Spacer()
            
            ZStack {
                ProgressTrack()
                
                ProgressBar(counter: viewModel.remainingTime, countTo: viewModel.totalTime, category: category)
                
                Clock(counter: $viewModel.remainingTime, countTo: viewModel.totalTime, category: category)
            }
            .onTapGesture {
                if viewModel.isRunning {
                    viewModel.pause()
                } else {
                    viewModel.start()
                }
            }
            
            HStack {
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pause()
                    } else {
                        viewModel.start()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.reset()
                    showingTimer = false
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 48)
            .padding(.bottom, 32)
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(habitTitle) 달성!"),
                message: Text("목표 시간이 완료되었습니다."),
                dismissButton: .cancel(Text("OK"))
            )
        }
        .onChange(of: viewModel.remainingTime) { newValue in
            if newValue == 0 {
                showAlert = true
            }
        }
    }
}

private struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 300, height: 300)
            .overlay(
                Circle().stroke(Color.textPrimary, lineWidth: 15)
            )
    }
}

private struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    let category: HabitCategory
    
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 300, height: 300)
            .overlay(
                Circle().trim(from: 0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(completed() ? Color.green : category.color)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1))
            )
    }
    
    func completed() -> Bool {
        return progress() == 1
    }
    
    func progress() -> CGFloat {
        return CGFloat(countTo - counter) / CGFloat(countTo)
    }
}

private struct Clock: View {
    @Binding var counter: Int
    
    var countTo: Int
    let category: HabitCategory
    
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.system(size: 65, weight: .bold, design: .rounded))
                .foregroundStyle(category.color)
        }
    }
    
    func counterToMinutes() -> String {
        let seconds = counter % 60
        let minutes = counter / 60
        
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
