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
        
        finedustListViewModel.finedustRelay
            .bind(to: collectionView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
          
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
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
                    return }
                vc.mode = .show
                vc.index = indexPath.item
                vc.modalPresentationStyle = .fullScreen
                
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwilappear")
        finedustListViewModel.getFineDust()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("---> viewdisappear")
        disposeBag = DisposeBag()
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        finedustListViewModel.addFineDust(FineDust(finedust: "16", finedustState: "좋음", finedustColor: .blue , ultrafinedust: "9", ultrafinedustState: "좋음", ultrafinedustColor: .blue, dateTime: "2021-06-15 22:00", stationName: "중구", lat: 37.375125349085906, lng: 127.95590235319048, timeStamp: Int(Date().timeIntervalSince1970.rounded())))
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
