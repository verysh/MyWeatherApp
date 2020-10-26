//
//  VisualEffectMethods.swift
//  OpenWeatherMapService
//
//  Created by warSong on 4/6/17.
//  Copyright © 2017 VS. All rights reserved.
//

import UIKit
class VisualEffectMethods {
    static let shared = VisualEffectMethods()
    // Нигду не вызывается !!
    func makeBlurEffectToView(view:UIView, effectStule:UIBlurEffectStyle) {
        view.backgroundColor = UIColor.clear
        let blurEffect:UIBlurEffect = UIBlurEffect(style: effectStule)
        let visualEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        view.insertSubview(visualEffectView, at: 0)
    }
}
