//
//  WeatherAnimations.swift
//  OpenWeatherMapService
//
//  Created by warSong on 4/6/17.
//  Copyright © 2017 VS. All rights reserved.
//

import UIKit
class WeatherAnimations {
    static let shared = WeatherAnimations()
    // Нигду не вызывается !!
    func createParciclass(view: UIView) {
        let rain = CAEmitterLayer()
        rain.emitterPosition = CGPoint(x: view.center.x, y: -50)
        rain.emitterShape = kCAEmitterLayerLine
        rain.renderMode = kCAEmitterLayerAdditive
        rain.emitterSize = CGSize(width: view.frame.size.width, height: 1.0)
        
        let flake = makeEmitterLayerCell()
        rain.emitterCells = [flake]
        view.layer.addSublayer(rain)
    }
    func makeEmitterLayerCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contentsScale = 8
        cell.birthRate = 4
        cell.lifetime = 50.0
        cell.velocity = 50
        cell.emissionLatitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 0
        cell.spinRange = 0
        cell.scaleRange = -0.005
        cell.contents = UIImage(named: "CupOfrain")?.cgImage
        return cell
    }
}
