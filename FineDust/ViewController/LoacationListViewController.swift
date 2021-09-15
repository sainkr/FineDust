//
//  LoacationListViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/08.
//

import UIKit

import NVActivityIndicatorView
import RxCocoa
import RxSwift

class LoacationListViewController: UIViewController{
  
  private enum SegueID: String {
    case showSearch
  }
  
  @IBOutlet weak var tableView: UITableView!
  private var indicator: NVActivityIndicatorView!
  
  private let fineDustListViewModel = FineDustListViewModel()
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
    configureIndicatior()
    
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
    NotificationCenter.default.addObserver(self, selector: #selector(completeCurrentData(_:)), name: NotificationName.CompleteCurrentDataNotification, object: nil)
    indicator.startAnimating()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
    NotificationCenter.default.removeObserver(self, name: NotificationName.CompleteCurrentDataNotification, object: nil)
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
  
  private func configureIndicatior(){
    indicator = NVActivityIndicatorView(frame: CGRect(
                                          x: view.bounds.width / 2 - 25,
                                          y: view.bounds.height / 2 - 25,
                                          width: 50,
                                          height: 50),
                                        type: .ballRotateChase,
                                        color: .black,
                                        padding: 0)
    view.addSubview(indicator)
  }
  
  @objc func completeCurrentData(_ noti: Notification){
    DispatchQueue.main.async {
      self.indicator.stopAnimating()
    }
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
