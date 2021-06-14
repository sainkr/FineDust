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
    
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finedustListViewModel.getFineDust()
        
        finedustListViewModel.finedustRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
                print("-------> 컬렉션뷰 : \(element)")
                
                self.collectionViewHeight.constant += 128
                
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
        
        collectionView.rx.itemSelected // indexPath를 가져옴
            .subscribe(onNext: { [weak self] indexPath in
                self?.index = indexPath.item
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ViewController else {
            return
        }
        
        if segue.identifier == SegueID.showMain.rawValue{
            guard let index = index else { return }
            
            vc.mode = .show
            vc.index = index
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
}

extension LoacationListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
        return CGSize(width: view.bounds.width, height: 128)
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
