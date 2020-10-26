//
//  RateManager.swift
//  MyWeatherApp
//
//  Created by VLAD on 19/12/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit
import StoreKit

class RateManager {
    
    class func incrementCount() {
        let count = UserDefaults.standard.integer(forKey: "run_count")
        if count < 4 {
            UserDefaults.standard.set(count + 1, forKey: "run_count")
        }
    }
    
    class func showRatesController() {
        let count = UserDefaults.standard.integer(forKey: "run_count")
        if count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                SKStoreReviewController.requestReview()
            })
        }
    }
}
