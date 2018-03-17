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

    @IBOutlet weak var paperLightButton: UIButton!
    @IBOutlet weak var deskLightButton: UIButton!
    @IBOutlet weak var bigLightButton: UIButton!
    @IBOutlet weak var hallwayLightButton: UIButton!
    @IBOutlet weak var kitchenLightButton: UIButton!
    @IBOutlet weak var bedroomLightButton: UIButton!
    @IBOutlet weak var livingroomGroupButton: UIButton!
    
    let apiClient = HADApiClient()
    
    var requestTimer: Timer!
    var peopleHome: Bool!
    var sleeping: Bool!
    var entities = [String:Entity]()
    var usedEntities = [String:AnyObject]()
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)
        checkState()
        requestTimer = Timer.scheduledTimer(timeInterval: 180.0, target: self, selector: #selector(self.checkState), userInfo: nil, repeats: true)
        usedEntities = ["light.paperlight": paperLightButton,
                        "light.desk": deskLightButton,
                        "light.big_light": bigLightButton,
                        "light.hallway": hallwayLightButton,
                        "light.kitchen": kitchenLightButton,
                        "light.yellow_light": bedroomLightButton]
    }
    @objc func checkState() {
        apiClient.getState(completion: { json in
            if let jsonArray = json {
                for jsonEntity in jsonArray {
                    if let entity = Entity.init(JSONData: jsonEntity) {
                        var newEntity = entity
                        if let button = self.usedEntities[newEntity.id] {
                            newEntity.button = button as? UIButton
                        }
                        self.entities[newEntity.id] = newEntity
                    }
                }
                self.checkPresence()
                self.updateIcons()
            }
        })
    }
    
    func checkPresence() {
        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        var screenOn = false
        if let presenceEntity = entities["group.tracked_devices"] {
            if presenceEntity.state == "home" {
                screenOn = true
            } else {
                screenOn = false
            }
        }
        
        
        if let sleepingEntity = entities["input_boolean.sleeping"] {
            if sleepingEntity.state == "on" {
                screenOn = false
            } else {
                screenOn = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("Screen on = \(screenOn)")
            UIApplication.shared.isIdleTimerDisabled = screenOn
        }
    }
    
    func updateIcons() {
        for usedEntity in usedEntities {
            if let entity = entities[usedEntity.key] {
                if let button = entity.button {
                    let imageName = entity.state == "on" ? "light_on": "light_off"
                    button.setImage(UIImage(named: imageName), for: .normal)
                }
            }
        }
    }
    
    func toggleEntityForButton(button: UIButton) {
        
    }
    @IBAction func toggleEntity(_ sender: Any) {
        if let key = (usedEntities as NSDictionary).allKeys(for: sender as! UIButton).first as? String {
            if let entity = entities[key] {
                apiClient.toggleEntity(name: entity.name, domain: entity.domain, completion: {
                    self.checkState()
                })
            }
        }
    }
    
    @IBAction func togglePaperlight(_ sender: Any) {
        if let paperlightEntity = entities["light.paperlight"] {
            apiClient.toggleEntity(name: paperlightEntity.name, domain: paperlightEntity.domain, completion: {
                self.checkState()
            })
        }
    }
    
    @IBAction func lightsOff(_ sender: Any) {
        apiClient.lightsOff(completion: {
            self.checkState()
        })
    }
    
    @objc func applicationDidTimeout(notification: NSNotification) {
        print("User inactive, dimming screen")
        UIScreen.main.brightness = CGFloat(0.01)
    }
    
    
}
