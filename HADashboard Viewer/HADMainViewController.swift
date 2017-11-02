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
    
    let headers: HTTPHeaders = [
        "x-ha-access": Secrets.apiPassword,
        "Content-Type": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: Secrets.dashboardUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.loadRequest(myRequest)
        //webView.load(myRequest)
        webView.scrollView.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)
        
        requestTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.requestPresence), userInfo: nil, repeats: true)
        self.requestPresence()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func requestPresence() {
        Alamofire.request("\(Secrets.homeAssistantUrl)/api/states/group.all_devices", headers:headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [String:AnyObject]{
                print("JSON: \(json)") // serialized json response
                if let state = json["state"] {
                    if (state.isEqual(to: "home")) {
                      print("Someone is home")
                      UIApplication.shared.isIdleTimerDisabled = true
                    } else {
                      print("No one is home")
                      UIApplication.shared.isIdleTimerDisabled = false
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
