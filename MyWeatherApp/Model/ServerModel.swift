//
//  ServiceObject.swift
//  MyWeatherApp
//
//  Created by VLAD on 17/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerModel: NSObject {
    var response: JSON
    
    init(response:JSON) {
        self.response = response
    }

    //MARK: -Helped Methods
    func setFormatedCurrentTime(unixTime:Int,dateFormat:String) -> String {
        
        var currentTime:String? = nil
        let formatter = DateFormatter.init()
        formatter.dateFormat = dateFormat
        if unixTime != 0 {
            let date = Date.init(timeIntervalSince1970: TimeInterval(unixTime))
            let timeDate = formatter.string(from: date)
            currentTime = timeDate
        }
        return currentTime!
    }
    func isSunsetOrSunRise(sunrise:Double,sunset:Double) -> Bool {
        
        let nigthTime:Bool = false
        let currentTime = Date().timeIntervalSince1970
        if (currentTime > sunrise || currentTime < sunset) {
            return nigthTime == true
        }else {
            return nigthTime == false
        }
    }
    func isTimeNightIcon(icon:String) -> Bool {
        if icon.range(of: "n") != nil {
            return false
        }else {
            return true
        }
    }
    
    func convertToFahrenheitOrCelWith(countryName:String,temperature:Double) -> Double {
        if (countryName == "US") {
            // F
            return round(((temperature - 273.15) * 1.8) + 32)
        }else {
            // C
            return round(temperature - 273.15)
        }
    }
}
