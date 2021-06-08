//
//  LoacationListViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/08.
//

import UIKit
import RxSwift
import RxCocoa

class LoacationListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let finedustViewModel = FineDustViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        finedustViewModel.finedustRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
                cell.localLabel.text = element.stationName
                cell.currentLocationLabel.isHidden = true
                
                cell.finedustValueLabel.text = element.finedust
                cell.ultrafinedustValueLabel.text = element.ultrafinedust
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
}

class LoactionCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var finedustValueLabel: UILabel!
    @IBOutlet weak var finedustStateLabel: UILabel!
    @IBOutlet weak var ultrafinedustValueLabel: UILabel!
    @IBOutlet weak var ultrafinedustStateLabel: UILabel!
    
}
