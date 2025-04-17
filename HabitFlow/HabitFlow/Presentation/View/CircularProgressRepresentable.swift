//
//  CircularProgressRepresentable.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import SwiftUI

struct CircularProgressRepresentable: UIViewRepresentable {
    var progress: CGFloat
    var duration: TimeInterval
    var lineWidth: CGFloat = 10
    var color: UIColor = .systemBlue

    func makeUIView(context: Context) -> CircularProgressView {
        let view = CircularProgressView()
        view.lineWidth = lineWidth
        view.progressColor = color
        return view
    }

    func updateUIView(_ uiView: CircularProgressView, context: Context) {
        uiView.setProgress(to: progress, animated: true, duration: duration)
    }
}
