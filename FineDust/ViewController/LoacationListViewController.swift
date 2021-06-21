//
//  LoacationListViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/08.
//

import UIKit
import RxSwift
import RxCocoa

class LoacationListViewController: UIViewController{
    
    private enum SegueID: String {
        case showMain
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let finedustListViewModel = FineDustListViewModel()
    var disposeBag = DisposeBag()
    
    let CompleteAddNotification: Notification.Name = Notification.Name("CompleteAddNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(completeAddNotication(_:)), name: CompleteAddNotification, object: nil)
        
        finedustListViewModel.finedustRelay
            .bind(to: tableView.rx.items(cellIdentifier: "LoactionCollectionViewCell", cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
                print("-----> 컬렉션 뷰 : \(element)")
                if index == 0 {
                    cell.currentLocationLabel.isHidden = false
                    
                }else{
                    cell.currentLocationLabel.isHidden = true
                }
                
                cell.localLabel.text = element.currentLocation
                cell.finedustValueLabel.text = element.finedust
                cell.finedustValueLabel.backgroundColor = element.finedustColor
                cell.finedustStateLabel.text = element.finedustState
                cell.finedustStateLabel.textColor = element.finedustColor
                
                cell.ultrafinedustValueLabel.text = element.ultrafinedust
                cell.ultrafinedustValueLabel.backgroundColor = element.ultrafinedustColor
                cell.ultrafinedustStateLabel.text = element.ultrafinedustState
                cell.ultrafinedustStateLabel.textColor = element.ultrafinedustColor
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected // indexPath를 가져옴
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
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        /*tableView.rx.itemDeleted
         .subscribe(onNext: { [weak self] indexPath in
            self?.finedustListViewModel.removeFineDust(indexPath.item)
         })
         .disposed(by: disposeBag)*/
        
        
        /*tableView.rx.setDataSource(self)
         .disposed(by: disposeBag)*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        finedustListViewModel.getFineDust()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    @objc func completeAddNotication(_ noti: Notification){
        finedustListViewModel.reloadFineDustList()
    }
         
}

extension LoacationListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item > 0 else { return nil }
        
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.finedustListViewModel.removeFineDust(indexPath.item)
            // tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        action.backgroundColor = .red
        action.title = "삭제"
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}



class LoactionCollectionViewCell: UITableViewCell{
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var finedustValueLabel: UILabel!
    @IBOutlet weak var finedustStateLabel: UILabel!
    @IBOutlet weak var ultrafinedustValueLabel: UILabel!
    @IBOutlet weak var ultrafinedustStateLabel: UILabel!
    
}
