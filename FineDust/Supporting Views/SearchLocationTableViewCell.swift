//
//  SearchLocationTableViewCell.swift
//  FineDust
//
//  Created by 홍승아 on 2021/09/05.
//

import UIKit

class SearchLocationTableViewCell: UITableViewCell {
  
  static let identifier = "SearchLocationTableViewCell"
  
  @IBOutlet weak var locationAddressLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
