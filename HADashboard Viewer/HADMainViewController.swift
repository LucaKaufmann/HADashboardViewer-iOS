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

class HADMainViewController: UIViewController, HAWebSocketDelegate {

    @IBOutlet weak var paperLightButton: UIButton!
    @IBOutlet weak var deskLightButton: UIButton!
    @IBOutlet weak var bigLightButton: UIButton!
    @IBOutlet weak var hallwayLightButton: UIButton!
    @IBOutlet weak var kitchenLightButton: UIButton!
    @IBOutlet weak var bedroomLightButton: UIButton!
    @IBOutlet weak var livingroomGroupButton: UIButton!
    
    let webSocketClient = HADWebsocketClient()
    
    var requestTimer: Timer!
    var peopleHome: Bool!
    var sleeping: Bool!
    var entities = [String:Entity]()
    var usedEntities = [String:AnyObject]()
    let interestingEntities = ["fan.xiaomi_air_purifier", "light.paperlight", "light.desk", "light.big_light", "light.hallway", "light.kitchen", "light.yellow_light", "group.tracked_devices", "input_boolean.sleeping"]
    let presenceEntities = ["group.tracked_devices", "input_boolean.sleeping"]
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil)
  
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.connect),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.disconnect),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        
        usedEntities = ["light.paperlight": paperLightButton,
                        "light.desk": deskLightButton,
                        "light.big_light": bigLightButton,
                        "light.hallway": hallwayLightButton,
                        "light.kitchen": kitchenLightButton,
                        "light.yellow_light": bedroomLightButton]
        
        webSocketClient.delegate = self
        webSocketClient.getStates()
    }
    
    @objc func connect() {
        webSocketClient.connect()
    }
    
    @objc func disconnect() {
        webSocketClient.disconnect()
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

    
    @IBAction func toggleEntity(_ sender: Any) {
        if let key = (usedEntities as NSDictionary).allKeys(for: sender as! UIButton).first as? String {
            if let entity = entities[key] {
                webSocketClient.toggle(entity: entity)
            }
        }
    }
    
    @IBAction func lightsOff(_ sender: Any) {
       webSocketClient.lightsOff()
    }
    
    
    func authenticated() {
        webSocketClient.getStates()
        webSocketClient.subscribeToEvent(event: .stateChange)
    }
    
    func receivedResult(result: [[String:Any]]) {
        for jsonEntity in result {
            if let entity = Entity.init(JSONData: jsonEntity) {
                var newEntity = entity
//                guard let button = self.usedEntities[newEntity.id] else {
//                    continue
//                }
                if self.interestingEntities.contains(entity.id) {
                    if let button = self.usedEntities[newEntity.id] {
                        newEntity.button = button as? UIButton
                    }
                    self.entities[newEntity.id] = newEntity
                }
            }
        }
        updateIcons()
        checkPresence()
    }
    
    func receivedEvent(event: [String:Any]) {
        if let data = event["data"] as? [String:AnyObject]{
            if let entity = data["new_state"] as? [String:AnyObject] {
                if let entityId = entity["entity_id"] as? String {
                    if self.interestingEntities.contains(entityId) {
                        self.entities[entityId]?.state = entity["state"] as? String
                        updateIcons()
                    }
                    if self.presenceEntities.contains(entityId) {
                        checkPresence()
                    }
                }
            }
        }
    }
    
    @objc func applicationDidTimeout(notification: NSNotification) {
        print("User inactive, dimming screen")
        UIScreen.main.brightness = CGFloat(0.01)
    }
    
    
}
