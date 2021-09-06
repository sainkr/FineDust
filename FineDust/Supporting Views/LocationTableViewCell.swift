//
//  LocationTableViewCell.swift
//  FineDust
//
//  Created by 홍승아 on 2021/09/05.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
  
  static let identifier = "LocationTableViewCell"

  @IBOutlet weak var locationNameLabel: UILabel!
  @IBOutlet weak var currentLocationLabel: UILabel!
  @IBOutlet weak var fineDustValueLabel: UILabel!
  @IBOutlet weak var fineDustStateLabel: UILabel!
  @IBOutlet weak var ultraFineDustValueLabel: UILabel!
  @IBOutlet weak var ultraFineDustStateLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
