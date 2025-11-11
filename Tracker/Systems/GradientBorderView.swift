//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 11.11.2025.
//

import UIKit

final class GradientBorderView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    var colors: [UIColor] = [.red, .green, .blue] {
        didSet {
            gradientLayer.colors = colors.map { $0.cgColor }
        }
    }

    var lineWidth: CGFloat = 1 {
        didSet {
            shapeLayer.lineWidth = lineWidth
            updatePath()
        }
    }

    var cornerRadiusValue: CGFloat = 16 {
        didSet {
            layer.cornerRadius = cornerRadiusValue
            updatePath()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundColor = .white
        layer.cornerRadius = cornerRadiusValue
        layer.masksToBounds = true

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = lineWidth

        gradientLayer.mask = shapeLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updatePath()
    }

    private func updatePath() {
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: lineWidth, dy: lineWidth),
            cornerRadius: cornerRadiusValue
        ).cgPath
    }
}
