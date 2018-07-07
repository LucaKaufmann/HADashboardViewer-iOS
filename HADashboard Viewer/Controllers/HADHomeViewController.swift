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

class HADHomeViewController: UIViewController {
    
    let webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //webView.load(myRequest)
        webView.frame = self.view.frame
        webView.scrollView.isScrollEnabled = false
        webView.reload()
        self.view.addSubview(webView)
    }
    
    func setDashboardUrl(url: String) {
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.loadRequest(myRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
