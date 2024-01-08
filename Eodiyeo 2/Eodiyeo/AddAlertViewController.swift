//
//  AddAlertViewController.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/3/24.
//

import UIKit
import MapKit
import CoreLocation

class AddAlertViewController: UIViewController {
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var pickedNewAlert: ((_ location: String, _ shortterm: String, _ content: String, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void)?
    
    var mark = Marker(title: "", subtitle: "", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var shortTerm: UITextField!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addAnnotation(mark)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.locationTextField.resignFirstResponder()
        self.shortTerm.resignFirstResponder()
        self.detailTextView.resignFirstResponder()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        pickedNewAlert?(locationTextField.text ?? "내용 없음", shortTerm.text ?? "내용 없어", detailTextView.text, latitude ?? 0.0, longitude ?? 0.0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocationButtonTapped(_ sender: UIButton) {
        guard let FindLocationVC = storyboard?.instantiateViewController(identifier:
        "FindLocationViewController") as? FindLocationViewController else {return}
        
        FindLocationVC.pickedNewLocation = { [weak self] location, latitude, longitude in
            guard let self = self else {return}
            self.locationTextField.text = location
            mark = Marker(title: location, subtitle: location, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            mapView.addAnnotation(mark)
            // 중심값(필수): 위, 경도
            let center = CLLocationCoordinate2D(latitude: latitude,
                                                longitude: longitude)

            // 영역을 확대 및 축소를 한다. (값이 낮을수록 화면을 확대/높으면 축소)
            let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                        longitudeDelta: 0.01)

            // center를 중심으로 span 영역만큼 확대/축소 해서 보여줌
            let region = MKCoordinateRegion(center: center,
                                            span: span)

            mapView.setRegion(region, animated: true)
            self.latitude = Double(latitude)
            self.longitude = Double(longitude)
            
            
        }
        
        self.present(FindLocationVC, animated: true, completion: nil)
        
    }
    
    /*
     var id: String = UUID().uuidString
     var location: String
     var shortterm: String
     var content: String
     var latitude: Double
     var longitude: Double
     var isOn: Bool
     
     */
    
}


extension AddAlertViewController: MKMapViewDelegate {
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        view.markerTintColor = .systemIndigo
        return view
    }
}
