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
  @IBOutlet weak var currentLocationImageView: UIImageView!
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
  
  func updateCurrentLocationLabel(_ index: Int){
    currentLocationImageView.isHidden = index == 0 ? false : true
  }
  
  func updateUI(_ fineDustData: FineDustData){
    locationNameLabel.text = fineDustData.location.locationName
    
    fineDustValueLabel.clipsToBounds = true
    fineDustValueLabel.layer.cornerRadius = 5
    fineDustValueLabel.text = fineDustData.fineDust.fineDustValue
    fineDustValueLabel.backgroundColor = fineDustData.fineDust.fineDustColor
    fineDustStateLabel.text = fineDustData.fineDust.fineDustState
    fineDustStateLabel.textColor = fineDustData.fineDust.fineDustColor
    
    ultraFineDustValueLabel.clipsToBounds = true
    ultraFineDustValueLabel.layer.cornerRadius = 5
    ultraFineDustValueLabel.text = fineDustData.ultraFineDust.ultraFineDustValue
    ultraFineDustValueLabel.backgroundColor = fineDustData.ultraFineDust.ultraFineDustColor
    ultraFineDustStateLabel.text = fineDustData.ultraFineDust.ultraFineDustState
    ultraFineDustStateLabel.textColor = fineDustData.ultraFineDust.ultraFineDustColor
  }
}
