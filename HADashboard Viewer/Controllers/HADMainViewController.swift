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

class HADMainViewController: UIViewController, HAEntityManagerDelegate {
    
    @IBOutlet weak var paperLightButton: UIButton!
    @IBOutlet weak var deskLightButton: UIButton!
    @IBOutlet weak var bigLightButton: UIButton!
    @IBOutlet weak var hallwayLightButton: UIButton!
    @IBOutlet weak var kitchenLightButton: UIButton!
    @IBOutlet weak var bedroomLightButton: UIButton!
    @IBOutlet weak var livingroomGroupButton: UIButton!
    
    let entityManager = HADEntityManager.instance
    
    var requestTimer: Timer!
    var floorplanEntities = [String:AnyObject]()
    
    

    override func viewDidLoad() {
        floorplanEntities = ["light.paperlight": paperLightButton,
                                      "light.desk": deskLightButton,
                                      "light.big_light": bigLightButton,
                                      "light.hallway": hallwayLightButton,
                                      "light.kitchen": kitchenLightButton,
                                      "light.yellow_light": bedroomLightButton]
        
        entityManager.delegates.addDelegate(delegate: self)
        entityManager.connect()
    }

    
    @IBAction func toggleEntity(_ sender: Any) {
        if let key = (floorplanEntities as NSDictionary).allKeys(for: sender as! UIButton).first as? String {
            entityManager.toggleEntity(entityId: key)
        }
    }
    
    @IBAction func lightsOff(_ sender: Any) {
       entityManager.allLightsOff()
    }
    
    func presenceChanged(shouldScreenBeOn: Bool) {
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("Screen on = \(shouldScreenBeOn)")
            UIApplication.shared.isIdleTimerDisabled = shouldScreenBeOn
        }
    }
    
    func entityUpdated(entity: Entity) {
        if let button = floorplanEntities[entity.id] {
            let imageName = entity.state == "on" ? "light_on": "light_off"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    func refreshUI() {
        let entities = entityManager.entities
        for (_, entity) in entities {
            if let button = floorplanEntities[entity.id] {
                let imageName = entity.state == "on" ? "light_on": "light_off"
                button.setImage(UIImage(named: imageName), for: .normal)
            }
        }
    }
    
}
