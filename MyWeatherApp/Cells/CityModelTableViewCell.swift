//
//  CityModelTableViewCell.swift
//  MyWeatherApp
//
//  Created by VLAD on 2020/10/22.
//  Copyright © 2020 Vlad. All rights reserved.
//

import UIKit

class CityModelTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configureCell(model: CityModel) {
        cityLabel.text = model.city
        countryLabel.text = model.country
    }
}
