//
//  AdditionalMethods.swift
//  MyWeatherApp
//
//  Created by VLAD on 18/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit

class AdditionalMethods {
    
    static let method = AdditionalMethods()
    
    func configureBackgroundImage(iconImage: String) -> UIImage {
        var imageName = String()
        switch iconImage {
        case let name where name == "01d" : imageName = "Sunshine"
        case let name where name == "02d" : imageName = "Sunshine"
        case let name where name == "03d" : imageName = "Clouds"
        case let name where name == "04d" : imageName = "Clouds"
        case let name where name == "09d" : imageName = "Rain-Day"
        case let name where name == "10d" : imageName = "Rain-Day"
        case let name where name == "11d" : imageName = "Rain-Day"
        case let name where name == "09n" : imageName = "Rain-Night"
        case let name where name == "10n" : imageName = "Rain-Night"
        case let name where name == "11n" : imageName = "Rain-Night"
        case let name where name == "01n" : imageName = "Moon-Night"
        case let name where name == "02n" : imageName = "Moon-Night"
        case let name where name == "03n" : imageName = "Moon-Night"
        case let name where name == "04n" : imageName = "Moon-Night"
        case let name where name == "13d" : imageName = "Snow-Day"
        case let name where name == "13n" : imageName = "Snow-Night"
        case let name where name == "50d" : imageName = "Rain-Day"
        case let name where name == "50n" : imageName = "Rain-Night"
        default: imageName = "Sunshine"
        }
        if let iconImage = UIImage(named: imageName) {
            return iconImage
        }else {
            return UIImage(named: "Sunshine")!
        }
    }
    func currentWeatherIconByID(condition:Int,nightTime:Bool) -> UIImage {
        var imagedName = String()
        let imgIcon = UIImage()
        
        switch (condition,nightTime)
        {
        //clear sky
        case let (x,y) where x == 800 && y == true: imagedName = "01n.png"
        case let (x,y) where x == 800 && y == false: imagedName = "01d.png"
        //few clouds
        case let (x,y) where x == 801 && y == true: imagedName = "02n.png"
        case let (x,y) where x == 801 && y == false: imagedName = "02d.png"
        //scattered clouds
        case let (x,y) where x == 802 && y == true: imagedName = "03n.png"
        case let (x,y) where x == 802 && y == false: imagedName = "03d.png"
        //broken clouds
        case let (x,y) where x == 803 && y == true: imagedName = "03d.png"
        case let (x,y) where x == 803 && y == false: imagedName = "04d.png"
        //overcast clouds
        case let (x,y) where x == 804 && y == true: imagedName = "04n.png"
        case let (x,y) where x == 804 && y == false: imagedName = "04d.png"
        //freeze rain
        case let (x,y) where x == 511 && y == true: imagedName = "13n.png"
        case let (x,y) where x == 511 && y == false: imagedName = "13d.png"
        //atmosphere
        case let (x,y) where (x <= 781 && x >= 701) && y == true: imagedName = "50n.png"
        case let (x,y) where (x <= 781 && x >= 701) && y == false: imagedName = "50d.png"
        //snow
        case let (x,y) where (x <= 622 && x >= 600) && y == true: imagedName = "13n.png"
        case let (x,y) where (x <= 622 && x >= 600) && y == false: imagedName = "13d.png"
        //rain
        case let (x,y) where (x <= 531 && x >= 520) && y == true: imagedName = "09n.png"
        case let (x,y) where (x <= 531 && x >= 520) && y == false: imagedName = "09d.png"
            
        case let (x,y) where (x <= 504 && x >= 500) && y == true: imagedName = "10n.png"
        case let (x,y) where (x <= 504 && x >= 500) && y == false: imagedName = "10d.png"
        //drizzle
        case let (x,y) where (x <= 321 && x >= 300) && y == true: imagedName = "09n.png"
        case let (x,y) where (x <= 321 && x >= 300) && y == false: imagedName = "09d.png"
        //thunderstorm
        case let (x,y) where (x <= 232 && x >= 200) && y == true: imagedName = "11n.png"
        case let (x,y) where (x <= 232 && x >= 200) && y == false: imagedName = "11d.png"
            
            default:imagedName = "question.png"
        }
        let iconImage = UIImage(named:imagedName)
        guard let icon = iconImage else { return imgIcon }
      
        return icon
    }
}



