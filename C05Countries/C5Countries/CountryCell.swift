//
//  CountryCell.swift
//  C5Countries
//
//  Created by Chris Parker on 13/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import MapKit

class CountryCell: UITableViewCell {
    
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var capitalLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var populationLabel: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var subRegionLabel: UILabel!
    @IBOutlet var nativeNameLabel: UILabel!
    @IBOutlet var numericCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
