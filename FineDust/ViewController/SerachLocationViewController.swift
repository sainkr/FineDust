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

class SerachLocationViewController: UIViewController {

    private enum SegueID: String {
        case showAdd
    }
    
    private var searchCompleter: MKLocalSearchCompleter?
    var completerResults: [MKLocalSearchCompletion]?
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var placeMark: MKPlacemark?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    var relay = PublishRelay<[MKLocalSearchCompletion]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Datasource
        relay
            .bind(to: self.tableView.rx.items(cellIdentifier: "SearchLocationCell",cellType: SearchLocationCell.self))
            { [weak self] (index, element, cell) in
                print("----> element: \(element)")
                if let suggestion = self?.completerResults?[index] {
                    cell.label?.attributedText = self?.createHighlightedString(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
                }
                
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
        
        // 내용을 가져옴
        /*tableView.rx.modelSelected(SearchLocationCell.self)
            .subscribe(onNext: { product in
                
            })
            .disposed(by: disposeBag)*/
        
        // SearchBar Delegate
        searchBar.rx.text
                    .orEmpty
                    .subscribe(onNext: { [weak self] searchText in
                        if searchText == "" {
                            self?.completerResults = nil
                            self?.tableView.reloadData()
                        }
                        
                        self?.searchCompleter?.queryFragment = searchText
                    })
                    .disposed(by: disposeBag)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ViewController else {
            return
        }
        if segue.identifier == SegueID.showAdd.rawValue {
            guard let place = placeMark?.coordinate else {
                return
            }
            vc.location = place
            vc.mode = .add
        }
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SerachLocationViewController{
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
            print("placeMark : \(self.placeMark)")
        }
    }
}

// Mark: 
extension SerachLocationViewController: MKLocalSearchCompleterDelegate{
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

/*extension SerachLocationViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            completerResults = nil
            tableView.reloadData()
        }
        
        // 사용자가 search bar 에 입력한 text를 자동완성 대상에 넣는다
        searchCompleter?.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}*/

/*extension SerachLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationCell", for: indexPath) as? SearchLocationCell else { return UITableViewCell() }
        
        if let suggestion = completerResults?[indexPath.row] {
   
            cell.label?.attributedText = createHighlightedString(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
        }
        
        return cell
    }
    
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
}*/


/*extension SerachLocationViewController: UITableViewDelegate{
    

    
    // 선택된 위치의 정보 가져오기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let suggestion = completerResults?[indexPath.row] {
            search(for: suggestion)
        }
    }
}*/

class SearchLocationCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}
