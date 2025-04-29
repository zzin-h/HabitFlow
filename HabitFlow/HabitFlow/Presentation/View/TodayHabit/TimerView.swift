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
    
    var body: some View {
        VStack {
            Text(habitTitle)
                .font(.title)
                .padding()
            
            ZStack {
                ProgressTrack()
                
                ProgressBar(counter: viewModel.remainingTime, countTo: viewModel.totalTime)
                
                Clock(counter: $viewModel.remainingTime, countTo: viewModel.totalTime) // 바인딩만 넘겨줌
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
                        .frame(width: 50, height: 50)
                }
                
                Button(action: {
                    viewModel.reset()
                    showingTimer = false
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .padding()
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
            .frame(width: 250, height: 250)
            .overlay(
                Circle().stroke(Color.black, lineWidth: 15)
            )
    }
}

private struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 250, height: 250)
            .overlay(
                Circle().trim(from: 0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(completed() ? Color.green : Color.orange)
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
    
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.custom("Avenir Next", size: 60))
                .fontWeight(.black)
        }
    }
    
    func counterToMinutes() -> String {
        let seconds = counter % 60
        let minutes = counter / 60
        
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
