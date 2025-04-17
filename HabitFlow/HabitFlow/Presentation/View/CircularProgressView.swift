//
//  CircularProgressView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import UIKit

class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    
    var lineWidth: CGFloat = 10 {
        didSet {
            configure()
        }
    }
    
    var progressColor: UIColor = UIColor.systemBlue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let circlePath = UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2))
        
        backgroundMask.path = circlePath.cgPath
        backgroundMask.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        backgroundMask.fillColor = UIColor.clear.cgColor
        backgroundMask.lineWidth = lineWidth
        backgroundMask.lineCap = .round
        layer.addSublayer(backgroundMask)

        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    func setProgress(to progress: CGFloat, animated: Bool, duration: TimeInterval) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = progress
            animation.duration = duration
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: "progressAnim")
        } else {
            progressLayer.strokeEnd = progress
        }
    }
}
