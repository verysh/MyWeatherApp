//
//  CityWeatherTableViewCell.swift
//  MyWeatherApp
//
//  Created by VLAD on 19/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit

class CityWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellWithModel(cityModel : City) {
        if let city = cityModel.name {
            cityLabel.text = city
        }
        if let country = cityModel.country {
            countryLabel.text = country
        }
        tempLabel.text = "\(cityModel.temp)"
    }

}
