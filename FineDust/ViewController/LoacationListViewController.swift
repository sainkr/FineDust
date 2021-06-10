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
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    let finedustListViewModel = FineDustListViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewHeight.constant = 0
        
        finedustListViewModel.getFineDust()
        
        finedustListViewModel.finedustRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ [self] (index, element, cell) in
                cell.localLabel.text = element.stationName
                cell.currentLocationLabel.isHidden = true
                
                cell.finedustValueLabel.text = element.finedust
                cell.ultrafinedustValueLabel.text = element.ultrafinedust
                
                self.collectionViewHeight.constant = self.collectionViewHeight.constant + 128
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
}


/*extension LoacationListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.width)
        return CGSize(width: collectionView.bounds.width, height: 128)
    }
}*/

class LoactionCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var finedustValueLabel: UILabel!
    @IBOutlet weak var finedustStateLabel: UILabel!
    @IBOutlet weak var ultrafinedustValueLabel: UILabel!
    @IBOutlet weak var ultrafinedustStateLabel: UILabel!
    
}
