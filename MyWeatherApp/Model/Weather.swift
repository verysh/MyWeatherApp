//
//  Weather.swift
//  MyWeatherApp
//
//  Created by VLAD on 17/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class Weather: ServerModel {
    
    var cityName = String()
    var country = String()
    var temperature: Double!
    var weatherDescription = String()
    var currentTime = String()
    var iconID: Int!
    var icon: UIImage!
    var iconName: String!
    var windSpeed: Double!
    var humidity: Int!
    var cityID: Int!
    var timeArray = [AnyObject]()
    var temperatureArray = [AnyObject]()
    var iconArray = [AnyObject]()

    
    func setWeatherProperties() {

        if let countryName = self.response["sys"]["country"].string {
            self.country = countryName
        }
        if let cityID = self.response["id"].int {
            self.cityID = cityID
        }
        if let tempResult = self.response["main"]["temp"].double {
            self.temperature = convertToFahrenheitOrCelWith(countryName: self.country, temperature: tempResult)
        }
        if let cityName = self.response["name"].string {
            self.cityName = cityName
        }
        if let weatherID = self.response["weather"][0]["description"].string {
            self.weatherDescription = weatherID
        }
        if let imageName = self.response["weather"][0]["icon"].string {
            self.iconName = imageName
        }
        if let sunrise = self.response["sys"]["sunrise"].double {
            if let sunset = self.response["sys"]["sunset"].double {
                if let currentIconID = self.response["weather"][0]["id"].int {
                    self.iconID = currentIconID
                    let isNightOrDay = isSunsetOrSunRise(sunrise: sunrise, sunset: sunset)
                    self.icon = AdditionalMethods.method.currentWeatherIconByID(condition: self.iconID, nightTime:isNightOrDay)
                }
            }
        }
        if let windSpeed = self.response["wind"]["speed"].double {
            self.windSpeed = windSpeed
        }
        if let humidity = self.response["main"]["humidity"].int {
            self.humidity = humidity
        }
        if let currentT = self.response["dt"].int{
            self.currentTime = setFormatedCurrentTime(unixTime:currentT,dateFormat:"dd MMMM HH:mm")
        }
        
    }
    

}



