//
//  CityModel.swift
//  MyWeatherApp
//
//  Created by VLAD on 2020/10/22.
//  Copyright © 2020 Vlad. All rights reserved.
//

import Foundation

struct CityModel {
    var city: String
    var country: String
    
    init(city: String, country: String) {
        self.city = city
        self.country = country
    }
}
