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
    registerLocationTableViewCells()
    fineDustListViewModel.observable
      .bind(to: tableView.rx.items(cellIdentifier: LocationTableViewCell.identifier, cellType: LocationTableViewCell.self)){ (index, element, cell) in
        // print("-----> 컬렉션 뷰 : \(element)")
        cell.updateCurrentLocationLabel(index)
        cell.updateUI(element)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected // indexPath를 가져옴
      .subscribe(onNext: { [weak self] indexPath in
        self?.presentPageViewController(indexPath.item)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    fineDustListViewModel.loadFineDustList()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
  }
  
  private func registerLocationTableViewCells(){
    let locationTableViewCellNib = UINib(nibName: LocationTableViewCell.identifier, bundle: nil)
    tableView.register(locationTableViewCellNib, forCellReuseIdentifier: LocationTableViewCell.identifier)
  }
  
  private func presentPageViewController(_ index: Int){
    guard let vc = storyboard?.instantiateViewController(withIdentifier: PageViewController.identifer) as? PageViewController else {
      return }
    vc.currentPage = index
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
}

// MARK: - CompleteAddDelegate
extension LoacationListViewController: CompleteAddDelegate{
  func completeAdd() {
    fineDustListViewModel.reloadFineDustList()
  }
}

// MARK: - UITableViewDelegate
extension LoacationListViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    // 첫번째 cell은 현재위치라 삭제 불가.
    guard indexPath.item > 0 else { return nil }
    let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
      self.fineDustListViewModel.removeFineDust(indexPath.item)
      completion(true)
    }
    action.backgroundColor = .red
    action.title = "삭제"
    let configuration = UISwipeActionsConfiguration(actions: [action])
    configuration.performsFirstActionWithFullSwipe = false
    return configuration
  }
}
