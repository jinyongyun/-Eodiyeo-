//
//  Alert.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/3/24.
//

import Foundation
import CoreLocation

struct Alert: Codable {
    var id: String = UUID().uuidString
    var location: String
    var shortterm: String
    var content: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var isOn: Bool
}
