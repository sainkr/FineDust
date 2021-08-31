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
    case showSearch
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  let fineDustListViewModel = FineDustListViewModel()
  var disposeBag = DisposeBag()
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let vc = segue.destination as? SearchLocationViewController else {
      return
    }
    if segue.identifier == SegueID.showSearch.rawValue {
      vc.completeAddDelegate = self
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fineDustListViewModel.observable
      .bind(to: tableView.rx.items(cellIdentifier: LoactionCollectionViewCell.identifier, cellType: LoactionCollectionViewCell.self)){ (index, element, cell) in
        // print("-----> 컬렉션 뷰 : \(element)")
        if index == 0 {
          cell.currentLocationLabel.isHidden = false
          
        }else{
          cell.currentLocationLabel.isHidden = true
        }
        
        cell.localLabel.text = element.location.locationName
        
        cell.finedustValueLabel.text = element.fineDust.fineDustValue
        cell.finedustValueLabel.backgroundColor = element.fineDust.fineDustColor
        cell.finedustStateLabel.text = element.fineDust.fineDustState
        cell.finedustStateLabel.textColor = element.fineDust.fineDustColor
        
        cell.ultrafinedustValueLabel.text = element.ultraFineDust.ultraFineDustValue
        cell.ultrafinedustValueLabel.backgroundColor = element.ultraFineDust.ultraFineDustColor
        cell.ultrafinedustStateLabel.text = element.ultraFineDust.ultraFineDustState
        cell.ultrafinedustStateLabel.textColor = element.ultraFineDust.ultraFineDustColor
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected // indexPath를 가져옴
      .subscribe(onNext: { [weak self] indexPath in
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PageViewController") as? PageViewController else {
          return }

        vc.currentPage = indexPath.item
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
    fineDustListViewModel.loadFineDustList()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
  }
}

extension LoacationListViewController: CompleteAddDelegate{
  func completeAdd() {
    fineDustListViewModel.reloadFineDustList()
  }
}

extension LoacationListViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard indexPath.item > 0 else { return nil }
    
    let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
      self.fineDustListViewModel.removeFineDust(indexPath.item)
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
  
  static let identifier = "LoactionCollectionViewCell"
  
  @IBOutlet weak var localLabel: UILabel!
  @IBOutlet weak var currentLocationLabel: UILabel!
  @IBOutlet weak var finedustValueLabel: UILabel!
  @IBOutlet weak var finedustStateLabel: UILabel!
  @IBOutlet weak var ultrafinedustValueLabel: UILabel!
  @IBOutlet weak var ultrafinedustStateLabel: UILabel!
}
