//
//  SerachLocationViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/08.
//

import UIKit
import RxCocoa
import RxSwift
import MapKit

class SearchLocationViewController: UIViewController{
  
  private enum SegueID: String {
    case showAdd
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  private var searchCompleter: MKLocalSearchCompleter?
  var completerResults: [MKLocalSearchCompletion]?
  private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.506817, longitude: 127.978929), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
  private var placeMark: MKPlacemark?
  private var disposeBag = DisposeBag()
  var relay = PublishRelay<[MKLocalSearchCompletion]>()
  
  let CompleteSearchNotification: Notification.Name = Notification.Name("CompleteSearchNotification")
  
  var completeAddDelegate: CompleteAddDelegate?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let vc = segue.destination as? FineDustViewController else {
      return
    }
    if segue.identifier == SegueID.showAdd.rawValue {
      vc.mode = .searched
      vc.completeAddDelegate = self
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // TableView Datasource
    relay
      .bind(to: self.tableView.rx.items(cellIdentifier: SearchLocationCell.identifier, cellType: SearchLocationCell.self))
      { [weak self] (index, element, cell) in
        cell.label?.attributedText = self?.createHighlightedString(text: element.title, rangeValues: element.titleHighlightRanges)
      }.disposed(by: disposeBag)
    
    
    // TableView Delegate
    tableView.rx.itemSelected // indexPath를 가져옴
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        if let suggestion = self?.completerResults?[indexPath.row] {
          self?.search(for: suggestion)
        }
      })
      .disposed(by: disposeBag)
    
    // SearchBar Delegate
    searchBar.rx.text
      .orEmpty
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] searchText in
        guard searchText != "" else {
          self?.searchCompleter?.queryFragment = " "
          return
        }
        self?.searchCompleter?.queryFragment = searchText
      })
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startProvidingCompletions()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopProvidingCompletions()
    disposeBag = DisposeBag()
  }
  
  private func startProvidingCompletions() {
    searchCompleter = MKLocalSearchCompleter()
    searchCompleter?.delegate = self
    searchCompleter?.resultTypes = .address
    searchCompleter?.region = searchRegion
  }
  
  private func stopProvidingCompletions() {
    searchCompleter = nil
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - CompleteAddDelegate
extension SearchLocationViewController: CompleteAddDelegate{
  func completeAdd() {
    dismiss(animated: true, completion: {
      self.completeAddDelegate?.completeAdd()
    })
  }
}

// MARK: - HighlightedString
extension SearchLocationViewController{
  private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
    let attributes = [NSAttributedString.Key.foregroundColor : UIColor.blue ]
    let highlightedString = NSMutableAttributedString(string: text)
    
    // Each `NSValue` wraps an `NSRange` that can be used as a style attribute's range with `NSAttributedString`.
    let ranges = rangeValues.map { $0.rangeValue }
    ranges.forEach { (range) in
      highlightedString.addAttributes(attributes, range: range)
    }
    
    return highlightedString
  }
  
  private func search(for suggestedCompletion: MKLocalSearchCompletion) {
    let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
    search(using: searchRequest)
  }
  
  private func search(using searchRequest: MKLocalSearch.Request) {
    // Confine the map search area to an area around the user's current location.
    searchRequest.region = searchRegion
    
    // Include only point of interest results. This excludes results based on address matches.
    searchRequest.resultTypes = .address
    
    let localSearch = MKLocalSearch(request: searchRequest)
    localSearch.start { (response, error) in
      guard error == nil else {
        return
      }
      self.placeMark = response?.mapItems[0].placemark
      NotificationCenter.default.post(name: self.CompleteSearchNotification, object: nil, userInfo: ["coordinate" : self.placeMark?.coordinate])
    }
  }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchLocationViewController: MKLocalSearchCompleterDelegate{
  /// - Tag: QueryResults
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    // As the user types, new completion suggestions are continuously returned to this method.
    // Overwrite the existing results, and then refresh the UI with the new results.
    completerResults = completer.results
    
    relay.accept(completerResults!)
    tableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    // Handle any errors returned from MKLocalSearchCompleter.
    if let error = error as NSError? {
      print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
    }
  }
}

class SearchLocationCell: UITableViewCell {
  static let identifier = "SearchLocationCell"
  @IBOutlet weak var label: UILabel!
}
