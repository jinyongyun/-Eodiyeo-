//
//  UNNotificationCenter.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/4/24.
//

import Foundation
import UserNotifications
import CoreLocation

extension UNUserNotificationCenter {
    
    func addNotificationRequest(by alert: Alert) {
            
            let content = UNMutableNotificationContent()
            content.title = "🤦🏻 \(alert.location)에서 뭐 하기로 혔슈?"
            content.body = "\(alert.shortterm)하기로 했잖유 기억나유?"
            content.sound = .default
            content.badge = 1
            
            let center = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
            let region = CLCircularRegion(center: center, radius: 50.0, identifier: "\(alert.location)")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            let trigger = UNLocationNotificationTrigger(region: region, repeats: alert.isOn)
        
            let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
            self.add(request, withCompletionHandler: nil)
        
    }
    
}
