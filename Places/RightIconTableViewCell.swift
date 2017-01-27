//
//  RightIconTableViewCell.swift
//  SKPlaces
//
//  Created by Boris Kachulachki on 1/26/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class RightIconTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setPlace(place: Place) {
      self.titleLabel.text = place.placeName
      if let address = place.address {
        self.subtitleLabel.text = address
      }
    }
  
    func setIcon(icon: UIImage) {
      self.iconImageView.image = icon
    }
  
  override func prepareForReuse() {
    self.iconImageView.image = nil
  }

}
