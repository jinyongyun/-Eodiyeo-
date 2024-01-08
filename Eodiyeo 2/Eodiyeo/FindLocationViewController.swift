//
//  FindLocationViewController.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/3/24.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController {
    
    var pickedNewLocation: ((_ location: String, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var searchCompleter: MKLocalSearchCompleter?
    
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    
    var completerResults: [MKLocalSearchCompletion]?
    
    private var places: MKMapItem? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.resultTypes = .pointOfInterest // 혹시 값이 안날아온다면 이건 주석처리 해주세요
        searchCompleter?.region = searchRegion
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchCompleter = nil
    }
    
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        // 검색 지역 설정
        searchRequest.region = searchRegion
        
        // 검색 유형 설정
        searchRequest.resultTypes = .pointOfInterest
        // MKLocalSearch 생성
        localSearch = MKLocalSearch(request: searchRequest)
        // 비동기로 검색 실행
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            // 검색한 결과 : reponse의 mapItems 값을 가져온다.
            self.places = response?.mapItems[0]
            
            print(places?.placemark.coordinate as Any) // 위경도 가져옴
            searchBar.text = places?.name
            pickedNewLocation?(searchBar.text ?? "잘못된 위치", places?.placemark.coordinate.latitude ?? 0.0, places?.placemark.coordinate.longitude ?? 0.0)
            dismiss(animated: true, completion: nil)
        }
    }
    
}


extension FindLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            completerResults = nil
        }
        
        searchCompleter?.queryFragment = searchText
    }
}

extension FindLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

extension FindLocationViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? locationCell else { return UITableViewCell()}
        
        if let suggestion = completerResults?[indexPath.row] {
            cell.titleLabel.text = suggestion.title
            cell.subtitleLabel.text = suggestion.subtitle
        }
        return cell
    }
}


extension FindLocationViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택 표시 해제
        
        if let suggestion = completerResults?[indexPath.row] {
            search(for: suggestion)
        }
    }
}
