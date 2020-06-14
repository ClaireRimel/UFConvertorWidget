//
//  ScheduleNotification.swift
//  UFConvertorWidget
//
//  Created by Claire on 12/06/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation
import UserNotifications
import UFConvertorKit


class ScheduleNotification {
    let center = UNUserNotificationCenter.current()
    
    func askPermission(completion: @escaping (Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) {
            (_, error) in
            completion(error)
        }
    }
    
    func scheduleNotification() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "rate of the day"
            content.body = "poto lindo y suave de mi pikallo <3"
            content.sound = .default
//            content.badge = 1
            
            var dateComponents = DateComponents()
            dateComponents.hour = 20
            dateComponents.minute = 7
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "UFConvNotification", content: content, trigger: trigger)
            
            self.center.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
        
//        center.getPendingNotificationRequests { (requests) in
//            if let request = requests.filter({ $0.identifier == "UFConvNotification" }).first {
//
//                let content = UNMutableNotificationContent()
//                content.title = request.content.title
//                content.body = "another message"
//                content.sound = request.content.sound
//
//                let trigger = request.trigger
//
//                self.center.removePendingNotificationRequests(withIdentifiers: ["UFConvNotification"])
//                let request = UNNotificationRequest(identifier: "UFConvNotification", content: content, trigger: trigger)
//
//                self.center.add(request) { (error) in
//                    if let error = error {
//                        print("Error \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
    }
}
