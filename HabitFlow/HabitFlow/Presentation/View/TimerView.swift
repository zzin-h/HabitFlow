//
//  TimerView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    let habitTitle: String

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text(viewModel.remainingTime.formattedTime)
                .font(.system(size: 48, weight: .bold))

            CircularProgressRepresentable(
                progress: 1 - CGFloat(viewModel.remainingTime) / CGFloat(viewModel.totalTime),
                duration: 1
            )
            .frame(width: 200, height: 200)

            HStack(spacing: 40) {
                Button(action: {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }

                Button(action: {
                    viewModel.reset()
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            
            Spacer()
        }
        .padding()
        .onDisappear {
            viewModel.reset()
        }
    }
}
