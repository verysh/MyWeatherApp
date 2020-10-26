//
//  ForecastCollectionViewCell.swift
//  MyWeatherApp
//
//  Created by VLAD on 18/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    var indexPath: IndexPath?
    
    func configureCell(model: ServerModel) {
        if let weatherOneDay = model as? Weather {
            guard let indexPath = indexPath else { return }
            let icon = weatherOneDay.iconArray[indexPath.item]
            let temp = weatherOneDay.temperatureArray[indexPath.item]
            let time = weatherOneDay.timeArray[indexPath.item]
            self.temperatureLabel.text = "\(String(describing: temp))°"
            self.weatherImageView.image = icon as? UIImage
            self.timeLabel.text = time as? String
        }
        if let weatherFiveDays = model as? DaysForeCast {
            self.temperatureLabel.text = "\(String(describing: weatherFiveDays.temp))°"
            self.weatherImageView.image = UIImage(named: weatherFiveDays.icon)
            self.timeLabel.text = weatherFiveDays.date
        }
    }
    
}
