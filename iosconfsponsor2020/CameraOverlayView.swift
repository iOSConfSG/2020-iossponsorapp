//
//  CameraOverlayView.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 8/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView {

    @IBOutlet var scanView: UIView!
    @IBOutlet var instructionLabel: UILabel!

    let lineWidth: CGFloat = 3

    lazy var maskCALayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        return maskLayer
    }()

    lazy var focusCALayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.purple.cgColor
        layer.lineWidth = lineWidth
        layer.lineJoin = CAShapeLayerLineJoin(rawValue: "round")
        return layer
    }()

    var focusRect: CGRect {
        return scanView.frame
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.addSublayer(maskCALayer)
        layer.mask = maskCALayer
        layer.addSublayer(focusCALayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    func setup() {
        updateLayers()
    }

    private func updateLayers() {
        maskCALayer.frame = bounds
        updateMaskCALayer()
    }

    func updateMaskCALayer() {
        let maskPath = UIBezierPath(rect: bounds)
        maskPath.append(UIBezierPath(rect: focusRect))
        maskCALayer.path = maskPath.cgPath
    }
}
