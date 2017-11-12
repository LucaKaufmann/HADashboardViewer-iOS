//
//  HADMainViewController.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 03/11/2017.
//  Copyright © 2017 Luca Kaufmann. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import Foundation

class HADMainViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    var requestTimer: Timer!
    var peopleHome: Bool!
    var sleeping: Bool!
    
    let headers: HTTPHeaders = [
        "x-ha-access": "\(Secrets.apiPassword)",
        "Content-Type": "application/json"
    ]
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)
        
        requestTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.checkState), userInfo: nil, repeats: true)
        self.requestPresence()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeDashboard = storyboard.instantiateViewController(withIdentifier: "HADHomeViewController") as! HADHomeViewController
            
        scrollView.contentSize = CGSize(width: 2 * view.frame.width, height: scrollView.frame.height)
        let frameVC = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        homeDashboard.view.frame = frameVC
        homeDashboard.setDashboardUrl(url: "\(Secrets.dashboardUrl)")
        homeDashboard.willMove(toParentViewController: self)
        self.addChildViewController(homeDashboard)
        homeDashboard.didMove(toParentViewController: self)
        scrollView.addSubview(homeDashboard.view)
        
        let weatherDashboard = storyboard.instantiateViewController(withIdentifier: "HADHomeViewController") as! HADHomeViewController
        
        let weatherFrame = CGRect(x: frameVC.size.width, y: 0, width: view.frame.width, height: view.frame.height)
        
        weatherDashboard.view.frame = weatherFrame
        weatherDashboard.setDashboardUrl(url: "\(Secrets.homeassistantUrl)/floorplan?api_password=\(Secrets.apiPassword)")
        weatherDashboard.willMove(toParentViewController: self)
        self.addChildViewController(weatherDashboard)
        weatherDashboard.didMove(toParentViewController: self)
        scrollView.addSubview(weatherDashboard.view)
    }
    @objc func checkState() {
        self.requestPresence()
        self.requestSleepingState()
        
        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            if (self.sleeping) {
                UIApplication.shared.isIdleTimerDisabled = false
            } else if (self.peopleHome) {
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        
    }
    
    
    func requestSleepingState() {
        Alamofire.request("\(Secrets.homeassistantUrl)/api/states/input_boolean.sleeping", headers:headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [String:AnyObject]{
                print("JSON: \(json)") // serialized json response
                if let state = json["state"] {
                    if (state.isEqual(to: "on")) {
                        print("Everyone is sleeping")
                        self.sleeping = true
                    } else {
                        print("Someone awake")
                        self.sleeping = false
                    }
                } else {
                    print("Wrong dictionary")
                }
            }
            
        }
    }
    
    func requestPresence() {
        Alamofire.request("\(Secrets.homeassistantUrl)/api/states/group.all_devices", headers:headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [String:AnyObject]{
                print("JSON: \(json)") // serialized json response
                if let state = json["state"] {
                    if (state.isEqual(to: "home")) {
                        print("Someone is home")
                        self.peopleHome = true
                    } else {
                        print("No one is home")
                        self.peopleHome = false
                    }
                } else {
                    print("Wrong dictionary")
                }
            }
            
        }
    }
    
    @objc func applicationDidTimeout(notification: NSNotification) {
        print("User inactive, dimming screen")
        UIScreen.main.brightness = CGFloat(0.01)
    }
    
    
}
