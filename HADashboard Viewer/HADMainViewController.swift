//
//  HADMainViewController.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 24/09/2017.
//  Copyright © 2017 Luca Kaufmann. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import Foundation

class HADMainViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var requestTimer: Timer!
    var peopleHome: Bool!
    var sleeping: Bool!
    
    let headers: HTTPHeaders = [
        "x-ha-access": "\(Secrets.apiPassword)",
        "Content-Type": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "\(Secrets.dashboardUrl)")
        let myRequest = URLRequest(url: myURL!)
        webView.loadRequest(myRequest)
        //webView.load(myRequest)
        webView.scrollView.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)
        
        requestTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.checkState), userInfo: nil, repeats: true)
        self.requestPresence()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
