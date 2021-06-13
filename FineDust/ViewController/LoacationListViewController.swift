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

    private enum SegueID: String {
        case showMain
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    let finedustListViewModel = FineDustListViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finedustListViewModel.getFineDust()
        
        finedustListViewModel.finedustRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
                print("-------> 컬렉션뷰 : \(element)")
                
                self.collectionViewHeight.constant += 128
                
                print(self.collectionViewHeight.constant)
                
                
                if index == 0 {
                    cell.currentLocationLabel.isHidden = false

                }else{
                    cell.currentLocationLabel.isHidden = true
                }
                
                cell.localLabel.text = element.stationName
                cell.finedustValueLabel.text = element.finedust
                cell.finedustValueLabel.backgroundColor = element.finedustColor
                cell.ultrafinedustValueLabel.text = element.ultrafinedust
                cell.ultrafinedustValueLabel.backgroundColor = element.ultrafinedustColor
            }
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ViewController else {
            return
        }
        
        if segue.identifier == SegueID.showMain.rawValue{
            vc.mode = .main
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
}

extension LoacationListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
        return CGSize(width: view.bounds.width - 100, height: 128)
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
