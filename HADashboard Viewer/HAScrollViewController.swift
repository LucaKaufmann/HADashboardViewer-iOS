//
//  HAScrollViewController.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 08/04/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit

class HAScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let floorplanView = storyboard.instantiateViewController(withIdentifier: "floorplan") as! HADMainViewController
        let floorplanUpstairsView = storyboard.instantiateViewController(withIdentifier: "upstairs") as! HADUpstairsViewController
        
        scrollView.contentSize = CGSize(width: 2 * view.frame.width, height: 1.0)
        let frameVC = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        
        floorplanView.view.frame = frameVC
        floorplanView.willMove(toParentViewController: self)
        self.addChildViewController(floorplanView)
        floorplanView.didMove(toParentViewController: self)
        scrollView.addSubview(floorplanView.view)
        
        let upstairsFrame = CGRect(x: frameVC.size.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        floorplanUpstairsView.view.frame = upstairsFrame
        floorplanUpstairsView.willMove(toParentViewController: self)
        self.addChildViewController(floorplanUpstairsView)
        floorplanUpstairsView.didMove(toParentViewController: self)
        scrollView.addSubview(floorplanUpstairsView.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
