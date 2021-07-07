//
//  BackgroundFetchHandler.swift
//  UFConvertorWidget
//
//  Created by Claire on 29/06/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UFConvertorKit
import BackgroundTasks

final class BackgroundFetchHandler {
    
    //TODO: how to cache the requested data ?
    let model = RequestModel()
    
    func registerAppRefreshTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.UFConvertorWidget.refresh", using: nil) { (task) in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.UFConvertorWidget.refresh")
        request.earliestBeginDate = Date() //TODO: set tomorrow date
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
                
        task.expirationHandler = {
            //TODO: kill server request
        }
        
        //sets any value, just to trigger the request
        model.convert(from: "1") { (result) in
            switch result {
            case .success:
                task.setTaskCompleted(success: true)
            case .failure:
                task.setTaskCompleted(success: false)
            }
        }
    }
}
