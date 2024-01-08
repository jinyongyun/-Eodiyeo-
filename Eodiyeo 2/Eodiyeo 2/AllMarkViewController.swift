//
//  AllMarkViewController.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/4/24.
//

import UIKit
import MapKit
import CoreLocation

class AllMarkViewController: UIViewController {
    
    var alerts: [Alert] = []
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 물어보기
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        for alert in alerts {
            let mark = Marker(title: alert.location, subtitle: alert.shortterm, coordinate: CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude))
            
            mapView.addAnnotation(mark)
            
        }
        
    }
    
    
}


extension AllMarkViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        let alert = UIAlertController(title: annotation.title ?? "", message: annotation.subtitle ?? "", preferredStyle: .actionSheet)
        let sucess = UIAlertAction(title: "확인", style: .default){ action in
          }
        alert.addAction(sucess)
        present(alert, animated: true)
    }
    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        view.markerTintColor = .systemIndigo
        return view
    }
    

}
