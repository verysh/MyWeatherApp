//
//  DaysForeCast.swift
//  MyWeatherApp
//
//  Created by VLAD on 2020/10/11.
//  Copyright © 2020 Vlad. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class DaysForeCast: ServerModel {
    
    var dateDescription = String()
    var date = String()
    var temp = Double()
    var icon = String()
    
    init(response:JSON, indx: Int) {
        super.init(response: nil)
        if let desc = response["list"][indx]["dt_txt"].string {
            self.dateDescription = desc
        }
        if let date = response["list"][indx]["dt"].double {
            let myTimeInterval = TimeInterval(date)
            let time = Date(timeIntervalSince1970:myTimeInterval)
            self.date = time.weekdayAndDateNameFull
        }
        if let temp = response["list"][indx]["main"]["temp"].double  {
            self.temp = super.convertToFahrenheitOrCelWith(countryName:"RU", temperature: temp)
        }
        if let icon = response["list"][indx]["weather"][0]["icon"].string  {
            self.icon = icon
        }
    }
}


